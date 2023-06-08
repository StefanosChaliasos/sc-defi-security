"""Slither result parser
The detectors of Slither can be found at
https://github.com/crytic/slither#bugs-and-optimizations-detection
We only included detectors in our vulns_map that are able to detect
vulnerabilities with high impact."""
from result_parsing.base import Base
from utils.vuln_map import (
    WEAK_RANDOMNESS,
    UNPROTECTED_SELFDESTRUCT,
    WARNING,
    DELEGATECALL_TO_UNTRUSTED_CONTRACT,
    INTEGER_OVERFLOW_AND_UNDERFLOW,
    LOCKED_ETHER,
    UNCHECKED_RET_VAL,
    REENTRANCY,
    TIMESTAMP_DEPENDENCE,
    TX_ORIGIN_USAGE,
    EFFECT_FREE_CODE,
    UNINITIALIZED_STORAGE_POINTER,
    OUTDATED_COMPILER_VERSION,
    SHADOWING_STATE_VARIABLES,
    UNPROTECTED_ETHER_WITHDRAWAL
)


class Slither(Base):
    # https://github.com/crytic/slither#detectors
    vulns_map = {
        "abiencoderv2-array": OUTDATED_COMPILER_VERSION,
        "arbitrary-send-erc20": UNPROTECTED_ETHER_WITHDRAWAL,
        "arbitrary-send": UNPROTECTED_ETHER_WITHDRAWAL,
        "array-by-reference": WARNING,
        "incorrect-shift": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "multiple-constructors": SHADOWING_STATE_VARIABLES,  # this is actually not the same but the closest
        "name-reused": SHADOWING_STATE_VARIABLES,
        "protected-vars": WARNING,
        "public-mappings-nested": OUTDATED_COMPILER_VERSION,
        "rtlo": WARNING,
        "shadowing-state": SHADOWING_STATE_VARIABLES,
        "suicidal": UNPROTECTED_SELFDESTRUCT,
        "uninitialized-state": UNINITIALIZED_STORAGE_POINTER,  # TODO this is not the same but the closest
        "uninitialized-storage": UNINITIALIZED_STORAGE_POINTER,
        "unprotected-upgrade": WARNING,  
        "codex": WARNING,
        "arbitrary-send-erc20-permit": WARNING,  
        "arbitrary-send-eth": WARNING,  
        "controlled-array-length": WARNING, 
        "controlled-delegatecall": DELEGATECALL_TO_UNTRUSTED_CONTRACT,
        "delegatecall-loop": WARNING,
        "msg-value-loop": WARNING,
        "reentrancy-eth": REENTRANCY,
        "storage-array": OUTDATED_COMPILER_VERSION,
        "unchecked-transfer": UNCHECKED_RET_VAL,
        "weak-prng": WEAK_RANDOMNESS,
        "domain-separator-collision": WARNING,
        "enum-conversion": WARNING,
        "erc20-interface": WARNING,
        "erc721-interface": WARNING,
        "incorrect-equality": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "locked-ether": LOCKED_ETHER,
        "mapping-deletion": WARNING,
        "shadowing-abstract": SHADOWING_STATE_VARIABLES,
        "tautology": WARNING,
        "write-after-write": WARNING,
        "boolean-cst": WARNING,
        "constant-function-asm": WARNING,
        "constant-function-state": WARNING,
        "divide-before-multiply": WARNING,
        "reentrancy-no-eth": REENTRANCY,
        "reused-constructor": WARNING,
        "tx-origin": TX_ORIGIN_USAGE,
        "unchecked-lowlevel": UNCHECKED_RET_VAL,
        "unchecked-send": UNCHECKED_RET_VAL,
        "uninitialized-local": UNINITIALIZED_STORAGE_POINTER,
        "unused-return": WARNING,  # EFFECT_FREE_CODE
        "incorrect-modifier": WARNING,
        "shadowing-builtin": WARNING,
        "shadowing-local": SHADOWING_STATE_VARIABLES,
        "uninitialized-fptr-cst": WARNING,
        "variable-scope": SHADOWING_STATE_VARIABLES,
        "void-cst": WARNING,
        "calls-loop": WARNING,
        "events-access": WARNING,
        "events-maths": WARNING,
        "incorrect-unary": INTEGER_OVERFLOW_AND_UNDERFLOW,
        "missing-zero-check": WARNING,
        "reentrancy-benign": REENTRANCY,
        "reentrancy-events": REENTRANCY,
        "timestamp": TIMESTAMP_DEPENDENCE,
        "assembly": WARNING,
        "assert-state-change": WARNING,
        "boolean-equal": WARNING,
        "deprecated-standards": WARNING,
        "erc20-indexed": WARNING,
        "function-init-state": WARNING,
        "low-level-calls": UNCHECKED_RET_VAL,
        "missing-inheritance": WARNING,
        "naming-convention": WARNING,
        "pragma": WARNING,
        "redundant-statements": WARNING,
        "solc-version": OUTDATED_COMPILER_VERSION,
        "unimplemented-functions": WARNING,
        "unused-state": WARNING,  # EFFECT_FREE_CODE
        "costly-loop": WARNING,
        "dead-code": WARNING,
        "reentrancy-unlimited-gas": REENTRANCY,
        "similar-names": WARNING,
        "too-many-digits": WARNING,
        "constable-states": WARNING,
        "external-function": WARNING,
        "immutable-states": WARNING,
        "var-read-using-this": WARNING,
    }

    fails = [
        'Invalid solc compilation',
        'Ternary operator are not convertible to SlithIR',
        'IndexError: list index out of range'
    ]

    def __init__(self, path, bytecode=False, contract=None):
        super().__init__(path, bytecode, contract)

    def process_analysis(self, analysis, output, findings):
        for res in analysis:
            output[res["name"]] += 1
