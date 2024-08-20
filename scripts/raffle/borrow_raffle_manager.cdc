import "FlowtyRaffles"

access(all) fun main(addr: Address) {
    getAccount(addr).capabilities.get<&FlowtyRaffles.Manager>(FlowtyRaffles.ManagerPublicPath).borrow()
        ?? panic("unable to borrow manager")
}