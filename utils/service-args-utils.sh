#!/bin/sh

. "$SNAP/utils/utils.sh"

SERVICE_ARGS_FILE="$SNAP_COMMON/service-arguments"

# reth db storage location for the snap
DATADIR_PATH="$SNAP_COMMON/datadir"

write_service_args_file()
{
    service_args="$(get_service_args)"
    log "Writing \"$service_args\" to $SERVICE_ARGS_FILE"
    echo "$service_args" > "$SERVICE_ARGS_FILE"
}

set_service_args()
{
    snapctl set service-args="$1"
    set_previous_service_args "$1"
}

get_service_args()
{
    # Start with default: fullnode on the mainnet
    DEFAULT_ARGS='node --full --chain mainnet'

    service_args="$(snapctl get service-args)"
    if [ -z "$service_args" ]; then
        log "Setting default service args"
        service_args="$DEFAULT_ARGS"
        snapctl set service-args="$service_args"
    fi
    echo "$service_args"
}

set_previous_service_args()
{
    snapctl set private.service-args="$1"
}

get_previous_service_args()
{
    snapctl get private.service-args
}

service_args_has_changed()
{
	[ "$(get_service_args)" != "$(get_previous_service_args)" ]
}

#
# Description: Checks that the service-args handles --datadir <path>.
#              It only allows those paths accepted by removable-media interface
#              or the default snap directory $SNAP_COMMON/datadir
#
# Argument(s): A single string containing the service-args argument.
validate_service_args()
{
    log "Validating service-args argument: $@"
    
    # These paths are allowed.
    allowed_removable_media_paths="/mnt /media /run/media $SNAP_COMMON/datadir"

    is_allowed_path() {
        local path="$1"
        for allowed_path in $allowed_removable_media_paths; do
            # Check if path is directly within or under the allowed path
            case "$path" in
                "$allowed_path"/* | "$allowed_path")
                    log "--datadir $path is allowed."
                    return 0
                    ;;
            esac
        done
        log "--datadir $path is NOT allowed. Use any of these: $allowed_removable_media_paths (Hint: sudo snap connect reth:removable-media)"
        # Echo also messages the user.
        echo "--datadir $path is NOT allowed. Use any of these: $allowed_removable_media_paths (Hint: sudo snap connect reth:removable-media)"
        return 1
    }
    
    # Split the function argument up into separate components which sets $# to the number of tokens.
    set -- $@

    # Iterate over the arguments to find --datadir and its value
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --datadir)
                shift
                if [ -z "$1" ]; then
                    log "No path specified for --datadir. No change was made to service-args."
                    set_service_args "$(get_previous_service_args)"
                    exit 1
                fi
                if ! is_allowed_path "$1"; then
                    set_service_args "$(get_previous_service_args)"
                    log  "--datadir $1 is not allowed. Only snap default or those allowed by removable-media is allowed. No change was made to servie-args."
                    exit 1
                fi
                ;;
        esac
        shift
    done
}
