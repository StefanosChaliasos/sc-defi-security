// Sources flattened with hardhat v2.3.0 https://hardhat.org

// File contracts/5/openzeppelin/SafeMath.sol

pragma solidity ^0.5.17;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a < _b ? _a : _b;
    }
}


// File contracts/5/openzeppelin/SignedSafeMath.sol

pragma solidity ^0.5.17;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */
library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

        /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}


// File contracts/5/openzeppelin/ReentrancyGuard.sol

pragma solidity ^0.5.17;


/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

    /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.
    /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056
    uint256 internal constant REENTRANCY_GUARD_FREE = 1;

    /// @dev Constant for locked guard state
    uint256 internal constant REENTRANCY_GUARD_LOCKED = 2;

    /**
    * @dev We use a single lock for the whole contract.
    */
    uint256 internal reentrancyLock = REENTRANCY_GUARD_FREE;

    /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * If you mark a function `nonReentrant`, you should also
    * mark it `external`. Calling one `nonReentrant` function from
    * another is not supported. Instead, you can implement a
    * `private` function doing the actual work, and an `external`
    * wrapper marked as `nonReentrant`.
    */
    modifier nonReentrant() {
        require(reentrancyLock == REENTRANCY_GUARD_FREE, "nonReentrant");
        reentrancyLock = REENTRANCY_GUARD_LOCKED;
        _;
        reentrancyLock = REENTRANCY_GUARD_FREE;
    }

}


// File contracts/5/openzeppelin/Context.sol

pragma solidity ^0.5.17;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File contracts/5/openzeppelin/Ownable.sol

pragma solidity ^0.5.17;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "unauthorized");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File contracts/5/openzeppelin/Address.sol

pragma solidity ^0.5.17;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


// File contracts/5/interfaces/IWbase.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;


interface IWbase {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}


// File contracts/5/interfaces/IERC20.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;


contract IERC20 {
    string public name;
    uint8 public decimals;
    string public symbol;
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/5/interfaces/IWbaseERC20.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;


contract IWbaseERC20 is IWbase, IERC20 {}


// File contracts/5/openzeppelin/Pausable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () public {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File contracts/5/connectors/loantoken/LoanTokenBase.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;







contract LoanTokenBase is ReentrancyGuard, Ownable {

    uint256 internal constant WEI_PRECISION = 10**18;
    uint256 internal constant WEI_PERCENT_PRECISION = 10**20;

    int256 internal constant sWEI_PRECISION = 10**18;

    string public name;
    string public symbol;
    uint8 public decimals;

    address public loanTokenAddress;

    uint256 public baseRate;
    uint256 public rateMultiplier;
    uint256 public lowUtilBaseRate;
    uint256 public lowUtilRateMultiplier;

    uint256 public targetLevel;
    uint256 public kinkLevel;
    uint256 public maxScaleRate;

    uint256 internal _flTotalAssetSupply;
    uint256 public checkpointSupply;
    uint256 public initialPrice;

    // uint88 for tight packing -> 8 + 88 + 160 = 256
    uint88 internal lastSettleTime_;

    mapping (uint256 => bytes32) public loanParamsIds; // mapping of keccak256(collateralToken, isTorqueLoan) to loanParamsId
    mapping (address => uint256) internal checkpointPrices_; // price of token at last user checkpoint
    
    mapping(address => uint256) public transactionLimit;                                 // the maximum trading/borrowing/lending limit per token address
                                                                                         // 0 -> no limit
}


// File contracts/5/connectors/loantoken/AdvancedTokenStorage.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;

contract AdvancedTokenStorage is LoanTokenBase {
    using SafeMath for uint256;

    // topic: 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    // topic: 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // topic: 0xb4c03061fb5b7fed76389d5af8f2e0ddb09f8c70d1333abbb62582835e10accb
    event Mint(
        address indexed minter,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 price
    );

    // topic: 0x743033787f4738ff4d6a7225ce2bd0977ee5f86b91a902a58f5e4d0b297b4644
    event Burn(
        address indexed burner,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 price
    );

    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 internal totalSupply_;

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return totalSupply_;
    }

    function balanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return balances[_owner];
    }

    function allowance(
        address _owner,
        address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }
}


// File contracts/5/connectors/loantoken/AdvancedToken.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;

contract AdvancedToken is AdvancedTokenStorage {
    using SafeMath for uint256;

    function approve(
        address _spender,
        uint256 _value)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _mint(
        address _to,
        uint256 _tokenAmount,
        uint256 _assetAmount,
        uint256 _price)
        internal
        returns (uint256)
    {
        require(_to != address(0), "15");

        uint256 _balance = balances[_to]
            .add(_tokenAmount);
        balances[_to] = _balance;

        totalSupply_ = totalSupply_
            .add(_tokenAmount);

        emit Mint(_to, _tokenAmount, _assetAmount, _price);
        emit Transfer(address(0), _to, _tokenAmount);

        return _balance;
    }

    function _burn(
        address _who,
        uint256 _tokenAmount,
        uint256 _assetAmount,
        uint256 _price)
        internal
        returns (uint256)
    {
        require(_tokenAmount <= balances[_who], "16");
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        uint256 _balance = balances[_who].sub(_tokenAmount);
        if (_balance <= 10) { // we can't leave such small balance quantities
            _tokenAmount = _tokenAmount.add(_balance);
            _balance = 0;
        }
        balances[_who] = _balance;

        totalSupply_ = totalSupply_.sub(_tokenAmount);

        emit Burn(_who, _tokenAmount, _assetAmount, _price);
        emit Transfer(_who, address(0), _tokenAmount);

        return _balance;
    }
}


// File contracts/5/core/objects/LoanParamsStruct.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;


contract LoanParamsStruct {
    struct LoanParams {
        bytes32 id;                 // id of loan params object
        bool active;                // if false, this object has been disabled by the owner and can't be used for future loans
        address owner;              // owner of this object
        address loanToken;          // the token being loaned
        address collateralToken;    // the required collateral token
        uint256 minInitialMargin;   // the minimum allowed initial margin
        uint256 maintenanceMargin;  // an unhealthy loan when current margin is at or below this value
        uint256 maxLoanTerm;        // the maximum term for new loans (0 means there's no max term)
    }
}


// File contracts/5/connectors/loantoken/interfaces/ProtocolSettingsLike.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

interface ProtocolSettingsLike {
    function setupLoanParams(
        LoanParamsStruct.LoanParams[] calldata loanParamsList)
        external
        returns (bytes32[] memory loanParamsIdList);

    function disableLoanParams(
        bytes32[] calldata loanParamsIdList)
        external;
}


// File contracts/5/connectors/loantoken/LoanTokenSettingsLowerAdmin.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;

contract LoanTokenSettingsLowerAdmin is AdvancedToken {
    using SafeMath for uint256;

    // It is important to maintain the variables order so the delegate calls can access pfiContractAddress
    address public pfiContractAddress;
    
    event SetTransactionLimits(address[] addresses, uint256[] limits);

    modifier onlyAdmin() {
        require(msg.sender == address(this) ||
            msg.sender == owner(), "unauthorized");
        _;
    }

    function()
        external
    {
        revert("LoanTokenSettingsLowerAdmin - fallback not allowed");
    }

    function setupLoanParams(
        LoanParamsStruct.LoanParams[] memory loanParamsList,
        bool areTorqueLoans)
        public
        onlyAdmin
    {
        bytes32[] memory loanParamsIdList;
        address _loanTokenAddress = loanTokenAddress;

        for (uint256 i = 0; i < loanParamsList.length; i++) {
            loanParamsList[i].loanToken = _loanTokenAddress;
            loanParamsList[i].maxLoanTerm = areTorqueLoans ? 0 : 1 days;
        }

        loanParamsIdList = ProtocolSettingsLike(pfiContractAddress).setupLoanParams(loanParamsList);
        for (uint256 i = 0; i < loanParamsIdList.length; i++) {
            loanParamsIds[uint256(keccak256(abi.encodePacked(
                loanParamsList[i].collateralToken,
                areTorqueLoans // isTorqueLoan
            )))] = loanParamsIdList[i];
        }
    }


    function disableLoanParams(
        address[] calldata collateralTokens,
        bool[] calldata isTorqueLoans)
        external
        onlyAdmin
    {
        require(collateralTokens.length == isTorqueLoans.length, "count mismatch");

        bytes32[] memory loanParamsIdList = new bytes32[](collateralTokens.length);
        for (uint256 i = 0; i < collateralTokens.length; i++) {
            uint256 id = uint256(keccak256(abi.encodePacked(
                collateralTokens[i],
                isTorqueLoans[i]
            )));
            loanParamsIdList[i] = loanParamsIds[id];
            delete loanParamsIds[id];
        }

        ProtocolSettingsLike(pfiContractAddress).disableLoanParams(loanParamsIdList);
    }

    // These params should be percentages represented like so: 5% = 5000000000000000000
    // rateMultiplier + baseRate can't exceed 100%
    function setDemandCurve(
        uint256 _baseRate,
        uint256 _rateMultiplier,
        uint256 _lowUtilBaseRate,
        uint256 _lowUtilRateMultiplier,
        uint256 _targetLevel,
        uint256 _kinkLevel,
        uint256 _maxScaleRate)
        public
        onlyAdmin
    {
        require(_rateMultiplier.add(_baseRate) <= WEI_PERCENT_PRECISION, "curve params too high");
        require(_lowUtilRateMultiplier.add(_lowUtilBaseRate) <= WEI_PERCENT_PRECISION, "curve params too high");

        require(_targetLevel <= WEI_PERCENT_PRECISION && _kinkLevel <= WEI_PERCENT_PRECISION, "levels too high");

        baseRate = _baseRate;
        rateMultiplier = _rateMultiplier;
        lowUtilBaseRate = _lowUtilBaseRate;
        lowUtilRateMultiplier = _lowUtilRateMultiplier;

        targetLevel = _targetLevel; // 80 ether
        kinkLevel = _kinkLevel; // 90 ether
        maxScaleRate = _maxScaleRate; // 100 ether
    }
    
    /**
     * sets the transaction limit per token address
     * @param addresses the token addresses
     * @param limits the limit denominated in the currency of the token address
     * */
    function setTransactionLimits(
        address[] memory addresses, 
        uint256[] memory limits) 
        public onlyOwner
    {
        require(addresses.length == limits.length, "mismatched array lengths");
        for(uint i = 0; i < addresses.length; i++){
            transactionLimit[addresses[i]] = limits[i];
        }
        emit SetTransactionLimits(addresses, limits);
    }

    function changeLoanTokenNameAndSymbol(string memory _name, string memory _symbol) public onlyAdmin {
        name = _name;
        symbol = _symbol;
    }

}


// File contracts/5/connectors/loantoken/interfaces/ProtocolLike.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;


interface ProtocolLike {
    function borrowOrTradeFromPool(
        bytes32 loanParamsId,
        bytes32 loanId, // if 0, start a new loan
        bool isTorqueLoan,
        uint256 initialMargin,
        address[4] calldata sentAddresses,
            // lender: must match loan if loanId provided
            // borrower: must match loan if loanId provided
            // receiver: receiver of funds (address(0) assumes borrower address)
            // manager: delegated manager of loan unless address(0)
        uint256[5] calldata sentValues,
            // newRate: new loan interest rate
            // newPrincipal: new loan size (borrowAmount + any borrowed interest)
            // torqueInterest: new amount of interest to escrow for Torque loan (determines initial loan length)
            // loanTokenReceived: total loanToken deposit (amount not sent to borrower in the case of Torque loans)
            // collateralTokenReceived: total collateralToken deposit
        bytes calldata loanDataBytes)
        external
        payable
        returns (uint256 newPrincipal, uint256 newCollateral);

    function getTotalPrincipal(
        address lender,
        address loanToken)
        external
        view
        returns (uint256);

    function withdrawAccruedInterest(
        address loanToken)
        external;

    function getLenderInterestData(
        address lender,
        address loanToken)
        external
        view
        returns (
            uint256 interestPaid,
            uint256 interestPaidDate,
            uint256 interestOwedPerDay,
            uint256 interestUnPaid,
            uint256 interestFeePercent,
            uint256 principalTotal);

    function priceFeeds()
        external
        view
        returns (address);

    function getEstimatedMarginExposure(
        address loanToken,
        address collateralToken,
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        uint256 interestRate,
        uint256 newPrincipal)
        external
        view
        returns (uint256);

    function getRequiredCollateral(
        address loanToken,
        address collateralToken,
        uint256 newPrincipal,
        uint256 marginAmount,
        bool isTorqueLoan)
        external
        view
        returns (uint256 collateralAmountRequired);

    function getBorrowAmount(
        address loanToken,
        address collateralToken,
        uint256 collateralTokenAmount,
        uint256 marginAmount,
        bool isTorqueLoan)
        external
        view
        returns (uint256 borrowAmount);

    function isLoanPool(
        address loanPool)
        external
        view
        returns (bool);

    function lendingFeePercent()
        external
        view
        returns (uint256);

    function getSwapExpectedReturn(
        address sourceToken,
        address destToken,
        uint256 sourceTokenAmount) 
        external 
        view
        returns(uint256);
}


// File contracts/5/connectors/loantoken/interfaces/FeedsLike.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;


interface FeedsLike {
    function queryRate(
        address sourceTokenAddress,
        address destTokenAddress)
        external
        view
        returns (uint256 rate, uint256 precision);
}


// File contracts/5/connectors/loantoken/LoanTokenLogicStandard.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity ^0.5.17;


contract LoanTokenLogicStandard is LoanTokenSettingsLowerAdmin, Pausable {
    using SignedSafeMath for int256;

    // It is important to maintain the variables order so the delegate calls can access pfiContractAddress and wbaseTokenAddress
    address public wbaseTokenAddress;
    address internal target_;

    uint256 public constant VERSION = 5;
    address internal constant arbitraryCaller = 0x000F400e6818158D541C3EBE45FE3AA0d47372FF;

    function()
        external
    {
        revert("loan token logic - fallback not allowed");
    }


    /* Public functions */

    function mint(
        address receiver,
        uint256 depositAmount)
        external
        nonReentrant
        returns (uint256 mintAmount)
    {
        //temporary: limit transaction size
        if(transactionLimit[loanTokenAddress] > 0)
            require(depositAmount <= transactionLimit[loanTokenAddress]);
            
        return _mintToken(
            receiver,
            depositAmount
        );
    }

    function burn(
        address receiver,
        uint256 burnAmount)
        external
        nonReentrant
        returns (uint256 loanAmountPaid)
    {
        loanAmountPaid = _burnToken(
            burnAmount
        );

        if (loanAmountPaid != 0) {
            _safeTransfer(loanTokenAddress, receiver, loanAmountPaid, "5");
        }
    }
    
    
    /*
    flashBorrow is disabled for the MVP, but is going to be added later.
    therefore, it needs to be revised
    
    function flashBorrow(
        uint256 borrowAmount,
        address borrower,
        address target,
        string calldata signature,
        bytes calldata data)
        external
        payable
        nonReentrant
        pausable(msg.sig)
        settlesInterest
        returns (bytes memory)
    {
        require(borrowAmount != 0, "38");

        _settleInterest();

        // save before balances
        uint256 beforeEtherBalance = address(this).balance.sub(msg.value);
        uint256 beforeAssetsBalance = _underlyingBalance()
            .add(totalAssetBorrow());

        // lock totalAssetSupply for duration of flash loan
        _flTotalAssetSupply = beforeAssetsBalance;

        // transfer assets to calling contract
        _safeTransfer(loanTokenAddress, borrower, borrowAmount, "39");

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // arbitrary call
        (bool success, bytes memory returnData) = arbitraryCaller.call.value(msg.value)(
            abi.encodeWithSelector(
                0xde064e0d, // sendCall(address,bytes)
                target,
                callData
            )
        );
        require(success, "call failed");

        // unlock totalAssetSupply
        _flTotalAssetSupply = 0;

        // verifies return of flash loan
        require(
            address(this).balance >= beforeEtherBalance &&
            _underlyingBalance()
                .add(totalAssetBorrow()) >= beforeAssetsBalance,
            "40"
        );

        return returnData;
    }
    */
    
    /**
     * borrows funds from the pool. The underlying loan token may not be used as collateral.
     * @param loanId the ID of the loan, 0 for a new loan 
     * @param withdrawAmount the amount to be withdrawn (actually borrowed)
     * @param initialLoanDuration the duration of the loan in seconds. if the loan is not paid back until then, it'll need to be rolled over
     * @param collateralTokenSent the amount of collateral token sent (150% of the withdrawn amount worth in collateral tokenns)
     * @param collateralTokenAddress the address of the tokenn to be used as collateral. cannot be the loan token address
     * @param borrower the one paying for the collateral
     * @param receiver the one receiving the withdrawn amount
     * */
    function borrow(
        bytes32 loanId,                 // 0 if new loan
        uint256 withdrawAmount,
        uint256 initialLoanDuration,    // duration in seconds
        uint256 collateralTokenSent,    // if 0, loanId must be provided; any ETH sent must equal this value
        address collateralTokenAddress, // if address(0), this means ETH and ETH must be sent with the call or loanId must be provided
        address borrower,
        address receiver,
        bytes memory /*loanDataBytes*/) // arbitrary order data (for future use)
        public
        payable
        nonReentrant                    //note: needs to be removed to allow flashloan use cases
        whenNotPaused
        returns (uint256, uint256) // returns new principal and new collateral added to loan
    {
        require(withdrawAmount != 0, "6");

        //temporary: limit transaction size
        if(transactionLimit[collateralTokenAddress] > 0)
            require(collateralTokenSent <= transactionLimit[collateralTokenAddress]);

        require(msg.value == 0 || msg.value == collateralTokenSent, "7");
        require(collateralTokenSent != 0 || loanId != 0, "8");
        require(collateralTokenAddress != address(0) || msg.value != 0 || loanId != 0, "9");

        if (collateralTokenAddress == address(0)) {
            collateralTokenAddress = wbaseTokenAddress;
        }
        require(collateralTokenAddress != loanTokenAddress, "10");

        // ensures authorized use of existing loan
        require(loanId == 0 || msg.sender == borrower, "13");

        _settleInterest();

        address[4] memory sentAddresses;
        uint256[5] memory sentAmounts;

        sentAddresses[0] = address(this); // lender
        sentAddresses[1] = borrower;
        sentAddresses[2] = receiver;
        //sentAddresses[3] = address(0); // manager

        sentAmounts[1] = withdrawAmount;

        // interestRate, interestInitialAmount, borrowAmount (newBorrowAmount)
        (sentAmounts[0], sentAmounts[2], sentAmounts[1]) = _getInterestRateAndBorrowAmount(
            sentAmounts[1],
            _totalAssetSupply(0), // interest is settled above
            initialLoanDuration
        );

        //sentAmounts[3] = 0; // loanTokenSent
        sentAmounts[4] = collateralTokenSent;

        return _borrowOrTrade(
            loanId,
            withdrawAmount,
            2 * 10**18, // leverageAmount (translates to 150% margin for a Torque loan)
            collateralTokenAddress,
            sentAddresses,
            sentAmounts,
            "" // loanDataBytes
        );
    }

    // Called to borrow and immediately get into a positions
    function marginTrade(
        bytes32 loanId,                 // 0 if new loan
        uint256 leverageAmount,         // expected in x * 10**18 where x is the actual leverage (2, 3, 4, or 5)
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        address collateralTokenAddress,
        address trader,
        bytes memory loanDataBytes)     // arbitrary order data
        public
        payable
        nonReentrant                    //note: needs to be removed to allow flashloan use cases
        whenNotPaused
        returns (uint256, uint256) // returns new principal and new collateral added to trade
    {
        // ensures authorized use of existing loan
        require(loanId == 0 || msg.sender == trader, "13");
 
        if (collateralTokenAddress == address(0)) {
            collateralTokenAddress = wbaseTokenAddress;
        }

        require(collateralTokenAddress != loanTokenAddress, "11");
        
        //temporary: limit transaction size
        if(transactionLimit[collateralTokenAddress] > 0)
            require(collateralTokenSent <= transactionLimit[collateralTokenAddress]);
        if(transactionLimit[loanTokenAddress] > 0)
            require(loanTokenSent <= transactionLimit[loanTokenAddress]);
        
        //computes the worth of the total deposit in loan tokens.
        //(loanTokenSent + convert(collateralTokenSent))
        //no actual swap happening here.
        uint256 totalDeposit = _totalDeposit(
            collateralTokenAddress,
            collateralTokenSent,
            loanTokenSent
        );
        require(totalDeposit != 0, "12");

        address[4] memory sentAddresses;
        uint256[5] memory sentAmounts;

        sentAddresses[0] = address(this); // lender
        sentAddresses[1] = trader;
        sentAddresses[2] = trader;
        //sentAddresses[3] = address(0); // manager

        //sentAmounts[0] = 0; // interestRate (found later)
        sentAmounts[1] = totalDeposit; // total amount of deposit
        //sentAmounts[2] = 0; // interestInitialAmount (interest is calculated based on fixed-term loan)
        sentAmounts[3] = loanTokenSent;
        sentAmounts[4] = collateralTokenSent;

        _settleInterest();

        (sentAmounts[1], sentAmounts[0]) = _getMarginBorrowAmountAndRate( // borrowAmount, interestRate
            leverageAmount,
            sentAmounts[1] // depositAmount
        );

        return _borrowOrTrade(
            loanId,
            0, // withdrawAmount
            leverageAmount,
            collateralTokenAddress,
            sentAddresses,
            sentAmounts,
            loanDataBytes
        );
    }

    function transfer(
        address _to,
        uint256 _value)
        external
        returns (bool)
    {
        return _internalTransferFrom(
            msg.sender,
            _to,
            _value,
            uint256(-1)
        );
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        external
        returns (bool)
    {
        return _internalTransferFrom(
            _from,
            _to,
            _value,
            ProtocolLike(pfiContractAddress).isLoanPool(msg.sender) ?
                uint256(-1) :
                allowed[_from][msg.sender]
        );
    }

    function _internalTransferFrom(
        address _from,
        address _to,
        uint256 _value,
        uint256 _allowanceAmount)
        internal
        returns (bool)
    {
        if (_allowanceAmount != uint256(-1)) {
            require(_value <= _allowanceAmount, "14");
            allowed[_from][msg.sender] = _allowanceAmount.sub(_value);
        }

        uint256 _balancesFrom = balances[_from];
        require(_value <= _balancesFrom &&
            _to != address(0),
            "14"
        );
        
        
        uint256 _balancesFromNew = _balancesFrom
            .sub(_value);
        balances[_from] = _balancesFromNew;
        
        uint256 _balancesTo = balances[_to];
        uint256 _balancesToNew = _balancesTo
            .add(_value);
        balances[_to] = _balancesToNew;

        // handle checkpoint update
        uint256 _currentPrice = tokenPrice();

        _updateCheckpoints(
            _from,
            _balancesFrom,
            _balancesFromNew,
            _currentPrice
        );
        _updateCheckpoints(
            _to,
            _balancesTo,
            _balancesToNew,
            _currentPrice
        );

        emit Transfer(_from, _to, _value);
        return true;
    }

    
    /**
     * @dev updates the user's checkpoint price and profit so far.
     * @param _user the user address
     * @param _oldBalance the user's previous balance
     * @param _newBalance the user's updated balance
     * @param _currentPrice the current iToken price
     * */
    function _updateCheckpoints(
        address _user,
        uint256 _oldBalance,
        uint256 _newBalance,
        uint256 _currentPrice)
        internal
    {
        // keccak256("iToken_ProfitSoFar")
        bytes32 slot = keccak256(
            abi.encodePacked(_user, uint256(0x37aa2b7d583612f016e4a4de4292cb015139b3d7762663d06a53964912ea2fb6))
        );

        uint256 _currentProfit;
        if (_oldBalance != 0 && _newBalance != 0) {
            _currentProfit = _profitOf(
                slot,
                _oldBalance,
                _currentPrice,
                checkpointPrices_[_user]
            );
        } else if (_newBalance == 0) {
            _currentPrice = 0;
        }

        assembly {
            sstore(slot, _currentProfit)
        }

        checkpointPrices_[_user] = _currentPrice;

    }

    /* Public View functions */

    function profitOf(
        address user)
        public
        view
        returns (uint256)
    {
        // keccak256("iToken_ProfitSoFar")
        bytes32 slot = keccak256(
            abi.encodePacked(user, uint256(0x37aa2b7d583612f016e4a4de4292cb015139b3d7762663d06a53964912ea2fb6))
        );

        return _profitOf(
            slot,
            balances[user],
            tokenPrice(),
            checkpointPrices_[user]
        );
    }

    function _profitOf(
        bytes32 slot,
        uint256 _balance,
        uint256 _currentPrice,
        uint256 _checkpointPrice)
        internal
        view
        returns (uint256)
    {
        if (_checkpointPrice == 0) {
            return 0;
        }

        uint256 profitSoFar;
        uint256 profitDiff;

        assembly {
            profitSoFar := sload(slot)
        }

        if (_currentPrice > _checkpointPrice) {
            profitDiff = _balance
                .mul(_currentPrice - _checkpointPrice)
                .div(10**18);
            profitSoFar = profitSoFar
                .add(profitDiff);
        } else {
            profitDiff = _balance
                .mul(_checkpointPrice - _currentPrice)
                .div(10**18);
            if (profitSoFar > profitDiff) {
                profitSoFar = profitSoFar - profitDiff;
            } else {
                profitSoFar = 0;
            }
        }

        return profitSoFar;
    }

    function tokenPrice()
        public
        view
        returns (uint256 price)
    {
        uint256 interestUnPaid;
        if (lastSettleTime_ != uint88(block.timestamp)) {
            (,interestUnPaid) = _getAllInterest();
        }

        return _tokenPrice(_totalAssetSupply(interestUnPaid));
    }

    function checkpointPrice(
        address _user)
        public
        view
        returns (uint256 price)
    {
        return checkpointPrices_[_user];
    }

    function marketLiquidity()
        public
        view
        returns (uint256)
    {
        uint256 totalSupply = _totalAssetSupply(0);
        uint256 totalBorrow = totalAssetBorrow();
        if (totalSupply > totalBorrow) {
            return totalSupply.sub(totalBorrow);
        }
    }

    function avgBorrowInterestRate()
        public
        view
        returns (uint256)
    {
        return _avgBorrowInterestRate(totalAssetBorrow());
    }

    // the minimum rate the next base protocol borrower will receive for variable-rate loans
    function borrowInterestRate()
        public
        view
        returns (uint256)
    {
        return _nextBorrowInterestRate(0);
    }

    function nextBorrowInterestRate(
        uint256 borrowAmount)
        public
        view
        returns (uint256)
    {
        return _nextBorrowInterestRate(borrowAmount);
    }

    // interest that lenders are currently receiving when supplying to the pool
    function supplyInterestRate()
        public
        view
        returns (uint256)
    {
        return totalSupplyInterestRate(_totalAssetSupply(0));
    }

    function nextSupplyInterestRate(
        uint256 supplyAmount)
        public
        view
        returns (uint256)
    {
        return totalSupplyInterestRate(_totalAssetSupply(0).add(supplyAmount));
    }

    function totalSupplyInterestRate(
        uint256 assetSupply)
        public
        view
        returns (uint256)
    {
        uint256 assetBorrow = totalAssetBorrow();
        if (assetBorrow != 0) {
            return _supplyInterestRate(
                assetBorrow,
                assetSupply
            );
        }
    }

    function totalAssetBorrow()
        public
        view
        returns (uint256)
    {
        return ProtocolLike(pfiContractAddress).getTotalPrincipal(
            address(this),
            loanTokenAddress
        );
    }

    function totalAssetSupply()
        public
        view
        returns (uint256)
    {
        uint256 interestUnPaid;
        if (lastSettleTime_ != uint88(block.timestamp)) {
            (,interestUnPaid) = _getAllInterest();
        }

        return _totalAssetSupply(interestUnPaid);
    }
    
    /**
     * @notice computes the maximum deposit amount under current market conditions
     * @dev maxEscrowAmount = liquidity * (100 - interestForDuration) / 100
     * @param leverageAmount the chosen leverage with 18 decimals
     * */
    function getMaxEscrowAmount(
        uint256 leverageAmount)
        public
        view
        returns (uint256 maxEscrowAmount)
    {
        //mathematical imperfection. depending on liquidity we might be able to borrow more if utilization is below the kink level
        uint256 interestForDuration = maxScaleRate.mul(28).div(365);
        uint256 factor = uint256(10**20).sub(interestForDuration);
        uint256 maxLoanSize = marketLiquidity().mul(factor).div(10**20);
        maxEscrowAmount = maxLoanSize.mul(10**18).div(leverageAmount);
    }

    // returns the user's balance of underlying token
    function assetBalanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return balanceOf(_owner)
            .mul(tokenPrice())
            .div(10**18);
    }

    function getEstimatedMarginDetails(
        uint256 leverageAmount,
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        address collateralTokenAddress)     // address(0) means ETH
        public
        view
        returns (uint256 principal, uint256 collateral, uint256 interestRate)
    {
        if (collateralTokenAddress == address(0)) {
            collateralTokenAddress = wbaseTokenAddress;
        }

        uint256 totalDeposit = _totalDeposit(
            collateralTokenAddress,
            collateralTokenSent,
            loanTokenSent
        );

        (principal, interestRate) = _getMarginBorrowAmountAndRate(
            leverageAmount,
            totalDeposit
        );
        if (principal > _underlyingBalance()) {
            return (0, 0, 0);
        }

        loanTokenSent = loanTokenSent
            .add(principal);

        collateral = ProtocolLike(pfiContractAddress).getEstimatedMarginExposure(
            loanTokenAddress,
            collateralTokenAddress,
            loanTokenSent,
            collateralTokenSent,
            interestRate,
            principal
        );
    }

    function getDepositAmountForBorrow(
        uint256 borrowAmount,
        uint256 initialLoanDuration,        // duration in seconds
        address collateralTokenAddress)     // address(0) means ETH
        public
        view
        returns (uint256 depositAmount)
    {
        if (borrowAmount != 0) {
            (,,uint256 newBorrowAmount) = _getInterestRateAndBorrowAmount(
                borrowAmount,
                totalAssetSupply(),
                initialLoanDuration
            );

            if (newBorrowAmount <= _underlyingBalance()) {
                return ProtocolLike(pfiContractAddress).getRequiredCollateral(
                    loanTokenAddress,
                    collateralTokenAddress != address(0) ? collateralTokenAddress : wbaseTokenAddress,
                    newBorrowAmount,
                    50 * 10**18, // initialMargin
                    true // isTorqueLoan
                ).add(10); // some dust to compensate for rounding errors
            }
        }
    }

    function getBorrowAmountForDeposit(
        uint256 depositAmount,
        uint256 initialLoanDuration,        // duration in seconds
        address collateralTokenAddress)     // address(0) means ETH
        public
        view
        returns (uint256 borrowAmount)
    {
        if (depositAmount != 0) {
            borrowAmount = ProtocolLike(pfiContractAddress).getBorrowAmount(
                loanTokenAddress,
                collateralTokenAddress != address(0) ? collateralTokenAddress : wbaseTokenAddress,
                depositAmount,
                50 * 10**18, // initialMargin,
                true // isTorqueLoan
            );

            (,,borrowAmount) = _getInterestRateAndBorrowAmount(
                borrowAmount,
                totalAssetSupply(),
                initialLoanDuration
            );

            if (borrowAmount > _underlyingBalance()) {
                borrowAmount = 0;
            }
        }
    }

    /* Internal functions */

    function _mintToken(
        address receiver,
        uint256 depositAmount)
        internal
        returns (uint256 mintAmount)
    {
        require (depositAmount != 0, "17");

        _settleInterest();

        uint256 currentPrice = _tokenPrice(_totalAssetSupply(0));
        mintAmount = depositAmount
            .mul(10**18)
            .div(currentPrice);

        if (msg.value == 0) {
            _safeTransferFrom(loanTokenAddress, msg.sender, address(this), depositAmount, "18");
        } else {
            IWbase(wbaseTokenAddress).deposit.value(depositAmount)();
        }

        uint256 oldBalance = balances[receiver];
        _updateCheckpoints(
            receiver,
            oldBalance,
            _mint(receiver, mintAmount, depositAmount, currentPrice), // newBalance
            currentPrice
        );
    }

    function _burnToken(
        uint256 burnAmount)
        internal
        returns (uint256 loanAmountPaid)
    {
        require(burnAmount != 0, "19");

        if (burnAmount > balanceOf(msg.sender)) {
            burnAmount = balanceOf(msg.sender);
        }

        _settleInterest();

        uint256 currentPrice = _tokenPrice(_totalAssetSupply(0));

        uint256 loanAmountOwed = burnAmount
            .mul(currentPrice)
            .div(10**18);
        uint256 loanAmountAvailableInContract = _underlyingBalance();

        loanAmountPaid = loanAmountOwed;
        require(loanAmountPaid <= loanAmountAvailableInContract, "37");

        uint256 oldBalance = balances[msg.sender];
        
        //this function does not only update the checkpoints but also the current profit of the user
        _updateCheckpoints(
            msg.sender,
            oldBalance,
            _burn(msg.sender, burnAmount, loanAmountPaid, currentPrice), // newBalance
            currentPrice
        );
    }

    function _settleInterest()
        internal
    {
        uint88 ts = uint88(block.timestamp);
        if (lastSettleTime_ != ts) {
            ProtocolLike(pfiContractAddress).withdrawAccruedInterest(
                loanTokenAddress
            );

            lastSettleTime_ = ts;
        }
    }

    /**
     * @dev computes what the deposit is worth in loan tokens using the swap rate 
     *      used for loan size computation
     * @param collateralTokenAddress the address of the collateral token
     * @param collateralTokenSent the number of collateral tokens provided the user
     * @param loanTokenSent the number of loan tokens provided by the user
     * @return the value of the deposit in loan tokens
     * */
    function _totalDeposit(
        address collateralTokenAddress,
        uint256 collateralTokenSent,
        uint256 loanTokenSent)
        internal
        view
        returns (uint256 totalDeposit)
    {
        totalDeposit = loanTokenSent;

        if (collateralTokenSent != 0) {
            //get the oracle rate from collateral -> loan
            (uint256 collateralToLoanRate, uint256 collateralToLoanPrecision) = FeedsLike(ProtocolLike(pfiContractAddress).priceFeeds()).queryRate(
                collateralTokenAddress,
                loanTokenAddress
            );
            require((collateralToLoanRate != 0) && (collateralToLoanPrecision != 0), "invalid exchange rate for the collateral token");
            
            //compute the loan token amount with the oracle rate
            uint256 loanTokenAmount = collateralTokenSent
                .mul(collateralToLoanRate)
                .div(collateralToLoanPrecision
            );
            
            //see how many collateralTokens we would get if exchanging this amount of loan tokens to collateral tokens
            uint256 collateralTokenAmount = ProtocolLike(pfiContractAddress).getSwapExpectedReturn(
                loanTokenAddress,
                collateralTokenAddress,
                loanTokenAmount
            );
            
            //probably not the same due to the price difference
            if (collateralTokenAmount != collateralTokenSent) {
                //scale the loan token amount accordingly, so we'll get the expected position size in the end
                loanTokenAmount = loanTokenAmount
                    .mul(collateralTokenAmount)
                    .div(collateralTokenSent
                );
            }

            totalDeposit = loanTokenAmount.add(totalDeposit);

        }            
    }

    function _getInterestRateAndBorrowAmount(
        uint256 borrowAmount,
        uint256 assetSupply,
        uint256 initialLoanDuration) // duration in seconds
        internal
        view
        returns (uint256 interestRate, uint256 interestInitialAmount, uint256 newBorrowAmount)
    {
        interestRate = _nextBorrowInterestRate2(
            borrowAmount,
            assetSupply
        );

        // newBorrowAmount = borrowAmount * 10^18 / (10^18 - interestRate * 7884000 * 10^18 / 31536000 / 10^20)
        newBorrowAmount = borrowAmount
            .mul(10**18)
            .div(
                SafeMath.sub(10**18,
                    interestRate
                        .mul(initialLoanDuration)
                        .mul(10**18)
                        .div(31536000 * 10**20) // 365 * 86400 * 10**20
                )
            );

        interestInitialAmount = newBorrowAmount
            .sub(borrowAmount);
    }

    // returns newPrincipal
    function _borrowOrTrade(
        bytes32 loanId,
        uint256 withdrawAmount,
        uint256 leverageAmount,
        address collateralTokenAddress,
        address[4] memory sentAddresses,
        uint256[5] memory sentAmounts,
        bytes memory loanDataBytes)
        internal
        whenNotPaused
        returns (uint256, uint256)
    {
        require (sentAmounts[1] <= _underlyingBalance() && // newPrincipal (borrowed amount + fees)
            sentAddresses[1] != address(0), // borrower
            "24"
        );

	    if (sentAddresses[2] == address(0)) {
            sentAddresses[2] = sentAddresses[1]; // receiver = borrower
        }

        // handle transfers prior to adding newPrincipal to loanTokenSent
        uint256 msgValue = _verifyTransfers(
            collateralTokenAddress,
            sentAddresses,
            sentAmounts,
            withdrawAmount
        );

        // adding the loan token portion from the lender to loanTokenSent
        // (add the loan to the loan tokens sent from the user)
        sentAmounts[3] = sentAmounts[3]
            .add(sentAmounts[1]); // newPrincipal

        if (withdrawAmount != 0) {
            // withdrawAmount already sent to the borrower, so we aren't sending it to the protocol
            sentAmounts[3] = sentAmounts[3]
                .sub(withdrawAmount);
        }

        bytes32 loanParamsId = loanParamsIds[uint256(keccak256(abi.encodePacked(
            collateralTokenAddress,
            withdrawAmount != 0 ? // isTorqueLoan
                true :
                false
        )))];

        // converting to initialMargin
        leverageAmount = SafeMath.div(10**38, leverageAmount);
        (sentAmounts[1], sentAmounts[4]) = ProtocolLike(pfiContractAddress).borrowOrTradeFromPool.value(msgValue)( // newPrincipal, newCollateral
            loanParamsId,
            loanId,
            withdrawAmount != 0 ? // isTorqueLoan
                true :
                false,
            leverageAmount, // initialMargin
            sentAddresses,
            sentAmounts,
            loanDataBytes
        );
        require (sentAmounts[1] != 0, "25");

        return (sentAmounts[1], sentAmounts[4]); // newPrincipal, newCollateral
    }

    // sentAddresses[0]: lender
    // sentAddresses[1]: borrower
    // sentAddresses[2]: receiver
    // sentAddresses[3]: manager
    // sentAmounts[0]: interestRate
    // sentAmounts[1]: newPrincipal
    // sentAmounts[2]: interestInitialAmount
    // sentAmounts[3]: loanTokenSent
    // sentAmounts[4]: collateralTokenSent
    function _verifyTransfers(
        address collateralTokenAddress,
        address[4] memory sentAddresses,
        uint256[5] memory sentAmounts,
        uint256 withdrawalAmount)
        internal
        returns (uint256 msgValue)
    {
        address _wbaseToken = wbaseTokenAddress;
        address _loanTokenAddress = loanTokenAddress;
        address receiver = sentAddresses[2];
        uint256 newPrincipal = sentAmounts[1];
        uint256 loanTokenSent = sentAmounts[3];
        uint256 collateralTokenSent = sentAmounts[4];

        require(_loanTokenAddress != collateralTokenAddress, "26");

        msgValue = msg.value;

        if (withdrawalAmount != 0) { // withdrawOnOpen == true
            _safeTransfer(_loanTokenAddress, receiver, withdrawalAmount, "");
            if (newPrincipal > withdrawalAmount) {
                _safeTransfer(_loanTokenAddress, pfiContractAddress, newPrincipal - withdrawalAmount, "");
            }
        } else {
            _safeTransfer(_loanTokenAddress, pfiContractAddress, newPrincipal, "27");
        }
        //this is a critical piece of code!
        //wEth are supposed to be held by the contract itself, while other tokens are being transfered from the sender directly
        if (collateralTokenSent != 0) {
            if (collateralTokenAddress == _wbaseToken && msgValue != 0 && msgValue >= collateralTokenSent) {
                IWbase(_wbaseToken).deposit.value(collateralTokenSent)();
                _safeTransfer(collateralTokenAddress, pfiContractAddress, collateralTokenSent, "28-a");
                msgValue -= collateralTokenSent;
            } else {
                _safeTransferFrom(collateralTokenAddress, msg.sender, pfiContractAddress, collateralTokenSent, "28-b");
            }
        }

        if (loanTokenSent != 0) {
            _safeTransferFrom(_loanTokenAddress, msg.sender, pfiContractAddress, loanTokenSent, "29");
        }
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 amount,
        string memory errorMsg)
        internal
    {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(IERC20(token).transfer.selector, to, amount),
            errorMsg
        );
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        string memory errorMsg)
        internal
    {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(IERC20(token).transferFrom.selector, from, to, amount),
            errorMsg
        );
    }

    function _callOptionalReturn(
        address token,
        bytes memory data,
        string memory errorMsg)
        internal
    {
        (bool success, bytes memory returndata) = token.call(data);
        require(success, errorMsg);

        if (returndata.length != 0) {
            require(abi.decode(returndata, (bool)), errorMsg);
        }
    }

    function _underlyingBalance()
        internal
        view
        returns (uint256)
    {
        return IERC20(loanTokenAddress).balanceOf(address(this));
    }

    /* Internal View functions */

    function _tokenPrice(
        uint256 assetSupply)
        internal
        view
        returns (uint256)
    {
        uint256 totalTokenSupply = totalSupply_;

        return totalTokenSupply != 0 ?
            assetSupply
                .mul(10**18)
                .div(totalTokenSupply) : initialPrice;
    }

    function _avgBorrowInterestRate(
        uint256 assetBorrow)
        internal
        view
        returns (uint256)
    {
        if (assetBorrow != 0) {
            (uint256 interestOwedPerDay,) = _getAllInterest();
            return interestOwedPerDay
                .mul(10**20)
                .div(assetBorrow)
                .mul(365);
        }
    }

    // next supply interest adjustment
    function _supplyInterestRate(
        uint256 assetBorrow,
        uint256 assetSupply)
        public
        view
        returns (uint256)
    {
        if (assetBorrow != 0 && assetSupply >= assetBorrow) {
            return _avgBorrowInterestRate(assetBorrow)
                .mul(_utilizationRate(assetBorrow, assetSupply))
                .mul(SafeMath.sub(10**20, ProtocolLike(pfiContractAddress).lendingFeePercent()))
                .div(10**40);
        }
    }

    function _nextBorrowInterestRate(
        uint256 borrowAmount)
        internal
        view
        returns (uint256)
    {
        uint256 interestUnPaid;
        if (borrowAmount != 0) {
            if (lastSettleTime_ != uint88(block.timestamp)) {
                (,interestUnPaid) = _getAllInterest();
            }

            uint256 balance = _underlyingBalance()
                .add(interestUnPaid);
            if (borrowAmount > balance) {
                borrowAmount = balance;
            }
        }

        return _nextBorrowInterestRate2(
            borrowAmount,
            _totalAssetSupply(interestUnPaid)
        );
    }

    function _nextBorrowInterestRate2(
        uint256 newBorrowAmount,
        uint256 assetSupply)
        internal
        view
        returns (uint256 nextRate)
    {
        uint256 utilRate = _utilizationRate(
            totalAssetBorrow().add(newBorrowAmount),
            assetSupply
        );

        uint256 thisMinRate;
        uint256 thisMaxRate;
        uint256 thisBaseRate = baseRate;
        uint256 thisRateMultiplier = rateMultiplier;
        uint256 thisTargetLevel = targetLevel;
        uint256 thisKinkLevel = kinkLevel;
        uint256 thisMaxScaleRate = maxScaleRate;

        if (utilRate < thisTargetLevel) {
            // target targetLevel utilization when utilization is under targetLevel
            utilRate = thisTargetLevel;
        }

        if (utilRate > thisKinkLevel) {
            // scale rate proportionally up to 100%
            uint256 thisMaxRange = WEI_PERCENT_PRECISION - thisKinkLevel; // will not overflow

            utilRate -= thisKinkLevel;
            if (utilRate > thisMaxRange)
                utilRate = thisMaxRange;

            thisMaxRate = thisRateMultiplier
                .add(thisBaseRate)
                .mul(thisKinkLevel)
                .div(WEI_PERCENT_PRECISION);

            nextRate = utilRate
                .mul(SafeMath.sub(thisMaxScaleRate, thisMaxRate))
                .div(thisMaxRange)
                .add(thisMaxRate);
        } else {
            nextRate = utilRate
                .mul(thisRateMultiplier)
                .div(WEI_PERCENT_PRECISION)
                .add(thisBaseRate);

            thisMinRate = thisBaseRate;
            thisMaxRate = thisRateMultiplier
                .add(thisBaseRate);

            if (nextRate < thisMinRate)
                nextRate = thisMinRate;
            else if (nextRate > thisMaxRate)
                nextRate = thisMaxRate;
        }
    }

    function _getAllInterest()
        internal
        view
        returns (
            uint256 interestOwedPerDay,
            uint256 interestUnPaid)
    {
        // interestPaid, interestPaidDate, interestOwedPerDay, interestUnPaid, interestFeePercent, principalTotal
        uint256 interestFeePercent;
        (,,interestOwedPerDay,interestUnPaid,interestFeePercent,) = ProtocolLike(pfiContractAddress).getLenderInterestData(
            address(this),
            loanTokenAddress
        );

        interestUnPaid = interestUnPaid
            .mul(SafeMath.sub(10**20, interestFeePercent))
            .div(10**20);
    }
    
    /**
     * @notice computes the loan size and interest rate
     * @param leverageAmount the leverage with 18 decimals
     * @param depositAmount the amount the user deposited in underlying loan tokens
     * */
    function _getMarginBorrowAmountAndRate(
        uint256 leverageAmount,
        uint256 depositAmount)
        internal
        view
        returns (uint256 borrowAmount, uint256 interestRate)
    {
        uint256 loanSizeBeforeInterest = depositAmount.mul(leverageAmount).div(10**18);
        //mathematical imperfection. we calculate the interest rate based on the loanSizeBeforeInterest, but 
        //the actual borrowed amount will be bigger.
        interestRate = _nextBorrowInterestRate2(loanSizeBeforeInterest, _totalAssetSupply(0));
        // assumes that loan, collateral, and interest token are the same
        borrowAmount = _adjustLoanSize(interestRate, 1 days, loanSizeBeforeInterest);
    }

    function _totalAssetSupply(
        uint256 interestUnPaid)
        internal
        view
        returns (uint256 assetSupply)
    {
        if (totalSupply_ != 0) {
            uint256 assetsBalance = _flTotalAssetSupply; // temporary locked totalAssetSupply during a flash loan transaction
            if (assetsBalance == 0) {
                assetsBalance = _underlyingBalance()
                    .add(totalAssetBorrow());
            }

            return assetsBalance
                .add(interestUnPaid);
        }
    }
    
    function toggleFunctionPause(bool isPaused) public onlyAdmin {
        if(isPaused) {
            _pause();
        } else {
            _unpause();
        }
    }
    /**
     * used to read externally from the smart contract to see if a function is paused
     * returns a bool
     * */
    function checkPause() public view returns (bool isPaused){
       isPaused = paused(); 
    }
    
    /**
     * @notice adjusts the loan size to make sure the expected exposure remains after prepaying the interest
     * @dev loanSizeWithInterest = loanSizeBeforeInterest * 100 / (100 - interestForDuration)
     * @param interestRate the interest rate to pay on the position
     * @param maxDuration the maximum duration of the position (until rollover)
     * @param loanSizeBeforeInterest the loan size before interest is added 
     * */
    function _adjustLoanSize(
        uint256 interestRate,
        uint256 maxDuration,
        uint256 loanSizeBeforeInterest)
        internal
        pure
        returns (uint256 loanSizeWithInterest)
    {
        uint256 interestForDuration = interestRate.mul(maxDuration).div(365 days);
        uint256 divisor = uint256(10**20).sub(interestForDuration);
        loanSizeWithInterest = loanSizeBeforeInterest.mul(10**20).div(divisor);
    }

    function _utilizationRate(
        uint256 assetBorrow,
        uint256 assetSupply)
        internal
        pure
        returns (uint256)
    {
        if (assetBorrow != 0 && assetSupply != 0) {
            // U = total_borrow / total_supply
            return assetBorrow
                .mul(10**20)
                .div(assetSupply);
        }
    }
    
    
}