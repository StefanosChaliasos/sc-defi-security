"""
The main parsing file that calls the result parser of all analysis tools.
Every tool has a class named after itself, and it is imported here.
"""
import argparse
import sqlite3
import csv
import os

from result_parsing.mythril import Mythril
from result_parsing.oyente import Oyente
from result_parsing.slither import Slither
from result_parsing.solhint import Solhint
from result_parsing.confuzzius import Confuzzius

from utils.vuln_map import ID_TO_TITLE

# All parsers should be added here.
PARSERS = {
    'mythril': Mythril,
    'oyente': Oyente,
    'slither': Slither,
    'solhint': Solhint,
    'confuzzius': Confuzzius,
    'all': {
        'bytecode': [
            Mythril,
            Oyente,
        ],
        'source': [
            Confuzzius,
            Mythril,
            Oyente,
            Slither,
            Solhint
        ]
    }
}

QUERY = "SELECT vulnerable_contract_id FROM VulnerableContract WHERE chain = '{chain}' AND contract_address = '{address}'"


def connect(db_name):
    """Connection to sqlite3 via the db_name argument"""
    return sqlite3.connect(db_name)


def run_query(con, query):
    """Execute a given query in the database and return results"""
    cur = con.cursor()
    res = cur.execute(query)
    return res


def get_total_vulnerable(tool_results):
    """Get total number of vulnerable contracts in results"""
    return sum(1 for r in tool_results.values() if r.total_vulnerabilities > 0)


def get_total_number_of_vuls(tool_results):
    """Get total number of vulnerabilities in results"""
    return sum(r.total_vulnerabilities for r in tool_results.values())


def get_total_errors(tool_results):
    """Get total number of errors in results"""
    return sum(1 for r in tool_results.values() if r.error)


def create_populate_script(results_path, filenames, table_names):
    """Creation of the script that is used to populate the database"""
    path = os.path.join(results_path, 'populate.sql')
    lines = [".mode csv\n"] + [
        f".import {filename} {table_name}\n"
        for filename, table_name in zip(filenames, table_names)
    ]
    with open(path, 'w') as f:
        f.writelines(lines)


def parse_results(tool_name, tool_directory, bytecode, contract):
    """Parse the results of a given tool, located in a given directory.
     Results passed to the function can be from bytecode or source code analysis"""
    res = {}
    if tool_name == "all" and bytecode:
        for parser in PARSERS['all']['bytecode']:
            name = parser.__name__.lower()
            try:
                res[name] = parser(tool_directory, bytecode, contract).parse()
            except FileNotFoundError:
                print(f"Warning: skip {name} because results not exist in {tool_directory}")
    elif tool_name == "all":
        for parser in PARSERS['all']['source']:
            name = parser.__name__.lower()
            try:
                res[name] = parser(tool_directory, bytecode, contract).parse()
            except FileNotFoundError:
                print(f"Warning: skip {name} because results not exist in {tool_directory}")
    else:
        try:
            res[tool_name] = PARSERS[tool_name](tool_directory, bytecode, contract).parse()
        except FileNotFoundError:
            print(f"Warning: skip {tool_name} because results not exist in {tool_directory}")

    for name, results in res.items():
        total_contracts = len(results)
        total_vulnerable = get_total_vulnerable(results)
        total_vulnerabilities = get_total_number_of_vuls(results)
        total_errors = get_total_errors(results)
        output = "name: {}: total => {}, vulnerable => {}, errors => {}, vulnerabilities = {}"
        output = output.format(name, total_contracts, total_vulnerable, total_errors,
                               total_vulnerabilities)
        print(output)
    return res


def get_args():
    """Argument parsing"""
    args = argparse.ArgumentParser(
        prog="result_parser",
        description="Parse the results of the analysis tools and print their findings"
    )
    parsers = args.add_subparsers(help="Subcommand")
    analysis = parsers.add_parser("analysis", help="Analyse a single directory")
    analysis.set_defaults(which="analysis")
    analysis.add_argument("directory",
                          help="Location where the results are saved")
    analysis.add_argument('-t',
                          '--tool',
                          choices=PARSERS.keys(),
                          help="Choice of tool to parse its results")
    analysis.add_argument('-c',
                          '--contract',
                          help="Parse only a specific contract")
    analysis.add_argument('-b',
                          '--bytecode',
                          action="store_true",
                          help="Run parsers for bytecode tools. If arg is not given, default is to run on source code")
    db = parsers.add_parser("db", help="Generate csv files for the database.")
    db.set_defaults(which="db")
    db.add_argument(
        "database",
        help="The database file (note that you should provide valid inputs.")
    db.add_argument(
        "result",
        help="Directory to save the produced files")
    db.add_argument(
        "directories",
        nargs='+',
        help="Directories with the results (should contain bsc/eth and source/bytecode")
    return args.parse_args()


def main():
    args = get_args()
    if args.which == "analysis":
        tool = args.tool
        directory = args.directory
        bytecode = args.bytecode
        contract = args.contract
        parse_results(tool, directory, bytecode, contract)
    else:
        # analysis_id, vulnerable_contract_id, tool, is_bytecode, error, total_findings
        analysis_rows = []
        analysis_id = 0
        # finding_id, analysis_id, vulnerability_type_id, occurrences
        finding_rows = []
        finding_id = 0
        tool = "all"
        contract = None
        con = connect(args.database)
        for directory in args.directories:
            bytecode = "bytecode" in directory
            assert bytecode or "source" in directory
            bsc = "bsc" in directory
            assert bsc or "eth" in directory
            chain = "BSC" if bsc else "ETH"

            print(f"Process: {directory}")
            res = parse_results(tool, directory, bytecode, contract)

            for tool_name, results in res.items():
                for address, result in results.items():
                    query = QUERY.format(chain=chain, address=address)
                    # try:
                    contract_id = next(run_query(con, query))[0]

                    analysis_rows.append([
                        analysis_id, contract_id, tool_name, bytecode,
                        result.error, result.total_vulnerabilities
                    ])

                    for vuln, occ in result.vulnerabilities.items():
                        finding_rows.append([
                            finding_id, analysis_id, vuln, occ
                        ])
                        finding_id += 1
                    analysis_id += 1
                    # except Exception:
                    #    print(f"Warning: {address} {chain} not in db.")
                    #    continue
        os.makedirs(args.result, exist_ok=True)
        analysis_path = os.path.join(args.result, "analysis.csv")
        finding_path = os.path.join(args.result, "finding.csv")
        vulnerabilities_path = os.path.join(args.result, "vulnerabilities.csv")
        with open(analysis_path, 'w') as outfile:
            writer = csv.writer(outfile, quoting=csv.QUOTE_NONNUMERIC)
            writer.writerows(analysis_rows)
        with open(finding_path, 'w') as outfile:
            writer = csv.writer(outfile, quoting=csv.QUOTE_NONNUMERIC)
            writer.writerows(finding_rows)
        with open(vulnerabilities_path, 'w') as outfile:
            writer = csv.writer(outfile, quoting=csv.QUOTE_NONNUMERIC)
            vulnerabilities_rows = [[int(k), v, -1] for k, v in ID_TO_TITLE.items()]
            writer.writerows(vulnerabilities_rows)
        # TODO create table with vulnerability_type_id
        filenames = [analysis_path, finding_path, vulnerabilities_path]
        table_names = ["RetroAnalysis", "RetroFindings", "SmartContractVulnerabilities"]
        create_populate_script(args.result, filenames, table_names)
        con.close()


if __name__ == "__main__":
    main()
