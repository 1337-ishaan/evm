// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "../abstracts/RMRKAbstractMultiAssetImpl.sol";
import "./RMRKErc20Pay.sol";

/**
 * @title RMRKMultiAssetImplErc20Pay
 * @author RMRK team
 * @notice Implementation of RMRK multi asset module with ERC20 pay.
 */
contract RMRKMultiAssetImplErc20Pay is
    RMRKErc20Pay,
    RMRKAbstractMultiAssetImpl
{
    /**
     * @notice Used to initialize the smart contract.
     * @dev The full `InitData` looks like this:
     *  [
     *      erc20TokenAddress,
     *      tokenUriIsEnumerable,
     *      royaltyRecipient,
     *      royaltyPercentageBps,
     *      maxSupply,
     *      pricePerMint
     *  ]
     * @param name_ Name of the token collection
     * @param symbol_ Symbol of the token collection
     * @param collectionMetadata_ The collection metadata URI
     * @param tokenURI_ The base URI of the token metadata
     * @param data The `InitData` struct containing additional initialization data
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory collectionMetadata_,
        string memory tokenURI_,
        InitData memory data
    )
        RMRKMintingUtils(data.maxSupply, data.pricePerMint)
        RMRKCollectionMetadata(collectionMetadata_)
        RMRKRoyalties(data.royaltyRecipient, data.royaltyPercentageBps)
        RMRKTokenURI(tokenURI_, data.tokenUriIsEnumerable)
        RMRKErc20Pay(data.erc20TokenAddress)
        RMRKMultiAsset(name_, symbol_)
    {}

    /**
     * @notice Used to mint the desired number of tokens to the specified address.
     * @dev The `data` value of the `_safeMint` method is set to an empty value.
     * @dev Can only be called while the open sale is open.
     * @param to Address to which to mint the token
     * @param numToMint Number of tokens to mint
     * @return The ID of the first token to be minted in the current minting cycle
     */
    function mint(
        address to,
        uint256 numToMint
    ) public virtual notLocked returns (uint256) {
        if (numToMint == uint256(0)) revert RMRKMintZero();
        if (numToMint + _nextId > _maxSupply) revert RMRKMintOverMax();

        uint256 mintPriceRequired = numToMint * _pricePerMint;
        _chargeFromToken(msg.sender, address(this), mintPriceRequired);
        uint256 nextToken = _nextId + 1;
        unchecked {
            _nextId += numToMint;
            _totalSupply += numToMint;
        }
        uint256 totalSupplyOffset = _nextId + 1;

        for (uint256 i = nextToken; i < totalSupplyOffset; ) {
            _safeMint(to, i, "");
            unchecked {
                ++i;
            }
        }

        return nextToken;
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
     * @notice Used to withdraw the minting proceedings to a specified address.
     * @dev This function can only be called by the owner.
     * @param erc20 Address of the ERC20 token to withdraw
     * @param to Address to receive the given amount of minting proceedings
     * @param amount The amount to withdraw
     */
    function withdrawRaisedERC20(
        address erc20,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20(erc20).transfer(to, amount);
    }
}
