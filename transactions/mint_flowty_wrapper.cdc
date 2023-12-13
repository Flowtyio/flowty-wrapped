import "FungibleToken"
import "FlowtyWrapper"
import "NonFungibleToken"
import "MetadataViews"


transaction(recipient: Address) {
    // local variable for storing the minter reference
    let minter: &FlowtyWrapper.NFTMinter

    prepare(acct: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = acct.borrow<&FlowtyWrapper.NFTMinter>(from: /storage/FlowtyWrapper_0xf8d6e0586b0a20c7_Minter)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        let receiver = getAccount(recipient).getCapability<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapper.CollectionPublicPath).borrow()!
        let nft <- self.minter.mintNFT()
        receiver.deposit(token: <-nft)

    }
}
