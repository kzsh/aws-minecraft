#!/bin/bash

. "$BASH_SCRIPTS_DIR/util.sh"

function usage() {
  echo_info "Deploy tool
  "
}

function create() {
  ./terraform.sh apply && \
  provision
}

function destroy() {
  ./ansible.sh playbook ./playbooks/mcserver/recover_world.yml && \
  ./terraform.sh destroy
}

function provision() {
  ./ansible.sh playbook ./playbooks/mcserver/server.yml
}

function select_operation() {
  OPERATION="$1"
  HOST="$2"

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
    *)
      usage
    ;;
  esac
}

main() {
  select_operation "$@"
}

main "$@"
