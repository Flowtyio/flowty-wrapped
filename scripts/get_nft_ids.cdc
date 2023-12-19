import "NonFungibleToken"

import "FlowtyWrapped"

pub fun main(addr: Address): AnyStruct {
    let cp = getAccount(addr).getCapability<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath).borrow()
        ?? panic("collection not found")

    let nftIDs = cp.getIDs()
    return  nftIDs
}