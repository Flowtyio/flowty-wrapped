import "FungibleToken"
import "FlowtyWrapped"
import "NonFungibleToken"
import "MetadataViews"
import "WrappedEditions"


transaction(acct: Address, username: String, ticket: Int, totalNftsOwned: Int, floatCount: Int, favoriteCollections: [String], collections: [String]) {
   // local variable for storing the minter reference
    let minter: &FlowtyWrapped.Admin


    prepare(acct: AuthAccount) {
       //borrow a reference to the NFTMinter resource in storage
        self.minter = acct.borrow<&FlowtyWrapped.Admin>(from: FlowtyWrapped.AdminStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")

    }

    execute {
        let wrapped2023Data = WrappedEditions.Wrapped2023Data(
            username, 
            ticket,
            totalNftsOwned,
            floatCount,
            favoriteCollections,
            collections
        )
         let data: {String: AnyStruct} = { 
            "wrapped": wrapped2023Data
        }
        let receiver = getAccount(acct).getCapability<&{NonFungibleToken.CollectionPublic}>(FlowtyWrapped.CollectionPublicPath).borrow()!
        let nft <- self.minter.mintNFT(editionName: "Flowty Wrapped 2023", data: data )
        receiver.deposit(token: <-nft)

    }
}
