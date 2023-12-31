// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;

interface IFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeToSetter() external view returns (address);
    
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(string calldata option0, string calldata option1, address reserveToken) external returns (address pair);
    function setFeeToSetter(address) external;
}