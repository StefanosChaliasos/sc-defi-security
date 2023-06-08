// SPDX-License-Identifier: GPL-3
pragma solidity ^0.7.6;

interface IImpossibleERC20 {
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
}



interface IImpossibleCallee {
    function ImpossibleCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}



interface IImpossibleFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    event UpdatedGovernance(address governance);

    function feeTo() external view returns (address);

    function governance() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setGovernance(address) external;
}



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



// a library for performing various math operations

library Math {
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










// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
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
}


contract ImpossibleERC20 is IImpossibleERC20 {
    using SafeMath for uint256;

    string public constant override name = 'Impossible Swap LPs';
    string public constant override symbol = 'IF-LP';
    uint8 public constant override decimals = 18;
    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    bytes32 public override DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant override PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public override nonces;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(deadline >= block.timestamp, 'IF: EXPIRED');
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    '\x19\x01',
                    DOMAIN_SEPARATOR,
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'IF: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
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
abstract contract ReentrancyGuard {
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

    constructor() {
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
        require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}







interface IImpossiblePair is IImpossibleERC20 {
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint256 reserve0, uint256 reserve1);
    event changeInvariant(bool _isXybk, uint256 _ratioStart, uint256 _ratioEnd);
    event updatedTradeFees(uint256 _prevFee, uint256 _newFee);
    event updatedDelay(uint256 _oldDelay, uint256 _newDelay);
    event updatedHardstops(uint8 _ratioStart, uint8 _ratioEnd);
    event updatedBoost(
        uint32 _prevBoost0,
        uint32 _prevBoost1,
        uint32 _newBoost0,
        uint32 _newBoost1,
        uint256 _start,
        uint256 _end
    );

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address); // address of token0

    function token1() external view returns (address); // address of token1

    function router() external view returns (address); // address of token1

    function getReserves() external view returns (uint256, uint256); // reserves of token0/token1

    function calcBoost() external view returns (uint256, uint256);

    function mint(address) external returns (uint256);

    function burn(address) external returns (uint256, uint256);

    function swap(
        uint256,
        uint256,
        address,
        bytes calldata
    ) external;

    function cheapSwap(
        uint256,
        uint256,
        address,
        bytes calldata
    ) external;

    function skim(address to) external;

    function sync() external;

    function getFeeAndXybk() external view returns (uint256, bool); // Uses single storage slot, save gas

    function delay() external view returns (uint256); // Amount of time delay required before any change to boost etc, denoted in seconds

    function initialize(
        address,
        address,
        address
    ) external;
}





contract ImpossiblePair is IImpossiblePair, ImpossibleERC20, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public constant override MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    uint256 private constant FEE = 201; // 1/201=0.4795% fee collected from LP if (feeOn)
    uint256 private constant THIRTY_MINS = 600; // 30 mins in 3 second blocks
    uint256 private constant ONE_DAY = 28800; // 50 for testing, will be 24*60*60/3 = 28800 in production.
    uint256 private constant TWO_WEEKS = 403200; //2 * 7 * 24 * 60 * 60 / 3;

    address public override factory;
    address public override token0;
    address public override token1;
    address public override router;

    uint128 private reserve0; // Single storage slot
    uint128 private reserve1; // Single storage slot

    uint256 public kLast;

    // Variables for xybk invariant.
    uint32 private boost0; // Boost0 applies when pool balance0 >= balance1 (when token1 is the more expensive token)
    uint32 private boost1; // Boost1 applies when pool balance1 > balance0 (when token0 is the more expensive token)
    uint32 private newBoost0;
    uint32 private newBoost1;
    uint16 private tradeFee; // Tradefee=amt of fees collected per swap denoted in basis points
    bool private isXybk;

    uint256 public startBlockChange; // Boost linearly interpolates between start/end block when changing
    uint256 public endBlockChange; // BSC mines 10m blocks a year. uint32 lasts 400 years before overflowing

    uint8 public ratioStart;
    uint8 public ratioEnd;

    // Delay sets the duration for boost changes over time
    uint256 public override delay;

    modifier onlyIFRouter() {
        require(msg.sender == router, 'IF: FORBIDDEN');
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == IImpossibleFactory(factory).governance(), 'IF: FORBIDDEN'); // NOTE: Comment out when running tests to allow calls to makeXybk
        _;
    }

    function getFeeAndXybk() external view override returns (uint256 _tradeFee, bool _isXybk) {
        _tradeFee = tradeFee;
        _isXybk = isXybk;
    }

    // Get reserves. No timestamp unlike uni
    function getReserves() public view override returns (uint256 _reserve0, uint256 _reserve1) {
        _reserve0 = uint256(reserve0);
        _reserve1 = uint256(reserve1);
    }

    // Helper function to get boost values
    function getBoost()
        internal
        view
        returns (
            uint32 _newBoost0,
            uint32 _newBoost1,
            uint32 _boost0,
            uint32 _boost1
        )
    {
        _newBoost0 = newBoost0;
        _newBoost1 = newBoost1;
        _boost0 = boost0;
        _boost1 = boost1;
    }

    // Helper function to calculate interpolated boost values. Allows for staircasing change of boost over time. Decimal places rounds down
    function linInterpolate(
        uint32 oldBst,
        uint32 newBst,
        uint256 end
    ) internal view returns (uint256) {
        uint256 start = startBlockChange;
        if (newBst > oldBst) {
            // old + diff * (curr-start) / (end-start)
            return
                uint256(oldBst).add(
                    (uint256(newBst).sub(uint256(oldBst))).mul(block.number.sub(start)).div(end.sub(start))
                );
        } else {
            // old - diff * (curr-start) / (end-start)
            return
                uint256(oldBst).sub(
                    (uint256(oldBst).sub(uint256(newBst))).mul(block.number.sub(start)).div(end.sub(start))
                );
        }
    }

    // Calculates boost if in the middle of a linear interpolation, else return _newBoosts
    function calcBoost() public view override returns (uint256 _boost0, uint256 _boost1) {
        uint256 _endBlockChange = endBlockChange;
        if (block.number >= _endBlockChange) {
            (uint32 _newBoost0, uint32 _newBoost1, , ) = getBoost();
            _boost0 = uint256(_newBoost0);
            _boost1 = uint256(_newBoost1);
        } else {
            (uint32 _newBoost0, uint32 _newBoost1, uint32 _oldBoost0, uint32 _oldBoost1) = getBoost();
            _boost0 = linInterpolate(_oldBoost0, _newBoost0, _endBlockChange);
            _boost1 = linInterpolate(_oldBoost1, _newBoost1, _endBlockChange);
        }
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'IF: TRANSFER_FAILED');
    }

    // Causes pool to use xybk invariant to uni invariant
    function makeXybk(
        uint8 _ratioStart,
        uint8 _ratioEnd,
        uint32 _boost0,
        uint32 _boost1
    ) external onlyGovernance nonReentrant {
        require(!isXybk, 'IF: IS_ALREADY_XYBK');
        require(0 <= _ratioStart && _ratioStart < _ratioEnd && _ratioEnd <= 100, 'IF: IF: INVALID_RATIO');
        require(_boost0 >= 1 && _boost1 >= 1 && _boost0 <= 1000000 && _boost1 <= 1000000, 'IF: INVALID_BOOST');
        require(block.number >= endBlockChange, 'IF: BOOST_ALREADY_CHANGING');
        (uint256 _reserve0, uint256 _reserve1) = getReserves();
        _mintFee(_reserve0, _reserve1);
        boost0 = newBoost0;
        boost1 = newBoost1;
        newBoost0 = _boost0;
        newBoost1 = _boost1;
        startBlockChange = block.number;
        endBlockChange = block.number + delay;
        ratioStart = _ratioStart;
        ratioEnd = _ratioEnd;
        isXybk = true;
        emit changeInvariant(isXybk, _ratioStart, _ratioEnd);
        emit updatedBoost(boost0, boost1, newBoost0, newBoost1, startBlockChange, endBlockChange);
    }

    // makeUni requires pool to already be at boost=1. Setting isXybk=false makes efficient uni swaps.
    // Removing isXybk state might save gas on xybk swaps. Then, isXybk is a function that returns calcBoost() == (1, 1)
    function makeUni() external onlyGovernance nonReentrant {
        require(isXybk, 'IF: IS_ALREADY_UNI');
        require(block.number >= endBlockChange, 'IF: BOOST_ALREADY_CHANGING');
        require(newBoost0 == 1 && newBoost1 == 1, 'IF: INVALID_BOOST');
        isXybk = false;
        boost0 = 1;
        boost1 = 1;
        ratioStart = 0;
        ratioEnd = 100;
        emit changeInvariant(isXybk, ratioStart, ratioEnd);
    }

    function updateTradeFees(uint16 _fee) external onlyGovernance {
        require(_fee <= 1000, 'IF: INVALID_FEE'); // capped at 10%
        emit updatedTradeFees(tradeFee, _fee);
        // fee is uint so can't be negative
        tradeFee = _fee;
    }

    // Allows delay change. Default is a 1 day delay
    // Timelock of 30 minutes is a minimum
    function updateDelay(uint256 _delay) external onlyGovernance {
        require(_delay >= THIRTY_MINS && delay <= TWO_WEEKS, 'IF: INVALID_DELAY');
        emit updatedDelay(delay, _delay);
        delay = _delay;
    }

    // Updates lower/upper hardstops for a pool
    function updateHardstops(uint8 _ratioStart, uint8 _ratioEnd) external onlyGovernance nonReentrant {
        require(isXybk, 'IF: IS_CURRENTLY_UNI');
        require(0 <= _ratioStart && _ratioStart < _ratioEnd && _ratioEnd <= 100, 'IF: INVALID_RATIO');
        ratioStart = _ratioStart;
        ratioEnd = _ratioEnd;
        emit updatedHardstops(_ratioStart, _ratioEnd);
    }

    // Updates boost values. Boost changes over delay number of blocks.
    function updateBoost(uint32 _boost0, uint32 _boost1) external onlyGovernance nonReentrant {
        require(isXybk, 'IF: IS_CURRENTLY_UNI');
        require(_boost0 >= 1 && _boost1 >= 1 && _boost0 <= 1000000 && _boost1 <= 1000000, 'IF: INVALID_BOOST');
        require(block.number >= endBlockChange, 'IF: BOOST_ALREADY_CHANGING');
        boost0 = newBoost0;
        boost1 = newBoost1;
        newBoost0 = _boost0;
        newBoost1 = _boost1;
        startBlockChange = block.number;
        endBlockChange = block.number + delay;
        emit updatedBoost(boost0, boost1, newBoost0, newBoost1, startBlockChange, endBlockChange);
    }

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(
        address _token0,
        address _token1,
        address _router
    ) external override {
        require(msg.sender == factory, 'IF: FORBIDDEN'); // sufficient check
        router = _router;
        token0 = _token0;
        token1 = _token1;
        boost0 = 1;
        boost1 = 1;
        newBoost0 = 1;
        newBoost1 = 1;
        tradeFee = 30; // 30 basis points
        delay = ONE_DAY;
    }

    // update reserves and, on the first call per block, price accumulators
    // PriceCumulativeLast calculations will cost too much gas for Impossibleswap invariant - scrap feature
    function _update(uint256 balance0, uint256 balance1) private {
        reserve0 = uint128(balance0);
        reserve1 = uint128(balance1);
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 4/5th of the growth in sqrt(k)
    function _mintFee(uint256 _reserve0, uint256 _reserve1) private returns (bool feeOn) {
        address feeTo = IImpossibleFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK =
                    isXybk ? Math.sqrt(_xybkComputeK(_reserve0, _reserve1)) : Math.sqrt(_reserve0.mul(_reserve1));
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply.mul(rootK.sub(rootKLast)).mul(4);
                    uint256 denominator = rootK.add(rootKLast.mul(4));
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    // Unchanged - LP tokens represent proportion of tokens in pool
    function mint(address to) external override nonReentrant returns (uint256 liquidity) {
        (uint256 _reserve0, uint256 _reserve1) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0.sub(_reserve0);
        uint256 amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'IF: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1);
        if (feeOn) kLast = isXybk ? _xybkComputeK(balance0, balance1) : balance0.mul(balance1);
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external override nonReentrant returns (uint256 amount0, uint256 amount1) {
        (uint256 _reserve0, uint256 _reserve1) = getReserves(); // gas savings
        bool feeOn = _mintFee(_reserve0, _reserve1);
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        {
            // Scope for _totalSupply is only within this block
            uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
            amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
            amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution

            require(amount0 > 0 && amount1 > 0, 'IF: INSUFFICIENT_LIQUIDITY_BURNED');

            if (feeOn) {
                uint256 _FEE = FEE;
                amount0 -= amount0.div(_FEE);
                amount1 -= amount1.div(_FEE);
                // Sends the 0.4975% Fee of LP tokens to the IImpossibleFactory feeTo Address
                _safeTransfer(address(this), IImpossibleFactory(factory).feeTo(), liquidity.div(_FEE));
                _burn(address(this), liquidity.sub(liquidity.div(_FEE)));
            } else {
                _burn(address(this), liquidity);
            }

            // Outside of this if feeOn statement, returns the appropriate funds to the user
            _safeTransfer(_token0, to, amount0);
            _safeTransfer(_token1, to, amount1);
        }

        // Grabs the new balances of the tokens in the LP pool after the withdrawal takes place
        {
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
            _update(balance0, balance1);
            if (feeOn) kLast = isXybk ? _xybkComputeK(balance0, balance1) : balance0.mul(balance1);
        }
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // This swap function can only be called from the Impossible router which has implemented checks
    function cheapSwap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external override onlyIFRouter nonReentrant {
        if (amount0Out > 0) _safeTransfer(token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(token1, to, amount1Out); // optimistically transfer tokens
        if (data.length > 0) IImpossibleCallee(to).ImpossibleCall(msg.sender, amount0Out, amount1Out, data);
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        if (isXybk) {
            bool side = balance0 >= balance1;
            uint256 ratio = side ? ratioStart : ratioEnd;
            if (side && ratio > 0) {
                require(balance1.mul(ratio) < balance0.mul(100 - ratio), 'IF: EXCEED_UPPER_STOP');
            } else if (!side && ratio < 100) {
                require(balance0.mul(ratio) > balance1.mul(100 - ratio), 'IF: EXCEED_LOWER_STOP');
            }
        }
        (uint256 _reserve0, uint256 _reserve1) = getReserves(); // gas savings
        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        _update(balance0, balance1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    // Without safety checks, calling swap directly will throw failure at bounds
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external override nonReentrant {
        require(amount0Out > 0 || amount1Out > 0, 'IF: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint256 _reserve0, uint256 _reserve1) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'IF: INSUFFICIENT_LIQUIDITY');

        uint256 balance0;
        uint256 balance1;
        uint256 amount0In;
        uint256 amount1In;
        {
            require(to != token0 && to != token1, 'IF: INVALID_TO');
            if (amount0Out > 0) _safeTransfer(token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(token1, to, amount1Out); // optimistically transfer tokens
            if (data.length > 0) IImpossibleCallee(to).ImpossibleCall(msg.sender, amount0Out, amount1Out, data);
            balance0 = IERC20(token0).balanceOf(address(this));
            balance1 = IERC20(token1).balanceOf(address(this));
            // Check bounds
            amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
            amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        }

        require(amount0In > 0 || amount1In > 0, 'IF: INSUFFICIENT_INPUT_AMOUNT');

        {
            // Avoid stack too deep errors
            bool _isXybk = isXybk;
            if (_isXybk) {
                bool side = balance0 >= balance1;
                uint256 ratio = side ? ratioStart : ratioEnd;
                if (side && ratio > 0) {
                    require(balance1.mul(ratio) < balance0.mul(100 - ratio), 'IF: EXCEED_UPPER_STOP');
                } else if (!side && ratio < 100) {
                    require(balance0.mul(ratio) > balance1.mul(100 - ratio), 'IF: EXCEED_LOWER_STOP');
                }
            }
            uint256 _tradeFee = uint256(tradeFee); // Gas savings?
            uint256 balance0Adjusted = balance0.mul(10000).sub(amount0In.mul(_tradeFee)); // tradeFee amt of basis pts
            uint256 balance1Adjusted = balance1.mul(10000).sub(amount1In.mul(_tradeFee)); // tradeFee amt of basis pts
            _isXybk
                ? require(
                    _xybkCheckK(balance0Adjusted, balance1Adjusted, _xybkComputeK(_reserve0, _reserve1).mul(10000**2)),
                    'IF: INSUFFICIENT_XYBK_K'
                )
                : require(
                    balance0Adjusted.mul(balance1Adjusted) >= _reserve0.mul(_reserve1).mul(10000**2),
                    'IF: INSUFFICIENT_UNI_K'
                );
        }

        _update(balance0, balance1);

        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // Calculating new stableswap invariant K value given balance0, balance1
    // Exact calculation of K given token balances. Called after mint/burn/swaps
    // let i=(boost-1)*(x+y)/(4*boost-2); sqrtK = sqrt(i**2 + b0*b1/(2*boost-1)) + i
    function _xybkComputeK(uint256 _balance0, uint256 _balance1) private view returns (uint256 k) {
        (uint256 _boost0, uint256 _boost1) = calcBoost();
        uint256 boost = (_balance0 > _balance1) ? _boost0.sub(1) : _boost1.sub(1);
        uint256 denom = boost.mul(2).add(1); // 1+2*boost
        uint256 term = boost.mul(_balance0.add(_balance1)).div(denom.mul(2)); // boost*(x+y)/(2+4*boost)
        k = (Math.sqrt(term**2 + _balance0.mul(_balance1).div(denom)) + term)**2;
    }

    // Calculating new stableswap invariant K given balance0, balance1, old K
    // Called to check K invariance post-swap
    // let i=(boost-1)*sqrt(K_old); K_new = (b0+i)*(b1+i)/(boost**2)
    // If K_new > K_old, this check still maintains correctness
    function _xybkCheckK(
        uint256 _balance0,
        uint256 _balance1,
        uint256 _oldK
    ) private view returns (bool) {
        uint256 sqrtOldK = Math.sqrt(_oldK);
        (uint256 _boost0, uint256 _boost1) = calcBoost();
        uint256 boost = (_balance0 > _balance1) ? _boost0.sub(1) : _boost1.sub(1);
        uint256 innerTerm = boost.mul(sqrtOldK);
        return (_balance0.add(innerTerm)).mul(_balance1.add(innerTerm)).div((boost.add(1))**2) >= _oldK;
    }

    // force balances to match reserves
    function skim(address to) external override nonReentrant {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        (uint256 _reserve0, uint256 _reserve1) = getReserves();
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(_reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(_reserve1));
    }

    // force reserves to match balances
    function sync() external override nonReentrant {
        uint256 _balance0 = IERC20(token0).balanceOf(address(this));
        uint256 _balance1 = IERC20(token1).balanceOf(address(this));
        _update(_balance0, _balance1);
    }
}



