// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import './libraries/Math.sol';
import './interfaces/IFactory.sol';
import './interfaces/ICallee.sol';
import './interfaces/IPair.sol';
import './Token.sol';

contract Pair is IPair {
    using SafeMath for uint;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;

    string public option0;
    string public option1;

    address public token0Address;
    address public token1Address;

    Token token0;
    Token token1;

    address public reserveToken; //underlying reserve token address

    uint private reserve0;           // 
    uint private reserve1;           // 
    uint private baseReserve;

    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent amountOut event
    uint private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
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

        token0 = new Token{salt: salt0}(option0, option1);
        token0Address = address(token0);

        token1 = new Token{salt: salt1}(option0, option1);
        token1Address = address(token1);
    }

    function voteYes(address to) external lock returns (uint amountOut) {

        uint balance = IERC20(reserveToken).balanceOf(address(this));

        uint totalPositions = reserve0.add(reserve1);

        uint amountIn = balance.sub(totalPositions);

        if (totalPositions == 0) {
            amountOut = amountIn.div(2);
            reserve0 = reserve0.add(amountOut);
            reserve1 = reserve1.add(amountOut);

            token0.mint(to, amountOut);
        } else {
            amountOut = reserve0.mul(amountIn.div(reserve1.add(amountIn)));
        }        
    }


    function voteNo(address to) external lock returns (uint amountOut) {

        uint balance = IERC20(reserveToken).balanceOf(address(this));

        uint totalPositions = reserve0.add(reserve1);

        uint amount = balance.sub(totalPositions);

        if (totalPositions == 0) {
            amountOut = Math.sqrt(amount);
        }
        require(amountOut > 0, 'INSUFFICIENT_amountOut_MINTED');

        token1.mint(to, amountOut);
    }


    //function reedem(){}

    //function resolve(){}

}