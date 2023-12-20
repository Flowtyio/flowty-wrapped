import Test
import "test_helpers.cdc"

import "FlowtyWrapped"
import "MetadataViews"

pub  let rafflesAcct = Test.getAccount(Address(0x0000000000000007))
pub  let minterAccount = Test.getAccount(Address(0x0000000000000007))

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

    // register a test wrapped edition
    let removeAfterReveal: Bool = true
    let start: UInt64 = 0
    let end: UInt64 = 100
    let baseImageUrl: String = ""
    let baseHtmlUrl: String = "https://flowty.io/asset/0x0000000000000007/FlowtyWrapped"
    registerEdition(rafflesAcct: Test.getAccount(Address(0x0000000000000007)), removeAfterReveal: removeAfterReveal, start: start, end: end, baseImageUrl: baseImageUrl, baseHtmlUrl: baseHtmlUrl)
    
}

pub fun testSetupManager() {
    let acct = Test.createAccount()
    txExecutor("setup_flowty_wrapped.cdc", [acct], [], nil)
}

pub fun testMint() {
    let acct = Test.createAccount()
    setupForMint(acct: acct)   
}

pub fun testGetEditions() {
    let acct = Test.createAccount()
    setupForMint(acct: acct)
    let result = scriptExecutor("get_nft_ids.cdc", [acct.address])

    let castedResult = result! as! [UInt64]
    var nftID1 = castedResult[0]

    scriptExecutor("get_editions_flowty_wrapped.cdc", [acct.address, nftID1])
}

pub fun testDepositToWrongAddressFails() {
    let acct = Test.createAccount()
    let wrongAccount = Test.createAccount()
    

    txExecutor("setup_flowty_wrapped.cdc", [acct], [], nil)
    txExecutor("setup_flowty_wrapped.cdc", [wrongAccount], [], nil)


    let username: String = "user1"
    let ticket: Int = 1
    let totalNftsOwned: Int = 1
    let floatCount: Int = 1
    let favoriteCollections: [String] = [""]
    let collections: [String] = [""]

    txExecutor("fail_mint_to_wrong_account.cdc", [minterAccount], [acct.address, wrongAccount.address, username, ticket, totalNftsOwned, floatCount, favoriteCollections, collections], "The NFT must be owned by the collection owner")

}

pub fun setupForMint(acct: Test.Account) {

    txExecutor("setup_flowty_wrapped.cdc", [acct], [], nil)

    let username: String = "user1"
    let ticket: Int = 1
    let totalNftsOwned: Int = 1
    let floatCount: Int = 1
    let favoriteCollections: [String] = [""]
    let collections: [String] = [""]

    txExecutor("mint_flowty_wrapped.cdc", [minterAccount], [acct.address, username, ticket, totalNftsOwned, floatCount, favoriteCollections, collections], nil)
}

pub fun testSingleMint() {
    let acct = Test.createAccount()

    txExecutor("setup_flowty_wrapped.cdc", [acct], [], nil)

    let username: String = "testSingleMint"
    let ticket: Int = 1
    let totalNftsOwned: Int = 1
    let floatCount: Int = 1
    let favoriteCollections: [String] = [""]
    let collections: [String] = [""]

    txExecutor("mint_flowty_wrapped.cdc", [minterAccount], [acct.address, username, ticket, totalNftsOwned, floatCount, favoriteCollections, collections], nil)

    // now try to mint again, this should fail
    txExecutor("mint_flowty_wrapped.cdc", [minterAccount], [acct.address, username, ticket, totalNftsOwned, floatCount, favoriteCollections, collections], "address has already been minted")
}

pub fun registerEdition(rafflesAcct: Test.Account, removeAfterReveal: Bool, start: UInt64, end: UInt64, baseImageUrl: String, baseHtmlUrl: String) {
    txExecutor("register_edition.cdc", [rafflesAcct], [removeAfterReveal, start, end, baseImageUrl, baseHtmlUrl], nil)
}
