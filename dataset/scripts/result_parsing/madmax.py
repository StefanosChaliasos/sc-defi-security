"""MadMax result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    INTEGER_OVERFLOW_AND_UNDERFLOW,
    DOS_WITH_FAILED_CALL,
    INSUFFICIENT_GAS_GRIEFING,
)


class Madmax(Base):
    vulns_map = {
            "OverflowLoopIterator": INTEGER_OVERFLOW_AND_UNDERFLOW,
            "UnboundedMassOp": DOS_WITH_FAILED_CALL,
            "WalletGriefing": INSUFFICIENT_GAS_GRIEFING,
    }

    def __init__(self, path, bytecode=False, contract=None):
        super(Madmax, self).__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for contract in analysis:
            for tp, values in analysis[contract]["patternResults"].items():
                output[tp] += len(values['violations'])
