#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="vardhandaws.online"
hosted_zone_id="Z07166913431ZYKE9ODG1"


for instance in $@
do

    echo "creating instance: $instance"

    instance_id=$(aws ec2 run-instances \
            --image-id $ami_id \
            --instance-type $instance_type \
            --security-groups "roboshop-common" "roboshop-$instance" \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
            --query "Instances[0].InstanceId" \
            --output text
    )

    echo " $? $instance created InstanceId: $instance_id"


    #  to get the public ip for frontend and private for remaining instances

    if [ $instance -ne "frontend"]; then
        INSTANCE_IP=$(aws ec2 describe-instances \
            --instance-ids $instance_id \
            --query "Reservations[*].Instances[*].PublicIpAddress" \
            --output text)
    echo "Instance ip for frontend $INSTANCE_IP"
    route53=$domain_name
    else
        INSTANCE_IP=$(aws ec2 describe-instances \
            --instance-ids $instance_id \
            --query "Reservations[*].Instances[*].PrivateIpAddress" \
            --output text)
    echo "Instance ip NOT for frontend $INSTANCE_IP"
        route53=${instance}.$domain_name

    fi


    # 
    aws route53 change-resource-record-sets \
      --hosted-zone-id $hosted_zone_id \
      --change-batch '{
        "Comment": "Creating record for EC2 instance",
        "Changes": [
          {
            "Action": "UPSERT",
            "ResourceRecordSet": {
              "Name": "'"$route53"'",
              "Type": "A",
              "TTL": 1,
              "ResourceRecords": [
                {
                  "Value": "'"$INSTANCE_IP"'"
                }
              ]
            }
          }
        ]
      }'

echo " $? Updated the route53 for $instance"

done

