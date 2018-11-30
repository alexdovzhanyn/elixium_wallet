## Functionality

## Complete
- Create Splash Screen with animation -- Done
- Mnemonics Working both directions -- Done
- Horizontal Navigation Bar Created -- Done
- Scenes change and operate correctly -- Done
- Key Pair Successfully saves in correct location -- Done
- OS Determination affects the Default Key Location -- Done
- Send Menu Created -- Done
- Receive Menu Created -- Done
- Back buttons on the key settings -- Done
- Receive page grabs random public keys -- Done
- Imports keys based on mnemonic and private keys -- Done
- Shift Import/Export Functions into Core PR -- Done
- Shift Mnemonic Modules into Core -- Done
- Make Wallet Send Transactions -- Done
- Make Wallet Receive Transactions -- Done
- Fix Mem/Performance issues -- Done
- Multi component internal state -- Done



# To Do:
- Path and fix import/export keys



# Minimum necessary functionality:
Send transactions - Working
Being able to specify miner fee - Working
Receive transactions - Working
Viewing your own address - Working
QR code with address info - Working
View balance - Working
Generate keys - Working
Backup keys via mnemonic - Working
Import keys - Working

#Nice to have somewhere down the line:
Debug section with useful stats like block number, peer connection info, and network usage
Generating a new key-pair for every transaction

#Implementation
The wallet will need to be a full node, which will verify blocks and transactions, fork and resolve
forks when necessary, and execute smart contract code (when we build out smart contracting).

#Keys
-Generate Create Key Pair
-ISSUES: File Location is in project, need to change the core to get the correct os
-Load Get file from location
-Importing: it should allow people to paste either a private key in or type in a mnemonic to restore a key
-issue: need get from private or mnemonic

#Send
-Validating Address Format
-Build TRANSACTION
-Broadcast Transaction Via Message

#Receive
-Validate new Public

# Main Menu
-Send
-Receive
-View Balance
-Keys (Gen/Backup/Import)
-Debug/Analysis

#Questions:
-Keys Not one key for wallet
-MVP basic Functionality
-Balance for entire wallet
-mnemonics
