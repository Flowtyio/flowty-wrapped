import "FlowtyWrapped"

transaction(name: String, provider: Address) {
    prepare(acct: AuthAccount) {
        let providerAdmin = acct.inbox.claim<&FlowtyWrapped.Admin>(name, provider: provider)
            ?? panic("capabiltiy not found")

        let admin <- providerAdmin.borrow()!.createAdmin()
        acct.save(<-admin, to: FlowtyWrapped.AdminStoragePath)
    }
}