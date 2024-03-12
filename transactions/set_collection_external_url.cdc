import "FlowtyWrapped"


transaction(url: String) {
    let admin: &FlowtyWrapped.Admin

    prepare(acct: auth(Storage) &Account) {
        self.admin = acct.storage.borrow<&FlowtyWrapped.Admin>(from: FlowtyWrapped.AdminStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        self.admin.setCollectionExternalUrl(url)
    }
}