import "FlowtyWrapped"


transaction(url: String) {
    let admin: &FlowtyWrapped.Admin

    prepare(acct: AuthAccount) {
        self.admin = acct.borrow<&FlowtyWrapped.Admin>(from: FlowtyWrapped.AdminStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        self.admin.setCollectionExternalUrl(url)
    }
}