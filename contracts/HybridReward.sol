// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HybridReward is ERC1155, Ownable {
    // Mapping to track if a user has earned a specific badge (non-fungible)
    mapping(address => mapping(uint256 => bool)) public learnerBadges;

    // Mapping to track XP balance for learners (fungible tokens)
    mapping(address => mapping(uint256 => uint256)) public learnerXP;

    // Events
    event XPMinted(address indexed learner, uint256 amount, uint256 xpId);
    event BadgeMinted(address indexed learner, uint256 badgeId);

    // Constructor: URI is passed dynamically from the deployment script
    constructor(string memory initialURI) ERC1155(initialURI) Ownable(msg.sender) {}

    // Mint XP for a learner (fungible token)
    function mintXP(address learner, uint256 amount, uint256 xpId) external onlyOwner {
        _mint(learner, xpId, amount, "");
        learnerXP[learner][xpId] += amount;
        emit XPMinted(learner, amount, xpId);
    }

    // Mint a badge for a learner (non-fungible token)
    function mintBadge(address learner, uint256 badgeId) external onlyOwner {
        require(!learnerBadges[learner][badgeId], "Badge already minted for this learner");
        _mint(learner, badgeId, 1, "");
        learnerBadges[learner][badgeId] = true;
        emit BadgeMinted(learner, badgeId);
    }

    // Batch mint XP to multiple learners
    function batchMintXP(address[] calldata learners, uint256[] calldata amounts, uint256 xpId) external onlyOwner {
        require(learners.length == amounts.length, "Mismatched input arrays");

        for (uint256 i = 0; i < learners.length; i++) {
            _mint(learners[i], xpId, amounts[i], "");
            learnerXP[learners[i]][xpId] += amounts[i];
            emit XPMinted(learners[i], amounts[i], xpId);
        }
    }

    // View if a learner owns a badge
    function hasBadge(address learner, uint256 badgeId) external view returns (bool) {
        return learnerBadges[learner][badgeId];
    }

    // View learner XP balance
    function balanceOfXP(address learner, uint256 xpId) external view returns (uint256) {
        return learnerXP[learner][xpId];
    }

    // Admin can update the base URI after deployment
    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }
}
