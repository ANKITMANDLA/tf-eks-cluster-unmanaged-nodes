#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case ${key} in
    -d|--destroy)
      DESTROY="1"
      shift # past argument
    ;;
    -n| --name)
        CUSTOM_DOMAIN=${2}
        shift
    ;;
    -s| --sleep)
          DOMAIN_SLEEP=1
          shift
    ;;
    *)    # unknown option
      shift # past argument
    ;;
esac
done

if [[ -z ${CUSTOM_DOMAIN} ]]; then
    echo "Missing domain name"
    exit 1
fi


if [[ -d ".terraform" ]]; then
  rm -rf .terraform
fi

terraform init -backend-config="key=${CUSTOM_DOMAIN}" || exit 1

if [[ ! -z ${DOMAIN_SLEEP} ]]; then
  terraform apply -var "custom_domain=${CUSTOM_DOMAIN}" -var "active=false" 
  exit 0
fi

if [[ ! -z ${DESTROY} ]]; then
    terraform destroy -var "custom_domain=${CUSTOM_DOMAIN}"
    exit 0
fi

terraform apply -var "custom_domain=${CUSTOM_DOMAIN}"
