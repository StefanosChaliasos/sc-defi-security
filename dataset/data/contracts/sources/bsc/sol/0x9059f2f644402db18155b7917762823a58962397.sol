// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




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
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}






/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}



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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}



// solhint-disable-next-line compiler-version





/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}




/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}



interface IMerlinMinter {
    function isMinter(address) view external returns(bool);
    function amountMerlinToMint(uint bnbProfit) view external returns(uint);
    function withdrawalFee(uint amount, uint depositedAt) view external returns(uint);
    function performanceFee(uint profit) view external returns(uint);
    function mintFor(address flip, uint _withdrawalFee, uint _performanceFee, address to, uint depositedAt) external payable;

    function merlinPerProfitBNB() view external returns(uint);
    function WITHDRAWAL_FEE_FREE_PERIOD() view external returns(uint);
    function WITHDRAWAL_FEE() view external returns(uint);

    function setMinter(address minter, bool canMint) external;

    function mintGov(uint amount) external;

    // V2 functions
    function mint(uint amount) external;
    function safeMerlinTransfer(address to, uint256 amount) external;
}












/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}














abstract contract PausableUpgradeable is OwnableUpgradeable {
    uint public lastPauseTime;
    bool public paused;

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "PausableUpgradeable: cannot be performed while the contract is paused");
        _;
    }

    function __PausableUpgradeable_init() internal initializer {
        __Ownable_init();
        require(owner() != address(0), "PausableUpgradeable: owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused == paused) {
            return;
        }

        paused = _paused;
        if (paused) {
            lastPauseTime = now;
        }

        emit PauseChanged(paused);
    }
    uint256[50] private __gap;
}






contract WhitelistUpgradeable is OwnableUpgradeable {
    mapping (address => bool) private _whitelist;
    bool private _disable;                      // default - true means whitelist feature is disabled.

    event Whitelisted(address indexed _address, bool whitelist);
    event EnableWhitelist();
    event DisableWhitelist();

    modifier onlyWhitelisted {
        require(_disable || _whitelist[msg.sender], "Whitelist: caller is not on the whitelist");
        _;
    }

    function __WhitelistUpgradeable_init() internal initializer {
        __Ownable_init();
    }

    function isWhitelist(address _address) public view returns(bool) {
        return _whitelist[_address];
    }

    function setWhitelist(address _address, bool _on) external onlyOwner {
        _whitelist[_address] = _on;

        emit Whitelisted(_address, _on);
    }

    function disableWhitelist(bool disable) external onlyOwner {
        _disable = disable;
        if (disable) {
            emit DisableWhitelist();
        } else {
            emit EnableWhitelist();
        }
    }

    uint256[49] private __gap;
}






/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}











/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}




interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPCSRouterLike {
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata, address to, uint256 deadline) external;
}

interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function totalSupply() external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract SwapUtils is OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 constant _DECIMAL = 1e18;
    address public  WRAPPED_NATIVE_TOKEN;


    function initialize(
        address _FACTORY, // pancake: 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73, ape: 0x0841BD0B734E4F5853f0dD8d7Ea041c241fb0Da6
        address _ROUTER, // pancake: 0x10ED43C718714eb63d5aA57B78B54704E256024E, ape: 0xC0788A3aD43d79aa53B09c2EaCc313A787d1d607
        address _WRAPPED_NATIVE_TOKEN // 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    ) external initializer {

        FACTORY = _FACTORY;
        PCS_LIKE_ROUTER = _ROUTER;
        WRAPPED_NATIVE_TOKEN = _WRAPPED_NATIVE_TOKEN;
        safeSwapThreshold = 20;
        __Ownable_init();

    }

    // --------------------------------------------------------------
    // Misc
    // --------------------------------------------------------------

    address public  FACTORY;
    uint256 public safeSwapThreshold;

    function updateSafeSwapThreshold(uint256 threshold) external onlyOwner {
        safeSwapThreshold = threshold;
    }

    function tokenPriceInBNB(address _token, uint256 amount) view external returns(uint256) {
        address pair = IPancakeFactory(FACTORY).getPair(_token, address(WRAPPED_NATIVE_TOKEN));
        if (pair == address(0)) return 0;
        if (IPancakePair(pair).totalSupply() == 0) return 0;

        (uint reserve0, uint reserve1, ) = IPancakePair(pair).getReserves();

        if (IPancakePair(pair).token0() == address(WRAPPED_NATIVE_TOKEN)) {
            return amount.mul(_DECIMAL).mul(reserve0).div(reserve1).div(_DECIMAL);
        } else {
            return amount.mul(_DECIMAL).mul(reserve1).div(reserve0).div(_DECIMAL);
        }
    }

    function checkNeedSwap(address _token, uint256 amount) view external returns (bool) {
        if (_token == WRAPPED_NATIVE_TOKEN) return false;

        address pair = IPancakeFactory(FACTORY).getPair(_token, address(WRAPPED_NATIVE_TOKEN));
        if (pair == address(0)) return false;
        if (IPancakePair(pair).totalSupply() == 0) return false;

        (uint reserve0, uint reserve1, ) = IPancakePair(pair).getReserves();

        if (IPancakePair(pair).token0() == _token) {
            return reserve0 > amount.mul(safeSwapThreshold);
        } else {
            return reserve1 > amount.mul(safeSwapThreshold);
        }
    }

    // --------------------------------------------------------------
    // Token swap
    // --------------------------------------------------------------

    address public  PCS_LIKE_ROUTER;

    function swap(address tokenA, address tokenB, uint256 amount) external returns (uint256) {
        if (amount <= 0) {
            return 0;
        }

        IERC20Upgradeable(tokenA).safeTransferFrom(msg.sender, address(this), amount);
        IERC20Upgradeable(tokenA).safeApprove(PCS_LIKE_ROUTER, 0);
        IERC20Upgradeable(tokenA).safeApprove(PCS_LIKE_ROUTER, amount);

        address[] memory path;
        if (tokenA == WRAPPED_NATIVE_TOKEN || tokenB == WRAPPED_NATIVE_TOKEN) {
            path = new address[](2);
            path[0] = tokenA;
            path[1] = tokenB;
        } else {
            path = new address[](3);
            path[0] = tokenA;
            path[1] = WRAPPED_NATIVE_TOKEN;
            path[2] = tokenB;
        }

        uint256 balanceBefore = IERC20Upgradeable(tokenB).balanceOf(address(this));

        IPCSRouterLike(PCS_LIKE_ROUTER).swapExactTokensForTokens(
            amount,
            uint256(0),
            path,
            address(this),
            block.timestamp.add(1800)
        );
        uint256 exchangeAmount = IERC20Upgradeable(tokenB).balanceOf(address(this)).sub(balanceBefore);
        IERC20Upgradeable(tokenB).safeApprove(msg.sender, 0);
        IERC20Upgradeable(tokenB).safeApprove(msg.sender, exchangeAmount);

        return exchangeAmount;
    }
}



pragma experimental ABIEncoderV2;





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IMerlinStrategy {
    function totalShares() external view returns (uint256);
    function earnedOf(address account) external view returns (uint256);
    function _underlyingShareAmount() external view returns (uint256);
    function totalBalance() external view returns(uint256);
    function STAKING_TOKEN() external view returns (address);
}

interface IMerlinStrategyWithEmergency {
    function IS_EMERGENCY_MODE() external returns (bool);
}

interface IFairLaunchV1 {
    // Data structure
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 bonusDebt;
        address fundedBy;
    }
    struct PoolInfo {
        address stakeToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accAlpacaPerShare;
        uint256 accAlpacaPerShareTilBonusEnd;
    }

    // Information query functions
    function alpacaPerBlock() external view returns (uint256);
    function totalAllocPoint() external view returns (uint256);
    function poolInfo(uint256 pid) external view returns (IFairLaunchV1.PoolInfo memory);
    function userInfo(uint256 pid, address user) external view returns (IFairLaunchV1.UserInfo memory);
    function poolLength() external view returns (uint256);

    // OnlyOwner functions
    function setAlpacaPerBlock(uint256 _alpacaPerBlock) external;
    function setBonus(uint256 _bonusMultiplier, uint256 _bonusEndBlock, uint256 _bonusLockUpBps) external;
    function manualMint(address _to, uint256 _amount) external;
    function addPool(uint256 _allocPoint, address _stakeToken, bool _withUpdate) external;
    function setPool(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external;

    // User's interaction functions
    function pendingAlpaca(uint256 _pid, address _user) external view returns (uint256);
    function updatePool(uint256 _pid) external;
    function deposit(address _for, uint256 _pid, uint256 _amount) external;
    function withdraw(address _for, uint256 _pid, uint256 _amount) external;
    function withdrawAll(address _for, uint256 _pid) external;
    function harvest(uint256 _pid) external;
}
interface IVault{
    function config() external view returns (address);
}

interface IVaultConfig {
    /// @dev Return minimum BaseToken debt size per position.
    function minDebtSize() external view returns (uint256);

    /// @dev Return the interest rate per second, using 1e18 as denom.
    function getInterestRate(uint256 debt, uint256 floating) external view returns (uint256);

    /// @dev Return the address of wrapped native token.
    function getWrappedNativeAddr() external view returns (address);

    /// @dev Return the address of wNative relayer.
    function getWNativeRelayer() external view returns (address);

    /// @dev Return the address of fair launch contract.
    function getFairLaunchAddr() external view returns (address);

    /// @dev Return the bps rate for reserve pool.
    function getReservePoolBps() external view returns (uint256);

    /// @dev Return the bps rate for Avada Kill caster.
    function getKillBps() external view returns (uint256);

    /// @dev Return whether the given address is a worker.
    function isWorker(address worker) external view returns (bool);

    /// @dev Return whether the given worker accepts more debt. Revert on non-worker.
    function acceptDebt(address worker) external view returns (bool);

    /// @dev Return the work factor for the worker + BaseToken debt, using 1e4 as denom. Revert on non-worker.
    function workFactor(address worker, uint256 debt) external view returns (uint256);

    /// @dev Return the kill factor for the worker + BaseToken debt, using 1e4 as denom. Revert on non-worker.
    function killFactor(address worker, uint256 debt) external view returns (uint256);
}
interface IAlpacaFairLaunch {
    function deposit(
        address _for,
        uint256 _pid,
        uint256 _amount
    ) external;

    function withdraw(
        address _for,
        uint256 _pid,
        uint256 _amount
    ) external;

    function withdrawAll(address _for, uint256 _pid) external;

    function emergencyWithdraw(uint256 _pid) external;

    // Harvest ALPACAs earn from the pool.
    function harvest(uint256 _pid) external;

    function pendingAlpaca(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user)
    external
    view
    returns (
        uint256 amount,
        uint256 rewardDebt,
        uint256 bonusDebt,
        uint256 fundedBy
    );
}
interface IAlpacaVault {
    // @dev Add more token to the lending pool. Hope to get some good returns.
    function deposit(uint256 amountToken) external payable;

    // @dev Withdraw token from the lending and burning ibToken.
    function withdraw(uint256 share) external;

    function totalToken() external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

interface IAlpacaToken {
    function canUnlockAmount(address _account) external view returns (uint256);

    function unlock() external;

    // @dev move ALPACAs with its locked funds to another account
    function transferAll(address _to) external;
}


interface PriceOracle {
    /// @dev Return the wad price of token0/token1, multiplied by 1e18
    /// NOTE: (if you have 1 token0 how much you can sell it for token1)
    function getPrice(address token0, address token1)
    external view
    returns (uint256 price, uint256 lastUpdate);
}

abstract contract BaseMerlinStrategy is IMerlinStrategy ,ReentrancyGuardUpgradeable,PausableUpgradeable, WhitelistUpgradeable{
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 constant _DECIMAL = 1e18;

    IMerlinMinter public merlinMinter;

    /// @dev total shares of this strategy
    uint256 public override totalShares;

    /// @dev user share
    mapping (address => uint256) internal userShares;

    /// @dev user principal
    mapping (address => uint256) internal userPrincipal;

    /// @dev Threshold for swap reward token to staking token for save gas fee
    uint256 public rewardTokenSwapThreshold;

    /// @dev Threshold for reinvest to save gas fee
    uint256 public stakingTokenReinvestThreshold;

    /// @dev Utils for swap token and get price in BNB
    address public SWAP_UTILS;

    /// @dev For reduce amount which is toooooooo small
    uint256 constant DUST = 1000;

    /// @dev Will be WBNB address in BSC Network
    address public constant WRAPPED_NATIVE_TOKEN = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    /// @dev Staking token
    address public  override STAKING_TOKEN;

    mapping (address => uint) internal _depositedAt;

    uint256[49] private __gap;

    function __Base_init(
        address _SWAP_UTILS
    ) internal initializer {

        SWAP_UTILS = _SWAP_UTILS;
        __ReentrancyGuard_init();
        __WhitelistUpgradeable_init();
        __PausableUpgradeable_init();
        rewardTokenSwapThreshold = 1e16;
        stakingTokenReinvestThreshold = 1e16;
        IS_EMERGENCY_MODE = false;

    }

    function depositedAt(address account) external view  returns (uint) {
        return _depositedAt[account];
    }

    function updateThresholds(uint256 _rewardTokenSwapThreshold, uint256 _stakingTokenReinvestThreshold) external onlyOwner {

        rewardTokenSwapThreshold = _rewardTokenSwapThreshold;
        stakingTokenReinvestThreshold = _stakingTokenReinvestThreshold;

    }

    // --------------------------------------------------------------
    // Misc
    // --------------------------------------------------------------

    function approveToken(address token, address to, uint256 amount) internal {

        if (IERC20Upgradeable(token).allowance(address(this), to) < amount) {
            IERC20Upgradeable(token).safeApprove(to, 0);
            IERC20Upgradeable(token).safeApprove(to, uint256(~0));
        }

    }

    function _swap(address tokenA, address tokenB, uint256 amount) internal returns (uint256) {

        approveToken(tokenA, SWAP_UTILS, amount);
        uint256 tokenReceived = SwapUtils(SWAP_UTILS).swap(tokenA, tokenB, amount);
        IERC20Upgradeable(tokenB).transferFrom(SWAP_UTILS, address(this), tokenReceived);
        return tokenReceived;

    }

    // --------------------------------------------------------------
    // User Read interface (shares and principal)
    // --------------------------------------------------------------

    function sharesOf(address account) public  view returns (uint256) {
        return userShares[account];
    }

    function principalOf(address account) public view returns (uint256) {
        return userPrincipal[account];
    }

    // --------------------------------------------------------------
    // User Read Interface
    // --------------------------------------------------------------

    function totalBalance() public override view returns(uint256) {
        return _underlyingWantTokenAmount();
    }

    function balanceOf(address account) public view returns(uint256) {

        if (totalShares == 0) return 0;
        if (sharesOf(account) == 0) return 0;

        return _underlyingWantTokenAmount().mul(sharesOf(account)).div(totalShares);
    }

    function earnedOf(address account) public view override returns (uint256) {

        if (balanceOf(account) >= principalOf(account)) {
            return balanceOf(account).sub(principalOf(account));
        } else {
            return 0;
        }

    }

    // --------------------------------------------------------------
    // User Write Interface
    // --------------------------------------------------------------

    function harvest() external nonEmergency nonReentrant {
        _harvest();
    }

    function withdraw(uint256 principalAmount) external  nonEmergency nonReentrant {
        _withdraw(principalAmount);
    }

    function withdrawAll() external virtual  nonEmergency nonReentrant {

        require(userShares[msg.sender] > 0, "MerlinStrategy: user without shares");

        uint256 shares = sharesOf(msg.sender);
        uint256 principal = principalOf(msg.sender);
        uint depositTimestamp = _depositedAt[msg.sender];
        // withdraw from under contract
        uint amount = balanceOf(msg.sender);

        userShares[msg.sender] = 0;
        userPrincipal[msg.sender] = 0;
        delete _depositedAt[msg.sender];
        totalShares = totalShares.sub(shares);

        // withdraw from under contract
        amount = _withdrawUnderlying(amount);
        uint profit = amount > principal ? amount.sub(principal) : 0;
        uint withdrawalFee = canMint() ? merlinMinter.withdrawalFee(principal, depositTimestamp) : 0;
        uint performanceFee = canMint() ? merlinMinter.performanceFee(profit) : 0;
        if (withdrawalFee.add(performanceFee) > DUST) {
            approveToken(STAKING_TOKEN, address(merlinMinter), withdrawalFee.add(performanceFee));
            merlinMinter.mintFor(STAKING_TOKEN, withdrawalFee, performanceFee, msg.sender, depositTimestamp);
            if (performanceFee > 0) {
                emit ProfitPaid(msg.sender, profit, performanceFee);
            }
            amount = amount.sub(withdrawalFee).sub(performanceFee);
        }
        _sendToken(msg.sender, amount);

        emit WithdrawAll(msg.sender, amount, shares);
    }

    function getReward() external nonEmergency nonReentrant {
        _getRewards();
    }

    // --------------------------------------------------------------
    // Deposit and withdraw
    // --------------------------------------------------------------

    function _deposit(uint256 wantTokenAmount) internal {

        require(wantTokenAmount > DUST, "MerlinStrategy: amount toooooo small");

        _receiveToken(msg.sender, wantTokenAmount);

        // save current underlying want token amount for caluclate shares
        uint underlyingWantTokenAmountBeforeEnter = _underlyingWantTokenAmount();

        // receive token and deposit into underlying contract
        uint256 wantTokenAdded = _depositUnderlying(wantTokenAmount);

        // calculate shares
        uint256 sharesAdded = 0;
        if (totalShares == 0) {
            sharesAdded = wantTokenAdded;
        } else {
            sharesAdded = totalShares
                .mul(wantTokenAdded).mul(_DECIMAL)
                .div(underlyingWantTokenAmountBeforeEnter).div(_DECIMAL);
        }

        // add our shares
        totalShares = totalShares.add(sharesAdded);
        userShares[msg.sender] = userShares[msg.sender].add(sharesAdded);

        // add principal in real want token amount
        userPrincipal[msg.sender] = userPrincipal[msg.sender].add(wantTokenAdded);
        _depositedAt[msg.sender] = block.timestamp;

        _tryReinvest();

        emit Deposit(msg.sender, wantTokenAmount, wantTokenAdded, sharesAdded);
    }

    function _withdraw(uint256 wantTokenAmount) internal {

        require(userShares[msg.sender] > 0, "MerlinStrategy: user without shares");

        // calculate max amount
        uint256 wantTokenRemoved = Math.min(
            userPrincipal[msg.sender],
            wantTokenAmount
        );

        // reduce principal dust
        if (userPrincipal[msg.sender].sub(wantTokenRemoved) < DUST) {
            wantTokenRemoved = userPrincipal[msg.sender];
        }

        // calculate shares
        uint256 shareRemoved = Math.min(
            userShares[msg.sender],
            wantTokenRemoved
                .mul(totalShares).mul(_DECIMAL)
                .div(_underlyingWantTokenAmount()).div(_DECIMAL)
        );

        // reduce share dust
        if (userShares[msg.sender].sub(shareRemoved) < DUST) {
            shareRemoved = userShares[msg.sender];
        }

        // remove our shares
        totalShares = totalShares.sub(shareRemoved);
        userShares[msg.sender] = userShares[msg.sender].sub(shareRemoved);

        // remove principal
        // most time withdrawnWantTokenAmount = wantTokenAmount except underlying has withdraw fee
        userPrincipal[msg.sender] = userPrincipal[msg.sender].sub(wantTokenRemoved);

        // withdraw from under contract
        uint256 withdrawnWantTokenAmount = _withdrawUnderlying(wantTokenRemoved);

        withdrawnWantTokenAmount = withdrawnWantTokenAmount.sub(_addProfitReward(msg.sender, withdrawnWantTokenAmount, true));

        _sendToken(msg.sender, withdrawnWantTokenAmount);

        _tryReinvest();

        emit Withdraw(msg.sender, wantTokenAmount, withdrawnWantTokenAmount, shareRemoved);
    }

    function _getRewards() internal {
        // get current earned
        uint earnedWantTokenAmount = earnedOf(msg.sender);

        if (earnedWantTokenAmount > 0) {
            // calculate shares
            uint256 shareRemoved = Math.min(
                userShares[msg.sender],
                earnedWantTokenAmount
                    .mul(totalShares).mul(_DECIMAL)
                    .div(_underlyingWantTokenAmount()).div(_DECIMAL)
            );

            // if principal already empty, take all shares
            if (userPrincipal[msg.sender] == 0) {
                shareRemoved = userShares[msg.sender];
            }

            // remove shares
            totalShares = totalShares.sub(shareRemoved);
            userShares[msg.sender] = userShares[msg.sender].sub(shareRemoved);

            // withdraw
            earnedWantTokenAmount = _withdrawUnderlying(earnedWantTokenAmount);

            // take some for profit reward
            earnedWantTokenAmount = earnedWantTokenAmount.sub(_addProfitReward(msg.sender, earnedWantTokenAmount,false));

            // transfer
            if (earnedWantTokenAmount > 0) {
                _sendToken(msg.sender, earnedWantTokenAmount);
            }

            _tryReinvest();

            emit GetReward(msg.sender, earnedWantTokenAmount, shareRemoved);
        } else {
            _harvest();
        }

    }

    function _addProfitReward(address userAddress, uint256 amount, bool isWithdraw) internal virtual returns (uint256) {

        if (canMint()) {

            uint depositTimestamp = _depositedAt[userAddress];

            if(isWithdraw){
                amount = merlinMinter.withdrawalFee(amount, depositTimestamp);
            }else{
                amount = merlinMinter.performanceFee(amount);
            }
            if (amount > DUST) {
                approveToken(STAKING_TOKEN, address(merlinMinter), amount);
                isWithdraw ? merlinMinter.mintFor(STAKING_TOKEN, amount, 0, msg.sender, depositTimestamp):merlinMinter.mintFor(STAKING_TOKEN, 0, amount, msg.sender, depositTimestamp);
                return amount;
            }
        }

        return 0;
    }

    // --------------------------------------------------------------
    // Interactive with under contract
    // --------------------------------------------------------------

    function _underlyingWantTokenAmount() public virtual view returns (uint256);
    function _receiveToken(address sender, uint256 amount) internal virtual;
    function _sendToken(address receiver, uint256 amount) internal virtual;
    function _tryReinvest() internal virtual;
    function _depositUnderlying(uint256 wantTokenAmount) internal virtual returns (uint256);
    function _withdrawUnderlying(uint256 wantTokenAmount) internal virtual returns (uint256);
    function _swapRewardTokenToWBNB(uint256 amount) internal virtual returns (uint256);
    function _harvest() internal virtual;

    // --------------------------------------------------------------
    // Call Minter
    // --------------------------------------------------------------

    function setMinter(address _minter) external onlyOwner {
        merlinMinter = IMerlinMinter(_minter);
    }

    function canMint() internal view returns (bool) {
        return address(merlinMinter) != address(0) && merlinMinter.isMinter(address(this));
    }

    function minter() external view  returns (address) {
        return canMint() ? address(merlinMinter) : address(0);
    }

    // --------------------------------------------------------------
    // !! Emergency !!
    // --------------------------------------------------------------

    bool public  IS_EMERGENCY_MODE;

    modifier nonEmergency() {
        require(IS_EMERGENCY_MODE == false, "MerlinStrategy: emergency mode.");
        _;
    }

    modifier onlyEmergency() {
        require(IS_EMERGENCY_MODE == true, "MerlinStrategy: not emergency mode.");
        _;
    }

    function emergencyExit() external virtual;
    function emergencyWithdraw() external virtual;

    // --------------------------------------------------------------
    // Events
    // --------------------------------------------------------------
    event Deposit(address user, uint256 wantTokenAmount, uint wantTokenAdded, uint256 shares);
    event Withdraw(address user, uint256 wantTokenAmount, uint withdrawWantTokenAmount, uint256 shares);
    event WithdrawAll(address user, uint256 wantTokenAmount, uint256 shares);
    event Reinvest(address user, uint256 amount);
    event GetReward(address user, uint256 amount, uint256 shares);
    event ProfitPaid(address indexed user, uint256 profit, uint256 performanceFee);

}


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

library SafeToken {
  function safeTransferETH(address to, uint256 value) internal {
    // solhint-disable-next-line no-call-value
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, "SafeToken::safeTransferETH:: can't transfer");
  }
}

contract MerlinStrategyAlpacaBNB is BaseMerlinStrategy {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // --------------------------------------------------------------
    // Address
    // --------------------------------------------------------------

    /// @dev MasterChef address, for interactive underlying contract
    address public constant ALPACA_FAIR_LAUNCH = 0xA625AB01B08ce023B2a342Dbb12a16f2C8489A8F;

    /// @dev Pool ID in MasterChef
    uint256 public constant ALPACA_FAIR_LAUNCH_POOL_ID = 1;

    /// @dev Underlying reward token, ALPACA.
    address public  UNDERLYING_REWARD_TOKEN ;

    /// @dev Strategy address, for calculate want token amount in underlying contract
    address public constant ALPACA_VAULT = 0xd7D069493685A581d27824Fc46EdA46B7EfC0063;


    function initialize(
        address _SWAP_UTILS
    ) external initializer {

      __Base_init(_SWAP_UTILS);
      UNDERLYING_REWARD_TOKEN = 0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F;

    }

    // --------------------------------------------------------------
    // Misc
    // --------------------------------------------------------------

    modifier transferTokenToVault(uint256 value) {

        if (msg.value != 0) {
            require(value == msg.value, "Vault::transferTokenToVault:: value != msg.value");
            IWETH(WRAPPED_NATIVE_TOKEN).deposit{value: msg.value}();
        } else {
            IERC20Upgradeable(WRAPPED_NATIVE_TOKEN).safeTransferFrom(msg.sender, address(this), value);
        }
        _;

    }

    /// @dev Fallback function to accept ETH.
    receive() external payable {}

    // --------------------------------------------------------------
    // Current strategy info in under contract
    // --------------------------------------------------------------

    function _underlyingShareAmount() public view override returns (uint256) {

        (uint256 amount,,,) = IAlpacaFairLaunch(ALPACA_FAIR_LAUNCH).userInfo(ALPACA_FAIR_LAUNCH_POOL_ID, address(this));
        return amount;

    }

    function __underlyingWantTokenPerShares() public view returns (uint256) {

        uint256 totalSupply = IAlpacaVault(ALPACA_VAULT).totalSupply();
        if (totalSupply <= 0) return _DECIMAL;

        return IAlpacaVault(ALPACA_VAULT).totalToken()
            .mul(_DECIMAL)
            .div(totalSupply);

    }

    function _underlyingWantTokenAmount() public override view returns (uint256) {
        return _underlyingShareAmount().mul(__underlyingWantTokenPerShares()).div(_DECIMAL);
    }

    // --------------------------------------------------------------
    // User Write Interface
    // --------------------------------------------------------------

    function deposit(uint256 wantTokenAmount) external payable nonEmergency nonReentrant transferTokenToVault(wantTokenAmount) {
        _deposit(wantTokenAmount);
    }

    // --------------------------------------------------------------
    // Interactive with under contract
    // --------------------------------------------------------------

    function _depositUnderlying(uint256 wBNBAmount) internal override returns (uint256) {
        // 1. to vault
        uint256 ibBNBBefore = IERC20Upgradeable(ALPACA_VAULT).balanceOf(address(this));
        approveToken(WRAPPED_NATIVE_TOKEN, ALPACA_VAULT, wBNBAmount);
        IAlpacaVault(ALPACA_VAULT).deposit(wBNBAmount);
        uint256 ibBNBAmount = IERC20Upgradeable(ALPACA_VAULT).balanceOf(address(this)).sub(ibBNBBefore);
        // 2. to fair launch
        if (ibBNBAmount > 0) {
            approveToken(ALPACA_VAULT, ALPACA_FAIR_LAUNCH, ibBNBAmount);
            IAlpacaFairLaunch(ALPACA_FAIR_LAUNCH).deposit(address(this), ALPACA_FAIR_LAUNCH_POOL_ID, ibBNBAmount);
        }
        return ibBNBAmount.mul(__underlyingWantTokenPerShares()).div(_DECIMAL);
    }

    function _withdrawUnderlying(uint256 wantTokenAmount) internal override returns (uint256) {

        uint256 masterChefShares = wantTokenAmount.mul(_DECIMAL).div(__underlyingWantTokenPerShares());

        // 1. from fair launch
        uint256 ibBNBBefore = IERC20Upgradeable(ALPACA_VAULT).balanceOf(address(this));
        IAlpacaFairLaunch(ALPACA_FAIR_LAUNCH).withdraw(address(this), ALPACA_FAIR_LAUNCH_POOL_ID, masterChefShares);
        uint256 ibBNBAmount = IERC20Upgradeable(ALPACA_VAULT).balanceOf(address(this)).sub(ibBNBBefore);

        // 2. from vault
        uint256 BNBBefore = address(this).balance;
        IAlpacaVault(ALPACA_VAULT).withdraw(ibBNBAmount);
        uint256 BNBAmount = address(this).balance.sub(BNBBefore);

        return BNBAmount;

    }

    function withdrawAll() external override nonEmergency nonReentrant {

        require(userShares[msg.sender] > 0, "MerlinStrategy: user without shares");
        uint256 shares = sharesOf(msg.sender);
        uint256 principal = principalOf(msg.sender);
        uint depositTimestamp = _depositedAt[msg.sender];
        // withdraw from under contract
        uint amount = balanceOf(msg.sender);

        userShares[msg.sender] = 0;
        userPrincipal[msg.sender] = 0;
        delete _depositedAt[msg.sender];
        totalShares = totalShares.sub(shares);

        // withdraw from under contract
        amount = _withdrawUnderlying(amount);
        uint profit = amount > principal ? amount.sub(principal) : 0;
        uint withdrawalFee = canMint() ? merlinMinter.withdrawalFee(principal, depositTimestamp) : 0;
        uint performanceFee = canMint() ? merlinMinter.performanceFee(profit) : 0;

        uint  withdrawalFee1 = _swapRewardTokenToWBNB(withdrawalFee);
        uint performanceFee1 = _swapRewardTokenToWBNB(performanceFee);

        if (withdrawalFee1.add(performanceFee1) > DUST) {

            approveToken(WRAPPED_NATIVE_TOKEN, address(merlinMinter), withdrawalFee1.add(performanceFee1));
            merlinMinter.mintFor(WRAPPED_NATIVE_TOKEN, withdrawalFee1, performanceFee1, msg.sender, depositTimestamp);
            if (performanceFee1 > 0) {
                emit ProfitPaid(msg.sender, profit, performanceFee);
            }
            amount = amount.sub(withdrawalFee).sub(performanceFee);
        }

        _sendToken(msg.sender, amount);

        emit WithdrawAll(msg.sender, amount, shares);

    }

    function _receiveToken(address sender, uint256 amount) internal override {
        // do nothing because BNB already received
    }

    function _sendToken(address receiver, uint256 amount) internal override {
        SafeToken.safeTransferETH(receiver, amount);
    }

    function _harvest() internal override {
        // if no token staked in underlying contract
        if (_underlyingWantTokenAmount() <= 0) return;

        IAlpacaFairLaunch(ALPACA_FAIR_LAUNCH).harvest(ALPACA_FAIR_LAUNCH_POOL_ID);

        _tryReinvest();
    }

    function _tryReinvest() internal override {

        if (IAlpacaToken(UNDERLYING_REWARD_TOKEN).canUnlockAmount(address(this)) > rewardTokenSwapThreshold) {
            IAlpacaToken(UNDERLYING_REWARD_TOKEN).unlock();
        }

        // get current reward token amount
        uint256 rewardTokenAmount = IERC20Upgradeable(UNDERLYING_REWARD_TOKEN).balanceOf(address(this));

        // if token amount too small, wait for save gas fee
        if (rewardTokenAmount < rewardTokenSwapThreshold) return;

        // swap reward token to staking token
        uint256 stakingTokenAmount = _swap(UNDERLYING_REWARD_TOKEN, WRAPPED_NATIVE_TOKEN, rewardTokenAmount);

        // get current staking token amount
        stakingTokenAmount = IERC20Upgradeable(WRAPPED_NATIVE_TOKEN).balanceOf(address(this));

        // if token amount too small, wait for save gas fee
        if (stakingTokenAmount < stakingTokenReinvestThreshold) return;

        // reinvest
        _depositUnderlying(stakingTokenAmount);

        emit Reinvest(msg.sender, stakingTokenAmount);

    }

    function _addProfitReward(address userAddress, uint256 amount, bool isWithdraw) internal override returns (uint256) {

        if (canMint()) {

            uint depositTimestamp = _depositedAt[userAddress];

            if(isWithdraw){
                amount = merlinMinter.withdrawalFee(amount, depositTimestamp);
            }else{
                amount = merlinMinter.performanceFee(amount);
            }

            uint256 wBNBExchanged = _swapRewardTokenToWBNB(amount);

            if (wBNBExchanged > DUST) {

                approveToken(WRAPPED_NATIVE_TOKEN, address(merlinMinter), wBNBExchanged);
                isWithdraw ? merlinMinter.mintFor(WRAPPED_NATIVE_TOKEN, amount, 0, msg.sender, depositTimestamp):merlinMinter.mintFor(WRAPPED_NATIVE_TOKEN, 0, amount, msg.sender, depositTimestamp);

                return amount;

            }
        }

        return 0;
    }

    function _swapRewardTokenToWBNB(uint256 amount) internal override returns (uint256) {
        // exchange to wBNB
        uint256 wBNBBefore = IERC20Upgradeable(WRAPPED_NATIVE_TOKEN).balanceOf(address(this));
        IWETH(WRAPPED_NATIVE_TOKEN).deposit{value: amount}();
        uint256 wBNBExchanged = IERC20Upgradeable(WRAPPED_NATIVE_TOKEN).balanceOf(address(this)).sub(wBNBBefore);
        return wBNBExchanged;
    }


    // --------------------------------------------------------------
    // !! Emergency !!
    // --------------------------------------------------------------

    function emergencyExit() external override onlyOwner {

        IAlpacaFairLaunch(ALPACA_FAIR_LAUNCH).withdrawAll(address(this), ALPACA_FAIR_LAUNCH_POOL_ID);
        IAlpacaVault(ALPACA_VAULT).withdraw(IERC20Upgradeable(ALPACA_VAULT).balanceOf(address(this)));
        IS_EMERGENCY_MODE = true;

    }

    function emergencyWithdraw() external override onlyEmergency nonReentrant {

        uint256 shares = userShares[msg.sender];

        userShares[msg.sender] = 0;
        userPrincipal[msg.sender] = 0;
        delete _depositedAt[msg.sender];

        // withdraw from under contract
        uint256 currentBalance = address(this).balance;
        uint256 amount = currentBalance.mul(_DECIMAL).mul(shares).div(totalShares).div(_DECIMAL);
        totalShares = totalShares.sub(shares);

        SafeToken.safeTransferETH(msg.sender, amount);
    }


}



