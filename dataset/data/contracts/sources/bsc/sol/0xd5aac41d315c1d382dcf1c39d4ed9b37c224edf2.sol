// File: @pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol


pragma solidity ^0.6.12;

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
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
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
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: @pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol


pragma solidity ^0.6.12;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// File: @pancakeswap/pancake-swap-lib/contracts/utils/Address.sol


pragma solidity ^0.6.12;

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
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
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
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

// File: @pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol


pragma solidity ^0.6.12;




/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// File: @pancakeswap/pancake-swap-lib/contracts/GSN/Context.sol


pragma solidity ^0.6.12;

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
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol


pragma solidity ^0.6.12;


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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.6.12;


/*
 * @dev Implementation of the {IBEP20} interface.
 * This implementation is a copy of @pancakeswap/pancake-swap-lib/contracts/token/BEP20/BEP20.sol
 * with a burn supply management.
 */
contract UraniumBEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _burnSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function burnSupply() public view returns (uint256) {
        return _burnSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        _burnSupply = _burnSupply.add(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller"s allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance")
        );
    }
}


// File: contracts/UraniumMoneyPot.sol

/*
* This contract is used to collect sRADS stacking rewards from fee (like swap, deposit on pools or farms)
*/
contract UraniumMoneyPot is Ownable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;


    struct TokenPot {
        uint256 tokenAmount;
        uint256 accTokenPerShare;
        uint256 lastRewardBlock;
        uint256 lastUpdateTokenPotBlocks;
    }

    struct UserInfo {
        uint256 rewardDept;
        uint256 pending;
    }

    SRadsToken public sRads;

    uint256 public updateMoneyPotPeriodNbBlocks;
    uint256 public lastUpdateMoneyPotBlocks;
    uint256 public startBlock;

    // _token => user => rewardsDebt / pending
    mapping(address => mapping (address => UserInfo)) public sRadsHoldersRewardsInfo;
    // user => LastSRadsAmountSaved
    mapping (address => uint256) public sRadsHoldersInfo;

    address[] public registeredToken; // Should never be too weight !
    mapping (address => bool )  public tokenInitialized;

    address public masterUranium;
    address public feeManager;

    mapping (address => TokenPot) private _distributedMoneyPot;
    mapping (address => uint256 ) public pendingTokenAmount;
    mapping (address => uint256) public reserveTokenAmount;

    uint256 public lastSRadsSupply;

    constructor (SRadsToken _sRads, address _feeManager, address _masterUranium, uint256 _startBlock, uint256 _initialUpdateMoneyPotPeriodNbBlocks) public{
        updateMoneyPotPeriodNbBlocks = _initialUpdateMoneyPotPeriodNbBlocks;
        startBlock = _startBlock;
        lastUpdateMoneyPotBlocks = _startBlock;
        sRads = _sRads;
        masterUranium = _masterUranium;
        feeManager = _feeManager;
    }

    function distributedMoneyPot(address _token) external view returns (uint256 tokenAmount, uint256 accTokenPerShare, uint256 lastRewardBlock ){
        return (
            _distributedMoneyPot[_token].tokenAmount,
            _distributedMoneyPot[_token].accTokenPerShare,
            _distributedMoneyPot[_token].lastRewardBlock
        );
    }

    function getRegisteredTokenLength() external view returns (uint256){
        return registeredToken.length;
    }

    function getTokenAmountPotFromMoneyPot(address _token) external view returns (uint256 tokenAmount){
        return _distributedMoneyPot[_token].tokenAmount;
    }

    function tokenPerBlock(address _token) external view returns (uint256){
        return _distributedMoneyPot[_token].tokenAmount.div(updateMoneyPotPeriodNbBlocks);
    }

    function massUpdateMoneyPot() public {
        uint256 length = registeredToken.length;
        for (uint256 index = 0; index < length; ++index) {
            _updateTokenPot(registeredToken[index]);
        }
    }

    function updateCurrentMoneyPot(address _token) external{
        _updateTokenPot(_token);
    }

    function getMultiplier(uint256 _from, uint256 _to) internal pure returns (uint256){
        return _to.sub(_from);
    }

    function _updateTokenPot(address _token) internal {
        TokenPot storage tokenPot = _distributedMoneyPot[_token];
        if (block.number <= tokenPot.lastRewardBlock) {
            return;
        }

        if (lastSRadsSupply == 0) {
            tokenPot.lastRewardBlock = block.number;
            return;
        }

        if (block.number >= tokenPot.lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks)){
            if(tokenPot.tokenAmount > 0){
                uint256 multiplier = getMultiplier(tokenPot.lastRewardBlock, tokenPot.lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks));
                uint256 tokenRewardsPerBlock = tokenPot.tokenAmount.div(updateMoneyPotPeriodNbBlocks);
                tokenPot.accTokenPerShare = tokenPot.accTokenPerShare.add(tokenRewardsPerBlock.mul(multiplier).mul(1e12).div(lastSRadsSupply));
            }
            tokenPot.tokenAmount = pendingTokenAmount[_token];
            pendingTokenAmount[_token] = 0;
            tokenPot.lastRewardBlock = tokenPot.lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks);
            tokenPot.lastUpdateTokenPotBlocks = tokenPot.lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks);
            lastUpdateMoneyPotBlocks = tokenPot.lastUpdateTokenPotBlocks;

            if (block.number >= tokenPot.lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks)){
//                _updateTokenPot(_token);
                // If something bad happen in blockchain and moneyPot aren't able to be updated since
                // return here, will allow us to re-call updatePool manually, instead of directly doing it recursively here
                // which can cause too much gas error and so break all the MP contract
                return;
            }
        }
        if(tokenPot.tokenAmount > 0){
            uint256 multiplier = getMultiplier(tokenPot.lastRewardBlock, block.number);
            uint256 tokenRewardsPerBlock = tokenPot.tokenAmount.div(updateMoneyPotPeriodNbBlocks);
            tokenPot.accTokenPerShare = tokenPot.accTokenPerShare.add(tokenRewardsPerBlock.mul(multiplier).mul(1e12).div(lastSRadsSupply));
        }

        tokenPot.lastRewardBlock = block.number;

        if (block.number >= tokenPot.lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks)){
            lastUpdateMoneyPotBlocks = tokenPot.lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks);
        }
    }

    function pendingTokenRewardsAmount(address _token, address _user) external view returns (uint256){

        if(lastSRadsSupply == 0){
            return 0;
        }

        uint256 accTokenPerShare = _distributedMoneyPot[_token].accTokenPerShare;
        uint256 tokenReward = _distributedMoneyPot[_token].tokenAmount.div(updateMoneyPotPeriodNbBlocks);
        uint256 lastRewardBlock = _distributedMoneyPot[_token].lastRewardBlock;
        uint256 lastUpdateTokenPotBlocks = _distributedMoneyPot[_token].lastUpdateTokenPotBlocks;
        if (block.number >= lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks)){
            accTokenPerShare = (accTokenPerShare.add(
                    tokenReward.mul(getMultiplier(lastRewardBlock, lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks))
                ).mul(1e12).div(lastSRadsSupply)));
            lastRewardBlock = lastUpdateTokenPotBlocks.add(updateMoneyPotPeriodNbBlocks);
            tokenReward = pendingTokenAmount[_token].div(updateMoneyPotPeriodNbBlocks);
        }

        if (block.number > lastRewardBlock && lastSRadsSupply != 0 && tokenReward > 0) {
            accTokenPerShare = accTokenPerShare.add(
                    tokenReward.mul(getMultiplier(lastRewardBlock, block.number)
                ).mul(1e12).div(lastSRadsSupply));
        }
        return (sRads.balanceOf(_user).mul(accTokenPerShare).div(1e12).sub(sRadsHoldersRewardsInfo[_token][_user].rewardDept))
                    .add(sRadsHoldersRewardsInfo[_token][_user].pending);
    }

    function updateSRadsHolder(address _sRadsHolder) external {
        uint256 holderPreviousSRadsAmount = sRadsHoldersInfo[_sRadsHolder];
        uint256 holderBalance = sRads.balanceOf(_sRadsHolder);
        uint256 length = registeredToken.length;
        for (uint256 index = 0; index < length; ++index) {
            _updateTokenPot(registeredToken[index]);
            TokenPot storage tokenPot = _distributedMoneyPot[registeredToken[index]];
            if(holderPreviousSRadsAmount > 0 && tokenPot.accTokenPerShare > 0){
                uint256 pending = holderPreviousSRadsAmount.mul(tokenPot.accTokenPerShare).div(1e12).sub(sRadsHoldersRewardsInfo[registeredToken[index]][_sRadsHolder].rewardDept);
                if(pending > 0) {
                    if (_sRadsHolder == masterUranium) {
                        reserveTokenAmount[registeredToken[index]] = reserveTokenAmount[registeredToken[index]].add(pending);
                    }
                    else {
                        sRadsHoldersRewardsInfo[registeredToken[index]][_sRadsHolder].pending = sRadsHoldersRewardsInfo[registeredToken[index]][_sRadsHolder].pending.add(pending);
                    }
                }
            }
            sRadsHoldersRewardsInfo[registeredToken[index]][_sRadsHolder].rewardDept = holderBalance.mul(tokenPot.accTokenPerShare).div(1e12);
        }
        if (holderPreviousSRadsAmount > 0){
            lastSRadsSupply = lastSRadsSupply.sub(holderPreviousSRadsAmount);
        }
        lastSRadsSupply = lastSRadsSupply.add(holderBalance);
        sRadsHoldersInfo[_sRadsHolder] = holderBalance;
    }

    function harvestRewards(address _sRadsHolder) external {
        uint256 length = registeredToken.length;

        for (uint256 index = 0; index < length; ++index) {
            harvestReward(_sRadsHolder, registeredToken[index]);
        }
    }

    function harvestReward(address _sRadsHolder, address _token) public {
        uint256 holderBalance = sRadsHoldersInfo[_sRadsHolder];
        _updateTokenPot(_token);
        TokenPot storage tokenPot = _distributedMoneyPot[_token];
        if(holderBalance > 0 && tokenPot.accTokenPerShare > 0){
            uint256 pending = holderBalance.mul(tokenPot.accTokenPerShare).div(1e12).sub(sRadsHoldersRewardsInfo[_token][_sRadsHolder].rewardDept);
            if(pending > 0) {
                if (_sRadsHolder == masterUranium) {
                    reserveTokenAmount[_token] = reserveTokenAmount[_token].add(pending);
                }
                else {
                    sRadsHoldersRewardsInfo[_token][_sRadsHolder].pending = sRadsHoldersRewardsInfo[_token][_sRadsHolder].pending.add(pending);
                }
            }
        }
        if ( sRadsHoldersRewardsInfo[_token][_sRadsHolder].pending > 0 ){
            safeTokenTransfer(_token, _sRadsHolder, sRadsHoldersRewardsInfo[_token][_sRadsHolder].pending);
            sRadsHoldersRewardsInfo[_token][_sRadsHolder].pending = 0;
        }
        sRadsHoldersRewardsInfo[_token][_sRadsHolder].rewardDept = holderBalance.mul(tokenPot.accTokenPerShare).div(1e12);
    }

    /*
    * Used by feeManager contract to deposit rewards (collected from many sources)
    */
    function depositRewards(address _token, uint256 _amount) external{
        require(msg.sender == feeManager);
        massUpdateMoneyPot();

        IBEP20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        if(block.number < startBlock){
            reserveTokenAmount[_token] = reserveTokenAmount[_token].add(_amount);
        }
        else {
            pendingTokenAmount[_token] = pendingTokenAmount[_token].add(_amount);
        }
    }

    /*
    * Used by dev to deposit bonus rewards that can be added to pending pot at any time
    */
    function depositBonusRewards(address _token, uint256 _amount) external onlyOwner{
        IBEP20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        reserveTokenAmount[_token] = reserveTokenAmount[_token].add(_amount);
    }

    function addTokenToRewards(address _token) external onlyOwner{
        if (!tokenInitialized[_token]){
            registeredToken.push(_token);
            _distributedMoneyPot[_token].lastRewardBlock = lastUpdateMoneyPotBlocks > block.number ? lastUpdateMoneyPotBlocks : lastUpdateMoneyPotBlocks.add(updateMoneyPotPeriodNbBlocks);
            _distributedMoneyPot[_token].accTokenPerShare = 0;
            _distributedMoneyPot[_token].tokenAmount = 0;
            _distributedMoneyPot[_token].lastUpdateTokenPotBlocks = _distributedMoneyPot[_token].lastRewardBlock;
            tokenInitialized[_token] = true;
        }
    }

    function removeTokenToRewards(address _token) external onlyOwner{
        require(_distributedMoneyPot[_token].tokenAmount == 0, "cannot remove before end of distribution");
        if (tokenInitialized[_token]){
            uint256 length = registeredToken.length;
            uint256 indexToRemove = length; // If token not found web do not try to remove bad index
            for (uint256 index = 0; index < length; ++index) {
                if(registeredToken[index] == _token){
                    indexToRemove = index;
                    break;
                }
            }
            if(indexToRemove < length){ // Should never be false.. Or something wrong happened
                registeredToken[indexToRemove] = registeredToken[registeredToken.length-1];
                registeredToken.pop();
            }
            tokenInitialized[_token] = false;
            return;
        }
    }

    function nextMoneyPotUpdateBlock() external view returns (uint256){
        return lastUpdateMoneyPotBlocks.add(updateMoneyPotPeriodNbBlocks);
    }

    function setUpdateMoneyPotPeriodNbBlocks(uint256 _updateRewardsDelay) external onlyOwner{
        updateMoneyPotPeriodNbBlocks = _updateRewardsDelay.div(3 * 1 seconds);
    }

    function addToPendingFromReserveTokenAmount(address _token, uint256 _amount) external onlyOwner{
        require(_amount <= reserveTokenAmount[_token], "Insufficient amount");
        reserveTokenAmount[_token] = reserveTokenAmount[_token].sub(_amount);
        pendingTokenAmount[_token] = pendingTokenAmount[_token].add(_amount);
    }


    // Safe Token transfer function, just in case if rounding error causes pool to not have enough Tokens.
    function safeTokenTransfer(address _token, address _to, uint256 _amount) internal {
        IBEP20 token = IBEP20(_token);
        uint256 tokenBal = token.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > tokenBal) {
            transferSuccess = token.transfer(_to, tokenBal);
        } else {
            transferSuccess = token.transfer(_to, _amount);
        }
        require(transferSuccess, "safeSRadsTransfer: Transfer failed");
    }

// Only use in testnet !
//    function emergencyWithdraw(IBEP20 _token) external onlyOwner {
//        _token.safeTransfer(address(msg.sender), _token.balanceOf(address(this)));
//    }

}


// File: contracts/SRadsToken.sol

pragma solidity ^0.6.12;


// SRadsToken with Governance.
contract SRadsToken is UraniumBEP20("Uranium ShareRads", "sRADS") {
    using SafeMath for uint256;
    using SafeMath for uint8;

    struct HolderInfo {
        uint256 amount;
        uint256 avgTransactionBlock;
        uint256 amountSwapped;
    }

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    UraniumMoneyPot public moneyPot;
    RadsToken public rads;
    bool private _isRadsSetup = false;
    bool private _isMoneyPotSetup = false;

    uint256 public immutable SWAP_PENALTY_MAX_PERIOD ; // after 24h penalty of holding sRads. Swap penalty is at the minimum
    uint8 public immutable SWAP_PENALTY_MAX_PER_SRADS ; // 30% => 1 srads = 0.3 rads

    mapping(address => HolderInfo) public holdersInfo;

    constructor (uint256 swapPenaltyMaxPeriod, uint8 swapPenaltyMaxPerSRads) public{
        SWAP_PENALTY_MAX_PERIOD = swapPenaltyMaxPeriod; // default 28800: after 24h penalty of holding sRads. Swap penalty is at the minimum
        SWAP_PENALTY_MAX_PER_SRADS = swapPenaltyMaxPerSRads; // 30% => 1 srads = 0.3 rads
    }

    function setupRads(RadsToken _rads) external onlyOwner {
        require(!_isRadsSetup, "Rads: already setup");
        rads = _rads;
        _isRadsSetup = true;
    }

    function setupMoneyPot(UraniumMoneyPot _moneyPot) external onlyOwner {
        require(!_isMoneyPotSetup, "MoneyPot already setup");
        moneyPot = _moneyPot;
        _isMoneyPotSetup = true;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner();
    }

    /**
     * @dev Returns true if the caller is the rads contract.
     */
    function isRads() internal view returns (bool) {
        return msg.sender == address(rads);
    }

    function swapToRads(uint256 _amount) external {
        require(_amount > 0, "amount 0");
        address _from = msg.sender;
        uint256 radsAmount = _swapRadsAmount( _from, _amount);
        super._burn(_from, _amount);
        holdersInfo[_from].avgTransactionBlock = _getAvgTransactionBlock(holdersInfo[_from], _amount, true);
        holdersInfo[_from].amount = holdersInfo[_from].amount.sub(_amount);
        if (holdersInfo[_from].amount > 0) {
            uint256 amountTRadsSwapped = getSRadsAtMinPenalty(_from);
            if (amountTRadsSwapped > _amount){
                amountTRadsSwapped = amountTRadsSwapped.sub(_amount);
            }
            holdersInfo[_from].amountSwapped = holdersInfo[_from].amountSwapped.add(amountTRadsSwapped);
        }
        else{
            holdersInfo[_from].amountSwapped = 0;
        }
        rads.mint(_from, radsAmount);

        if (address(moneyPot) != address(0)) {
            moneyPot.updateSRadsHolder(_from);
        }
    }

    /* @notice Preview swap return in rads with _sRadsAmount by _holderAddress
    *  this function used by front-end to show how much rads will be retrieve if _holderAddress swap _sRadsAmount
    */
    function previewSwapRadsExpectedAmount(address _holderAddress, uint256 _sRadsAmount) external view returns (uint256 expectedRads){
        return _swapRadsAmount( _holderAddress, _sRadsAmount);
    }

    function getSRadsAtMinPenalty(address _holderAddress) public view returns (uint256){
        HolderInfo storage holderInfo = holdersInfo[_holderAddress];
        if(holderInfo.avgTransactionBlock.add(SWAP_PENALTY_MAX_PERIOD) <= block.number ){
            return holderInfo.amount;
        }
        return (((block.number.sub(holderInfo.avgTransactionBlock)).mul(1000).div(SWAP_PENALTY_MAX_PERIOD))
                .mul(holderInfo.amount.sub(holderInfo.amountSwapped))).div(1000);
    }

    /* @notice Calculate the adjustment for a user if he want to swap _sRadsAmount to rads */
    function _swapRadsAmount(address _holderAddress, uint256 _sRadsAmount) internal view returns (uint256 expectedRads){
        HolderInfo storage holderInfo = holdersInfo[_holderAddress];
        require(holderInfo.amount >= _sRadsAmount, "Not enough sRADS");
        if(block.number >= holderInfo.avgTransactionBlock.add(SWAP_PENALTY_MAX_PERIOD)){
            return _sRadsAmount;
        }

        uint256 _sRadsAtMinPenalty = getSRadsAtMinPenalty(_holderAddress);

        if (_sRadsAtMinPenalty >= _sRadsAmount){
            return _sRadsAmount;
        }

        uint256 swapPenaltyPerSRads = SWAP_PENALTY_MAX_PER_SRADS.sub(
            (_sRadsAtMinPenalty.div(holderInfo.amount)).mul(SWAP_PENALTY_MAX_PER_SRADS)
        );
        uint256 _sRadsWithPenalty = _sRadsAmount.sub(_sRadsAtMinPenalty);
        uint256 _radsForSRadsWithPenalty = _sRadsWithPenalty.sub(_sRadsWithPenalty.mul(swapPenaltyPerSRads).div(100));
        return _radsForSRadsWithPenalty.add(_sRadsAtMinPenalty);
    }

    /* @notice Calculate average deposit/withdraw block for _holderAddress */
    function _getAvgTransactionBlock(HolderInfo storage holderInfo, uint256 _sRadsAmount, bool _onWithdraw) internal view returns (uint256){
        if (holderInfo.amount == 0) {
            return block.number;
        }
        uint256 transactionBlockWeight;
        if (_onWithdraw) {
            if (holderInfo.amount == _sRadsAmount) {
                return 0;
            }
            else {
                return holderInfo.avgTransactionBlock;
            }
        }
        else {
            transactionBlockWeight = (holderInfo.amount.mul(holderInfo.avgTransactionBlock).add(block.number.mul(_sRadsAmount)));
        }
        return transactionBlockWeight.div(holderInfo.amount.add(_sRadsAmount));
    }


    /// @notice Creates `_amount` token to `_to`.
    function mint(address _to, uint256 _amount) external onlyOwner() {
        HolderInfo storage holder = holdersInfo[_to];
        _mint(_to, _amount);
        holder.avgTransactionBlock = _getAvgTransactionBlock(holder, _amount, false);
        holder.amount = holder.amount.add(_amount);
        _moveDelegates(address(0), _delegates[_to], _amount);

        if (address(moneyPot) != address(0)) {
            moneyPot.updateSRadsHolder(_to);
        }
    }

    /// @dev overrides transfer function to meet tokenomics of RADS
    function _transfer(address _sender, address _recipient, uint256 _amount) internal virtual override {
        holdersInfo[_sender].avgTransactionBlock = _getAvgTransactionBlock(holdersInfo[_sender], _amount, true);
        holdersInfo[_sender].amount = holdersInfo[_sender].amount.sub(_amount);
        if (_recipient == BURN_ADDRESS) {
            super._burn(_sender, _amount);
            if (address(moneyPot) != address(0)) {
                moneyPot.updateSRadsHolder(_sender);
            }
            emit Transfer(_sender, _recipient, 0);
        } else {
            super._transfer(_sender, _recipient, _amount);
            holdersInfo[_recipient].avgTransactionBlock = _getAvgTransactionBlock(holdersInfo[_recipient], _amount, false);
            holdersInfo[_recipient].amount = holdersInfo[_recipient].amount.add(_amount);

            if (address(moneyPot) != address(0)) {
                moneyPot.updateSRadsHolder(_sender);
                if (_sender != _recipient){
                    moneyPot.updateSRadsHolder(_recipient);
                }
            }
        }

    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    /// @dev A record of each accounts delegate
    mapping(address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
    keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
    keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
    external
    view
    returns (address)
    {
        return _delegates[delegator];
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
    external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "RADS::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "RADS::delegateBySig: invalid nonce");
        require(now <= expiry, "RADS::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
    external
    view
    returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
    external
    view
    returns (uint256)
    {
        require(blockNumber < block.number, "RADS::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2;
            // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
    internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator);
        // balance of underlying RADSs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
    internal
    {
        uint32 blockNumber = safe32(block.number, "RADS::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2 ** 32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly {chainId := chainid()}
        return chainId;
    }
}


// RadsToken with Governance.
contract RadsToken is UraniumBEP20("Uranium Rads", "RADS") {

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    SRadsToken public sRads;
    bool private _isSRadsSetup = false;

    /*
     * @dev Throws if called by any account other than the owner or sRads
     */
    modifier onlyOwnerOrSRads() {
        require(isOwner() || isSRads(), "caller is not the owner or sRads");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner();
    }

    /**
     * @dev Returns true if the caller is sRads contracts.
     */
    function isSRads() internal view returns (bool) {
        return msg.sender == address(sRads);
    }

    function setupSRads(SRadsToken _sRads) external onlyOwner{
        require(!_isSRadsSetup, "sRads: already setup");
        sRads = _sRads;
        _isSRadsSetup = true;
    }

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterUranium).
    function mint(address _to, uint256 _amount) external onlyOwnerOrSRads {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    /// @dev overrides transfer function to meet tokenomics of RADS
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(amount > 0, "amount 0");

        if (recipient == BURN_ADDRESS) {
            super._burn(sender, amount);
            emit Transfer(sender, recipient, 0);
        } else {
            // 2% of every transfer burnt
            uint256 burnAmount = amount.mul(2).div(100);
            // 98% of transfer sent to recipient
            uint256 sendAmount = amount.sub(burnAmount);
            require(amount == sendAmount + burnAmount, "RADS::transfer: Burn value invalid");

            super._burn(sender, burnAmount);
            super._transfer(sender, recipient, sendAmount);
            amount = sendAmount;
        }
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    /// @dev A record of each accounts delegate
    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

      /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   /**
    * @notice Delegate votes from `msg.sender` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "RADS::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "RADS::delegateBySig: invalid nonce");
        require(now <= expiry, "RADS::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "RADS::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying RADSs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "RADS::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

pragma solidity ^0.6.12;

contract UraniumBonusAggregator is Ownable{
    using SafeMath for uint256;
    using SafeMath for uint16;

    MasterUranium master;

    mapping(address => mapping(uint256 => uint16)) public userBonusOnFarms;

    mapping (address => bool) public contractBonusSource;

    /**
     * @dev Throws if called by any account other than the verified contracts.
     */
    modifier onlyVerifiedContract() {
        require(contractBonusSource[msg.sender], "caller is not in contract list");
        _;
    }

    function setupMaster(MasterUranium _master) external onlyOwner{
        master = _master;
    }

    function addOrRemoveContractBonusSource(address _contract, bool _add) external onlyOwner{
        contractBonusSource[_contract] = _add;
    }

    function addUserBonusOnFarm(address _user, uint16 _percent, uint256 _pid) external onlyVerifiedContract{
        require(_percent < 10000, "Invalid percent");
        userBonusOnFarms[_user][_pid] = uint16(userBonusOnFarms[_user][_pid].add(_percent));
        master.updateUserBonus(_user, _pid, userBonusOnFarms[_user][_pid]);
    }

    function removeUserBonusOnFarm(address _user, uint16 _percent, uint256 _pid) external onlyVerifiedContract{
        require(_percent < 10000, "Invalid percent");
        userBonusOnFarms[_user][_pid] = uint16(userBonusOnFarms[_user][_pid].sub(_percent));
        master.updateUserBonus(_user, _pid, userBonusOnFarms[_user][_pid]);
    }

    function getBonusOnFarmsForUser(address _user, uint256 _pid) public view returns (uint16){
        return userBonusOnFarms[_user][_pid];
    }

}



// File: contracts/MasterUranium.sol

pragma solidity ^0.6.12;

// import "@nomiclabs/buidler/console.sol";

// MasterUranium is the master of RADS AND THO.
// He can make Rads and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once RADS is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterUranium is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint16;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 amountWithBonus;
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of RADSs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accRadsPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accRadsPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 lpSupply;
        uint256 allocPoint;       // How many allocation points assigned to this pool. RADSs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that RADSs distribution occurs.
        uint256 accRadsPerShare; // Accumulated RADSs per share, times 1e12. See below.
        uint16 depositFeeBP;     // deposit Fee
        bool isSRadsRewards;
    }

    UraniumBonusAggregator public bonusAggregator;
    // The RADS TOKEN!
    RadsToken public rads;
    // The SRADS TOKEN!
    SRadsToken public sRads;
    // Dev address.
    address public devaddr;
    // RADS tokens created per block.
    uint256 public radsPerBlock;
    // Deposit Fee address
    address public feeAddress;


    // Info of each user that stakes LP tokens.
    mapping (address => bool) public knownPoolLp;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when RADS mining starts.
    uint256 public immutable startBlock;

    // Initial emission rate: 1 RADS per block.
    uint256 public immutable initialEmissionRate;
    // Minimum emission rate: 0.1 RADS per block.
    uint256 public immutable minimumEmissionRate = 100 finney;
    // Reduce emission every 9,600 blocks ~ 12 hours.
    uint256 public immutable emissionReductionPeriodBlocks = 14400;
    // Emission reduction rate per period in basis points: 3%.
    uint256 public immutable emissionReductionRatePerPeriod = 300;
    // Last reduction period index
    uint256 public lastReductionPeriodIndex = 0;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmissionRateUpdated(address indexed caller, uint256 previousAmount, uint256 newAmount);

    constructor(
        RadsToken _rads,
        SRadsToken _srads,
        UraniumBonusAggregator _bonusAggregator,
        address _devaddr,
        address _feeAddress,
        uint256 _radsPerBlock,
        uint256 _startBlock
    ) public {
        rads = _rads;
        sRads = _srads;
        bonusAggregator = _bonusAggregator;
        devaddr = _devaddr;
        feeAddress = _feeAddress;
        radsPerBlock = _radsPerBlock;
        startBlock = _startBlock;
        initialEmissionRate = _radsPerBlock;

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _rads,
            lpSupply: 0,
            allocPoint: 800,
            lastRewardBlock: _startBlock,
            accRadsPerShare: 0,
            depositFeeBP: 0,
            isSRadsRewards: false
        }));
        totalAllocPoint = 800;
    }

    modifier validatePool(uint256 _pid) {
        require(_pid < poolInfo.length, "validatePool: pool exists?");
        _;
    }

    modifier onlyAggregator() {
        require(msg.sender == address(bonusAggregator), "Ownable: caller is not the owner");
        _;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function userBonus(uint256 _pid, address _user) public view returns (uint16){
        return bonusAggregator.getBonusOnFarmsForUser(_user, _pid);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IBEP20 _lpToken, uint16 _depositFeeBP, bool _isSRadsRewards, bool _withUpdate) external onlyOwner {
        require(_depositFeeBP <= 10000, "add: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        require(!knownPoolLp[address(_lpToken)], "add: existing pool");
        knownPoolLp[address(_lpToken)] = true;
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            lpSupply: 0,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accRadsPerShare: 0,
            depositFeeBP : _depositFeeBP,
            isSRadsRewards: _isSRadsRewards
        }));
    }

    // Update the given pool's RADS allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, bool _isSRadsRewards, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].isSRadsRewards = _isSRadsRewards;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
        }
    }

    // View function to see pending RADSs on frontend.
    function pendingRads(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRadsPerShare = pool.accRadsPerShare;
        uint256 lpSupply = pool.lpSupply;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 radsReward = multiplier.mul(radsPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accRadsPerShare = accRadsPerShare.add(radsReward.mul(1e12).div(lpSupply));
        }
        return user.amountWithBonus.mul(accRadsPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Reduce emission rate by 3% every 9,600 blocks ~ 8hours
    function updateEmissionRate() internal {
        if(startBlock > 0 && block.number <= startBlock){
            return;
        }
        if(radsPerBlock <= minimumEmissionRate){
            return;
        }

        uint256 currentIndex = block.number.sub(startBlock).div(emissionReductionPeriodBlocks);
        if (currentIndex <= lastReductionPeriodIndex) {
            return;
        }

        uint256 newEmissionRate = radsPerBlock;
        for (uint256 index = lastReductionPeriodIndex; index < currentIndex; ++index) {
            newEmissionRate = newEmissionRate.mul(1e4 - emissionReductionRatePerPeriod).div(1e4);
        }

        newEmissionRate = newEmissionRate < minimumEmissionRate ? minimumEmissionRate : newEmissionRate;
        if (newEmissionRate >= radsPerBlock) {
            return;
        }

        lastReductionPeriodIndex = currentIndex;
        uint256 previousEmissionRate = radsPerBlock;
        radsPerBlock = newEmissionRate;
        emit EmissionRateUpdated(msg.sender, previousEmissionRate, newEmissionRate);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public validatePool(_pid) {
        updateEmissionRate();
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 radsReward = multiplier.mul(radsPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        uint256 devMintAmount = radsReward.div(10);
        rads.mint(devaddr, devMintAmount);
        if (pool.isSRadsRewards){
            sRads.mint(address(this), radsReward);
        }
        else{
            rads.mint(address(this), radsReward);
        }
        pool.accRadsPerShare = pool.accRadsPerShare.add(radsReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function updateUserBonus(address _user, uint256 _pid, uint256 bonus) external  validatePool(_pid) onlyAggregator{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amountWithBonus.mul(pool.accRadsPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                if(pool.isSRadsRewards){
                    safeSRadsTransfer(_user, pending);
                }
                else{
                    safeRadsTransfer(_user, pending);
                }
            }
        }
        pool.lpSupply = pool.lpSupply.sub(user.amountWithBonus);
        user.amountWithBonus =  user.amount.mul(bonus.add(10000)).div(10000);
        pool.lpSupply = pool.lpSupply.add(user.amountWithBonus);
        user.rewardDebt = user.amountWithBonus.mul(pool.accRadsPerShare).div(1e12);
    }

    // Deposit LP tokens to MasterUranium for RADS allocation.
    function deposit(uint256 _pid, uint256 _amount) external validatePool(_pid) {
        address _user = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amountWithBonus.mul(pool.accRadsPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                if(pool.isSRadsRewards){
                    safeSRadsTransfer(_user, pending);
                }
                else{
                    safeRadsTransfer(_user, pending);
                }
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(_user), address(this), _amount);
            if (address(pool.lpToken) == address(rads)) {
                uint256 transferTax = _amount.mul(2).div(100);
                _amount = _amount.sub(transferTax);
            }
            if (pool.depositFeeBP > 0) {
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);
                uint256 _bonusAmount = _amount.sub(depositFee).mul(userBonus(_pid, _user).add(10000)).div(10000);
                user.amountWithBonus = user.amountWithBonus.add(_bonusAmount);
                pool.lpSupply = pool.lpSupply.add(_bonusAmount);
            } else {
                user.amount = user.amount.add(_amount);
                uint256 _bonusAmount = _amount.mul(userBonus(_pid, _user).add(10000)).div(10000);
                user.amountWithBonus = user.amountWithBonus.add(_bonusAmount);
                pool.lpSupply = pool.lpSupply.add(_bonusAmount);
            }
        }
        user.rewardDebt = user.amountWithBonus.mul(pool.accRadsPerShare).div(1e12);
        emit Deposit(_user, _pid, _amount);
    }

    // Withdraw LP tokens from MasterUranium.
    function withdraw(uint256 _pid, uint256 _amount) external validatePool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amountWithBonus.mul(pool.accRadsPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            if(pool.isSRadsRewards){
                safeSRadsTransfer(msg.sender, pending);
            }
            else{
                safeRadsTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            uint256 _bonusAmount = _amount.mul(userBonus(_pid, msg.sender).add(10000)).div(10000);
            user.amountWithBonus = user.amountWithBonus.sub(_bonusAmount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            pool.lpSupply = pool.lpSupply.sub(_bonusAmount);
        }
        user.rewardDebt = user.amountWithBonus.mul(pool.accRadsPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function getPoolInfo(uint256 _pid) external view
    returns(address lpToken, uint256 allocPoint, uint256 lastRewardBlock,
            uint256 accRadsPerShare, uint16 depositFeeBP, bool isSRadsRewards) {
        return (
            address(poolInfo[_pid].lpToken),
            poolInfo[_pid].allocPoint,
            poolInfo[_pid].lastRewardBlock,
            poolInfo[_pid].accRadsPerShare,
            poolInfo[_pid].depositFeeBP,
            poolInfo[_pid].isSRadsRewards
        );
    }

    // Safe rads transfer function, just in case if rounding error causes pool to not have enough RADSs.
    function safeRadsTransfer(address _to, uint256 _amount) internal {
        uint256 radsBal = rads.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > radsBal) {
            transferSuccess = rads.transfer(_to, radsBal);
        } else {
            transferSuccess = rads.transfer(_to, _amount);
        }
        require(transferSuccess, "safeRadsTransfer: Transfer failed");
    }

    // Safe sRads transfer function, just in case if rounding error causes pool to not have enough SRADSs.
    function safeSRadsTransfer(address _to, uint256 _amount) internal {
        uint256 sRadsBal = sRads.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > sRadsBal) {
            transferSuccess = sRads.transfer(_to, sRadsBal);
        } else {
            transferSuccess = sRads.transfer(_to, _amount);
        }
        require(transferSuccess, "safeSRadsTransfer: Transfer failed");
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) external {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        feeAddress = _feeAddress;
    }

}