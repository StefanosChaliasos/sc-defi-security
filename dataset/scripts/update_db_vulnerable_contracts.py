"""
Update is_proxy, is_vyper, has_source in VulnerableContracts table of the database.
The script will generate a file with the update statements.
"""
import argparse
import sqlite3
from typing import Dict, List
from collections import defaultdict


def get_addresses_per_chain(db: str) -> Dict[str, Dict[str, int]]:
    """Retrieve from the database a map from address to id per chain
    """
    query: str = "SELECT vulnerable_contract_id, chain, contract_address FROM VulnerableContract"
    # Connect to the database
    con: sqlite3.Connection = sqlite3.connect(db)
    cur: sqlite3.Cursor = con.cursor()
    qset: sqlite3.Cursor = cur.execute(query)
    res = defaultdict(dict)
    for vcid, chain, addr in qset:
        res[chain][addr] = vcid
    return res


def get_update_statements(eth_file:str, bsc_file: str, sql_column: str, ids: Dict[str, Dict[str, int]]) -> List[str]:
    """Get the UPDATE statements for the given column
    """
    def process_file():
        res.extend([
            template.format(
                column=sql_column,
                vcid=ids[chain][line.rstrip('\n')]
            )
            for line in f
        ])

    template: str = "UPDATE VulnerableContract SET {column} = 1 WHERE vulnerable_contract_id = {vcid};"
    res: List[str] = []
    with open(eth_file, 'r') as f:
        chain: str = "ETH"
        process_file()
    with open(bsc_file, 'r') as f:
        chain: str = "BSC"
        process_file()
    return res


def get_args(): 
    """Argument Parsing
    """
    args = argparse.ArgumentParser(
        description="Update the is_proxy, is_vyper, and has_source fields"
    )
    args.add_argument(
        "eth_proxies"
    )
    args.add_argument(
        "bsc_proxies"
    )
    args.add_argument(
        "eth_sources"
    )
    args.add_argument(
        "bsc_sources"
    )
    args.add_argument(
        "eth_vyper"
    )
    args.add_argument(
        "bsc_vyper"
    )
    args.add_argument(
        "db"
    )
    args.add_argument(
        "--results",
        default="update_commands.sql",
        help="File to save the update statements"
    )
    return args.parse_args()


def main():
    args = get_args()
    # Get addresses ids per chain
    addresses: Dict[str, Dict[str, int]] = get_addresses_per_chain(args.db)
    # Get update statements
    stmts: List[str] = []
    stmts.extend(get_update_statements(args.eth_proxies, args.bsc_proxies, "is_proxy", addresses))
    stmts.extend(get_update_statements(args.eth_sources, args.bsc_sources, "has_source", addresses))
    stmts.extend(get_update_statements(args.eth_vyper, args.bsc_vyper, "is_vyper", addresses))
    # Save results
    with open(args.results, 'w') as f:
        for stmt in stmts:
            f.write(f"{stmt}\n")


if __name__ == "__main__":
    main()
