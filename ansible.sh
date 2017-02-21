#!/bin/bash
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#IS_DEBUG=1

. "$BASH_SCRIPTS_DIR/util.sh"

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
  cd_to_ansible
  if [ "$IS_DEBUG" ]; then
    AWS_PROFILE=minecraft EC2_INI_PATH=./config/ec2.ini ansible -u ec2-user -vvv "$1" -i ./vendor/ec2.py "${@:2}"
   else
    AWS_PROFILE=minecraft EC2_INI_PATH=./config/ec2.ini ansible -u ec2-user "$1" -i ./vendor/ec2.py "${@:2}"
  fi
}

function _execute_ansible_playbook() {
  cd_to_ansible
  if [ "$IS_DEBUG" ]; then
    AWS_PROFILE=minecraft EC2_INI_PATH=./config/ec2.ini ansible-playbook "$1" -i ./vendor/ec2.py "${@:2}"
   else
    AWS_PROFILE=minecraft EC2_INI_PATH=./config/ec2.ini ansible-playbook "$1" -i ./vendor/ec2.py "${@:2}"
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

function cd_to_ansible() {
  go_to_path "$ROOT_DIR/ansible"
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
