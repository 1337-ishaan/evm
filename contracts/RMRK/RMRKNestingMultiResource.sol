// SPDX-License-Identifier: Apache-2.0

//Generally all interactions should propagate downstream

pragma solidity ^0.8.9;

import "./RMRKNesting.sol";
import "./abstracts/MultiResourceAbstract.sol";
import "./abstracts/NestingAbstract.sol";
import "./library/RMRKLib.sol";
import "./utils/Address.sol";
import "./utils/Strings.sol";
import "hardhat/console.sol";

contract RMRKNestingMultiResource is MultiResourceAbstract, RMRKNesting {

    using RMRKLib for uint256;
    using Address for address;
    using Strings for uint256;

    constructor(string memory name_, string memory symbol_) RMRKNesting(name_, symbol_) {
    }

    function acceptResource(uint256 tokenId, uint256 index) external virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "MultiResource: not owner"
        );
        // FIXME: clean approvals and test
        _acceptResource(tokenId, index);
    }

    function rejectResource(uint256 tokenId, uint256 index) external virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "MultiResource: not owner"
        );
        // FIXME: clean approvals and test
        _rejectResource(tokenId, index);
    }

    function rejectAllResources(uint256 tokenId) external virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "MultiResource: not owner"
        );
        // FIXME: clean approvals and test
        _rejectAllResources(tokenId);
    }

    function setPriority(
        uint256 tokenId,
        uint16[] memory priorities
    ) external virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "MultiResource: not owner"
        );
        // FIXME: clean approvals and test
        _setPriority(tokenId, priorities);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(MultiResourceAbstract, NestingAbstract) returns (string memory) {
        return _tokenURIAtIndex(tokenId, 0);
    }

}