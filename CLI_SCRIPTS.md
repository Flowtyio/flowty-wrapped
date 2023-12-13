Flow CLI ready to paste scripts for Flowty Wrapper transactions and scripts


1 - Create new emulator account
(if you already made this step before but restarted emulator, remove emulator-1 object from flow.json)
`flow accounts create`

On account name you can add: `emulator-1`

2 - Setup FlowtyWrapper Collection
`flow transactions send --signer=emulator-1 transactions/setup_flowty_wrapper.cdc`

3 - Mint FlowtyWrapper 

`flow transactions send --signer=emulator-account transactions/mint_flowty_wrapper.cdc '0x01cf0e2f2f715450'`
