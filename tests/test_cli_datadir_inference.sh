#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WRAPPER_PATH="$ROOT_DIR/wrappers/run-reth-cli.bash"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    if [ "$expected" != "$actual" ]; then
        fail "$message
expected: $expected
actual:   $actual"
    fi
}

assert_contains() {
    local actual="$1"
    local needle="$2"
    local message="$3"
    case "$actual" in
        *"$needle"*) ;;
        *)
            fail "$message
expected to contain: $needle
actual:             $actual"
            ;;
    esac
}

make_fake_snap_env() {
    local tmpdir
    tmpdir="$(mktemp -d)"
    mkdir -p "$tmpdir/snap/bin" "$tmpdir/snap/utils" "$tmpdir/common"
    cat >"$tmpdir/snap/bin/reth" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" > "$TEST_ARGS_FILE"
EOF
    chmod +x "$tmpdir/snap/bin/reth"
    cp "$ROOT_DIR/utils/service-args-utils.sh" "$tmpdir/snap/utils/service-args-utils.sh"
    cp "$ROOT_DIR/utils/utils.sh" "$tmpdir/snap/utils/utils.sh"
    echo "$tmpdir"
}

prepare_inferred_datadir() {
    local service_args="$1"
    local tmpdir="$2"

    if [[ "$service_args" =~ --datadir[[:space:]]+([^[:space:]]+) ]]; then
        mkdir -p "${BASH_REMATCH[1]}"
        return 0
    fi

    if [[ "$service_args" =~ --datadir=([^[:space:]]+) ]]; then
        mkdir -p "${BASH_REMATCH[1]}"
        return 0
    fi

    mkdir -p "$tmpdir/common/datadir"
}

run_case_expect_failure() {
    local service_args="$1"
    shift
    local tmpdir
    tmpdir="$(make_fake_snap_env)"
    trap 'rm -rf "$tmpdir"' RETURN

    if [ -n "$service_args" ]; then
        printf '%s\n' "$service_args" > "$tmpdir/common/service-arguments"
    fi

    set +e
    output="$(
        SNAP="$tmpdir/snap" \
        SNAP_COMMON="$tmpdir/common" \
        "$WRAPPER_PATH" "$@" 2>&1
    )"
    status=$?
    set -e

    printf '%s\n' "$status"
    printf '%s\n' "$output"
}

run_case() {
    local service_args="$1"
    shift
    local tmpdir
    tmpdir="$(make_fake_snap_env)"
    trap 'rm -rf "$tmpdir"' RETURN

    if [ -n "$service_args" ]; then
        printf '%s\n' "$service_args" > "$tmpdir/common/service-arguments"
    fi
    prepare_inferred_datadir "$service_args" "$tmpdir"

    TEST_ARGS_FILE="$tmpdir/args.txt" \
    SNAP="$tmpdir/snap" \
    SNAP_COMMON="$tmpdir/common" \
    "$WRAPPER_PATH" "$@"

    mapfile -t actual_args < "$tmpdir/args.txt"
    printf '%s\n' "${actual_args[@]}"
}

test_infers_datadir_from_service_args() {
    mapfile -t actual < <(run_case 'node --full --datadir /tmp/reth-test-datadir --chain mainnet' db stats)
    assert_equals "db" "${actual[0]}" "wrapper should preserve command"
    assert_equals "--datadir" "${actual[1]}" "wrapper should inject --datadir after command"
    assert_equals "/tmp/reth-test-datadir" "${actual[2]}" "wrapper should inject datadir from service args"
    assert_equals "stats" "${actual[3]}" "wrapper should preserve subcommand"
}

test_explicit_cli_datadir_wins() {
    mapfile -t actual < <(run_case 'node --full --datadir /tmp/reth-test-datadir --chain mainnet' db --datadir /tmp/reth-override-path stats)
    assert_equals "db" "${actual[0]}" "explicit CLI args should be passed through untouched"
    assert_equals "--datadir" "${actual[1]}" "explicit datadir flag should be preserved"
    assert_equals "/tmp/reth-override-path" "${actual[2]}" "explicit CLI datadir should win"
    assert_equals "stats" "${actual[3]}" "explicit CLI args should preserve subcommand"
}

test_falls_back_to_snap_common_datadir() {
    mapfile -t actual < <(run_case 'node --full --chain mainnet' db stats)
    assert_equals "db" "${actual[0]}" "wrapper should preserve fallback command"
    assert_equals "--datadir" "${actual[1]}" "wrapper should inject fallback --datadir flag"
    assert_contains "${actual[2]}" "/common/datadir" "wrapper should fall back to SNAP_COMMON datadir"
    assert_equals "stats" "${actual[3]}" "wrapper should preserve fallback subcommand"
}

test_non_datadir_command_passthrough() {
    mapfile -t actual < <(run_case 'node --full --datadir /tmp/reth-test-datadir --chain mainnet' config --default)
    assert_equals "config" "${actual[0]}" "non-datadir command should pass through"
    assert_equals "--default" "${actual[1]}" "non-datadir command args should pass through"
}

test_missing_inferred_datadir_surfaces_snap_message() {
    mapfile -t actual < <(run_case_expect_failure 'node --full --chain mainnet' db stats)
    assert_equals "1" "${actual[0]}" "missing inferred datadir should fail early"
    combined_output="${actual[*]}"
    assert_contains "$combined_output" "Resolved datadir" "preflight should mention resolved datadir"
    assert_contains "$combined_output" "Start the reth daemon once" "preflight should explain how to initialize the datadir"
}

main() {
    test_infers_datadir_from_service_args
    test_explicit_cli_datadir_wins
    test_falls_back_to_snap_common_datadir
    test_non_datadir_command_passthrough
    test_missing_inferred_datadir_surfaces_snap_message
    echo "PASS: cli datadir inference"
}

main "$@"
