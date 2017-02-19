#!/bin/bash

function apply() {
  terraform apply -var-file=secrets.tfvars
}

function destroy() {
  terraform destroy -var-file=secrets.tfvars
}

main() {
  operation="$1"

  if [[ "$operation" == 'destroy' ]]; then
    destroy
  else
    apply
  fi
}

main "$@"
