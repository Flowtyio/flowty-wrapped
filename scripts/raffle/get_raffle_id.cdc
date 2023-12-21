import "FlowtyWrapped"
import "WrappedEditions"

pub fun main(addr: Address, editionName: String): UInt64 {
    let acct = getAuthAccount(addr)
    let admin = acct.borrow<&FlowtyWrapped.Admin>(from: FlowtyWrapped.AdminStoragePath)!
    
    let edition = admin.getEdition(editionName: editionName) as! &AnyStruct{FlowtyWrapped.WrappedEdition}

    let raffleID = edition.getRaffleID()

    return raffleID
}