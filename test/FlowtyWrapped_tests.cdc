import Test
import "test_helpers.cdc"

import "FlowtyWrapped"


pub fun setup() {

    var err = Test.deployContract(name: "FlowtyRaffles", path: "../contracts/raffle/FlowtyRaffles.cdc", arguments: [])
    Test.expect(err, Test.beNil())

    err = Test.deployContract(name: "FlowtyRaffleSource", path: "../contracts/raffle/FlowtyRaffleSource.cdc", arguments: [])
    Test.expect(err, Test.beNil())

    err = Test.deployContract(name: "FlowtyWrapped", path: "../contracts/FlowtyWrapped.cdc", arguments: [])
    Test.expect(err, Test.beNil())

    // err = Test.deployContract(name: "WrappedEditions", path: "../contracts/WrappedEditions.cdc", arguments: [])
    // Test.expect(err, Test.beNil())
}

pub fun setupManager() {
    let acct = Test.createAccount()
    txExecutor("setup_flowty_wrapped", [acct], [], nil)
    scriptExecutor("borrow_wrapped_collection.cdc", [acct.address])
}