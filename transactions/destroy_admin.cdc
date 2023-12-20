import "FlowtyWrapped"

transaction {
    prepare(acct: AuthAccount) {
        let admin <- acct.load<@AnyResource>(from: FlowtyWrapped.AdminStoragePath)
        destroy admin

        // borrow the contract admin resource to make sure we haven't destroyed the wrong admin 
        let publicAdmin = getAccount(FlowtyWrapped.getAccountAddress()).getCapability<&{FlowtyWrapped.AdminPublic}>(FlowtyWrapped.AdminPublicPath)
        assert(publicAdmin.check(), message: "admin public isn't configured anymore!")
    }
}