Bitcoin Ultimate BTCU Core Main Concepts
=====================================

The concept of BTCU is similar to the concept of the second cryptocurrency by capitalization - Ethereum. 
Like Ethereum, the Bitcoin Ultimatum blockchain provides smart contracts in the blockchain protocol as one of the important functions for the implementation of transactions and DAPP applications. 
The BTCU team sets itself the task of developing the direction of smart contracts and implementing atomic swap technology natively into the blockchain protocol to allow carry out transactions not only within the framework of a single blockchain protocol, 
but also interact with other protocols, which will globally expand the possibilities of this technology. 
The main goal is to make a hybrid of LPoS mining algorithm and PoA to make a real decentralizing infrastructure with limited validators. 
 


 


### Smart Contracts
Virtual Machine BTCU -  Ethereum Virtual Machine (EVM)  which supports Solidity programming language, facilitating mainstream adoption of smart contract development.

Smart contracts are the future of the blockchain world. Creating your own smart contract is the main feature of the blockchain world - so access for every user who wants to make a smart contract is one of the largest steps of BTCU.

The EVM is stack-based with a 256-bit machine word. Smart contracts that run on Ethereum use this virtual machine for their execution. The EVM is designed for the blockchain of Ethereum and thus assumes that all value transfers use an account-based method. BTCU is based on the blockchain design of Bitcoin and uses the UTXO-based model. Thus, BTCU has an account abstraction layer that translates the UTXO-based model to an account-based interface for the EVM. Note that an abstraction layer in computing is instrumental for hiding the implementation details of particular functionality to establish a separation of concerns for facilitating interoperability and platform independence.

The next step of evolution is a  WebAssembly. The next generation of the platform for smart contract building in BTCU. WebAssembly (abbreviated Wasm) is a binary instruction format for a stack-based virtual machine. Wasm is designed as a portable target for compilation of high-level languages like C/C++/Rust, enabling deployment on the web for client and server applications. 



### Private transactions 
Based on Zerocash protocol, this is a privacy-protecting, digital currency built on strong science. Transact efficiently and safely with low fees while ensuring digital transactions remain private. Selectively share address and transaction information for auditing or regulatory compliance



### Airdrop
The important thing to focus on for a Bitcoin airdrop is not the blockchain like a fork, but rather Bitcoin's UTXO(Unspent Transaction Output) set, which is a log containing the current ownership of bitcoin and associated addresses. As new blocks are mined with a new set of transactions on the Bitcoin network, the UTXO set is modified to incorporate the change of ownership reflected by those transactions.

When the fork is launched, an airdrop will be conducted to all users of the Bitcoin network to wallets identical in the BTCU network in the ratio of 1:1 to the BTC balance on the branch block. 


### Network validation principle 

+ Masternode network
The BTCU network is two-tiered. The network is composed of the first, staking tier, in which all BTCU holders can participate in through staking their coins; and the more exclusive masternode tier.
Masternodes are a set of incentivised nodes on a network within the BTCU network responsible for the handling of particular specialised tasks. The functions carried out by BTCU masternodes are fundamentally similar, however, like in PoS coins. As such, these nodes are an integral part of the BTCU digital ecosystem, and necessary to network functionality.


+ Masternode network technical functions
The Masternode network fulfils a range of functions independent of staking nodes. These distinct functions are limited to masternodes, and cannot be completed by a standard staking node. These responsibilities are distributed across the Masternode network, and no one masternode has power or authority in excess of others in the network.



### Hash algorithm: SHA-256



### Private key generation algorithm
BTCU uses the ECDSA, or Elliptic Curve Digital Signature Algorithm. More specifically, it uses one particular curve called secp256k1.
This curve has an order of 256 bits, takes 256 bits as input, and outputs 256-bit integers. And 256 bits is exactly 32 bytes. To put it another way, we need 32 bytes of data to feed to this curve algorithm.
There is an additional requirement for the private key. Because we use ECDSA, the key should be positive and should be less than the order of the curve. The order of secp256k1 is in format F..FEBAAEDCE6AF48A03BBFD25E8CD0364141, which is pretty big: almost any 32-byte number will be smaller than it.



Based on…
=================================

BTCU is based on PiVX, fork of DaSH which is based on the Bitcoin blockchain. BTCU integrates Quantum smart contract functionality, which is based on Ethereum Virtual Machine to improve the consensus algorithm by core-coin logic and for user contract creation. 
Airdrop will be used by the BTC UXTO - will be deposited for all users of the Bitcoin network to wallets identical in the BTCU network in the ratio of 1: 1 to the BTC balance on the branch block. The consensus algorithm based on PoA and LPoS logic and the main thing is Leased Proof of Stake gives users the opportunity to lease their balance to full nodes to make a profit - base logic of Waves.

So BTCU based on the next blockchain technologies:


+ Bitcoin
+ PiVX
+ Quantum
+ Ethereum
+ ZCash
+ Waves


This amount of blockchain integration gives all users the opportunity to use all the advantages of the world's lead coins and blockchain technologies.

Futures
==============================================
### Post-quantum cryptography
Even though current, publicly known, experimental quantum computers lack processing power to break any real cryptographic algorithm, we are designing new algorithms to prepare for a time when quantum computing becomes a threat.

It will be based on currently post-quantum cryptography research is mostly focused on six different approaches:


+ Lattice-based cryptography
+ Multivariate cryptography
+ Hash-based cryptography
+ Code-based cryptography
+ Supersingular elliptic curve isogeny cryptography
+ Symmetric key quantum resistance



### Atomic swap
One of the best features of cross swap is the removal of intermediary tokens. Eg. if you have LTC and want to buy BTCU in a normal exchange, you will have to sell your LTC for BTC and then buy your BTCU. Via atomic swaps, you can get this trade done in one go. Is no more necessary to use other services for exchange.

Atomic Swaps has the potential of completely revolutionizing the money transfer system in the crypto world. To put it in simple terms, atomic swaps will enable people to directly trade with one another wallet-to-wallet. As we have stated earlier, can either be conducted on-chain or off-chain.
On-Chain swaps take place on either currency’s blockchain. In order to do this though, both currencies must:


+ Support HTLC
+ Have the same hashing algorithm

### Advantages of Atomic Swaps
+ Interoperability between the different assets is a huge problem right now in cryptocurrencies. Atomic swaps are going to bring users of all these different coins together to help them interact with each other.

+ Atomic swap makes the crypto ecosystem more “currency agnostic”. Because people with different crypto holdings will now be able to interact with each other, it is pretty likely that people will be more open to diversifying their holdings instead of just depending on a few coins.

+ Atomic Swaps will open the doors to trustless and fee-less decentralized exchanges.
+ Central exchanges are centralized and hence open to a host of attacks. Atomic swaps remove the need for having a 3rd party and makes the trade as direct as possible.
+ External attacks aside, centralized exchanges are also suspect to internal maintenance issues and corruption. Wallet maintenance” or disabled withdrawals are especially two big problems. Atomic swaps are going to give you complete control over your money.
+ Direct wallet-to-wallet trading epitomizes decentralization in its purest form. Exchanges are constantly targeted for regulation purposes which makes the whole trading process increasingly centralized.
+ Since atomic swap directly connects two wallets to each other, it removes all the steps and confirmations required by centralized exchanges.



 ###More information at [btcu.io](http://www.btcu.io/)
 
