// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RPSToken is ERC20 {
    address private _owner;

    constructor() ERC20("RPSToken", "RPS") {
        _owner = msg.sender;
    }
}
