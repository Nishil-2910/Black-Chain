// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AchievementBadges is ERC1155, Ownable {
    uint256 public nextBadgeId = 1;

    struct Badge {
        string name;
        string description;
    }

    mapping(uint256 => Badge) public badgeInfo;

    event BadgeMinted(
        uint256 indexed badgeId,
        address indexed to,
        uint256 amount,
        string name,
        string description
    );

    constructor(string memory uri) ERC1155(uri) Ownable(msg.sender) {}

    // Create a new badge type with metadata
    function createBadge(string memory name, string memory description) external onlyOwner returns (uint256) {
        uint256 badgeId = nextBadgeId;
        badgeInfo[badgeId] = Badge(name, description);
        nextBadgeId++;
        return badgeId;
    }

    // Mint a badge to a user
    function mintBadge(address to, uint256 badgeId, uint256 amount) external onlyOwner {
        require(badgeExists(badgeId), "Badge does not exist");
        _mint(to, badgeId, amount, "");

        Badge memory badge = badgeInfo[badgeId];
        emit BadgeMinted(badgeId, to, amount, badge.name, badge.description);
    }

    // Update the metadata URI (if using dynamic IPFS or metadata hosting)
    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    // Get metadata for a badge
    function getBadge(uint256 badgeId) external view returns (Badge memory) {
        return badgeInfo[badgeId];
    }

    // Internal helper to check if badge exists
    function badgeExists(uint256 badgeId) public view returns (bool) {
        return bytes(badgeInfo[badgeId].name).length > 0;
    }
}
