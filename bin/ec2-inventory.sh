#!/bin/bash
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#IS_DEBUG=1

. "$BASH_SCRIPTS_DIR/util.sh"

function ansible_list_inventory() {
  cd_to_ansible
  _send_ansible_dynamic_inventory_command "--list"
}

function ansible_host_info() {
  _send_ansible_dynamic_inventory_command "--host" "$1"
}

function ansible_refresh_cache() {
  _send_ansible_dynamic_inventory_command "--refresh-cache"
}

function _send_ansible_dynamic_inventory_command() {
  cd_to_ansible
  AWS_PROFILE=minecraft EC2_INI_PATH=./config/ec2.ini ./vendor/ec2.py "$@"
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
  echo_info "Ansible Dynamic Inventory wrapper:
    'host-info'
    'list'
    'refresh-cache'"
}

function cd_to_ansible() {
  go_to_path "$ROOT_DIR/ansible"
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
