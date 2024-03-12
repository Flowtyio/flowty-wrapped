import Test

import "NFTCatalog"
import "NonFungibleToken"

import "ExampleNFT"
import "ExampleNFT2"
import "ExampleToken"
import "ExampleTokenUnsupported"
import "FlowToken"
import "NFTStorefrontV2"

// Helper functions. All of the following were taken from
// https://github.com/onflow/Offers/blob/fd380659f0836e5ce401aa99a2975166b2da5cb0/lib/cadence/test/Offers.cdc
// - deploy
// - scriptExecutor
// - txExecutor
// - getErrorMessagePointer

access(all) fun scriptExecutor(_ scriptName: String, _ arguments: [AnyStruct]): AnyStruct? {
    let scriptCode = loadCode(scriptName, "scripts")
    let scriptResult = Test.executeScript(scriptCode, arguments)

    if let failureError = scriptResult.error {
        panic(
            "Failed to execute the script because -:  ".concat(failureError.message)
        )
    }

    return scriptResult.returnValue
}

access(all) fun expectScriptFailure(_ scriptName: String, _ arguments: [AnyStruct]): String {
    let scriptCode = loadCode(scriptName, "scripts")
    let scriptResult = Test.executeScript(scriptCode, arguments)

    assert(scriptResult.error != nil, message: "script error was expected but there is no error message")
    return scriptResult.error!.message
}

access(all) fun loadCode(_ fileName: String, _ baseDirectory: String): String {
    return Test.readFile("../".concat(baseDirectory).concat("/").concat(fileName))
}

access(all) enum ErrorType: UInt8 {
    access(all) case TX_PANIC
    access(all) case TX_ASSERT
    access(all) case TX_PRE
}

access(all) fun getErrorMessagePointer(errorType: ErrorType): Int {
    switch errorType {
        case ErrorType.TX_PANIC: return 159
        case ErrorType.TX_ASSERT: return 170
        case ErrorType.TX_PRE: return 174
        default: panic("Invalid error type")
    }
}


// https://github.com/green-goo-dao/flow-utils/blob/main/cadence/contracts/ArrayUtils.cdc
access(all) fun rangeFunc(_ start: Int, _ end: Int, _ f: ((Int): Void)) {
    var current = start
    while current < end {
        f(current)
        current = current + 1
    }
}

access(all) fun range(_ start: Int, _ end: Int): [Int] {
    let res: [Int] = []
    rangeFunc(start, end, fun (i: Int) {
        res.append(i)
    })
    return res
}

// https://github.com/green-goo-dao/flow-utils/blob/main/cadence/contracts/StringUtils.cdc
access(all) fun index(_ s: String, _ substr: String, _ startIndex: Int): Int? {
    for i in range(startIndex, s.length - substr.length + 1) {
        if s[i] == substr[0] && s.slice(from: i, upTo: i + substr.length) == substr {
            return i
        }
    }
    return nil
}

// Copied functions from flow-utils so we can assert on error conditions
// https://github.com/green-goo-dao/flow-utils/blob/main/cadence/contracts/StringUtils.cdc
access(all) fun contains(_ s: String, _ substr: String): Bool {
    if let index = index(s, substr, 0) {
        return true
    }
    return false
}

access(all) fun txExecutor(_ txName: String, _ signers: [Test.TestAccount], _ arguments: [AnyStruct], _ expectedError: String?, _ expectedErrorType: ErrorType?): Test.TransactionResult {
    let txCode = loadCode(txName, "transactions")

    let authorizers: [Address] = []
    for signer in signers {
        authorizers.append(signer.address)
    }

    let tx = Test.Transaction(
        code: txCode,
        authorizers: authorizers,
        signers: signers,
        arguments: arguments,
    )

    let txResult = Test.executeTransaction(tx)
    if let err = txResult.error {
        if let expectedErrorMessage = expectedError {
            let ptr = getErrorMessagePointer(errorType: expectedErrorType!)
            let errMessage = err.message
            let hasEmittedCorrectMessage = contains(errMessage, expectedErrorMessage)
            let failureMessage = "Expecting - "
                .concat(expectedErrorMessage)
                .concat("\n")
                .concat("But received - ")
                .concat(err.message)
            assert(hasEmittedCorrectMessage, message: failureMessage)
        }
        panic(err.message)
    } else {
        if let expectedErrorMessage = expectedError {
            panic("Expecting error - ".concat(expectedErrorMessage).concat(". While no error triggered"))
        }
    }

    return txResult
}


// the cadence testing framework allocates 4 addresses for system acounts,
// and 10 pre-created accounts for us to use for deployments:
pub let Account0x1 = Address(0x0000000000000001)
pub let Account0x2 = Address(0x0000000000000002)
pub let Account0x3 = Address(0x0000000000000003)
pub let Account0x4 = Address(0x0000000000000004)
pub let Account0x5 = Address(0x0000000000000005)
pub let Account0x6 = Address(0x0000000000000006)
pub let Account0x7 = Address(0x0000000000000007)
pub let Account0x8 = Address(0x0000000000000008)
pub let Account0x9 = Address(0x0000000000000009)
pub let Account0xa = Address(0x000000000000000a)
pub let Account0xb = Address(0x000000000000000b)
pub let Account0xc = Address(0x000000000000000c)
pub let Account0xd = Address(0x000000000000000d)
pub let Account0xe = Address(0x000000000000000e)

pub let serviceAccount = Test.getAccount(Account0x5)
pub let flowtyAccount = Test.getAccount(Account0x5)
pub let flowtyUtilsAccount = Test.getAccount(Account0x6)
pub let storefrontAccount= Test.getAccount(Account0x6)
pub let permittedAccount = Test.getAccount(Account0x6)
pub let catalogAccount = Test.getAccount(Account0x9)
pub let flowtyTestNFTAccount = Test.getAccount(Account0xb)
pub let exampleTokenAccount = Test.getAccount(Account0xb)

// Example NFT constants
pub let exampleNftStoragePath = /storage/exampleNFTCollection
pub let exampleNftPublicPath = /public/exampleNFTCollection
pub let exampleNftProviderPath = /private/exampleNFTCollection

// Example NFT 2 constants
pub let exampleNft2StoragePath = /storage/exampleNFT2Collection
pub let exampleNft2PublicPath = /public/exampleNFT2Collection
pub let exampleNft2ProviderPath = /private/exampleNFT2Collection

// Example Token constants
pub let exampleTokenStoragePath = /storage/exampleTokenVault
pub let exampleTokenReceiverPath = /public/exampleTokenReceiver
pub let exampleTokenProviderPath = /private/exampleTokenProvider
pub let exampleTokenBalancePath = /public/exampleTokenBalance

// Unsupported Token constants
pub let exampleUnsupportedTokenStoragePath = /storage/exampleTokenUnsupportedVault
pub let exampleUnsupportedTokenReceiverPath = /public/exampleTokenUnsupportedReceiver

// Flow Token constants
pub let flowTokenStoragePath = /storage/flowTokenVault
pub let flowTokenReceiverPath = /public/flowTokenReceiver


pub fun deployAll() {
    deploy("ExampleNFT", "../contracts/standard/ExampleNFT.cdc", [])
    deploy("ExampleNFT2", "../contracts/standard/ExampleNFT2.cdc", [])
    deploy("FlowtyTestNFT", "../contracts/standard/FlowtyTestNFT.cdc", [])
    deploy("ExampleToken", "../contracts/standard/ExampleToken.cdc", [])
    deploy("ExampleTokenUnsupported", "../contracts/standard/ExampleTokenUnsupported.cdc", [])
    deploy("FUSD", "../contracts/standard/FUSD.cdc", [])
    deploy("MaliciousNftProvider", "../contracts/malicious/MaliciousNftProvider.cdc", [])

    deploy("NFTCatalog", "../node_modules/@flowtyio/flow-contracts/contracts/nft-catalog/NFTCatalog.cdc", [])
    deploy("NFTCatalogAdmin", "../node_modules/@flowtyio/flow-contracts/contracts/nft-catalog/NFTCatalogAdmin.cdc", [])
    deploy("FeeEstimator", "../node_modules/@flowtyio/flow-contracts/contracts/lost-and-found/FeeEstimator.cdc", [])
    deploy("LostAndFound", "../node_modules/@flowtyio/flow-contracts/contracts/lost-and-found/LostAndFound.cdc", [])
    deploy("TokenForwarding", "../node_modules/@flowtyio/flow-contracts/contracts/TokenForwarding.cdc", [])
    deploy("DapperUtilityCoin", "../node_modules/@flowtyio/flow-contracts/contracts/dapper/DapperUtilityCoin.cdc", [])
    deploy("FlowUtilityToken", "../node_modules/@flowtyio/flow-contracts/contracts/dapper/FlowUtilityToken.cdc", [])
    
    deploy("ArrayUtils", "../node_modules/@flowtyio/flow-contracts/contracts/flow-utils/ArrayUtils.cdc", [])
    deploy("StringUtils", "../node_modules/@flowtyio/flow-contracts/contracts/flow-utils/StringUtils.cdc", [])
    
    deploy("ScopedFTProviders", "../contracts/ScopedFTProviders.cdc", [])
    deploy("RoyaltiesLedger", "../contracts/RoyaltiesLedger.cdc", [])
    deploy("Filter", "../contracts/Filter.cdc", [])
    deploy("Permitted", "../contracts/Permitted.cdc", [])
    deploy("RoyaltiesOverride", "../contracts/RoyaltiesOverride.cdc", [])
    deploy("FlowtyUtils", "../contracts/FlowtyUtils.cdc", [])

    // Must be deployed after Filter
    deploy("InvalidFilter", "../contracts/malicious/InvalidFilter.cdc", [])

    deploy("Flowty", "../contracts/Flowty.cdc", [])
    deploy("FlowtyRentals", "../contracts/FlowtyRentals.cdc", [])
    deploy("NFTStorefrontV2", "../contracts/NFTStorefrontV2.cdc", [])
    deploy("Offers", "../contracts/Offers.cdc", [])

    let typeIdentifier = Type<@ExampleNFT.NFT>().identifier
    addEntryToCatalog(
        collectionIdentifier: "Test NFT",
        contractName: "ExampleNFT",
        contractAddress: flowtyTestNFTAccount.address,
        nftTypeIdentifer: typeIdentifier,
        message: "na"
    )

    txExecutor("admin/configure_flowty_utils.cdc", [flowtyUtilsAccount], [], nil, nil)
    txExecutor("admin/configure_flowty.cdc", [flowtyAccount], [], nil, nil)
    txExecutor("example-token/setup.cdc", [flowtyAccount], [], nil, nil)

    setupDepositor(flowtyAccount)
    setupDepositor(flowtyUtilsAccount)

    setupExampleToken(acct: flowtyTestNFTAccount)
    setupExampleToken(acct: storefrontAccount)
}

pub fun deploy(_ name: String, _ path: String, _ arguments: [AnyStruct]) {
    let err = Test.deployContract(name: name, path: path, arguments: arguments)
    Test.expect(err, Test.beNil()) 
}

pub fun addEntryToCatalog(
  collectionIdentifier : String,
  contractName: String,
  contractAddress: Address,
  nftTypeIdentifer: String,
  message: String
) {
    txExecutor("nft-catalog/add_entry.cdc", [catalogAccount], [collectionIdentifier, contractName, contractAddress, nftTypeIdentifer, message], nil, nil)
    let proposalEvent = Test.eventsOfType(Type<NFTCatalog.ProposalEntryAdded>()).removeLast() as! NFTCatalog.ProposalEntryAdded
    let proposalID = proposalEvent.proposalID
    txExecutor("nft-catalog/approve_entry.cdc", [catalogAccount], [proposalID], nil, nil)
}

pub fun removeEntryFromCatalog(_ identifier: String) {
    txExecutor("nft-catalog/remove_entry.cdc", [catalogAccount], [identifier], nil, nil)
}

pub fun flowtyAdminConfigureAll() {
    txExecutor("admin/configure_all.cdc", [flowtyAccount], [], nil, nil)
}

pub fun getNewAccount(): Test.Account {
    let acct = Test.createAccount()
    setupExampleNFT(acct: acct)
    setupExampleToken(acct: acct)
    return acct
}

pub fun setupExampleToken(acct: Test.Account) {
    txExecutor("example-token/setup.cdc", [acct], [], nil, nil)
}

pub fun mintExampleTokens(_ acct: Test.Account, _ amount: UFix64) {
    txExecutor("example-token/mint.cdc", [exampleTokenAccount], [acct.address, amount], nil, nil)
}

pub fun mintExampleTokensUnsupported(_ acct: Test.Account, _ amount: UFix64) {
    txExecutor("example-token-unsupported/mint.cdc", [exampleTokenAccount], [acct.address, amount], nil, nil)
}

pub fun setupExampleNFT(acct: Test.Account) {
    txExecutor("example-nft/setup.cdc", [acct], [], nil, nil)
}

pub fun mintExampleNFTs(_ acct: Test.Account, _ num: Int): [UInt64] {
    let txRes = txExecutor("example-nft/mint_example_nft.cdc", [flowtyTestNFTAccount], [acct.address, num], nil, nil)
    let events = Test.eventsOfType(Type<ExampleNFT.Deposit>())

    let ids: [UInt64] = []
    while ids.length < num {
        let event = events.removeLast() as! ExampleNFT.Deposit
        ids.append(event.id)
    }

    return ids
}

pub fun mintExampleNFTByID(_ acct: Test.Account, _ id: UInt64): UInt64 {
    post {
        result == id
    }

    let txRes = txExecutor("example-nft/mint_example_nft_with_id.cdc", [flowtyTestNFTAccount], [acct.address, id], nil, nil)
    let events = Test.eventsOfType(Type<ExampleNFT.Deposit>())
    let event = events.removeLast() as! ExampleNFT.Deposit
    return event.id
}

pub fun setupExampleNFT2(acct: Test.Account) {
    txExecutor("example-nft-2/setup.cdc", [acct], [], nil, nil)
}


pub fun mintExampleNFT2s(_ acct: Test.Account, _ num: Int): [UInt64] {
    let txRes = txExecutor("example-nft-2/mint.cdc", [flowtyTestNFTAccount], [acct.address, num], nil, nil)
    let events = Test.eventsOfType(Type<ExampleNFT2.Deposit>())

    let ids: [UInt64] = []
    while ids.length < num {
        let event = events.removeLast() as! ExampleNFT2.Deposit
        ids.append(event.id)
    }

    return ids
}

pub fun mintExampleNFT2ByID(_ acct: Test.Account, _ id: UInt64): UInt64 {
    post {
        result == id
    }

    let txRes = txExecutor("example-nft-2/mint_example_nft_with_id.cdc", [flowtyTestNFTAccount], [acct.address, id], nil, nil)
    let events = Test.eventsOfType(Type<ExampleNFT.Deposit>())
    let event = events.removeLast() as! ExampleNFT.Deposit
    return event.id
}

pub fun exampleNftIdentifier(): String {
    return Type<@ExampleNFT.NFT>().identifier
}

pub fun exampleNft2Identifier(): String {
    return Type<@ExampleNFT2.NFT>().identifier
}

pub fun exampleTokenIdentifier(): String {
    return Type<@ExampleToken.Vault>().identifier
}

pub fun flowTokenIdentifier(): String {
    return Type<@FlowToken.Vault>().identifier
}

pub fun exampleTokenUnsupportedIdentifier(): String {
    return Type<@ExampleTokenUnsupported.Vault>().identifier
}

pub fun setupExampleTokenUnsupported(_ acct: Test.Account) {
    txExecutor("example-token-unsupported/setup.cdc", [acct], [], nil, nil)
}

pub fun unlinkPath(_ acct: Test.Account, _ path: CapabilityPath) {
    txExecutor("util/unlink_path.cdc", [acct], [path], nil, nil)
}

pub fun heartbeat() {
    txExecutor("util/heartbeat.cdc", [serviceAccount], [], nil, nil)
}

pub fun getCurrentTime(): UFix64 {
    return scriptExecutor("util/get_current_time.cdc", [])! as! UFix64
}

pub fun mintFlowTokens(to: Test.Account, amount: UFix64) {
    let service = Test.serviceAccount()
    txExecutor("flow-token/send.cdc", [service], [to.address, amount], nil, nil)
}

pub fun setupMaliciousProvider(_ acct: Test.Account, _ id: UInt64?) {
    txExecutor("malicious/example_nft_to_example_nft_2_provider.cdc", [acct], [id], nil, nil)
}

pub fun setupDepositor(_ acct: Test.Account) {
    let threshold = 10.0
    // mintFlowTokens(to: acct, amount: threshold)
    txExecutor("lost-and-found/setup_depositor.cdc", [acct], [threshold], nil, nil)
}

pub fun getExampleTokenBalance(_ acct: Test.Account): UFix64 {
    return scriptExecutor("example-token/get_balance.cdc", [acct.address])! as! UFix64
}

pub fun overrideRoyalties(_ identifier: String) {
    txExecutor("admin/royalties/override_royalties.cdc", [flowtyUtilsAccount], [identifier], nil, nil)
}

pub fun removeRoyaltiesOverride(_ identifier: String) {
    txExecutor("admin/royalties/remove_override.cdc", [flowtyUtilsAccount], [identifier], nil, nil)
}

pub fun redeemNftFromLostAndFound(_ redeemer: Test.Account, ticketID: UInt64, path: CapabilityPath, typeIdentifier: String) {
    txExecutor("lost-and-found/redeem_ticket_nft.cdc", [redeemer], [ticketID, path, typeIdentifier], nil, nil)
}

pub fun redeemFtFromLostAndFound(_ redeemer: Test.Account, ticketID: UInt64, path: CapabilityPath, typeIdentifier: String) {
    txExecutor("lost-and-found/redeem_ticket_ft.cdc", [redeemer], [ticketID, path, typeIdentifier], nil, nil)
}

pub fun transferNft(sender: Test.Account, receiver: Test.Account, nftID: UInt64, nftStoragePath: StoragePath) {
    txExecutor("util/transfer_nft.cdc", [sender], [receiver.address, nftID, nftStoragePath], nil, nil)
}

pub fun createStorefrontListing(
    maker: Test.Account,
    nftID: UInt64,
    price: UFix64,
    customID: String?,
    expiry: UInt64,
    tokenIdentifier: String,
    nftProviderPath: PrivatePath,
    nftTypeIdentifier: String,
    paymentReceiverPath: PublicPath
): UInt64 {
    txExecutor("nftstorefront/sell_item.cdc", [maker], [nftID, price, customID, expiry, tokenIdentifier, nftProviderPath, nftTypeIdentifier, paymentReceiverPath], nil, nil)
    let event = Test.eventsOfType(Type<NFTStorefrontV2.ListingAvailable>()).removeLast() as! NFTStorefrontV2.ListingAvailable
    return event.listingResourceID
}

pub fun getNftUuid(acct: Test.Account, nftID: UInt64, nftStoragePath: StoragePath): UInt64 {
    return scriptExecutor("util/get_nft_uuid.cdc", [acct.address, nftID, nftStoragePath])! as! UInt64
}

pub fun setPermittedType(identifier: String, value: Bool) {
    txExecutor("permitted/set_permitted_type.cdc", [storefrontAccount], [identifier, value, "some message"], nil, nil)
}