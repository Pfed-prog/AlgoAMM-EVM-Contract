// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import './interfaces/IFactory.sol';
import './interfaces/ICallee.sol';
import './interfaces/IPair.sol';

abstract contract Pair is ERC20, IPair {
    using SafeMath for uint;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    string public option0;
    string public option1;

    address public reserveToken;

    uint private reserve0;           // uses single storage slot, accessible via getReserves
    uint private reserve1;           // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint _reserve0, uint _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    }

    event Mint(address indexed sender, uint amount0, uint amount1);

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(string calldata _option0, string calldata _option1) external {
        require(msg.sender == factory, 'FORBIDDEN');
        option0 = _option0;
        option1 = _option1;
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        //uint _kLast = kLast; // gas savings
/*         if (feeOn) {
            if (_kLast != 0) {
                uint rootK = SafeMath.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = SafeMath.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        } */
    }

    function mint(address to) external lock returns (uint liquidity) {
        (uint _reserve0, uint _reserve1,) = getReserves(); // gas savings
        uint balance = IERC20(reserveToken).balanceOf(address(this));
        
        // uint amount0 = balance0.sub(_reserve0);


        //bool feeOn = _mintFee(_reserve0, _reserve1);
        //uint _totalSupply = totalSupply; 
/*         if (_totalSupply == 0) {
            liquidity = SafeMath.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = SafeMath.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity); */

        //_update(balance0, balance1, _reserve0, _reserve1);
        //if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        //emit Mint(msg.sender, amount0, amount1);
    }

}