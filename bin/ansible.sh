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

function ansible_playbook() {
  _execute_ansible_playbook "$@"
}

function _send_ansible_command() {
  AWS_PROFILE=minecraft ansible -u ec2-user -i "$ANSIBLE_DIR"/vendor/ec2.py "$@"
}

function _execute_ansible_playbook() {
  AWS_PROFILE=minecraft EC2_INI_PATH="$ANSIBLE_DIR"/config/ec2.ini ansible-playbook -i "$ANSIBLE_DIR"/vendor/ec2.py "$@"
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
         ansible_ping
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
