import "FlowtyRaffles"

access(all) fun main(addr: Address) {
    getAccount(addr).capabilities.borrow<&FlowtyRaffles.Manager>(FlowtyRaffles.ManagerPublicPath)
        ?? panic("unable to borrow manager")
}