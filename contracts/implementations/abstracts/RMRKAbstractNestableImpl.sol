// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "../../RMRK/extension/RMRKRoyalties.sol";
import "../../RMRK/nestable/RMRKNestable.sol";
import "../../RMRK/utils/RMRKCollectionMetadata.sol";
import "../../RMRK/utils/RMRKMintingUtils.sol";
import "../../RMRK/utils/RMRKTokenURI.sol";
import "../IRMRKInitData.sol";

error RMRKMintZero();

/**
 * @title RMRKAbstractNestableImpl
 * @author RMRK team
 * @notice Abstract implementation of RMRK nestable module.
 */
abstract contract RMRKAbstractNestableImpl is
    IRMRKInitData,
    RMRKMintingUtils,
    RMRKCollectionMetadata,
    RMRKRoyalties,
    RMRKTokenURI,
    RMRKNestable
{
    /**
     * @notice Used to calculate the token IDs of tokens to be minted.
     * @param numToMint Amount of tokens to be minted
     * @return The ID of the first token to be minted in the current minting cycle
     * @return The ID of the last token to be minted in the current minting cycle
     */
    function _preMint(
        uint256 numToMint
    ) internal virtual returns (uint256, uint256) {
        if (numToMint == uint256(0)) revert RMRKMintZero();
        if (numToMint + _nextId > _maxSupply) revert RMRKMintOverMax();

        uint256 mintPriceRequired = numToMint * _pricePerMint;
        _charge(mintPriceRequired);

        uint256 nextToken = _nextId + 1;
        unchecked {
            _nextId += numToMint;
            _totalSupply += numToMint;
        }
        uint256 totalSupplyOffset = _nextId + 1;

        return (nextToken, totalSupplyOffset);
    }

    /**
     * @notice Used to verify and/or receive the payment for the mint.
     * @param value The expected amount to be received for the mint
     */
    function _charge(uint256 value) internal virtual;

    /**
     * @inheritdoc RMRKRoyalties
     */
    function updateRoyaltyRecipient(
        address newRoyaltyRecipient
    ) public virtual override onlyOwner {
        _setRoyaltyRecipient(newRoyaltyRecipient);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (to == address(0)) {
            unchecked {
                _totalSupply -= 1;
            }
        }
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, RMRKNestable) returns (bool) {
        return
            super.supportsInterface(interfaceId) ||
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == RMRK_INTERFACE;
    }
}
