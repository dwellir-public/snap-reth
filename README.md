# reth snap

The Rust ethereum execution client.

Use with some consensus client, such as lighthouse to participate in the ethereum network.

It installs the "reth" command line tool and a reth-daemon service.

The snap will not open HTTP/WS ports by default. You can change this by adding the --http, --ws flags, 
respectively and using the --http.api and --ws.api flags to enable various JSON-RPC APIs. 

The snap only accepts --datadir paths: "/mnt /media /run/media" or $SNAP_COMMON/datadir (default)

## Running

This example assumes reth and lighthouse are both on localhost.

* Reth --datadir path: /mnt/reth/datadir


Start by installing reth:

    sudo snap install reth

(Optionally) Set the snap to not restart after an automatic upgrade. You need to restart the reth-daemon yourself if set.

    sudo snap set reth endure=true

Install and use with "lighthouse" to participate in the ethereum network.

    sudo snap install lighthouse

Check and change the configuration of reth and/or lighthouse to your liking:

    snap get lighthouse
    snap get reth

Change the location of the --datadir and allow the snap to access some external filsystems/dirs (see: snap interface removable-media)

    sudo snap connect reth:removable-media
    sudo snap set reth service-args='node --full --datadir /mnt/reth/datadir'

Start reth.

    sudo snap start reth

Copy the jwt.hex from where you set the reth --datadir -> lighthouse

    sudo cp /mnt/reth/datadir/jwt.hex /var/snap/lighthouse/common/

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
