#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="vardhandaws.online"
hosted_zone_id="Z07166913431ZYKE9ODG1"


for instance in $@
do

    instance_id=$(aws ec2 run-instances \
        --image-id $ami_id \
        --instance-type $instance_type \
        --security-groups "roboshop-common" "roboshop-${instance}" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-${instance}}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )

    if [ $instance != "frontend" ]; then
         IP=$(aws ec2 describe-instances \
            --instance-ids "i-1234567890abcdef0" \
            --query "Reservations[*].Instances[*].PrivateIpAddress" \
            --output text
        )
        route="$instance.$domain_name"
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "i-1234567890abcdef0" \
            --query "Reservations[*].Instances[*].PublicIpAddress" \
            --output text
        )
        route="$domain_name"
    fi


    aws route53 change-resource-record-sets \
        --hosted-zone-id "$hosted_zone_id" \
        --change-batch'{
      "Comment": "Creating or updating an A record",
      "Changes": [
        {
          "Action": "UPSERT",
          "ResourceRecordSet": {
            "Name": "'"$route"'",
            "Type": "A",
            "TTL": 1,
            "ResourceRecords": [
              {
                "Value": "'"$IP"'"
              }
            ]
          }
        }
      ]
    }'


done