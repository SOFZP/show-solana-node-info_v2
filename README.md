# Solana Nodes CLI Monitoring Script
#### 💛💙 Stand with Ukraine! 💙💛
##### ❇️ Say thanks to author (SOL): BrnMNcFz6EzjZsQM8xNbrTsJE88fyXU2X6Crar9QPpsK / cryptovik.sol
  
 
### This is complex CLI script for solana nodes monitoring
 
 
## TL;DR
Script uses **on-chain solana data, API of solana.org, API of Grafana**

You can see data of **ANY solana validator node**

This is the tool for monitoring multiple nodes with cli

Tool has two modes: **full and short**

If node don't have standart Grafana (telegraf) installed than you cannot see hardware info of it

All returned parameters are decribed in the end of this readme
 
 
## How to use show-solana-node-info_v2.sh:

1. Move file `show-solana-node-info_v2.sh` to the server or instance **with installed solana**


2. Install **rust, solana-foundation-delegation-program-cli and jq**:

`apt-get update && curl https://sh.rustup.rs/ -sSf | sh`

enter 1 + Enter

`source $HOME/.cargo/env && rustup update`

`sudo apt-get install libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang make`

enter y + Enter

`cargo install solana-foundation-delegation-program-cli`

`sudo apt  install jq  # version 1.6-1ubuntu0.20.04.1`
 
 
3. Give permissions to the script: `chmod u+x ./show-solana-node-info_v2.sh`
 
 
4. Run it on your node without parameters: `./show-solana-node-info_v2.sh`


### You can use script on any instance with installed solana,
and you can read data of **any node** in solana blockchain:

`./show-solana-node-info_v2.sh <NODE_PUBKEY> <CLUSTER> <TRUE_FOR_SHORT>`

where
`<NODE_PUBKEY>` - pubkey of any node, 

`<CLUSTER>` - `-ut` or `-ud` or `-um` or `-ul` for cluster, 

`<TRUE_FOR_SHORT>` - `true` if you want short return and `false` / nothing if you want full return


## Known issues:
1. **RPC issues**. If PRC is slow or unavailable than you can see RPC errors. Working now to rotate RPC if so happens.
2. **If --no-voting is set**, than you cannot see node info here.
3. **If pubkey doesn't belongs to node**, there will be some errors.
 
  
## Appreciation
Part of `see schedule block` (shows estimated time of scheduled slots of node) modified from https://github.com/Vahhhh/solana/blob/main/see-schedule.sh - BIG THANKS!!!
 
  
## Examples
### My TDS node FULL return (Testnet cluster restart was active at that moment)
![My TDS node FULL return](/example1.png "My TDS node FULL return")
### My MB node SHORT return
![My MB node SHORT return](/example2.png "My MB node SHORT return")


# All script returned data

1. *Time now* - counting as time of server. You can change time of server:

`sudo ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime`

Check it:

`date` or `timedatectl`

2. *Solana Price*. If Grafana is not set or have its own issues than you can see NULL here

3. *Epoch Progress*

4. 

5.

6.

7.

.

.

❇️ Say thanks to author (SOL): BrnMNcFz6EzjZsQM8xNbrTsJE88fyXU2X6Crar9QPpsK / cryptovik.sol
