#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."
ANSIBLE_DIR="$ROOT_DIR/ansible"
SCRIPTS_DIR="$ROOT_DIR/scripts"
CONFIG_FILE="$ROOT_DIR/config.yml"

. "$SCRIPTS_DIR/util.sh"

function ansible_ping() {
  _send_ansible_command "tag_Name_mcserver" "-m ping" "$@"
}

function ansible_run() {
  _send_ansible_command "tag_Name_mcserver" "$@"
}

function _send_ansible_command() {
  AWS_PROFILE=$(config_value "aws_profile") AWS_REGION=$(config_value "aws_region") ansible -u ec2-user --extra-vars="$(inject_config)"  -i "$ANSIBLE_DIR"/vendor/ec2.py "$@"
}

function ansible_playbook() {
  AWS_PROFILE=$(config_value "aws_profile") AWS_REGION=$(config_value "aws_region") EC2_INI_PATH="$ANSIBLE_DIR"/config/ec2.ini ansible-playbook --extra-vars="ssh_key_path=$(config_value "ssh_key_path")" -i "$ANSIBLE_DIR"/vendor/ec2.py "$@"
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

config_value() {
  local key="$1"
  #echo "$(get_config_value "$key" "$CONFIG_FILE")"
  get_config_value "$key" "$CONFIG_FILE"
}

main() {
  perform_operation "$@"
}

main "$@"
