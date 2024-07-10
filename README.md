# reth snap

The Rust ethereum execution client.

Use with some consensus client, such as lighthouse to participate in the ethereum network.

The snap will not open HTTP/WS ports by default. You can change this by adding the --http, --ws flags, 
respectively and using the --http.api and --ws.api flags to enable various JSON-RPC APIs. 

For more commands, see the reth node CLI reference.

## Initial information

The snap uses (defaults)

* Config: /var/snap/reth/common/datadir/reth.toml
* debug log directory: /root/snap/reth/current/.cache/reth/logs/mainnet
* database path="/var/snap/reth/common/datadir/db"
* Configuration loaded path="/var/snap/reth/common/datadir/reth.toml"
* JWT auth secret file path="$SNAP_COMMON/jwt.hex"
* RPC auth server started url=127.0.0.1:8551
* RPC IPC server started path=/tmp/reth.ipc

## Running
Assuming you run reth and lighthouse on the same localhost, this will get you running lighthouse with reth.

Start by installing reth:

    sudo snap install reth

(Optionally) Set the snap to not restart after an automatic upgrade. You need to restart the reth-daemon yourself if set.

    sudo snap set reth endure=true

Install and use with "lighthouse" to participate in the ethereum network.

    sudo snap install lighthouse

Check and change the configuration of reth and/or lighthouse to your liking:

    snap get lighthouse
    snap get reth

Start reth.

    sudo snap start reth

Copy the jwt.hex from reth -> lighthouse

    sudo cp /var/snap/reth/common/datadir/jwt.hex /var/snap/lighthouse/common/

Start lighthouse:

    sudo snap start lighthouse

Check logs:

    sudo snap logs reth -f
    sudo snap logs lighthouse -f

## Start reth-daemon (snap)
    sudo snap start reth

## Query database (using the reth cli)
    sudo reth db stats

## Pruning

Stop the reth-daemon:

    sudo snap stop reth

Prune:
  
    sudo reth prune --chain mainnet
