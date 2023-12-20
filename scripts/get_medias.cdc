import "FlowtyWrapped"
import "MetadataViews"
import "NonFungibleToken"

pub fun main(addr: Address, nftID: UInt64): MetadataViews.Medias {
    let acct = getAuthAccount(addr)
    let col = acct.borrow<&FlowtyWrapped.Collection>(from: FlowtyWrapped.CollectionStoragePath)
        ?? panic("collection not found")
    let nft = col.borrowFlowtyWrapped(id: nftID) ?? panic("nft not found")
    return nft.resolveView(Type<MetadataViews.Medias>())! as! MetadataViews.Medias
}