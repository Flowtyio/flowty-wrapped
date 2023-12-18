import Test
import "test_helpers.cdc"

import "FlowtyWrapped"


pub fun setup() {
    let err = Test.deployContract(name: "FlowtyWrapped", path: "../contracts/FlowtyWrapped.cdc", arguments: [])
    Test.expect(err, Test.beNil())
}

pub fun setupManager() {
    let acct = Test.createAccount()
    txExecutor("setup_flowty_wrapped", [acct], [], nil)
    scriptExecutor("borrow_wrapped_collection.cdc", [acct.address])
}