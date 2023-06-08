"""Osiris result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    TX_ORDER_DEPENDENCE,
    REENTRANCY,
    INTEGER_OVERFLOW_AND_UNDERFLOW,
    TIMESTAMP_DEPENDENCE,
)


class Osiris(Base):
    vulns_map = {
          "Arithmetic bugs": INTEGER_OVERFLOW_AND_UNDERFLOW,
          "Overflow bugs": INTEGER_OVERFLOW_AND_UNDERFLOW,
          "Underflow bugs": INTEGER_OVERFLOW_AND_UNDERFLOW,
          "Division bugs": INTEGER_OVERFLOW_AND_UNDERFLOW,
          "Modulo bugs": INTEGER_OVERFLOW_AND_UNDERFLOW,
          "Truncation bugs": INTEGER_OVERFLOW_AND_UNDERFLOW,
          "Signedness bugs": INTEGER_OVERFLOW_AND_UNDERFLOW,
          "Callstack bug": INTEGER_OVERFLOW_AND_UNDERFLOW,
          "Concurrency bug": TX_ORDER_DEPENDENCE,
          "Timedependency bug": TIMESTAMP_DEPENDENCE,
          "Reentrancy bug": REENTRANCY,
    }

    def __init__(self, path, bytecode=False, contract=None):
        super(Osiris, self).__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        if self.bytecode:
            for res in analysis:
                for tp, exists in res.items():
                    if tp == "EVM code coverage":
                        continue
                    if exists:
                        output[tp] += 1
