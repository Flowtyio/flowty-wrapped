import "NonFungibleToken"
import "MetadataViews"

import "FlowtyWrapped"

access(all) fun main(addr: Address, nftID: UInt64): Bool{
  let cp = getAccount(addr).capabilities.borrow<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath)
    ?? panic("collection not found")

  let nft = cp.borrowNFT(nftID) 
      
  if (nft != nil) {
    return true
  } else {
    return false
  }
}