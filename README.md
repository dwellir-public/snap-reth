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

## Start reth-daemon (snap)
  sudo snap start reth

## Query database (using the reth cli)
  sudo reth db stats

## Pruning

Stop the reth-daemon:

  sudo snap stop reth

Prune:
  
   sudo reth prune --chain mainnet
