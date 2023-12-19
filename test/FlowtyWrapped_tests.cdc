import Test
import "test_helpers.cdc"

import "FlowtyWrapped"

pub fun setup() {
    var err = Test.deployContract(name: "FlowtyRaffles", path: "../contracts/raffle/FlowtyRaffles.cdc", arguments: [])
    Test.expect(err, Test.beNil())

    err = Test.deployContract(name: "FlowtyRaffleSource", path: "../contracts/raffle/FlowtyRaffleSource.cdc", arguments: [])
    Test.expect(err, Test.beNil())

    err = Test.deployContract(name: "ArrayUtils", path: "../node_modules/@flowtyio/flow-contracts/contracts/flow-utils/ArrayUtils.cdc", arguments: [])
    Test.expect(err, Test.beNil())

    err = Test.deployContract(name: "StringUtils", path: "../node_modules/@flowtyio/flow-contracts/contracts/flow-utils/StringUtils.cdc", arguments: [])
    Test.expect(err, Test.beNil())

    err = Test.deployContract(name: "FlowtyWrapped", path: "../contracts/FlowtyWrapped.cdc", arguments: [])
    Test.expect(err, Test.beNil())

    err = Test.deployContract(name: "WrappedEditions", path: "../contracts/WrappedEditions.cdc", arguments: [])
    Test.expect(err, Test.beNil())
}

pub  let rafflesAcct = Test.getAccount(Address(0x0000000000000007))
pub  let minterAccount = Test.getAccount(Address(0x0000000000000007))

pub fun testSetupManager() {
    let acct = Test.createAccount()
    txExecutor("setup_flowty_wrapped.cdc", [acct], [], nil)
}

pub fun testRegisterEdition() {
    let acct = Test.createAccount()

    let removeAfterReveal: Bool = true
    let start: UInt64 = 0
    let end: UInt64 = 100
    let baseImageUrl: String = ""
    let baseHtmlUrl: String = "https://flowty.io/asset/0x0000000000000007/FlowtyWrapped" //TODO change to dynamic address testnet/mainnet
    registerEdition(rafflesAcct: rafflesAcct, removeAfterReveal: removeAfterReveal, start: start, end: end, baseImageUrl: baseImageUrl, baseHtmlUrl: baseHtmlUrl)
}

pub fun testMint(){
    let acct = Test.createAccount()

    txExecutor("setup_flowty_wrapped.cdc", [acct], [], nil)

    let username: String = "user1"
    let ticket: Int = 1
    let totalNftsOwned: Int = 1
    let floatCount: Int = 1
    let favoriteCollections: [String] = [""]
    let collections: [String] = [""]

   mintFlowtyWrapped(minterAccount: minterAccount, address: acct.address, username: username, ticket: ticket, totalNftsOwned: totalNftsOwned, floatCount: floatCount, favoriteCollections: favoriteCollections, collections: collections)
}

pub fun registerEdition(rafflesAcct: Test.Account, removeAfterReveal: Bool, start: UInt64, end: UInt64, baseImageUrl: String, baseHtmlUrl: String) {
    txExecutor("register_edition.cdc", [rafflesAcct], [removeAfterReveal, start, end, baseImageUrl, baseHtmlUrl], nil)
}

pub fun mintFlowtyWrapped(minterAccount: Test.Account, address: Address, username: String, ticket: Int, totalNftsOwned: Int, floatCount: Int, favoriteCollections: [String], collections: [String]) {
    txExecutor("mint_flowty_wrapped.cdc", [minterAccount], [address, username, ticket, totalNftsOwned, floatCount, favoriteCollections, collections], nil)
}