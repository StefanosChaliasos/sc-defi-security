"""
This module maps SWC IDs to their registry equivalents.
Data taken from https://swcregistry.io/ and https://dasp.co/
"""

DEFAULT_FUNCTION_VISIBILITY = "100"
INTEGER_OVERFLOW_AND_UNDERFLOW = "101"  # DASP10 CATEGORY = 3
OUTDATED_COMPILER_VERSION = "102"
FLOATING_PRAGMA = "103"
UNCHECKED_RET_VAL = "104"  # DASP10 CATEGORY = 4
UNPROTECTED_ETHER_WITHDRAWAL = "105"  # DASP10 CATEGORY = 2
UNPROTECTED_SELFDESTRUCT = "106"  # DASP10 CATEGORY = 2
REENTRANCY = "107"  # DASP10 CATEGORY = 1
DEFAULT_STATE_VARIABLE_VISIBILITY = "108"
UNINITIALIZED_STORAGE_POINTER = "109"
ASSERT_VIOLATION = "110"
DEPRECATED_FUNCTIONS_USAGE = "111"
DELEGATECALL_TO_UNTRUSTED_CONTRACT = "112"
DOS_WITH_FAILED_CALL = "113"  # DASP10 CATEGORY = 5
TX_ORDER_DEPENDENCE = "114"  # DASP10 CATEGORY = 7
TX_ORIGIN_USAGE = "115"  # DASP10 CATEGORY = 2
TIMESTAMP_DEPENDENCE = "116"  # DASP10 CATEGORY = 8
SIGNATURE_MALLEABILITY = "117"
INCORRECT_CONSTRUCTOR_NAME = "118"
SHADOWING_STATE_VARIABLES = "119"
WEAK_RANDOMNESS = "120"  # DASP10 CATEGORY = 6
SIGNATURE_REPLAY = "121"
IMPROPER_VERIFICATION_BASED_ON_MSG_SENDER = "122"
# This seems like not a vulnerability
# If any tool detects it we should include it
# REQUIREMENT_VIOLATION = "123"
WRITE_TO_ARBITRARY_STORAGE = "124"  # DASP10 CATEGORY = 5
INCORRECT_INHERITANCE_ORDER = "125"
INSUFFICIENT_GAS_GRIEFING = "126"  # DASP10 CATEGORY = 11
ARBITRARY_JUMP = "127"
DOS_WITH_BLOCK_GAS_LIMIT = "128"
TYPOGRAPHICAL_ERROR = "129"
UNEXPECTED_ETHER_BALANCE = "132"
HASH_COLLISION = "133"
MESSAGE_CALL_WITH_HARDCODED_GAS_AMOUNT = "134"
EFFECT_FREE_CODE = "135"
UNENCRYPTED_PRIVATE_DATA_ON_CHAIN = "136"
# Vulnerabilities with no SWC entry
HONEYPOT = "137"
SHORT_ADDRESS_ATTACK = "138"  # DASP10 CATEGORY = 6
CALLSTACK_DEPTH_ATTACK_VULNERABILITY = "139"
MISSING_INPUT_VALIDATION = "140"
MESSAGE_CALL_TO_EXTERNAL_CONTRACT = "141"
LOCKED_ETHER = "142"
WARNING = "-1"  # Warning or Optimization severity

ID_TO_TITLE = {
    "100": "Function Default Visibility",
    "101": "Integer Overflow and Underflow",
    "102": "Outdated Compiler Version",
    "103": "Floating Pragma",
    "104": "Unchecked Call Return Value",
    "105": "Unprotected Ether Withdrawal",
    "106": "Unprotected SELFDESTRUCT Instruction",
    "107": "Reentrancy",
    "108": "State Variable Default Visibility",
    "109": "Uninitialized Storage Pointer",
    "110": "Assert Violation",
    "111": "Use of Deprecated Solidity Functions",
    "112": "Delegatecall to Untrusted Callee",
    "113": "DoS with Failed Call",
    "114": "Transaction Order Dependence",
    "115": "Authorization through tx.origin",
    "116": "Timestamp Dependence",
    "117": "Signature Malleability",
    "118": "Incorrect Constructor Name",
    "119": "Shadowing State Variables",
    "120": "Weak Randomness",
    "121": "Missing Protection against Signature Replay Attacks",
    "122": "Lack of Proper Signature Verification",
    # "123": "Requirement Violation",
    "124": "Write to Arbitrary Storage Location",
    "125": "Incorrect Inheritance Order",
    "126": "Insufficient Gas Griefing",
    "127": "Arbitrary Jump with Function Type Variable",
    "128": "DoS With Block Gas Limit",
    # "129": "Typographical Error",
    "132": "Unexpected Ether Balance",
    "133": "Hash Collisions With Multiple Variable Length Arguments",
    "134": "Message call with hardcoded gas amount",
    # "135": "Effect Free Code",
    "136": "Unencrypted Private Data On-Chain",
    "137": "Honeypot Contract",
    "138": "Short Address Attack",
    "139": "Callstack Depth Attack Vulnerability",
    "140": "Missing Input Validation",
    "141": "Message call to external contract",
    "142": "Locked Ether",
}

SOK_ID_TO_TITLE = {
    # Third Party Layer
    "0": "Faulty web development",
    "1": "Compromised private key / hacked wallet",
    "2": "Weak password",
    "3": "Deployment mistake",
    "4": "Malicious oracle updater",
    "5": "Malicious data source",
    "6": "External market manipulation",
    "7": "Backdoor / Honeypot",
    "8": "Insider trade or other activities",
    "9": "Phishing attack",
    "10": "Authority control or breach of promise",
    "11": "Faulty wallet provider",
    "12": "Faulty API / RPC",
    "13": "Other third party factors",
    # DeFi Protocol Layer/Design Flaw
    "14": "Frontrunning",
    "15": "Backrunning",
    "16": "Sandwiching",
    "17": "Other transaction order dependency",
    "18": "Transaction / strategy replay",
    "19": "Randomness",
    "20": "Other block state dependency",
    "21": "Fake tokens",
    "22": "Other fake contracts",
    "23": "On-chain oracle manipulation",
    "24": "Governance attack",
    "25": "Token standard incompatibility",
    "26": "Flash liquidity borrow, purchase, mint or deposit",
    "27": "Unsafe call to phantom function",
    "28": "Other unsafe DeFi protocol dependency",
    "29": "Unfair slippage protection",
    "30": "Unfair liquidity providing",
    "31": "Unsafe or infinite token approval",
    "32": "Other unfair or unsafe DeFi protocol interaction",
    "33": "Other DeFi protocol design flaw",
    # Smart Contract Layer
    "34": "Direct call to untrusted contract",
    "35": "Reentrancy",
    "36": "Delegatecall injection",
    "37": "Unhandled or mishandled exception",
    "38": "Locked or frozen tokens",
    "39": "Integer overflow or underflow",
    "40": "Absence of code logic or sanity check",
    "41": "Casting",
    "42": "Unbounded operation, including gas limit and call-stack depth",
    "43": "Arithmetic mistakes",
    "44": "Other coding mistakes",
    "45": "Inconsistent access control",
    "46": "Visibility errors, including unrestricted action",
    "47": "Underpriced opcodes",
    "48": "Outdated compiler version",
    "49": "Known vulnerability not patched",
    "50": "Broken patch",
    "51": "Other smart contract vulnerabilities",
    # Consensus Layer
    "52": "Vulnerabilities in blockchain application layer protocol",
    "53": "Majority (51%) attack",
    "54": "Block reorg",
    "55": "Selfish mining",
    "56": "Double spending",
    "57": "Transaction/Block order manipulation",
    "58": "Other consensus or consensus implementation vulnerabilities",
    # Network Layer
    "59": "Leaked strategy",
    "60": "Transaction fee transparency",
    "61": "Eclipse",
    "62": "Sybil attack",
    "63": "Intentional DoS",
    "64": "Unintentional DoS",
    "65": "Sensitive DNS servers",
    "66": "Unreliable BGP messages",
    "67": "Other network layer vulnerabilities",
    # Exit mechanism
    "68": "Receive tokens at low cost",
    "69": "Minting new tokens",
    "70": "Arbitrage",
    "71": "Liquidation",
    "72": "Theft",
    # Unknown
    "73": "Unknown",
}
