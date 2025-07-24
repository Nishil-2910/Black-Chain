// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RevenueSplitter {
    address public educator;
    address public platform;
    address public sponsor;

    uint256 public educatorShare; // in basis points (e.g., 5000 = 50%)
    uint256 public platformShare;
    uint256 public sponsorShare;

    mapping(address => uint256) public pendingWithdrawals;

    event RevenueReceived(address from, uint256 amount);
    event RevenueSplit(uint256 educatorAmount, uint256 platformAmount, uint256 sponsorAmount);
    event Withdrawn(address indexed recipient, uint256 amount);
    event EducatorUpdated(address indexed oldEducator, address indexed newEducator);
    event PlatformUpdated(address indexed oldPlatform, address indexed newPlatform);
    event SponsorUpdated(address indexed oldSponsor, address indexed newSponsor);
    event SharesUpdated(uint256 educatorShare, uint256 platformShare, uint256 sponsorShare);

    modifier onlyPlatform() {
        require(msg.sender == platform, "Only platform can call this");
        _;
    }

    constructor(
        address _educator,
        address _platform,
        address _sponsor,
        uint256 _educatorShare,
        uint256 _platformShare,
        uint256 _sponsorShare
    ) {
        require(_educator != address(0), "Invalid educator address");
        require(_platform != address(0), "Invalid platform address");
        require(_sponsor != address(0), "Invalid sponsor address");

        require(
            _educatorShare + _platformShare + _sponsorShare == 10000,
            "Total share must be 100%"
        );

        educator = _educator;
        platform = _platform;
        sponsor = _sponsor;

        educatorShare = _educatorShare;
        platformShare = _platformShare;
        sponsorShare = _sponsorShare;
    }

    receive() external payable {
        uint256 amount = msg.value;
        require(amount > 0, "No ETH sent");

        uint256 educatorAmount = (amount * educatorShare) / 10000;
        uint256 platformAmount = (amount * platformShare) / 10000;
        uint256 sponsorAmount = amount - educatorAmount - platformAmount;

        pendingWithdrawals[educator] += educatorAmount;
        pendingWithdrawals[platform] += platformAmount;
        pendingWithdrawals[sponsor] += sponsorAmount;

        emit RevenueReceived(msg.sender, amount);
        emit RevenueSplit(educatorAmount, platformAmount, sponsorAmount);
    }

    function withdraw() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // Effects
        pendingWithdrawals[msg.sender] = 0;

        // Interactions (call is safer than transfer)
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");

        emit Withdrawn(msg.sender, amount);
    }

    function getPending(address user) external view returns (uint256) {
        return pendingWithdrawals[user];
    }

    // Update addresses — only platform can call
    function updateEducator(address newEducator) external onlyPlatform {
        require(newEducator != address(0), "Invalid educator address");
        address old = educator;
        educator = newEducator;
        emit EducatorUpdated(old, newEducator);
    }

    function updatePlatform(address newPlatform) external onlyPlatform {
        require(newPlatform != address(0), "Invalid platform address");
        address old = platform;
        platform = newPlatform;
        emit PlatformUpdated(old, newPlatform);
    }

    function updateSponsor(address newSponsor) external onlyPlatform {
        require(newSponsor != address(0), "Invalid sponsor address");
        address old = sponsor;
        sponsor = newSponsor;
        emit SponsorUpdated(old, newSponsor);
    }

    // Update shares — only platform can call
    function updateShares(
        uint256 newEducatorShare,
        uint256 newPlatformShare,
        uint256 newSponsorShare
    ) external onlyPlatform {
        require(
            newEducatorShare + newPlatformShare + newSponsorShare == 10000,
            "Total share must be 100%"
        );
        educatorShare = newEducatorShare;
        platformShare = newPlatformShare;
        sponsorShare = newSponsorShare;
        emit SharesUpdated(newEducatorShare, newPlatformShare, newSponsorShare);
    }
}
