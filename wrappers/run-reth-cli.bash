#!/bin/bash
set -eu

SERVICE_ARGS_FILE="$SNAP_COMMON/service-arguments"
DATADIR_PATH="$SNAP_COMMON/datadir"
BINARY_PATH="${SNAP}/bin/reth"

. "$SNAP/utils/service-args-utils.sh"

if cli_args_have_datadir "$@"; then
    exec "$BINARY_PATH" "$@"
fi

if ! command_accepts_datadir "$@"; then
    exec "$BINARY_PATH" "$@"
fi

RESOLVED_DATADIR="$(resolve_cli_datadir)"

if [ ! -d "$RESOLVED_DATADIR" ]; then
    echo "Resolved datadir does not exist: $RESOLVED_DATADIR" >&2
    echo "Start the reth daemon once, or configure 'snap set reth service-args=\"... --datadir <path>\"' and create that directory first." >&2
    exit 1
fi

args=("$@")
new_args=()
command_inserted=false

for ((i = 0; i < ${#args[@]}; i++)); do
    arg="${args[$i]}"

    if ! $command_inserted; then
        case "$arg" in
            --)
                new_args+=("$arg")
                ;;
            -*)
                new_args+=("$arg")
                ;;
            *)
                new_args+=("$arg" "--datadir" "$RESOLVED_DATADIR")
                command_inserted=true
                ;;
        esac
    else
        new_args+=("$arg")
    fi
done

exec "$BINARY_PATH" "${new_args[@]}"
