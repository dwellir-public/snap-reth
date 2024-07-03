# reth snap

The Rust ethereum exexution client.

Use with some consensus client, such as lighthouse to participate in the ethereum network.

The snap will not open HTTP/WS ports by default. You can change this by adding the --http, --ws flags, 
respectively and using the --http.api and --ws.api flags to enable various JSON-RPC APIs. 

For more commands, see the reth node CLI reference.

## Initial information

The snap uses (defaults)

* debug log directory: /root/snap/reth/x1/.cache/reth/logs/mainnet
* database path="/root/snap/reth/x1/.local/share/reth/mainnet/db"
* Configuration loaded path="/root/snap/reth/x1/.local/share/reth/mainnet/reth.toml"
* JWT auth secret file path="/root/snap/reth/x1/.local/share/reth/mainnet/jwt.hex"
* RPC auth server started url=127.0.0.1:8551
* RPC IPC server started path=/tmp/reth.ipc

## Start reth-daemon (systemd)
  sudo systemctl start snap.reth.reth-daemon.service

## Query database (using the reth cli)
  sudo reth db stats

## TODO

- [] Test with some 
