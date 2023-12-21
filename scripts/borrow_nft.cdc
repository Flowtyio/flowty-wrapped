import "NonFungibleToken"
import "MetadataViews"

import "FlowtyWrapped"

pub fun main(addr: Address, nftID: UInt64): Bool{
  let cp = getAccount(addr).getCapability<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath).borrow()
    ?? panic("collection not found")

  let nft = cp.borrowNFT(id: nftID) 
      
  if (nft != nil) {
    return true
  } else {
    return false
  }
}