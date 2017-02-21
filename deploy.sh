#!/bin/bash
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#IS_DEBUG=1

. "$BASH_SCRIPTS_DIR/util.sh"

function terraform_apply() {
  _send_terraform_command "apply"
}

function terraform_destroy() {
  cd_to_terraform
  _send_terraform_command "destroy"
}

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

function ansible_ping() {
  _send_ansible_command "tag_Name_mcserver" "-m ping"
}

function ansible_run() {
  _send_ansible_command "tag_Name_mcserver" "$@"
}

function ansible_playbook() {
  _execute_ansible_playbook "$@"
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

function _send_terraform_command() {
  cd_to_terraform
  terraform "$1" -var-file=./config/secrets.tfvars ./operations
}


function usage() {
  echo_info "Deploy tool
    Terraform:
    'apply'
    'destroy'
    Ansible Dynamic Inventory:
    'list-inventory'
    'host-info'
    'refresh-cache'
    Ansible
    'run'
    'playbook'
    'ping-all'"
}

function cd_to_terraform() {
  goToPath "$ROOT_DIR/terraform"
}

function cd_to_ansible() {
  goToPath "$ROOT_DIR/ansible"
}

main() {
  OPERATION="$1"
  HOST="$2"

  case "$OPERATION" in
    'apply')
      begin_section "Deploying infrastructure changes to EC2"
        terraform_apply
      end_section
    ;;
    'destroy')
      begin_section "Destroying all project-related infrastructure on EC2"
        terraform_destroy
      end_section
    ;;
    'list-inventory')
      begin_section "Provisioning EC2 instances"
        ansible_list_inventory
      end_section
    ;;
    'host-info')
      begin_section "Gathering host info"
         ansible_host_info "$HOST"
      end_section
    ;;
    'ping-all')
      begin_section "Gathering host info"
         ansible_ping
      end_section
    ;;
    'run')
      begin_section "Running command"
          echo "$@"
         ansible_run "${@:2}"
      end_section
    ;;
    'playbook')
      begin_section "Executing playbook"
         ansible_playbook "${@:2}"
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

main "$@"
