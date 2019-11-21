#!/bin/bash

if test -z "$AWS_PROFILE"; then
    echo "No AWS_PROFILE set"
    exit 1
fi

function print_region() {
    echo "$(tput setaf 3) $1 $(tput sgr 0)"
}

function print_delete_ingress() {
    echo "$(tput setaf 1) Deleting default ingress rule for SG: $1 $(tput sgr 0)"
}

for region in $(aws ec2 describe-regions --region eu-west-1 --query 'Regions[].RegionName' --output text); do
    echo -en "\n>> Region:"; print_region $region

    default_sg=$(aws ec2 describe-security-groups --region $region --query 'SecurityGroups[].GroupId' --filter 'Name=group-name, Values=default' --output text)
    for sg in $default_sg; do
        print_delete_ingress $sg
        ip_permissions=$(aws ec2 describe-security-groups --region $region --group-id $sg --query 'SecurityGroups[].IpPermissions[]')
        echo $ip_permissions
        if test "$ip_permissions" != '[]'; then
            aws ec2 revoke-security-group-ingress --region $region --group-id $sg --ip-permissions "$ip_permissions"
        fi
    done
done