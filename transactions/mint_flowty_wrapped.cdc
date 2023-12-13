import "FungibleToken"
import "FlowtyWrapped"
import "NonFungibleToken"
import "MetadataViews"


transaction(recipient: Address, year: UInt64) {
    // local variable for storing the minter reference
    let minter: &FlowtyWrapped.NFTMinter

    prepare(acct: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = acct.borrow<&FlowtyWrapped.NFTMinter>(from: /storage/FlowtyWrapped_0xf8d6e0586b0a20c7_Minter)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        let receiver = getAccount(recipient).getCapability<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath).borrow()!
        let nft <- self.minter.mintNFT(year: year)
        receiver.deposit(token: <-nft)

    }
}
