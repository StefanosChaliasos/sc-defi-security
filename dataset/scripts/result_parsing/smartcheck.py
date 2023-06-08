"""Smartcheck result parser"""
from result_parsing.base import Base
from utils.vuln_map import (
    WARNING
)


class Smartcheck(Base):
    vulns_map = {
      "SOLIDITY_ADDRESS_HARDCODED": "-1",
      "SOLIDITY_CALL_WITHOUT_DATA": "-1",
      "SOLIDITY_DIV_MUL": "-1",
      "SOLIDITY_ERC20_APPROVE": "-1",
      "SOLIDITY_EXACT_TIME": "-1",
      "SOLIDITY_EXTRA_GAS_IN_LOOPS": "-1",
      "SOLIDITY_FUNCTIONS_RETURNS_TYPE_AND_NO_RETURN": "-1",
      "SOLIDITY_GAS_LIMIT_IN_LOOPS": "-1",
      "SOLIDITY_LOCKED_MONEY": "-1",
      "SOLIDITY_MSGVALUE_EQUALS_ZERO": "-1",
      "SOLIDITY_OVERPOWERED_ROLE": "-1",
      "SOLIDITY_PRAGMAS_VERSION": "-1",
      "SOLIDITY_PRIVATE_MODIFIER_DONT_HIDE_DATA": "-1",
      "SOLIDITY_REDUNDANT_FALLBACK_REJECT": "-1",
      "SOLIDITY_REVERT_REQUIRE": "-1",
      "SOLIDITY_SAFEMATH": "-1",
      "SOLIDITY_SHOULD_NOT_BE_PURE": "-1",
      "SOLIDITY_SHOULD_NOT_BE_VIEW": "-1",
      "SOLIDITY_SHOULD_RETURN_STRUCT": "-1",
      "SOLIDITY_TX_ORIGIN": "-1",
      "SOLIDITY_UNCHECKED_CALL": "-1",
      "SOLIDITY_UPGRADE_TO_050": "-1",
      "SOLIDITY_USING_INLINE_ASSEMBLY": "-1",
      "SOLIDITY_VISIBILITY": "-1",
      "SOLIDITY_WRONG_SIGNATURE": WARNING,
      "SOLIDITY_ARRAY_LENGTH_MANIPULATION": WARNING,
      "SOLIDITY_UINT_CANT_BE_NEGATIVE": WARNING,
      "SOLIDITY_DEPRECATED_CONSTRUCTIONS": WARNING,
    }

    def __init__(self, path, bytecode=False, contract=None):
        super().__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for issue in analysis:
            output[issue["name"]] += 1
