# Cryptovik Monitoring Script / show-solana-node-info_v2.sh
### 💛💙 Stand with Ukraine! 💙💛
❇️ Say thanks to author (SOL): BrnMNcFz6EzjZsQM8xNbrTsJE88fyXU2X6Crar9QPpsK / cryptovik.sol
  
 
### This is complex CLI script for solana node monitoring
 
 
## TL;DR
Script uses On-chain solana data, API of solana.org, API of Grafana

You can see data of ANY solana validator node

This is the tool for monitoring multiple nodes with cli

Tool has two modes: full and short

If node don't have standart Grafana (telegraf) installed than you cannot see hardware info of it
 
 
## How to use show-solana-node-info_v2.sh:

1. Move file `show-solana-node-info_v2.sh` to the server or instance **with installed solana**


2. Install rust, solana-foundation-delegation-program-cli and jq:

`apt-get update && curl https://sh.rustup.rs/ -sSf | sh`

enter 1 + Enter

`source $HOME/.cargo/env && rustup update`

`sudo apt-get install libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang make`

enter y + Enter

`cargo install solana-foundation-delegation-program-cli`

`sudo apt  install jq  # version 1.6-1ubuntu0.20.04.1`
 
 
3. `chmod u+x ./show-solana-node-info_v2.sh`
 
 
4. `./show-solana-node-info_v2.sh` - if you run this script on your node


### You can use script on any instance with installed solana,
and you can read data of **any node** in solana blockchain:

`./show-solana-node-info.sh <NODE_PUBKEY> <CLUSTER> <TRUE_FOR_SHORT>`

where
`<NODE_PUBKEY>` - pubkey of any node, 
`<CLUSTER_ABBREVIATED>` - `-ut` or `-ud` or `-um` or `-ul` for cluster, 
`<TRUE_FOR_SHORT>` - `true` if you want short return and `false` / nothing if you wnt full return

## Known issues:
1. **RPC issues**. If PRC is slow or un unavailable than you can see errors. Working to rotate RPC if so.
2. **If --no-voting is set**, than you cannot see node info here.
3. **If pubkey doesn't belongs to node**, there will be some errors.
 
  
## Appreciation
Part of `see schedule block` (shows estimated time of scheduled slots of node) modified from https://github.com/Vahhhh/solana/blob/main/see-schedule.sh - BIG THANKS!!!
 
  
## Example
![My TDS node FULL return](/example1.png "My TDS node FULL return")

![My MB node SHORT return](/example2.png "My MB node SHORT return")
