"""MadMax result parser"""
from result_parsing.base import Base
from utils.vuln_map import HONEYPOT


class Honeybadger(Base):
    vulns_map = {
            "Money flow": HONEYPOT,
            "Balance disorder": HONEYPOT,
            "Inheritance disorder": HONEYPOT,
            "Uninitialised struct": HONEYPOT,
            "Type overflow": HONEYPOT,
            "Skip empty string": HONEYPOT,
            "Hidden state update": HONEYPOT,
            "Straw man contract": HONEYPOT,
    }

    def __init__(self, path, bytecode=False, contract=None):
        super(Honeybadger, self).__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        if self.bytecode:
            for contract in analysis:
                for tp, detected in contract.items():
                    if tp == "EVM code coverage":
                        continue
                    if detected:
                        output[tp] += 1
