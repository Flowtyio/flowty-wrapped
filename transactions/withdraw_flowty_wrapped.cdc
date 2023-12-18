import "FungibleToken"
import "FlowtyWrapped"
import "NonFungibleToken"
import "MetadataViews"


transaction(recipient: Address) {
    // local variable for storing the minter reference
    let collection: &FlowtyWrapped.Collection

    prepare(acct: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.collection = acct.borrow<&FlowtyWrapped.Collection>(from: FlowtyWrapped.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        let receiver = getAccount(recipient).getCapability<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath).borrow()!
        let nft <- self.collection.withdraw(withdrawID: 1)
        receiver.deposit(token: <-nft)

    }
}
