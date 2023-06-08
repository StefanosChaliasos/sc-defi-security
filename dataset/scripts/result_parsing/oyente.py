"""Oyente result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    CALLSTACK_DEPTH_ATTACK_VULNERABILITY,
    TX_ORDER_DEPENDENCE,
    TIMESTAMP_DEPENDENCE,
    REENTRANCY,
    INTEGER_OVERFLOW_AND_UNDERFLOW,
    UNPROTECTED_SELFDESTRUCT,
    ASSERT_VIOLATION
)


class Oyente(Base):
    # https://www.comp.nus.edu.sg/~prateeks/papers/Oyente.pdf
    # https://github.com/enzymefinance/oyente/blob/master/oyente/vulnerability.py
    vulns_map = {
        # bytecode
        "Callstack Depth Attack Vulnerability": CALLSTACK_DEPTH_ATTACK_VULNERABILITY,
        "Transaction-Ordering Dependence (TOD)": TX_ORDER_DEPENDENCE,
        "Timestamp Dependency": TIMESTAMP_DEPENDENCE,
        "Integer Underflow": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "Re-Entrancy Vulnerability": REENTRANCY,
        # source code
        "callstack_depth_attack_vulnerability": CALLSTACK_DEPTH_ATTACK_VULNERABILITY,
        "integer_overflow": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "Integer Overflow": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "integer_underflow": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "parity_multisig_bug_2": UNPROTECTED_SELFDESTRUCT,
        "re-entrancy_vulnerability": REENTRANCY,
        "timestamp_dependency": TIMESTAMP_DEPENDENCE,
        "transaction-ordering_dependence_tod": TX_ORDER_DEPENDENCE,
        "AssertionFailure": ASSERT_VIOLATION
    }

    errors = [
        "Solidity compilation failed"
    ]

    def __init__(self, path, bytecode=False, contract=None):
        super(Oyente, self).__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for res in analysis:
            if res["name"] == "EVM Code Coverage":
                continue
            output[res["name"]] += 1
