import "FlowtyWrapped"
import "WrappedEditions"

access(all) fun main(addr: Address, editionName: String): UInt64 {

    let acct = getAuthAccount<auth(BorrowValue) &Account>(addr)
    let admin = acct.storage.borrow<&FlowtyWrapped.Admin>(from: FlowtyWrapped.AdminStoragePath)!
    

    let edition = admin.getEdition(editionName: editionName) as! &{FlowtyWrapped.WrappedEdition}

    let editionSupply = edition.getEditionSupply()

    return editionSupply
}