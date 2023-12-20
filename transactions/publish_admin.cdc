import "FlowtyWrapped"

transaction(receiver: Address) {
    prepare(acct: AuthAccount) {
        let identifier = "FlowtyWrapped_Admin_".concat(receiver.toString())
        let p = PrivatePath(identifier: identifier)!

        acct.unlink(p)
        let cap = acct.link<&FlowtyWrapped.Admin>(p, target: FlowtyWrapped.AdminStoragePath)
            ?? panic("failed to link admin capability")

        acct.inbox.publish(cap, name: "flowty-wrapped-minter", recipient: receiver)
    }
}