// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;

interface IPair {
    function factory() external view returns (address);
    function option0() external view returns (string calldata);
    function option1() external view returns (string calldata);
    function token0Address() external view returns (address);
    function token1Address() external view returns (address);

    function initialize(string calldata option0, string calldata option1, address reserveToken) external;
    function resolve(uint result) external;
    event Mint(address indexed sender, uint amount0, uint amount1);
}