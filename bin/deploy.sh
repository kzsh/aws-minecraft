#!/bin/bash

. "$BASH_SCRIPTS_DIR/util.sh"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."
BIN_DIR="$ROOT_DIR/bin"
ANSIBLE_DIR="$ROOT_DIR/ansible"

function usage() {
  echo_info "Deploy tool
    'create': create the necessary EC2 infrastructure
    'destroy': destroy EC2 infrastructure
    'provision': Download and set up minecraft.  Uploads a local world if one exists.
    'recover-world': Archive and download the world on the server to the local artifacts dir.
  "
}

function create() {
  "$BIN_DIR"/terraform.sh apply "$@"
}

function destroy() {
  recover_world && "$BIN_DIR"/terraform.sh destroy "$@"
}

function recover_world() {
  "$BIN_DIR"/ansible.sh playbook "$ANSIBLE_DIR"/playbooks/mcserver/recover_world.yml "$@"
}

function provision() {
  "$BIN_DIR"/ansible.sh playbook "$ANSIBLE_DIR"/playbooks/mcserver/server.yml "$@"
}

function select_operation() {
  OPERATION="$1"

  case "$OPERATION" in
    'create')
      create "${@:2}"
    ;;
    'destroy')
      destroy "${@:2}"
    ;;
    'provision')
      provision "${@:2}"
    ;;
    'recover-world')
      recover_world "${@:2}"
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
