import "FlowtyWrapped"

transaction(editionName: String, key: String, value: String) {
    prepare(acct: AuthAccount) {
        let admin = acct.borrow<&FlowtyWrapped.Admin>(from: FlowtyWrapped.AdminStoragePath)
            ?? panic("missing admin")
        admin.setEditionParam(editionName: editionName, key: key, value: value)
    }
}