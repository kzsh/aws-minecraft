#!/bin/bash

. "$BASH_SCRIPTS_DIR/util.sh"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."
BIN_DIR="$ROOT_DIR/bin"
ANSIBLE_DIR="$ROOT_DIR/ansible"

function usage() {
  echo_info "Deploy tool
  "
}

function create() {
  "$BIN_DIR"/terraform.sh apply && \
  provision
}

function destroy() {
  recover_world && \
  "$BIN_DIR"/terraform.sh destroy
}

function recover_world() {
  "$BIN_DIR"/ansible.sh playbook "$ANSIBLE_DIR"/playbooks/mcserver/recover_world.yml
}

function provision() {
  "$BIN_DIR"/ansible.sh playbook "$ANSIBLE_DIR"/playbooks/mcserver/server.yml
}

function select_operation() {
  OPERATION="$1"

  case "$OPERATION" in
    'create')
      create
    ;;
    'destroy')
      destroy
    ;;
    'provision')
      provision
    ;;
    'recover-world')
      recover_world
    ;;
    *)
      usage
    ;;
  esac
}

main() {
  select_operation "$@"
}

main "$@"
