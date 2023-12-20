import "NonFungibleToken"

import "FlowtyWrapped"

pub fun main(addr: Address): [UInt64] {
    let cp = getAccount(addr).getCapability<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath).borrow()
        ?? panic("collection not found")

    let nftIDs = cp.getIDs()
    return  nftIDs
}