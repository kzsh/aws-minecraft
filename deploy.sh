#!/bin/bash
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$BASH_SCRIPTS_DIR/util.sh"

function terraform_apply() {
  cd_to_terraform
  terraform apply -var-file=./config/secrets.tfvars ./operations
}

function terraform_destroy() {
  cd_to_terraform
  terraform destroy -var-file=./config/secrets.tfvars ./operations
}

function ansible_provision() {
  cd_to_ansible
  AWS_PROFILE=minecraft EC2_INI_PATH=./config/ec2.ini ./vendor/ec2.py --list
}

function ansible_host_info() {
  cd_to_ansible
  AWS_PROFILE=minecraft EC2_INI_PATH=./config/ec2.ini ./vendor/ec2.py --host "$1"
}

function usage() {
  echo "Write usage here"
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
    *)
      usage
    ;;
  esac
}

main "$@"
