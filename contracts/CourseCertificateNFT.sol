// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CertificateNFT
 * @notice ERC721 NFT contract to issue course completion certificates with dynamic metadata URIs.
 */
contract CertificateNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    // learner => courseId => metadata URI
    mapping(address => mapping(uint256 => string)) public learnerCertificates;

    // Dynamic base CID for metadata storage (e.g., IPFS root)
    string public baseIpfsCID;

    event CertificateMinted(address indexed learner, uint256 indexed courseId, uint256 tokenId);
    event BaseIpfsCIDUpdated(string newCID);

    constructor() ERC721("CertificateNFT", "CERT") Ownable(msg.sender) {}

    /**
     * @notice Set the base IPFS CID (can be updated if your IPFS folder structure changes).
     */
    function setBaseIpfsCID(string memory newCID) external onlyOwner {
        baseIpfsCID = newCID;
        emit BaseIpfsCIDUpdated(newCID);
    }

    /**
     * @notice Mint a new certificate to a learner.
     * @param learner Address receiving the certificate.
     * @param courseId The course ID being certified.
     */
    function mintCertificate(address learner, uint256 courseId) external onlyOwner {
        require(bytes(baseIpfsCID).length > 0, "Base CID not set");

        uint256 tokenId = _tokenIdCounter;

        // Generate metadata URI dynamically
        string memory ipfsMetadataURI = generateMetadataURI(courseId, learner);

        _mint(learner, tokenId);
        _setTokenURI(tokenId, ipfsMetadataURI);

        learnerCertificates[learner][courseId] = ipfsMetadataURI;

        emit CertificateMinted(learner, courseId, tokenId);
        _tokenIdCounter++;
    }

    /**
     * @notice Dynamically generates the full IPFS metadata URI.
     */
    function generateMetadataURI(uint256 courseId, address learner)
        public
        view
        returns (string memory)
    {
        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/",
                baseIpfsCID,
                "/",
                uint2str(courseId),
                "/",
                toAsciiString(learner),
                ".json"
            )
        );
    }

    function toAsciiString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 tmp = _i;
        uint256 len;
        while (tmp != 0) {
            len++;
            tmp /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k--;
            bstr[k] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}
