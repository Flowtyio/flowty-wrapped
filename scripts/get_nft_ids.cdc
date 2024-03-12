import "NonFungibleToken"

import "FlowtyWrapped"

access(all) fun main(addr: Address): [UInt64] {
    let cp = getAccount(addr).capabilities.borrow<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath)
        ?? panic("collection not found")

    let nftIDs = cp.getIDs()
    return  nftIDs
}