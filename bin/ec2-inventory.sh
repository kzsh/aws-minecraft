#!/bin/bash
#IS_DEBUG=1

. "$BASH_SCRIPTS_DIR/util.sh"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."
ANSIBLE_DIR="$ROOT_DIR/ansible"

function ansible_list_inventory() {
  _send_ansible_dynamic_inventory_command "--list"
}

function ansible_host_info() {
  _send_ansible_dynamic_inventory_command "--host" "$1"
}

function ansible_refresh_cache() {
  _send_ansible_dynamic_inventory_command "--refresh-cache"
}

function _send_ansible_dynamic_inventory_command() {
  AWS_PROFILE=minecraft EC2_INI_PATH="$ANSIBLE_DIR"/config/ec2.ini "$ANSIBLE_DIR"/vendor/ec2.py "$@"
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
    AWS_PROFILE=minecraft EC2_INI_PATH="$ANSIBLE_DIR"/config/ec2.ini ansible-playbook "$1" -i "$ANSIBLE_DIR"/vendor/ec2.py "${@:2}"
  fi
}

function usage() {
  echo_info "Ansible Dynamic Inventory wrapper:
    'host-info'
    'list'
    'refresh-cache'"
}

function perform_operation() {
  OPERATION="$1"
  HOST="$2"

  case "$OPERATION" in
    'host-info')
      begin_section "Gathering host info"
      ansible_host_info "$HOST" end_section
    ;;
    'list-inventory')
      begin_section "Provisioning EC2 instances"
        ansible_list_inventory
      end_section
    ;;
    'refresh-cache')
      begin_section "Refresh cached EC2 info"
        ansible_refresh_cache
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
