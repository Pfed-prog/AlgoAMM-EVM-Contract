// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import './libraries/Math.sol';
import './interfaces/IFactory.sol';
import './interfaces/ICallee.sol';
import './interfaces/IPair.sol';

contract Pair is ERC20, IPair {
    using SafeMath for uint;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;

    string public option0;
    string public option1;

    address public token0;
    address public token1;

    address public reserveToken;

    uint private reserve0;           // uses single storage slot, accessible via getReserves
    uint private reserve1;           // uses single storage slot, accessible via getReserves
    uint private baseReserve;
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event
    uint private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint _baseReserve, uint _reserve0, uint _reserve1, uint32 _blockTimestampLast) {
        _baseReserve = baseReserve;
        _reserve0 = reserve0;
        _reserve1 = reserve1;

        _blockTimestampLast = blockTimestampLast;
    }

    /* function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    } */

    constructor(string memory name_, string memory symbol_) ERC20 (name_, symbol_) {
        factory = msg.sender;
    }
    
    // called once by the factory at time of deployment
    function initialize(string calldata _option0, string calldata _option1, address _reserveToken) external {
        require(msg.sender == factory, 'FORBIDDEN');

        reserveToken = _reserveToken;
        option0 = _option0;
        option1 = _option1;

        bytes32 salt0 = keccak256(abi.encodePacked(option0, option1));
        bytes32 salt1 = keccak256(abi.encodePacked(option1, option1));

        token0 = address(
            new ERC20{salt: salt0}(option0, option1)
        );

        token1 = address(
            new ERC20{salt: salt1}(option0, option1)
        );

    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint _reserve0, uint _reserve1) private returns (bool feeOn) {
        address feeTo = IFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast;
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = SafeMath.mul(totalSupply(), rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function mint(address to) external lock returns (uint liquidity) {
        // might need to remove baseReserve
        (uint _baseReserve, uint _reserve0, uint _reserve1,) = getReserves(); 


        uint balance = IERC20(reserveToken).balanceOf(address(this));
        
        uint amount = balance.sub(_reserve0.add(reserve1));

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            liquidity = amount;
        } else {
            liquidity = Math.min(amount.mul(_totalSupply) / _reserve0, amount.mul(_totalSupply) / _reserve1);
        }
        
        require(liquidity > 0, 'INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        //_update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = (_reserve0).mul(_reserve1); // reserve0 and reserve1 are up-to-date
    }

}