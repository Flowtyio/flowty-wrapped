import "FlowtyRaffles"

transaction(id: UInt64) {
    prepare(acct: auth(Storage) &Account) {
        let manager = acct.storage.borrow<&FlowtyRaffles.Manager>(from: FlowtyRaffles.ManagerStoragePath)
            ?? panic("raffles manager not found")
        let receiptID = manager.commitDrawing(raffleID: id)

        let ref = manager
        manager.revealDrawing(manager: ref, raffleID: id, receiptID: receiptID)
    }
}