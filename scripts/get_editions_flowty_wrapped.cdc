import "NonFungibleToken"
import "MetadataViews"

import "FlowtyWrapped"

access(all) fun main(addr: Address, nftID: UInt64): AnyStruct {
    let cp = getAccount(addr).capabilities.borrow<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath)
        ?? panic("collection not found")

    let nft = cp.borrowNFT(nftID) ?? panic("nft not found")
    return nft.resolveView(Type<MetadataViews.Editions>())!
}