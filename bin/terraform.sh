#!/bin/bash
#IS_DEBUG=1

. "$BASH_SCRIPTS_DIR/util.sh"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."
TERRAFORM_DIR="$ROOT_DIR/terraform"

function terraform_apply() {
  _send_terraform_command "apply"
}

function terraform_destroy() {
  _send_terraform_command "destroy"
}

function _send_terraform_command() {
  terraform "$1" -var-file="$TERRAFORM_DIR"/config/secrets.tfvars -state-out="$ROOT_DIR"/output/terraform/minecraft.tfstate "$TERRAFORM_DIR"/operations
}


function usage() {
  echo_info "Terraform wrapper:
    Terraform:
    'apply'
    'destroy'"
}

function perform_operation() {
  OPERATION="$1"

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
