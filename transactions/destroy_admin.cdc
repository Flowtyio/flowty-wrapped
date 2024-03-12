import "FlowtyWrapped"

transaction {
    prepare(acct: auth(Storage) &Account) {
        let admin <- acct.storage.load<@AnyResource>(from: FlowtyWrapped.AdminStoragePath)
        destroy admin

        // borrow the contract admin resource to make sure we haven't destroyed the wrong admin 
        let publicAdmin = getAccount(FlowtyWrapped.getAccountAddress()).capabilities.borrow<&{FlowtyWrapped.AdminPublic}>(FlowtyWrapped.AdminPublicPath)!
        
        //Is this correct? Not sure, we don't have a check fn anymore
        assert(publicAdmin != nil, message: "admin public isn't configured anymore!")
    }
}