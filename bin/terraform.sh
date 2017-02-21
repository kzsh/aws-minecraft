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

function _send_terraform_command() {
  cd_to_terraform
  terraform "$1" -var-file=./config/secrets.tfvars ./operations
}


function usage() {
  echo_info "Terraform wrapper:
    Terraform:
    'apply'
    'destroy'"
}

function cd_to_terraform() {
  go_to_path "$ROOT_DIR/terraform"
}

function perform_operation() {
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
    *)
      usage
    ;;
  esac
}

main() {
  perform_operation "$@"
}

main "$@"
