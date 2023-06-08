"""Maian result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    UNPROTECTED_ETHER_WITHDRAWAL,
    LOCKED_ETHER,
    UNPROTECTED_SELFDESTRUCT,
)


class Maian(Base):
    # https://arxiv.org/pdf/1802.06038.pdf
    vulns_map = {
            # bytecode
            "Ether leak": UNPROTECTED_ETHER_WITHDRAWAL,
            "Ether leak (verified)": UNPROTECTED_SELFDESTRUCT,
            "Ether lock": LOCKED_ETHER,
            "Ether lock (Ether accepted without send)": LOCKED_ETHER,
            "Destructible": UNPROTECTED_SELFDESTRUCT,
            "Destructible (verified)": UNPROTECTED_SELFDESTRUCT,
            # source code
            "is_lock_vulnerable": LOCKED_ETHER,
            "is_prodigal_vulnerable": UNPROTECTED_SELFDESTRUCT,
            "is_suicidal_vulnerable": UNPROTECTED_SELFDESTRUCT
    }

    errors = [
        "Cannot compile the contract"
    ]

    def __init__(self, path, bytecode=False, contract=None):
        super(Maian, self).__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        if self.bytecode:
            for issue in analysis:
                if issue['name'] in self.vulns_map:
                    output[issue['name']] += 1
        else:
            for issue in analysis:
                if issue['name'] in self.vulns_map:
                    output[issue['name']] += 1
