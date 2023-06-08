"""Securify result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    REENTRANCY,
    MESSAGE_CALL_WITH_HARDCODED_GAS_AMOUNT,
    UNPROTECTED_ETHER_WITHDRAWAL,
    TX_ORDER_DEPENDENCE,
    ASSERT_VIOLATION,
    MISSING_INPUT_VALIDATION,
)


class Securify(Base):
    vulns_map = {
        "DAO": REENTRANCY,
        "DAOConstantGas": MESSAGE_CALL_WITH_HARDCODED_GAS_AMOUNT,
        "UnrestrictedEtherFlow": UNPROTECTED_ETHER_WITHDRAWAL,
        "TODAmount": TX_ORDER_DEPENDENCE,
        "TODReceiver": TX_ORDER_DEPENDENCE,
        "TODTransfer": TX_ORDER_DEPENDENCE,
        "UnhandledException": ASSERT_VIOLATION,
        "MissingInputValidation": MISSING_INPUT_VALIDATION
    }

    def __init__(self, path, bytecode=False, contract=None):
        super().__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        if self.bytecode:
            for contract in analysis:
                for tp, values in analysis[contract]["patternResults"].items():
                    output[tp] += len(values['violations'])
        else:
            for contract in analysis:
                for tp, values in analysis[contract]["results"].items():
                    output[tp] += len(values['violations'])
