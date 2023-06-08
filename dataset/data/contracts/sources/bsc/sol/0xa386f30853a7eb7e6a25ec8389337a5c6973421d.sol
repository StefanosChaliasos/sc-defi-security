// File: paraluni_protocol/contracts/libraries/Proxy.sol



pragma solidity ^0.6.12;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}
// File: paraluni_protocol/contracts/ParaProxyStorage.sol


pragma solidity ^0.6.12;

contract ParaProxyAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract
    */
    address public pendingAdmin;

    /**
    * @notice Active brains of Proxy
    */
    address public implementation;

    /**
    * @notice Pending brains of Proxy
    */
    address public pendingImplementation;
}
// File: paraluni_protocol/contracts/ParaProxy.sol


pragma solidity ^0.6.12;


/**
 * @title ParaCore
 * @dev Storage for the comptroller is at this address, while execution is delegated to the `implementation`.
 * CTokens should reference this contract as their comptroller.
 */
contract ParaProxy is ParaProxyAdminStorage, Proxy{

    /**
      * @notice Emitted when pendingImplementation is changed
      */
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    /**
      * @notice Emitted when pendingImplementation is accepted, which means comptroller implementation is updated
      */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
      * @notice Emitted when pendingAdmin is changed
      */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
      * @notice Emitted when pendingAdmin is accepted, which means admin is updated
      */
    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() public {
        // Set admin to caller
        admin = msg.sender;
    }

    /*** Admin Functions ***/
    function _setPendingImplementation(address newPendingImplementation) public returns (uint) {

        require(msg.sender == admin, "auth");

        address oldPendingImplementation = pendingImplementation;

        pendingImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingImplementation);

        return 0;
    }

    /**
    * @notice Accepts new implementation of comptroller. msg.sender must be pendingImplementation
    * @dev Admin function for new implementation to accept it's role as implementation
    * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
    */
    function _acceptImplementation() public returns (uint) {
        // Check caller is pendingImplementation and pendingImplementation ≠ address(0)
        if (msg.sender != pendingImplementation || pendingImplementation == address(0)) {
            return 1;
        }

        // Save current values for inclusion in log
        address oldImplementation = implementation;
        address oldPendingImplementation = pendingImplementation;

        implementation = pendingImplementation;

        pendingImplementation = address(0);

        emit NewImplementation(oldImplementation, implementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingImplementation);

        return 0;
    }


    /**
      * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @param newPendingAdmin New pending admin.
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _setPendingAdmin(address newPendingAdmin) public returns (uint) {
        // Check caller = admin
        if (msg.sender != admin) {
            return 1;
        }

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return 0;
    }

    /**
      * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
      * @dev Admin function for pending admin to accept role and update admin
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _acceptAdmin() public returns (uint) {
        // Check caller is pendingAdmin and pendingAdmin ≠ address(0)
        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return 1;
        }

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

        return 0;
    }

    function _implementation() internal view virtual override returns (address){
        return implementation;
    }

}
// File: paraluni_protocol/contracts/interfaces/IFeeDistributor.sol


pragma solidity ^0.6.12;

interface IFeeDistributor {
    function incomeClaimFee(address user, address token, uint256 fee) external;
    function incomeWithdrawFee(address user, address token, uint256 fee, uint256 amount) external;
    function incomeSwapFee(address user, address token, uint256 fee) payable external;
    function setReferalByChef(address user, address referal) external;
}
// File: paraluni_protocol/contracts/libraries/TransferHelper.sol



pragma solidity ^0.6.12;

// helper methods for interacting with BEP20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}
// File: paraluni_protocol/contracts/interfaces/IParaPair.sol

pragma solidity ^0.6.12;

interface IParaPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: paraluni_protocol/contracts/interfaces/IParaRouter01.sol


pragma solidity ^0.6.12;

interface IParaRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// File: paraluni_protocol/contracts/interfaces/IParaRouter02.sol

pragma solidity ^0.6.12;


interface IParaRouter02 is IParaRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// File: paraluni_protocol/contracts/interfaces/IWETH.sol

pragma solidity ^0.6.12;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// File: paraluni_protocol/contracts/libraries/EnumerableSet.sol



pragma solidity ^0.6.12;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}
// File: paraluni_protocol/contracts/libraries/Address.sol



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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// File: paraluni_protocol/contracts/libraries/SafeMath_para.sol

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

// File: paraluni_protocol/contracts/interfaces/IERC20.sol


pragma solidity ^0.6.12;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: paraluni_protocol/contracts/libraries/SafeERC20.sol



pragma solidity ^0.6.12;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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
// File: paraluni_protocol/contracts/libraries/Context.sol



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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// File: paraluni_protocol/contracts/libraries/Ownable.sol



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
abstract contract Ownable is Context {
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
}
// File: paraluni_protocol/contracts/libraries/ERC20.sol



pragma solidity ^0.6.12;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

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
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

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
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
// File: paraluni_protocol/contracts/ParaToken.sol



pragma solidity ^0.6.12;


// ParaToken with Governance.
contract ParaToken is ERC20("ParalUni Token", "T42"), Ownable {
    using SafeMath for uint256;

    uint denominator = 1e18;
    uint256 public hardLimit = 10000000000e18; // Hardtop: upper limit of total T42 issuance
    uint256 public _issuePerBlock = 1150e18;   // Initial issued quantity per block
    uint256 public startBlock;          // Issuing start block height
    uint256 public lastBlockHalve;             // Block height at last production reduction
    uint256 public lastSoftLimit = 0;          // Soft roof at last production reduction
    uint256 constant HALVE_INTERVAL = 880000;   // Number of production reduction interval blocks
    uint256 constant HALVE_RATE = 90;           // Production reduction ratio
    
    mapping(address => bool) public minersAddress;
    address public fineAcceptAddress;
    mapping(address => bool) public whiteAdmins;
    mapping(address => bool) public whitelist;
    mapping(address => bool) public fromWhitelist;
    mapping(address => bool) public toWhitelist;
    mapping(address => Maturity) public userMaturity;

    struct Maturity {
        uint lastBlockHalve;
        uint blockNum;
        uint whiteBalance;
    }

    constructor(uint _startBlock) public {
        startBlock = _startBlock;
        lastBlockHalve = _startBlock;
    }
    
    function _setMinerAddress(address _minerAddress, bool flag) external onlyOwner{
        minersAddress[_minerAddress] = flag;
    }
    
    function _setFineAcceptAddress(address _fineAcceptAddress) external onlyOwner{
        fineAcceptAddress = _fineAcceptAddress;
    }
    
    function _setWhiteAdmin(address _whiteAdmin, bool flag) external onlyOwner{
        whiteAdmins[_whiteAdmin] = flag;
    }

    function _setWhiteListAll(uint whiteType, address[] memory users, bool[] memory flags) external onlyOwner{
        require(users.length == flags.length);
        for(uint i = 0; i < users.length; i++){
           _setWhiteList(whiteType, users[i], flags[i]);
        }
    }

    function _setWhiteList(uint whiteType, address user, bool flag) public{
        require(whiteAdmins[address(msg.sender)] || address(msg.sender) == owner(), "WhiteList:auth");
        if(whiteType == 0){
            whitelist[user] = flag;
        }
        if(whiteType == 1){
            fromWhitelist[user] = flag;
        }
        if(whiteType == 2){
            toWhitelist[user] = flag;
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        uint fine = 0;
        if(whitelist[recipient] || toWhitelist[recipient]){
            if(!whitelist[sender]){
                Maturity storage maturity = userMaturity[sender];
                maturity.whiteBalance = maturity.whiteBalance.add(amount);
            }
        }else{
            Maturity storage maturity = userMaturity[recipient];
            if(maturity.lastBlockHalve == 0){
                maturity.lastBlockHalve = block.number;
            }
            if(whitelist[sender] || fromWhitelist[sender]){
                if(!fromWhitelist[sender]){
                    if(maturity.whiteBalance >= amount){
                        /** ===== set storage =====   */
                        maturity.whiteBalance = maturity.whiteBalance.sub(amount);
                    }else{
                        /** ===== set storage =====   */
                        maturity.whiteBalance = 0;
                    }
                }
            }else{
                fine = getFine(sender, amount);
                uint virtualAmount = balanceOf(recipient).add(maturity.whiteBalance);
                (uint currentMaturityTo, ) = currentMaturity(recipient);
                uint latestMaturity = 0;
                if(virtualAmount.add(amount) > 0){
                   latestMaturity = virtualAmount.mul(currentMaturityTo).div(virtualAmount.add(amount));
                }        
                uint newBlockNum = getBlockNumByMaturity(latestMaturity);

                /** ===== set storage =====   */
                maturity.blockNum = newBlockNum;
                maturity.lastBlockHalve = block.number;
            }
        }
        super._transfer(sender, recipient, amount.sub(fine));
        if(fine > 0){
            super._transfer(sender, fineAcceptAddress, fine);    
        }
    }

    function currentMaturity(address user) public view returns (uint mturityValue, uint blockNeeded){
        Maturity memory maturity = userMaturity[user];
        uint short = block.number.sub(maturity.lastBlockHalve);
        if(maturity.lastBlockHalve == 0){
            short = 0;
        }
        uint x0 = maturity.blockNum.add(short);
        (mturityValue, blockNeeded) = getMaturity(x0);
    }

    function getMaturity(uint blockNum) internal view returns (uint maturity, uint blockNeeded) {
        if(blockNum < uint(403200)){
            blockNeeded = uint(403200).sub(blockNum);
        }
        blockNum = blockNum.mul(denominator);
        if(blockNum < uint(201600).mul(denominator)){
            maturity = blockNum.div(806400);
        }
        if(blockNum >= uint(201600).mul(denominator) && blockNum < uint(403200).mul(denominator)){
            maturity = blockNum.div(268800).sub(5e17);
        }
        if(blockNum >= uint(403200).mul(denominator)){
            maturity = 1e18;
        }
    }

   function getBlockNumByMaturity(uint maturity)internal view returns (uint blockNum){
       if(maturity < 0.25e18){
           return maturity.mul(806400).div(denominator);
       }
       if(maturity >= 0.25e18 && maturity < 1e18){
           return maturity.add(5e17).mul(268800).div(denominator);
       }
       if(maturity >= 1e18){
           return 403200;
       }
   }

   function getFine(address user, uint amount) public view returns (uint) {
        (uint currentMaturityFrom, ) = currentMaturity(user);
        return amount.mul(denominator.sub(currentMaturityFrom)).div(5).div(denominator);
   }

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public { 
        require(minersAddress[msg.sender], "!mint:auth");
        uint256 newTotal = totalSupply().add(_amount);
        updateSoftLimit();
        require(newTotal <= softLimit(), "^softLimit");
        require(newTotal <= hardLimit, "^hardLimit");

        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function updateSoftLimit() internal {
        if(block.number > startBlock){
            uint256 n = block.number.sub(startBlock).div(HALVE_INTERVAL) 
                    - lastBlockHalve.sub(startBlock).div(HALVE_INTERVAL);
            for (uint i = 0; i < n; i++) {
                lastSoftLimit = lastSoftLimit.add(_issuePerBlock.mul(HALVE_INTERVAL));
                _issuePerBlock = _issuePerBlock.mul(HALVE_RATE).div(100);
                lastBlockHalve = block.number;
            }
        }
    }

    function softLimit() public view returns (uint) {
        uint256 _lastSoftLimit = lastSoftLimit;
        uint256 _lastBlockHalve = lastBlockHalve;
        uint256 __issuePerBlock = _issuePerBlock;
        if(block.number > startBlock){
            uint256 n = block.number.sub(startBlock).div(HALVE_INTERVAL) - lastBlockHalve.sub(startBlock).div(HALVE_INTERVAL);
            for (uint i = 0; i < n; i++) {
                _lastSoftLimit = _lastSoftLimit.add(__issuePerBlock.mul(HALVE_INTERVAL));
                __issuePerBlock = __issuePerBlock.mul(HALVE_RATE).div(100);
                _lastBlockHalve = block.number;
            }
            uint256 blocks = block.number.sub(_lastBlockHalve).add(1);
            return _lastSoftLimit.add(__issuePerBlock.mul(blocks));
        }
        return 0;
    }

    function issuePerBlock() public view returns (uint) {
        uint retval = _issuePerBlock;
        if (block.number >= startBlock) {
            uint256 n = block.number.sub(startBlock).div(HALVE_INTERVAL) - lastBlockHalve.sub(startBlock).div(HALVE_INTERVAL);
            for (uint i = 0; i < n; i++) {
                retval = retval.mul(HALVE_RATE).div(100);
            }
            return retval;
        }
        return 0;
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    /// @notice A record of each accounts delegate
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
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

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
        require(signatory != address(0), "PARA::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "PARA::delegateBySig: invalid nonce");
        require(now <= expiry, "PARA::delegateBySig: signature expired");
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
        require(blockNumber < block.number, "PARA::getPriorVotes: not yet determined");

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
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying T42s (not scaled);
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
        uint32 blockNumber = safe32(block.number, "PARA::_writeCheckpoint: block number exceeds 32 bits");

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
// File: paraluni_protocol/contracts/ParaChef.sol


pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;












interface IParaTicket {
    function level() external pure returns (uint256);
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
    function setApprovalForAll(address to, bool approved) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function setUsed(uint256 tokenId) external;
    function _used(uint256 tokenId) external view returns(bool);
}

interface IMigratorChef {
    function migrate(IERC20 token) external returns (IERC20);
}

// MasterChef is the master of ParaSwap. He can make T42 and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once T42 is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is ParaProxyAdminStorage {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of T42s
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accT42PerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accT42PerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accT42PerShare;
        IParaTicket ticket;
        uint256 pooltype;
    }
    uint8[10] public farmPercent;
    ParaToken public t42;
    address public devaddr;
    address public treasury;
    address public feeDistributor;
    uint256 public claimFeeRate;
    uint256 public withdrawFeeRate;
    uint256 public bonusEndBlock;
    uint256 public constant BONUS_MULTIPLIER = 1;
    IMigratorChef public migrator;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;
    uint256 public startBlock;
    
    address public WETH;
    IParaRouter02 public paraRouter;
    mapping(address => mapping(address => uint)) public userChange;
    mapping(address => mapping(address => uint[])) public ticket_stakes;
    mapping(address => mapping(uint256 => uint256)) public _totalClaimed;
    mapping(address => address) public _whitelist;
    mapping(uint => uint) public poolsTotalDeposit;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event WithdrawChange(
        address indexed user,
        address indexed token,
        uint256 change);
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(admin == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor() public {
        admin = msg.sender;
    }
    
    function initialize(
        ParaToken _t42,
        address _treasury,
        address _feeDistributor,
        address _devaddr,
        uint256 _bonusEndBlock,
        address _WETH,
        IParaRouter02 _paraRouter
    ) external onlyOwner {
        t42 = _t42;
        treasury = _treasury;
        feeDistributor = _feeDistributor;
        devaddr = _devaddr;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _t42.startBlock();
        WETH = _WETH;
        paraRouter = _paraRouter;
        claimFeeRate = 500;
        withdrawFeeRate = 130;
    }

    function _become(ParaProxy proxy) public {
        require(msg.sender == proxy.admin(), "only proxy admin can change brains");
        require(proxy._acceptImplementation() == 0, "change not authorized");
    }
    
    function setWhitelist(address _whtie, address accpeter) public onlyOwner {
        _whitelist[_whtie] = accpeter;
    }

    function setT42(ParaToken _t42) public onlyOwner {
        require(address(_t42) != address(0), "Should not set _t42 to 0x0");
        t42 = _t42;
    }
    
    function setTreasury(address _treasury) public onlyOwner {
        require(_treasury != address(0), "Should not set treasury to 0x0");
        require(_treasury != treasury, "Need a different treasury address");
        treasury = _treasury;
    }
    
    function setRouter(address _router) public onlyOwner {
        require(_router != address(0), "Should not set _router to 0x0");
        require(_router != address(paraRouter), "Need a different treasury address");
        paraRouter = IParaRouter02(_router);
    }
    
    function setFeeDistributor(address _newAddress) public onlyOwner {
        require(_newAddress != address(0), "Should not set fee distributor to 0x0");
        require(_newAddress != feeDistributor, "Need a different fee distributor address");
        feeDistributor = _newAddress;
    }

    function setFarmPercents(uint8[] memory percents) public onlyOwner {
        uint8 sum = 0;
        uint8 i = 0;
        for (i = 0; i < percents.length; i++) {
            sum += percents[i];
        }
        require(sum == 100, "Total percent should be 100%");
        for (i = 0; i < percents.length; i++) {
            farmPercent[i] = percents[i];
        }
    }

    function t42PerBlock(uint8 index) public view returns (uint) {
        return t42.issuePerBlock().mul(farmPercent[index]).div(100);
    }

    function setClaimFeeRate(uint256 newRate) public onlyOwner {
        require(newRate <= 2000, "Claim fee rate should not be greater than 20%");
        require(newRate != claimFeeRate, "Need a different value");
        claimFeeRate = newRate;
    }

    function setWithdrawFeeRate(uint256 newRate) public onlyOwner {
        require(newRate <= 500, "Withdraw fee rate should not be greater than 5%");
        require(newRate != withdrawFeeRate, "Need a different value");
        withdrawFeeRate = newRate;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

	function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        uint256 _pooltype,
        IParaTicket _ticket,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accT42PerShare: 0,
                pooltype: _pooltype,
                ticket: _ticket
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = poolsTotalDeposit[_pid];
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        uint newLpAmountNew = newLpToken.balanceOf(address(this));
        require(bal <= newLpAmountNew, "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return
                bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                    _to.sub(bonusEndBlock)
                );
        }
    }

    // View function to see pending T42s on frontend.
    function pendingT42(uint256 _pid, address _user)
        external
        view
        returns (uint256 pending, uint256 fee)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accT42PerShare = pool.accT42PerShare;
        uint256 lpSupply = poolsTotalDeposit[_pid];
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 t42Reward =
                multiplier.mul(t42PerBlock(1)).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accT42PerShare = accT42PerShare.add(
                t42Reward.mul(1e12).div(lpSupply)
            );
        }
        pending = user.amount.mul(accT42PerShare).div(1e12).sub(user.rewardDebt);
        fee = pending.mul(claimFeeRate).div(10000);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = poolsTotalDeposit[_pid];
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 t42Reward =
            multiplier.mul(t42PerBlock(1)).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        t42.mint(treasury, t42Reward.div(9));
        t42.mint(address(this), t42Reward);
        pool.accT42PerShare = pool.accT42PerShare.add(
            t42Reward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function depositSingle(uint256 _pid, address _token, uint256 _amount, address[][2] memory paths, uint _minTokens) payable external{
        depositSingleInternal(msg.sender, msg.sender, _pid, _token, _amount, paths, _minTokens);
    }

    function depositSingleTo(address _user, uint256 _pid, address _token, uint256 _amount, address[][2] memory paths, uint _minTokens) payable external{
        require(_whitelist[msg.sender] != address(0), "only white");
        
        IFeeDistributor(feeDistributor).setReferalByChef(_user, _whitelist[msg.sender]);
        depositSingleInternal(msg.sender, _user, _pid, _token, _amount, paths, _minTokens);
    }

    function depositByAddLiquidity(uint256 _pid, address[2] memory _tokens, uint256[2] memory _amounts) external{
        require(_amounts[0] > 0 && _amounts[1] > 0, "!0");
        address[2] memory tokens;
        uint256[2] memory amounts;
        (tokens[0], amounts[0]) = _doTransferIn(msg.sender, _tokens[0], _amounts[0]);
        (tokens[1], amounts[1]) = _doTransferIn(msg.sender, _tokens[1], _amounts[1]);
        depositByAddLiquidityInternal(msg.sender, _pid, tokens,amounts);
    }

    function depositByAddLiquidityETH(uint256 _pid, address _token, uint256 _amount) external payable{
        require(msg.value > 0 && _amount > 0, "!0");
        address[2] memory _tokens;
        uint256[2] memory _amounts;
        (_tokens[0], _amounts[0]) = _doTransferIn(msg.sender, _token, _amount);
        IWETH(WETH).deposit{value: msg.value}();
        assert(IWETH(WETH).transfer(address(this), msg.value));
        _tokens[1] = WETH;
        _amounts[1] = msg.value;
        depositByAddLiquidityInternal(msg.sender, _pid, _tokens, _amounts);
    }

    function depositByAddLiquidityInternal(address _user, uint256 _pid, address[2] memory _tokens, uint256[2] memory _amounts) internal {
        PoolInfo memory pool = poolInfo[_pid];
        require(address(pool.ticket) == address(0), "T:E");
        uint liquidity = addLiquidityInternal(address(pool.lpToken), _user, _tokens, _amounts);
        _deposit(_pid, liquidity, _user);
    }

    function addLiquidityInternal(address _lpAddress, address _user, address[2] memory _tokens, uint256[2] memory _amounts) internal returns (uint){
        //Stack too deep, try removing local variables
        DepositVars memory vars;
        approveIfNeeded(_tokens[0], address(paraRouter), _amounts[0]);
        approveIfNeeded(_tokens[1], address(paraRouter), _amounts[1]);
        vars.oldBalance = IERC20(_lpAddress).balanceOf(address(this));
        (vars.amountA, vars.amountB, vars.liquidity) = paraRouter.addLiquidity(_tokens[0], _tokens[1], _amounts[0], _amounts[1], 1, 1, address(this), block.timestamp + 600);
        vars.newBalance = IERC20(_lpAddress).balanceOf(address(this));
        require(vars.newBalance > vars.oldBalance, "B:E");
        vars.liquidity = vars.newBalance.sub(vars.oldBalance);
        addChange(_user, _tokens[0], _amounts[0].sub(vars.amountA));
        addChange(_user, _tokens[1], _amounts[1].sub(vars.amountB));
        return vars.liquidity;
    }

    struct DepositVars{
        uint oldBalance;
        uint newBalance;
        uint amountA;
        uint amountB;
        uint liquidity;
    }
    function depositSingleInternal(address payer, address _user, uint256 _pid, address _token, uint256 _amount, address[][2] memory paths, uint _minTokens) internal {
        require(paths.length == 2,"deposit: PE");
        (_token, _amount) = _doTransferIn(payer, _token, _amount);
        require(_amount > 0, "deposit: zero");
        (address[2] memory tokens, uint[2] memory amounts) = depositSwapForTokens(_token, _amount, paths);
        PoolInfo memory pool = poolInfo[_pid];
        require(address(pool.ticket) == address(0), "T:E");
        uint liquidity = addLiquidityInternal(address(pool.lpToken), _user, tokens, amounts);
        require(liquidity >= _minTokens, "H:S");
        _deposit(_pid, liquidity, _user);
    }

    function depositSwapForTokens(address _token, uint256 _amount, address[][2] memory paths) internal returns(address[2] memory tokens, uint[2] memory amounts){
        for (uint256 i = 0; i < 2; i++) {
            if(paths[i].length == 0){
                tokens[i] = _token;
                amounts[i] = _amount.div(2);
            }else{
                require(paths[i][0] == _token,"invalid path");
                approveIfNeeded(_token, address(paraRouter), _amount);
                (tokens[i], amounts[i]) = swapTokensIn(_amount.div(2), paths[i]);
            }
        }
    }

    function addChange(address user, address _token, uint change) internal returns(uint){
        if(change > 0){
            uint changeOld = userChange[user][_token];
            userChange[user][_token] = changeOld.add(change);
        }
    }

    function swapTokensIn(uint amountIn, address[] memory path) internal returns(address tokenOut, uint amountOut){
        uint[] memory amounts = paraRouter.swapExactTokensForTokens(amountIn, 0, path, address(this), block.timestamp + 600);
        tokenOut = path[path.length - 1];
        amountOut = amounts[amounts.length - 1];
    }

    function _claim(uint256 pooltype, uint pending) internal {
        uint256 fee = pending.mul(claimFeeRate).div(10000);
        safeT42Transfer(msg.sender, pending.sub(fee));
        _totalClaimed[msg.sender][pooltype] += pending.sub(fee);
        t42.approve(feeDistributor, fee);
        IFeeDistributor(feeDistributor).incomeClaimFee(msg.sender, address(t42), fee);
    }

    function totalClaimed(address _user, uint256 pooltype, uint index) public view returns (uint256) {
        if (pooltype > 0)
            return _totalClaimed[_user][pooltype];
            uint sum = 0;
            for(uint i = 0; i <= index; i++){
                sum += _totalClaimed[_user][i];
            }
        return sum;
    }

    function deposit_all_tickets(IParaTicket ticket) public {
        uint256[] memory idlist = ticket.tokensOfOwner(msg.sender);
        if (idlist.length > 0) {
            for (uint i = 0; i < idlist.length; i++) {
                uint tokenId = idlist[i];
                ticket.safeTransferFrom(msg.sender, address(this), tokenId);
                if(!ticket._used(tokenId)){
                    ticket.setUsed(tokenId);
                }
                ticket_stakes[msg.sender][address(ticket)].push(tokenId);
            }
        }
    }

    function ticket_staked_count(address who, address ticket) public view returns (uint) {
        return ticket_stakes[who][ticket].length;
    }

    function ticket_staked_array(address who, address ticket) public view returns (uint[] memory) {
        return ticket_stakes[who][ticket];
    }

    function check_vip_limit(uint ticket_level, uint ticket_count, uint256 amount) public view returns (uint allowed, uint overflow){
        uint256 limit;
        if (ticket_level == 0) limit = 1000 * 1e18;
        else if (ticket_level == 1) limit = 5000 * 1e18;
        else if (ticket_level == 2) limit = 10000 * 1e18;
        else if (ticket_level == 3) limit = 25000 * 1e18;
        else if (ticket_level == 4) limit = 100000 * 1e18;
        uint limitAll = ticket_count.mul(limit);
        if(amount <= limitAll){
            allowed = limitAll.sub(amount);
        }else{
            overflow = amount.sub(limitAll);
        }
    }
    
    function deposit(uint256 _pid, uint256 _amount) external {
        depositInternal(_pid, _amount, msg.sender, msg.sender);
    }

    function depositTo(uint256 _pid, uint256 _amount, address _user) external {
        require(_whitelist[msg.sender] != address(0), "only white");
        
        IFeeDistributor(feeDistributor).setReferalByChef(_user, _whitelist[msg.sender]);
        depositInternal(_pid, _amount, _user, msg.sender);
    }

    // Deposit LP tokens to MasterChef for T42 allocation.
    function depositInternal(uint256 _pid, uint256 _amount, address _user, address payer) internal {
        PoolInfo storage pool = poolInfo[_pid];
        pool.lpToken.safeTransferFrom(
            address(payer),
            address(this),
            _amount
        );
        if (address(pool.ticket) != address(0)) {
            UserInfo storage user = userInfo[_pid][_user];
            uint256 new_amount = user.amount.add(_amount);
            uint256 user_ticket_count = pool.ticket.tokensOfOwner(_user).length;
            uint256 staked_ticket_count = ticket_staked_count(_user, address(pool.ticket));
            uint256 ticket_level = pool.ticket.level();
            (, uint overflow) = check_vip_limit(ticket_level, user_ticket_count + staked_ticket_count, new_amount);
            require(overflow == 0, "Exceeding the ticket limit");
            deposit_all_tickets(pool.ticket);
        }
        _deposit(_pid, _amount, _user);
    }

    // Deposit LP tokens to MasterChef for para allocation.
    function _deposit(uint256 _pid, uint256 _amount, address _user) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        poolsTotalDeposit[_pid] = poolsTotalDeposit[_pid].add(_amount);
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(pool.accT42PerShare).div(1e12).sub(
                    user.rewardDebt
                );
            _claim(pool.pooltype, pending);
        }
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accT42PerShare).div(1e12);
        emit Deposit(_user, _pid, _amount);
    }

    function withdraw_tickets(uint256 _pid, uint256 tokenId) public {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][msg.sender];
        uint256[] storage idlist = ticket_stakes[msg.sender][address(pool.ticket)];
        for (uint i; i< idlist.length; i++) {
            if (idlist[i] == tokenId) {
                (, uint overflow) = check_vip_limit(pool.ticket.level(), idlist.length - 1, user.amount);
                require(overflow == 0, "Please withdraw usdt in advance");
                pool.ticket.safeTransferFrom(address(this), msg.sender, tokenId);
                idlist[i] = idlist[idlist.length - 1];
                idlist.pop();
                return;
            }
        }
        require(false, "You never staked this ticket before");
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        _withdrawInternal(_pid, _amount, msg.sender);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function _withdrawInternal(uint256 _pid, uint256 _amount, address _operator) internal{
        (address lpToken,uint actual_amount) = _withdrawWithoutTransfer(_pid, _amount, _operator);
        IERC20(lpToken).safeTransfer(_operator, actual_amount);
    }

    function _withdrawWithoutTransfer(uint256 _pid, uint256 _amount, address _operator) internal returns (address lpToken, uint actual_amount){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_operator];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accT42PerShare).div(1e12).sub(
                user.rewardDebt
            );
        _claim(pool.pooltype, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accT42PerShare).div(1e12);
        poolsTotalDeposit[_pid] = poolsTotalDeposit[_pid].sub(_amount);
        lpToken = address(pool.lpToken);
        uint fee = _amount.mul(withdrawFeeRate).div(10000);
        IERC20(lpToken).approve(feeDistributor, fee);
        IFeeDistributor(feeDistributor).incomeWithdrawFee(_operator, lpToken, fee, _amount);
        actual_amount = _amount.sub(fee);
    }

    function withdrawAndRemoveLiquidity(uint256 _pid, uint256 _amount, bool isBNB) external{
        (address lpToken, uint actual_amount) = _withdrawWithoutTransfer(_pid, _amount, msg.sender);
        approveIfNeeded(lpToken, address(paraRouter), actual_amount);
        address token0 = IParaPair(lpToken).token0();
        address token1 = IParaPair(lpToken).token1();
        if(isBNB){
            require(token0 == WETH || token1 == WETH, "!BNB");
            address token = token1;
            if(token1 == WETH){
                token = token0;
            }
            paraRouter.removeLiquidityETH(token, actual_amount, 1, 1, msg.sender, block.timestamp.add(600));  
        }else{
             paraRouter.removeLiquidity(
            token0, token1, actual_amount, 1, 1, msg.sender, block.timestamp.add(600));
        }
               
    }

    function withdrawSingle(address tokenOut, uint256 _pid, uint256 _amount, address[][2] memory paths) external{
        require(paths[0].length >= 2 && paths[1].length >= 2, "PE:2");
        require(paths[0][paths[0].length - 1] == tokenOut,"invalid path_");
        require(paths[1][paths[1].length - 1] == tokenOut,"invalid path_");
        (address lpToken, uint actual_amount) = _withdrawWithoutTransfer(_pid, _amount, msg.sender);
        address[2] memory tokens;
        uint[2] memory amounts;
        tokens[0] = IParaPair(lpToken).token0();
        tokens[1] = IParaPair(lpToken).token1();
        approveIfNeeded(lpToken, address(paraRouter), actual_amount);
        (amounts[0], amounts[1]) = paraRouter.removeLiquidity(
            tokens[0], tokens[1], actual_amount, 0, 0, address(this), block.timestamp.add(600));
        for (uint i = 0; i < 2; i++){
            address[] memory path = paths[i];
            require(path[0] == tokens[0] || path[0] == tokens[1], "invalid path_0");
            if(path[0] == tokens[0]){
                swapTokensOut(amounts[0], tokenOut, path);
            }else{
                swapTokensOut(amounts[1], tokenOut, path);    
            }
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function approveIfNeeded(address _token, address spender, uint _amount) private{
        if (IERC20(_token).allowance(address(this), spender) < _amount) {
             IERC20(_token).approve(spender, _amount);
        }
    }

    function swapTokensOut(uint amountIn, address tokenOut, address[] memory path) internal {
        if(path[0] == path[1]){
            _doTransferOut(tokenOut, amountIn);
            return;
        }
        approveIfNeeded(path[0], address(paraRouter), amountIn);
        if(tokenOut == address(0)){
            paraRouter.swapExactTokensForETH(amountIn, 0, path, msg.sender, block.timestamp + 600);
        }else{
            paraRouter.swapExactTokensForTokens(amountIn, 0, path, msg.sender, block.timestamp + 600);
        }
    }

    function _doTransferOut(address _token, uint amount) private{
        if(_token == address(0)){
            IWETH(WETH).withdraw(amount);
            TransferHelper.safeTransferETH(msg.sender, amount);
        }else{
            IERC20(_token).safeTransfer(msg.sender, amount);
        }
    }

    function _doTransferIn(address payer, address _token, uint _amount) private returns(address, uint){
        if(_token == address(0)){
            _amount = msg.value;
            IWETH(WETH).deposit{value: _amount}();
            _token = WETH;
        }else{
            IERC20(_token).safeTransferFrom(address(payer), address(this), _amount);
        }
        return (_token, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        //To get the value in user.amount = 0; calculate
        uint saved_amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;   
        uint fee = saved_amount.mul(withdrawFeeRate).div(10000);
        pool.lpToken.safeTransfer(address(msg.sender), saved_amount.sub(fee));
        pool.lpToken.approve(feeDistributor, fee);
        IFeeDistributor(feeDistributor).incomeWithdrawFee(msg.sender, address(pool.lpToken), fee, saved_amount);
        emit EmergencyWithdraw(msg.sender, _pid, saved_amount);
    }

    function withdrawChange(address[] memory tokens) external{
        for(uint256 i = 0; i < tokens.length; i++){
            uint change = userChange[msg.sender][tokens[i]];
            //set storage
            userChange[msg.sender][tokens[i]] = 0;
            IERC20(tokens[i]).safeTransfer(address(msg.sender), change);
            emit WithdrawChange(msg.sender, tokens[i], change);
        }
    }

    // Safe t42 transfer function, just in case if rounding error causes pool to not have enough T42s.
    function safeT42Transfer(address _to, uint256 _amount) internal {
        uint256 t42Bal = t42.balanceOf(address(this));
        if (_amount > t42Bal) {
            t42.transfer(_to, t42Bal);
        } else {
            t42.transfer(_to, _amount);
        }
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}