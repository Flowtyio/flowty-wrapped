import "FlowtyWrapped"

transaction(receiver: Address) {
    prepare(acct: auth(Storage, Capabilities, Inbox) &Account) {

        let cap = acct.capabilities.storage.issue<&FlowtyWrapped.Admin>(FlowtyWrapped.AdminStoragePath)

        acct.inbox.publish(cap, name: "flowty-wrapped-minter", recipient: receiver)
    }
}