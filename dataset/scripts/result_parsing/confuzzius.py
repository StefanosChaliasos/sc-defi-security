"""Confuzzius result parser
detectors: https://github.com/christoftorres/ConFuzzius/tree/master/fuzzer/detectors
"""
from result_parsing.base import Base
from utils.vuln_map import (
    ASSERT_VIOLATION,
    INTEGER_OVERFLOW_AND_UNDERFLOW,
    TIMESTAMP_DEPENDENCE,
    WRITE_TO_ARBITRARY_STORAGE,
    REENTRANCY,
    UNPROTECTED_ETHER_WITHDRAWAL,
    LOCKED_ETHER,
    TX_ORDER_DEPENDENCE,
    UNCHECKED_RET_VAL,
    UNPROTECTED_SELFDESTRUCT,
    DELEGATECALL_TO_UNTRUSTED_CONTRACT
)


class Confuzzius(Base):
    vulns_map = {
        "Arbitrary Memory Access": WRITE_TO_ARBITRARY_STORAGE,
        "Assertion Failure": ASSERT_VIOLATION,
        "Block Dependency": TIMESTAMP_DEPENDENCE,
        "Integer Overflow": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "Leaking Ether": UNPROTECTED_ETHER_WITHDRAWAL,
        "Locking Ether": LOCKED_ETHER,
        "Reentrancy": REENTRANCY,
        "Transaction Order Dependency": TX_ORDER_DEPENDENCE,
        "Unchecked Return Value": UNCHECKED_RET_VAL,
        "Unprotected SELFDESTRUCT": UNPROTECTED_SELFDESTRUCT,
        "Unsafe Delegatecall": DELEGATECALL_TO_UNTRUSTED_CONTRACT,
        "Unhandled Exception": ASSERT_VIOLATION,
    }

    fails = [
        "exception (UnicodeDecodeError"
    ]

    errors = [
        "No compiler output for",
        "Problem while deploying contract",
        "cannot be encoded in 64 bits",
        "Parse error at",
        "Unsupported type"
    ]

    def __init__(self, path, bytecode=False, contract=None):
        super().__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for res in analysis:
            output[res["name"]] += 1
