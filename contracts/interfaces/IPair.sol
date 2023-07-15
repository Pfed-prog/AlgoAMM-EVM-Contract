// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;

interface IPair {
    //function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function option0() external view returns (string calldata);
    function option1() external view returns (string calldata);
    function token0Address() external view returns (address);
    function token1Address() external view returns (address);
    //function getReserves() external view returns (uint baseReserve, uint reserve0, uint reserve1);
    // function price0CumulativeLast() external view returns (uint);
    // function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    //function mint(address to) external returns (uint liquidity);
    // function burn(address to) external returns (uint amount0, uint amount1);
    // function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function initialize(string calldata option0, string calldata option1, address reserveToken) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
}