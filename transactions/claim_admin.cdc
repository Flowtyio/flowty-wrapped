import "FlowtyWrapped"

transaction(name: String, provider: Address) {
    prepare(acct: auth(Storage, Inbox) &Account) {
        let providerAdmin = acct.inbox.claim<&FlowtyWrapped.Admin>(name, provider: provider)
            ?? panic("capabiltiy not found")

        let admin <- providerAdmin.borrow()!.createAdmin()
        acct.storage.save(<-admin, to: FlowtyWrapped.AdminStoragePath)
    }
}