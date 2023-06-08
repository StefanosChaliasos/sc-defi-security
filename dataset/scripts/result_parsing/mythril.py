"""Mythril result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    TX_ORDER_DEPENDENCE,
    REENTRANCY,
    INTEGER_OVERFLOW_AND_UNDERFLOW,
    TIMESTAMP_DEPENDENCE,
    TX_ORIGIN_USAGE,
    DOS_WITH_FAILED_CALL,
    ASSERT_VIOLATION,
    ARBITRARY_JUMP,
    UNPROTECTED_ETHER_WITHDRAWAL,
    UNCHECKED_RET_VAL,
    MESSAGE_CALL_TO_EXTERNAL_CONTRACT,
    DELEGATECALL_TO_UNTRUSTED_CONTRACT,
    UNPROTECTED_SELFDESTRUCT,
    WRITE_TO_ARBITRARY_STORAGE,
)


class Mythril(Base):
    # https://mythril-classic.readthedocs.io/en/master/analysis-modules.html
    vulns_map = {
        "Delegatecall to user-supplied address (SWC 112)": DELEGATECALL_TO_UNTRUSTED_CONTRACT,

        "Dependence on predictable environment variable (SWC 116)": TIMESTAMP_DEPENDENCE,
        "Dependence on predictable environment variable (SWC 120)": TIMESTAMP_DEPENDENCE,
        "Dependence on predictable environment variable": TIMESTAMP_DEPENDENCE,
        "Dependence on tx.origin": TX_ORIGIN_USAGE,
        "Dependence on tx.origin (SWC 115)": TX_ORIGIN_USAGE,
        "Transaction order dependence": TX_ORDER_DEPENDENCE,

        "Unprotected Ether Withdrawal": UNPROTECTED_ETHER_WITHDRAWAL,
        "Unprotected Ether Withdrawal (SWC 105)": UNPROTECTED_ETHER_WITHDRAWAL,

        "Exception State": ASSERT_VIOLATION,
        "Exception State (SWC 110)": ASSERT_VIOLATION,

        "External Call To User-Supplied Address (SWC 107)": REENTRANCY,
        "External Call To User-Supplied Address": REENTRANCY,

        "Integer Arithmetic Bugs": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "Integer Arithmetic Bugs (SWC 101)": INTEGER_OVERFLOW_AND_UNDERFLOW,

        "Multiple Calls in a Single Transaction (SWC 113)": DOS_WITH_FAILED_CALL,

        "Unprotected SELFDESTRUCT": UNPROTECTED_SELFDESTRUCT,

        "State access after external call": REENTRANCY,
        "State access after external call (SWC 107)": REENTRANCY,

        "Unchecked CALL return value": UNCHECKED_RET_VAL,
        "Unchecked return value from external call. (SWC 104)": UNCHECKED_RET_VAL,

        "User Supplied assertion": ASSERT_VIOLATION,

        "Integer Overflow": INTEGER_OVERFLOW_AND_UNDERFLOW,

        "Jump to an arbitrary instruction": ARBITRARY_JUMP,
        "Jump to an arbitrary instruction (SWC 127)": ARBITRARY_JUMP,

        "Arbitrary Storage Write": WRITE_TO_ARBITRARY_STORAGE,

        "Message call to external contract": MESSAGE_CALL_TO_EXTERNAL_CONTRACT,
    }

    errors = [
        "Traceback (most recent call last)",
        "Solc experienced a fatal error"
    ]

    def __init__(self, path, bytecode=False, contract=None):
        super(Mythril, self).__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for issue in analysis:
            output[issue['name'].strip()] += 1
