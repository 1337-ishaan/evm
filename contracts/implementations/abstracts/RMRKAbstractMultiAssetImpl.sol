// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "../../RMRK/extension/RMRKRoyalties.sol";
import "../../RMRK/multiasset/RMRKMultiAsset.sol";
import "../../RMRK/utils/RMRKCollectionMetadata.sol";
import "../../RMRK/utils/RMRKMintingUtils.sol";
import "../../RMRK/utils/RMRKTokenURI.sol";
import "../IRMRKInitData.sol";

error RMRKMintZero();

/**
 * @title RMRKAbstractMultiAssetImpl
 * @author RMRK team
 * @notice Abstract implementation of RMRK multi asset module.
 */
abstract contract RMRKAbstractMultiAssetImpl is
    IRMRKInitData,
    RMRKMintingUtils,
    RMRKCollectionMetadata,
    RMRKRoyalties,
    RMRKTokenURI,
    RMRKMultiAsset
{
    uint256 private _totalAssets;

    /**
     * @notice Used to destroy the specified token.
     * @dev The approval is cleared when the token is burned.
     * @dev Requirements:
     *  - `tokenId` must exist.
     * @param tokenId ID of the token to burn
     */
    function burn(uint256 tokenId) public virtual onlyApprovedOrOwner(tokenId) {
        _burn(tokenId);
    }

    /**
     * @notice Used to add an asset to a token.
     * @dev If the given asset is already added to the token, the execution will be reverted.
     * @dev If the asset ID is invalid, the execution will be reverted.
     * @dev If the token already has the maximum amount of pending assets (128), the execution will be
     *  reverted.
     * @param tokenId ID of the token to add the asset to
     * @param assetId ID of the asset to add to the token
     * @param replacesAssetWithId ID of the asset to replace from the token's list of active assets
     */
    function addAssetToToken(
        uint256 tokenId,
        uint64 assetId,
        uint64 replacesAssetWithId
    ) public virtual onlyOwnerOrContributor {
        _addAssetToToken(tokenId, assetId, replacesAssetWithId);
    }

    /**
     * @notice Used to add a asset entry.
     * @dev The ID of the asset is automatically assigned to be the next available asset ID.
     * @param metadataURI Metadata URI of the asset
     * @return ID of the newly added asset
     */
    function addAssetEntry(
        string memory metadataURI
    ) public virtual onlyOwnerOrContributor returns (uint256) {
        unchecked {
            ++_totalAssets;
        }
        _addAssetEntry(uint64(_totalAssets), metadataURI);
        return _totalAssets;
    }

    /**
     * @notice Used to retrieve the total number of assets.
     * @return The total number of assets
     */
    function totalAssets() public view virtual returns (uint256) {
        return _totalAssets;
    }

    /**
     * @inheritdoc RMRKRoyalties
     */
    function updateRoyaltyRecipient(
        address newRoyaltyRecipient
    ) public virtual override onlyOwner {
        _setRoyaltyRecipient(newRoyaltyRecipient);
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, RMRKMultiAsset) returns (bool) {
        return
            super.supportsInterface(interfaceId) ||
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == RMRK_INTERFACE;
    }
}
