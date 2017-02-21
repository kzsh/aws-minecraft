#!/bin/bash
#IS_DEBUG=1

. "$BASH_SCRIPTS_DIR/util.sh"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."
ANSIBLE_DIR="$ROOT_DIR/ansible"

function ansible_ping() {
  _send_ansible_command "tag_Name_mcserver" "-m ping"
}

function ansible_run() {
  _send_ansible_command "tag_Name_mcserver" "$@"
}

function ansible_playbook() {
  _execute_ansible_playbook "$@"
}

function _send_ansible_command() {
  if [ "$IS_DEBUG" ]; then
    AWS_PROFILE=minecraft EC2_INI_PATH="$ANSIBLE_DIR"/config/ec2.ini ansible -u ec2-user -vvv "$1" -i "$ANSIBLE_DIR"/vendor/ec2.py "${@:2}"
   else
    AWS_PROFILE=minecraft EC2_INI_PATH="$ANSIBLE_DIR"/config/ec2.ini ansible -u ec2-user "$1" -i "$ANSIBLE_DIR"/vendor/ec2.py "${@:2}"
  fi
}

function _execute_ansible_playbook() {
  if [ "$IS_DEBUG" ]; then
    AWS_PROFILE=minecraft EC2_INI_PATH="$ANSIBLE_DIR"/config/ec2.ini ansible-playbook "$1" -i "$ANSIBLE_DIR"/vendor/ec2.py "${@:2}"
   else
    AWS_PROFILE=minecraft EC2_INI_PATH=."$ANSIBLE_DIR"/config/ec2.ini ansible-playbook "$1" -i "$ANSIBLE_DIR"/vendor/ec2.py "${@:2}"
  fi
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
