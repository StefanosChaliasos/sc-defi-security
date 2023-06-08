pragma solidity ^0.5.7;


interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface ExchangeInterface {
    function swapEtherToToken (uint _ethAmount, address _tokenAddress, uint _maxAmount) payable external returns(uint, uint);
    function swapTokenToEther (address _tokenAddress, uint _amount, uint _maxAmount) external returns(uint);
    function swapTokenToToken(address _src, address _dest, uint _amount) external payable returns(uint);

    function getExpectedRate(address src, address dest, uint srcQty) external view
        returns (uint expectedRate);
}

contract TokenInterface {
    function allowance(address, address) public returns (uint);
    function balanceOf(address) public returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
    function deposit() public payable;
    function withdraw(uint) public;
}

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function div(uint x, uint y) internal pure returns (uint z) {
        return x / y;
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract SaverExchangeConstantAddresses {
    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address payable public constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;
    address public constant DISCOUNT_ADDRESS = 0x1b14E8D511c9A4395425314f849bD737BAF8208F;

    address public constant KYBER_WRAPPER = 0x8F337bD3b7F2b05d9A8dC8Ac518584e833424893;
    address public constant UNISWAP_WRAPPER = 0x1e30124FDE14533231216D95F7798cD0061e5cf8;
    address public constant OASIS_WRAPPER = 0x891f5A171f865031b0f3Eb9723bb8f68C901c9FE;

    // Our contracts
    address public constant ERC20_PROXY_0X = 0x95E6F48254609A6ee006F7D493c8e5fB97094ceF;
}

contract Discount {

    address public owner;
    mapping (address => CustomServiceFee) public serviceFees;

    uint constant MAX_SERVICE_FEE = 400;

    struct CustomServiceFee {
        bool active;
        uint amount;
    }

    constructor() public {
        owner = msg.sender;
    }

    function isCustomFeeSet(address _user) public view returns (bool) {
        return serviceFees[_user].active;
    }

    function getCustomServiceFee(address _user) public view returns (uint) {
        return serviceFees[_user].amount;
    }

    function setServiceFee(address _user, uint _fee) public {
        require(msg.sender == owner, "Only owner");
        require(_fee >= MAX_SERVICE_FEE || _fee == 0);

        serviceFees[_user] = CustomServiceFee({
            active: true,
            amount: _fee
        });
    }

    function disableServiceFee(address _user) public {
        require(msg.sender == owner, "Only owner");

        serviceFees[_user] = CustomServiceFee({
            active: false,
            amount: 0
        });
    }
}

contract SaverExchange is DSMath, SaverExchangeConstantAddresses {

    uint public constant SERVICE_FEE = 800; // 0.125% Fee

    event Swap(address src, address dest, uint amountSold, uint amountBought, address wrapper);

    function swapTokenToToken(address _src, address _dest, uint _amount, uint _minPrice, uint _exchangeType, address _exchangeAddress, bytes memory _callData, uint _0xPrice) public payable {
        // use this to avoid stack too deep error
        address[3] memory orderAddresses = [_exchangeAddress, _src, _dest];

        if (orderAddresses[1] == KYBER_ETH_ADDRESS) {
            require(msg.value >= _amount, "msg.value smaller than amount");
        } else {
            require(ERC20(orderAddresses[1]).transferFrom(msg.sender, address(this), _amount), "Not able to withdraw wanted amount");
        }

        uint fee = takeFee(_amount, orderAddresses[1]);
        _amount = sub(_amount, fee);
        // [tokensReturned, tokensLeft]
        uint[2] memory tokens;
        address wrapper;
        uint price;
        bool success;

        // at the beggining tokensLeft equals _amount
        tokens[1] = _amount;

        if (_exchangeType == 4) {
            if (orderAddresses[1] != KYBER_ETH_ADDRESS) {
                ERC20(orderAddresses[1]).approve(address(ERC20_PROXY_0X), _amount);
            }

            (success, tokens[0], ) = takeOrder(orderAddresses, _callData, address(this).balance, _amount);
            // either it reverts or order doesn't exist anymore, we reverts as it was explicitely asked for this exchange
            require(success && tokens[0] > 0, "0x transaction failed");
            wrapper = address(_exchangeAddress);
        }

        if (tokens[0] == 0) {
            (wrapper, price) = getBestPrice(_amount, orderAddresses[1], orderAddresses[2], _exchangeType);

            require(price > _minPrice || _0xPrice > _minPrice, "Slippage hit");

            // handle 0x exchange, if equal price, try 0x to use less gas
            if (_0xPrice >= price) {
                if (orderAddresses[1] != KYBER_ETH_ADDRESS) {
                    ERC20(orderAddresses[1]).approve(address(ERC20_PROXY_0X), _amount);
                }
                (success, tokens[0], tokens[1]) = takeOrder(orderAddresses, _callData, address(this).balance, _amount);
                // either it reverts or order doesn't exist anymore
                if (success && tokens[0] > 0) {
                    wrapper = address(_exchangeAddress);
                    emit Swap(orderAddresses[1], orderAddresses[2], _amount, tokens[0], wrapper);
                }
            }

            if (tokens[1] > 0) {
                // in case 0x swapped just some amount of tokens and returned everything else
                if (tokens[1] != _amount) {
                    (wrapper, price) = getBestPrice(tokens[1], orderAddresses[1], orderAddresses[2], _exchangeType);
                }

                // in case 0x failed, price on other exchanges still needs to be higher than minPrice
                require(price > _minPrice, "Slippage hit onchain price");
                if (orderAddresses[1] == KYBER_ETH_ADDRESS) {
                    (tokens[0],) = ExchangeInterface(wrapper).swapEtherToToken.value(tokens[1])(tokens[1], orderAddresses[2], uint(-1));
                } else {
                    ERC20(orderAddresses[1]).transfer(wrapper, tokens[1]);

                    if (orderAddresses[2] == KYBER_ETH_ADDRESS) {
                        tokens[0] = ExchangeInterface(wrapper).swapTokenToEther(orderAddresses[1], tokens[1], uint(-1));
                    } else {
                        tokens[0] = ExchangeInterface(wrapper).swapTokenToToken(orderAddresses[1], orderAddresses[2], tokens[1]);
                    }
                }

                emit Swap(orderAddresses[1], orderAddresses[2], _amount, tokens[0], wrapper);
            }
        }

        // return whatever is left in contract
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }

        // return if there is any tokens left
        if (orderAddresses[2] != KYBER_ETH_ADDRESS) {
            if (ERC20(orderAddresses[2]).balanceOf(address(this)) > 0) {
                ERC20(orderAddresses[2]).transfer(msg.sender, ERC20(orderAddresses[2]).balanceOf(address(this)));
            }
        }

        if (orderAddresses[1] != KYBER_ETH_ADDRESS) {
            if (ERC20(orderAddresses[1]).balanceOf(address(this)) > 0) {
                ERC20(orderAddresses[1]).transfer(msg.sender, ERC20(orderAddresses[1]).balanceOf(address(this)));
            }
        }
    }

    // @notice Takes order from 0x and returns bool indicating if it is successful
    // @param _addresses [exchange, src, dst]
    // @param _data Data to send with call
    // @param _value Value to send with call
    // @param _amount Amount being sold
    function takeOrder(address[3] memory _addresses, bytes memory _data, uint _value, uint _amount) private returns(bool, uint, uint) {
        bool success;

        (success, ) = _addresses[0].call.value(_value)(_data);

        uint tokensLeft = _amount;
        uint tokensReturned = 0;
        if (success){
            // check how many tokens left from _src
            if (_addresses[1] == KYBER_ETH_ADDRESS) {
                tokensLeft = address(this).balance;
            } else {
                tokensLeft = ERC20(_addresses[1]).balanceOf(address(this));
            }

            // check how many tokens are returned
            if (_addresses[2] == KYBER_ETH_ADDRESS) {
                TokenInterface(WETH_ADDRESS).withdraw(TokenInterface(WETH_ADDRESS).balanceOf(address(this)));
                tokensReturned = address(this).balance;
            } else {
                tokensReturned = ERC20(_addresses[2]).balanceOf(address(this));
            }
        }

        return (success, tokensReturned, tokensLeft);
    }

    /// @notice Returns the best estimated price from 2 exchanges
    /// @param _amount Amount of source tokens you want to exchange
    /// @param _srcToken Address of the source token
    /// @param _destToken Address of the destination token
    /// @return (address, uint) The address of the best exchange and the exchange price
    function getBestPrice(uint _amount, address _srcToken, address _destToken, uint _exchangeType) public returns (address, uint) {
        uint expectedRateKyber;
        uint expectedRateUniswap;
        uint expectedRateOasis;


        if (_exchangeType == 1) {
            return (OASIS_WRAPPER, getExpectedRate(OASIS_WRAPPER, _srcToken, _destToken, _amount));
        }

        if (_exchangeType == 2) {
            return (KYBER_WRAPPER, getExpectedRate(KYBER_WRAPPER, _srcToken, _destToken, _amount));
        }

        if (_exchangeType == 3) {
            expectedRateUniswap = getExpectedRate(UNISWAP_WRAPPER, _srcToken, _destToken, _amount);
            expectedRateUniswap = expectedRateUniswap * (10 ** (18 - getDecimals(_destToken)));
            return (UNISWAP_WRAPPER, expectedRateUniswap);
        }

        expectedRateKyber = getExpectedRate(KYBER_WRAPPER, _srcToken, _destToken, _amount);
        expectedRateUniswap = getExpectedRate(UNISWAP_WRAPPER, _srcToken, _destToken, _amount);
        expectedRateUniswap = expectedRateUniswap * (10 ** (18 - getDecimals(_destToken)));
        expectedRateOasis = getExpectedRate(OASIS_WRAPPER, _srcToken, _destToken, _amount);

        if ((expectedRateKyber >= expectedRateUniswap) && (expectedRateKyber >= expectedRateOasis)) {
            return (KYBER_WRAPPER, expectedRateKyber);
        }

        if ((expectedRateOasis >= expectedRateKyber) && (expectedRateOasis >= expectedRateUniswap)) {
            return (OASIS_WRAPPER, expectedRateOasis);
        }

        if ((expectedRateUniswap >= expectedRateKyber) && (expectedRateUniswap >= expectedRateOasis)) {
            return (UNISWAP_WRAPPER, expectedRateUniswap);
        }
    }

    function getExpectedRate(address _wrapper, address _srcToken, address _destToken, uint _amount) public returns(uint) {
        bool success;
        bytes memory result;

        (success, result) = _wrapper.call(abi.encodeWithSignature("getExpectedRate(address,address,uint256)", _srcToken, _destToken, _amount));

        if (success) {
            return sliceUint(result, 0);
        } else {
            return 0;
        }
    }

    /// @notice Takes a feePercentage and sends it to wallet
    /// @param _amount Dai amount of the whole trade
    /// @return feeAmount Amount in Dai owner earned on the fee
    function takeFee(uint _amount, address _token) internal returns (uint feeAmount) {
        uint fee = SERVICE_FEE;

        if (Discount(DISCOUNT_ADDRESS).isCustomFeeSet(msg.sender)) {
            fee = Discount(DISCOUNT_ADDRESS).getCustomServiceFee(msg.sender);
        }

        if (fee == 0) {
            feeAmount = 0;
        } else {
            feeAmount = _amount / SERVICE_FEE;
            if (_token == KYBER_ETH_ADDRESS) {
                WALLET_ID.transfer(feeAmount);
            } else {
                ERC20(_token).transfer(WALLET_ID, feeAmount);
            }
        }
    }


    function getDecimals(address _token) internal view returns(uint) {
        // DGD
        if (_token == address(0xE0B7927c4aF23765Cb51314A0E0521A9645F0E2A)) {
            return 9;
        }
        // USDC
        if (_token == address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)) {
            return 6;
        }
        // WBTC
        if (_token == address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599)) {
            return 8;
        }

        return 18;
    }

    function sliceUint(bytes memory bs, uint start) internal pure returns (uint) {
        require(bs.length >= start + 32, "slicing out of range");

        uint x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }

        return x;
    }

    // receive eth from wrappers
    function() external payable {}
}