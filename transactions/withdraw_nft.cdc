import "NonFungibleToken"
import "FlowtyWrapped"

transaction(owner: Address, receiver: Address, withdrawID: UInt64) {

  prepare(acct: AuthAccount){

  let collectionRef = acct.borrow<&FlowtyWrapped.Collection>(from: FlowtyWrapped.CollectionStoragePath)
    ?? panic("Could not borrow a reference to the owner's collection")

  let nft <- collectionRef.withdraw(withdrawID: 42)

  let recipient = getAccount(receiver).getCapability<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath).borrow() ?? panic("invalid receiver collection")

  recipient.deposit(token: <-nft)
  }
} 