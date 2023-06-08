"""
Update the vuln_map_id foreign key in SmartContractVulnerabilities and Cause tables
Populate ToolsVulnerabilities
"""
import argparse
import sqlite3
import csv
import importlib

from typing import Dict, List

from utils.vuln_map import ID_TO_TITLE


def get_insert_stmt_for_tools(db: str, map_to_vuln_map: Dict, vuln_title_to_id: Dict):
    """
    Get SQL statements to populate ToolsVulnerabilities table
    """
    insert_stmt = "INSERT INTO ToolsVulnerabilities (tool_id,vuln_map_id) VALUES ({}, {});"
    res = []
    # Get all tools
    tools = get_tool_names(db)
    # For each tool get the ids it could detect
    for tool_name, tool_id in tools.items():
        tool_module = importlib.import_module(f'result_parsing.{tool_name}')
        tool_class = getattr(tool_module, tool_name.capitalize())
        tool_vuln_ids = {
            vuln_id for vuln_id in tool_class.vulns_map.values()
            if vuln_id != "-1"
        }
        # For each vuln id get its title
        titles = {
            ID_TO_TITLE[vuln_id] for vuln_id in tool_vuln_ids
        }
        # For each vuln id add the corrent vuln_map id to the table
        vuln_map_ids = {
            vuln_title_to_id[map_to_vuln_map[sc_vuln_title]] 
            for sc_vuln_title in titles
        }
        for vuln_map_id in vuln_map_ids:
            stmt = insert_stmt.format(tool_id, vuln_map_id)
            res.append(stmt)
    return res


def get_update_statements(
        table:str, 
        id_column: str,
        title_column: str,
        column: str, 
        map_to_vuln_map: Dict, 
        vuln_title_to_id: Dict,
        db: str
    ) -> List[str]:
    """Get the UPDATE SQL statements
    """
    template: str = "UPDATE {table} SET {column} = {vuln_id} WHERE {id_column} = {id};"
    title_to_id = get_map_from_title_to_id(db, id_column, title_column, table)
    res: List[str] = []
    for title, vuln_title in map_to_vuln_map.items():
        try:
            res.append(
                template.format(
                    table=table,
                    column=column,
                    vuln_id=vuln_title_to_id[vuln_title],
                    id_column=id_column,
                    id=title_to_id[title]
                )
            )
        except KeyError as e:
            print("Key error: ", e, " not in table", table)
    return res


def get_map_from_title_to_id(db: str, id_column: str, title_column: str, table: str):
    con: sqlite3.Connection = sqlite3.connect(db)
    cur: sqlite3.Cursor = con.cursor()
    qset: sqlite3.Cursor = cur.execute(f"SELECT {id_column}, {title_column} FROM {table}")
    return {title: vm_id for vm_id, title in qset}


def get_map_from_id_to_title(db: str, id_column: str, title_column: str, table: str):
    con: sqlite3.Connection = sqlite3.connect(db)
    cur: sqlite3.Cursor = con.cursor()
    qset: sqlite3.Cursor = cur.execute(f"SELECT {id_column}, {title_column} FROM {table}")
    return {vm_id: title for vm_id, title in qset}


def get_column(db: str, column: str, table: str):
    con: sqlite3.Connection = sqlite3.connect(db)
    cur: sqlite3.Cursor = con.cursor()
    qset: sqlite3.Cursor = cur.execute(f"SELECT {column} FROM {table}")
    return [title[0] for title in qset]


def parse_map_from_csv_to_dict(filename, key_row, value_row):
    """Parse the csv and return a dict from source to vuln_map_title.
    """
    with open(filename, 'r') as file:
        csvreader = csv.reader(file)
        return {v[key_row]: v[value_row] for v in csvreader}


def get_tool_names(db: str):
    con: sqlite3.Connection = sqlite3.connect(db)
    cur: sqlite3.Cursor = con.cursor()
    qset: sqlite3.Cursor = cur.execute(f"SELECT tool_name, tool_id FROM Tool")
    return {name: tool_id for name, tool_id in qset}


def sanity_checks(vuln_map_dict, sc_vuln_to_vuln_map, cause_to_vuln_map, db):
    """Do sanity checks to detect typos or missing categories in the provided files.
    """
    # SC vulnerabilities
    sc_vulns_titles = get_column(db, "vulnerability_type", "SmartContractVulnerabilities")
    # Check that all the titles from the db exist in the provided mapping
    for title in sc_vulns_titles:
        if title not in sc_vuln_to_vuln_map.keys():
            raise AssertionError(f"SC: {title} not in sc_vuln_to_vuln_map")
    # Check that all the titles in the provided mapping exist in the DB
    for title in sc_vuln_to_vuln_map.keys():
        if title not in sc_vulns_titles:
            raise AssertionError(f"SC: {title} not in SmartContractVulnerabilities")
    # Check that all vulnerabilities in the mapping exist in the DB
    for title in sc_vuln_to_vuln_map.values():
        if title not in vuln_map_dict.keys():
            raise AssertionError(f"SC: {title} not in VulnerabilitiesMap")
    # Causes
    cause_titles = get_column(db, "cause_title", "Cause")
    # Check that all the titles from the db exist in the provided mapping
    for title in cause_titles:
        if title not in cause_to_vuln_map.keys():
            raise AssertionError(f"Cause: {title} not in cause_to_vuln_map")
    # Check that all the titles in the provided mapping exist in the DB
    for title in cause_to_vuln_map.keys():
        if title not in cause_titles:
            raise AssertionError(f"Cause: {title} not in Cause")
    # Check that all vulnerabilities in the mapping exist in the DB
    for title in cause_to_vuln_map.values():
        if title not in vuln_map_dict.keys():
            raise AssertionError(f"Cause: {title} not in VulnerabilitiesMap")
    print("Sanity checks passed")


def get_args(): 
    """Argument Parsing
    """
    args = argparse.ArgumentParser(
        description="Update vuln_map_id foreign key in Cause and SmartContractVulnerabilities tables"
    )
    args.add_argument(
        "cause_to_vuln_map"
    )
    args.add_argument(
        "sc_vuln_to_vuln_map"
    )
    args.add_argument(
        "db"
    )
    args.add_argument(
        "--results",
        default="mapping_commands.sql",
        help="File to save the update statements"
    )
    return args.parse_args()


def main():
    args = get_args()
    # Get lookup from vuln_title to vuln_map_id 
    title_to_id = get_map_from_title_to_id(args.db, "vuln_map_id", "vuln_title", "VulnerabilitiesMap")
    sc_vuln_to_vuln_map = parse_map_from_csv_to_dict(args.sc_vuln_to_vuln_map, 0, 1)
    cause_to_vuln_map = parse_map_from_csv_to_dict(args.cause_to_vuln_map, 0, 1)
    sanity_checks(title_to_id, sc_vuln_to_vuln_map, cause_to_vuln_map, args.db)
    # Get update statements
    stmts: List[str] = []
    stmts.extend(get_update_statements(
        "SmartContractVulnerabilities", 
        "vulnerability_type_id", 
        "vulnerability_type", 
        "vuln_map_id", 
        sc_vuln_to_vuln_map, 
        title_to_id, 
        args.db
    ))
    stmts.extend(get_update_statements(
        "Cause", 
        "cause_id", 
        "cause_title", 
        "vuln_map_id", 
        cause_to_vuln_map, 
        title_to_id, 
        args.db
    ))
    stmts.extend(get_insert_stmt_for_tools(
        args.db, 
        sc_vuln_to_vuln_map, 
        title_to_id
    ))
    # Save results
    with open(args.results, 'w') as f:
        for stmt in stmts:
            f.write(f"{stmt}\n")


if __name__ == "__main__":
    main()
