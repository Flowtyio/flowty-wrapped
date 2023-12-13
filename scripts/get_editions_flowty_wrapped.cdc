import "NonFungibleToken"
import "MetadataViews"

import "FlowtyWrapped"

pub fun main(addr: Address, nftID: UInt64): AnyStruct {
    let cp = getAccount(addr).getCapability<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath).borrow()
        ?? panic("collection not found")

    let nft = cp.borrowNFT(id: nftID)
    return nft.resolveView(Type<MetadataViews.Editions>())!
}