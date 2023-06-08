"""Manticore result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    WARNING
)


class Manticore(Base):
    # Manticore does not detect vulnerabilities we care about
    vulns_map = {
            "INVALID instruction": "-1",
            "Potentially reading uninitialized memory": "-1",
            "Reachable external call to sender via argument": "-1",
            "Warning NUMBER instruction used": WARNING,
    }
    errors = [
        "solc error"
    ]

    def __init__(self, path, bytecode=False, contract=None):
        super().__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for issues in analysis:
            for issue in issues:
                if "Potentially reading uninitialized memory" in issue["name"]:
                    output["Potentially reading uninitialized memory"] += 1
                else:
                    output[issue["name"]] += 1
