// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LearningAchievementToken is ERC20, Ownable {

    // Mapping to track learning achievements
    mapping(address => mapping(uint256 => bool)) public learnerAchievements; // learner → courseId → achievement completed
    
    // Emitted when tokens are minted as rewards
    event TokensMinted(address indexed learner, uint256 amount, uint256 courseId);

    // Constructor to initialize the token
    constructor() ERC20("LearningAchievementToken", "LAT") Ownable(msg.sender) {}

    // Override decimals to issue whole-number tokens only
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    // Batch mint tokens for multiple learners at once
    function batchMintForAchievement(address[] calldata learners, uint256[] calldata amounts, uint256 courseId) external onlyOwner {
        require(learners.length == amounts.length, "Mismatched input arrays");

        for (uint256 i = 0; i < learners.length; i++) {
            address learner = learners[i];
            uint256 amount = amounts[i];
            
            // Ensure the learner has not already received the reward for the course
            require(!learnerAchievements[learner][courseId], "Achievement already rewarded");

            // Mark achievement as completed for the learner
            learnerAchievements[learner][courseId] = true;

            // Mint tokens to the learner's address
            _mint(learner, amount);

            // Emit an event to log the token minting
            emit TokensMinted(learner, amount, courseId);
        }
    }

    // Transfer tokens from one user to another (standard ERC20 transfer)
    function transferTokens(address to, uint256 amount) external {
        _transfer(msg.sender, to, amount);
    }

    // Check the balance of a specific user
    function checkBalance(address account) external view returns (uint256) {
        return balanceOf(account);
    }

    // Admin function to mint tokens to a specific address (optional, for flexibility)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Admin function to burn tokens (optional)
    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}
