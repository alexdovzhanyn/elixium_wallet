## Functionality

## Complete
# Create Splash Screen with animation -- Done
# Mnemonics Working both directions -- Done
# Horizontal Navigation Bar Created -- Done
# Scenes change and operate correctly -- Done
# Key Pair Successfully saves in correct location -- Done
# OS Determination affects the Default Key Location -- Done
# Send Menu Created -- Done
# Receive Menu Created -- Done



## ToDo

# Shift Import/Export Functions into Core PR
# Shift Mnemonic Modules into Core
# Make Wallet Send Transactions
# Make Wallet Receive Transactions
# Fix Mem/Performance issues


# Minimum necessary functionality:
Send transactions
Being able to specify miner fee
Receive transactions
Viewing your own address
QR code with address info
View balance
Generate keys
Backup keys via mnemonic
Import keys

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
