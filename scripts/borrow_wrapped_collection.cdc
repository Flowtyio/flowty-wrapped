import "FlowtyWrapped"
import "NonFungibleToken"
import "MetadataViews"

pub fun main(addr: Address) {
    getAccount(addr).getCapability<&FlowtyWrapped.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(FlowtyWrapped.CollectionPublicPath).borrow()
        ?? panic("unable to borrow manager")
}