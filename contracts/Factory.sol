// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;

import './interfaces/IFactory.sol';
import './Pair.sol';

abstract contract Factory is IFactory {
    address public feeTo;
    address public feeToSetter;

    mapping(string => mapping(string => address)) public getPair;
    address[] public allPairs;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(string calldata option0, string calldata option1) external returns (address pair) {
        require(getPair[option0][option1] == address(0), 'PAIR_EXISTS');

        IPair(pair).initialize(option0, option1);
        getPair[option0][option1] = pair;
        getPair[option1][option0] = pair;
        allPairs.push(pair);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}