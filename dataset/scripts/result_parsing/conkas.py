"""Conkas result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    TX_ORDER_DEPENDENCE,
    REENTRANCY,
    INTEGER_OVERFLOW_AND_UNDERFLOW,
    UNCHECKED_RET_VAL,
    TIMESTAMP_DEPENDENCE,
)


class Conkas(Base):
    # https://github.com/nveloso/conkas#detected-vulnerabilities
    vulns_map = {
        "Integer Overflow": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "Integer Underflow": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "Integer_Overflow": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "Integer_Underflow": INTEGER_OVERFLOW_AND_UNDERFLOW,

        "Reentrancy": REENTRANCY,

        "Time Manipulation": TIMESTAMP_DEPENDENCE,

        "Transaction Ordering Dependence": TX_ORDER_DEPENDENCE,

        "Unchecked Low Level Call": UNCHECKED_RET_VAL,
    }

    errors = [
       # https://github.com/nveloso/conkas/issues/6
       "PHI instruction need arguments but 0 was given",
       "EXIT_CODE_1"
    ]
    fails = [
        "TypeError: object of type 'NoneType' has no len()",
        "ValueError: too many values to unpack (expected 4)",
        "AttributeError: 'NoneType' object has no attribute 'getText')",
        "solcx.exceptions.SolcError: An error occurred during execution)",
        "ValueError: Invalid version string: 'review-0.8.x'",
        "AttributeError: 'NoneType' object has no attribute 'expressionList'",
        "TypeError: the JSON object must be str, bytes or bytearray, not list)",
        "exception (ANTLR runtime and generated code versions disagree: 4.9.2!=4.7.2)"
    ]

    def __init__(self, path, bytecode=False, contract=None):
        super(Conkas, self).__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for res in analysis:
            output[res["name"]] += 1
