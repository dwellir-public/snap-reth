#!/bin/sh

# Logs to journalctl. Watch with e.g. journalctl -t SNAP_NAME -f
log()
{
    logger -t ${SNAP_NAME} -- "$1"
}

restart_reth()
{
    reth_status="$(snapctl services reth)"
    current_status=$(echo "$reth_status" | awk 'NR==2 {print $3}')
    if [ "$current_status" = "active" ]; then
        snapctl restart reth
    fi
}
