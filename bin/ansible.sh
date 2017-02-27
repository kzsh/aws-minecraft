#!/bin/bash

. "$BASH_SCRIPTS_DIR/util.sh"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."
ANSIBLE_DIR="$ROOT_DIR/ansible"

function ansible_ping() {
  _send_ansible_command "tag_Name_mcserver" "-m ping" "$@"
}

function ansible_run() {
  _send_ansible_command "tag_Name_mcserver" "$@"
}

function _send_ansible_command() {
  AWS_PROFILE=minecraft ansible -u ec2-user --extra-vars="$(inject_config)"  -i "$ANSIBLE_DIR"/vendor/ec2.py "$@"
}

function ansible_playbook() {
  AWS_PROFILE=minecraft EC2_INI_PATH="$ANSIBLE_DIR"/config/ec2.ini ansible-playbook --extra-vars="$(inject_config)" -i "$ANSIBLE_DIR"/vendor/ec2.py "$@"
}

function inject_config() {
  echo "$(cat "$ROOT_DIR/config.yml" | tr "\n" " ")"
}

function usage() {
  echo_info "Ansible deploy wrapper:
    Ansible
    'ping-all'
    'playbook'
    'run'
    "
}


function perform_operation() {
  OPERATION="$1"

  case "$OPERATION" in
    'ping-all')
      begin_section "Gathering host info"
        ansible_ping "${@:2}"
      end_section
    ;;
    'playbook')
      begin_section "Executing playbook"
        ansible_playbook "${@:2}"
      end_section
    ;;
    'run')
      begin_section "Running command"
        ansible_run "${@:2}"
      end_section
    ;;
    *)
      usage
    ;;
  esac
}

main() {
  perform_operation "$@"
}

main "$@"
