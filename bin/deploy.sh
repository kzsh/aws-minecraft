#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#IS_DEBUG=1

ROOT_DIR="$SCRIPT_DIR/.."

. "$BASH_SCRIPTS_DIR/util.sh"

function usage() {
  echo_info "Deploy tool
  "
}

function perform_operation() {
  OPERATION="$1"
  HOST="$2"

  case "$OPERATION" in
    *)
      usage
    ;;
  esac
}

main() {
  perform_operation "$@"
}

main "$@"
