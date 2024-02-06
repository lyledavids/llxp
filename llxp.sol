// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XPChallenge is ERC20, Ownable {
    uint256 public constant LEVEL_THRESHOLD = 1000;
    uint256 public constant BURN_RATE = 2; // 2% burn rate

    mapping(address => uint256) public userXP;
    mapping(address => uint256) public userLevel;

    event XPBurned(address indexed user, uint256 amount);

    constructor() ERC20("XP Token", "XP") Ownable(msg.sender) {
    _mint(msg.sender, 1000000000 * (10**18));
}

    function earnXP(uint256 amount) external {
        _mint(msg.sender, amount);
        userXP[msg.sender] += amount;
        updateLevel(msg.sender);
    }

    function burnXP(uint256 amount) external {
        require(userXP[msg.sender] >= amount, "Insufficient XP balance");

        uint256 burnAmount = (amount * BURN_RATE) / 100;
        _burn(msg.sender, burnAmount);

        userXP[msg.sender] -= amount;
        emit XPBurned(msg.sender, burnAmount);
        updateLevel(msg.sender);
    }

    function getCurrentLevel(address user) external view returns (uint256) {
        return userLevel[user];
    }

    function updateLevel(address user) internal {
        uint256 currentLevel = userLevel[user];
        uint256 userXPBalance = userXP[user];

        while (userXPBalance >= LEVEL_THRESHOLD) {
            currentLevel++;
            userXPBalance -= LEVEL_THRESHOLD;
        }

        userLevel[user] = currentLevel;
    }
}