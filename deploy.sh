#!/bin/bash
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$BASH_SCRIPTS_DIR/util.sh"

function terraform_apply() {
  _send_terraform_command "apply"
}

function terraform_destroy() {
  cd_to_terraform
  _send_terraform_command "destroy"
}

function ansible_provision() {
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
  _send_ansible_command "tag_Name_mcserver" "ping"
}

function _send_ansible_dynamic_inventory_command() {
  cd_to_ansible
  AWS_PROFILE=minecraft EC2_INI_PATH=./config/ec2.ini ./vendor/ec2.py "$@"
}

function _send_ansible_command() {
  cd_to_ansible
  AWS_PROFILE=minecraft EC2_INI_PATH=./config/ec2.ini ansible "$1" -i ./vendor/ec2.py -m "$2"
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
    'provision'
    'host-info'
    'refresh-cache'
    Ansible
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
    'provision')
      begin_section "Provisioning EC2 instances"
        ansible_provision
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
