"""Solhint result parser
The rules in the vulns_map dictionary are taken from Solhint's
GitHub repository: https://github.com/protofire/solhint/blob/master/docs/rules.md
We only include Security Rules, Style Rules are ignored.
"""
from result_parsing.base import Base
from utils.vuln_map import (
    OUTDATED_COMPILER_VERSION,
    REENTRANCY,
    UNCHECKED_RET_VAL,
    UNPROTECTED_SELFDESTRUCT,
    ASSERT_VIOLATION,
    UNCHECKED_RET_VAL,
    DEFAULT_FUNCTION_VISIBILITY,
    TX_ORIGIN_USAGE,
    TIMESTAMP_DEPENDENCE,
    WEAK_RANDOMNESS,
    DEFAULT_STATE_VARIABLE_VISIBILITY,
    WARNING
)


class Solhint(Base):
    # https://github.com/protofire/solhint/blob/master/docs/rules.md#security-rules
    vulns_map = {
        "avoid-call-value": REENTRANCY,
        "avoid-low-level-calls": UNCHECKED_RET_VAL,
        "avoid-sha3": WARNING,
        "avoid-suicide": UNPROTECTED_SELFDESTRUCT,
        "avoid-throw": WARNING,
        "avoid-tx-origin": TX_ORIGIN_USAGE,
        "check-send-result": UNCHECKED_RET_VAL,
        "compiler-version": OUTDATED_COMPILER_VERSION,
        "func-visibility": DEFAULT_FUNCTION_VISIBILITY,
        "mark-callable-contracts": WARNING,
        "multiple-sends": WARNING,
        "no-complex-fallback": WARNING,
        "no-inline-assembly": WARNING,
        "not-rely-on-block-hash": WEAK_RANDOMNESS,
        "not-rely-on-time": TIMESTAMP_DEPENDENCE,
        "reentrancy": REENTRANCY,
        "state-visibility": DEFAULT_STATE_VARIABLE_VISIBILITY,

        "max-line-length": WARNING,
        "indent": WARNING,
    }

    def __init__(self, path, bytecode=False, contract=None):
        super().__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for res in analysis:
            if "name" in res:
                output[res["name"]] += 1
