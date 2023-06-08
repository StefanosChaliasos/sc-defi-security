"""Vandal result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    REENTRANCY,
    TX_ORIGIN_USAGE,
    UNCHECKED_RET_VAL,
)


class Vandal(Base):
    vulns_map = {
            "CheckedCallStateUpdate": REENTRANCY,
            "ReentrantCall": REENTRANCY,
            "UncheckedCall": UNCHECKED_RET_VAL,
            "OriginUsed": TX_ORIGIN_USAGE,
    }

    def __init__(self, path, bytecode=False, contract=None):
        super(Vandal, self).__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for issue in analysis:
            if issue in findings:
                output[issue] += 1
