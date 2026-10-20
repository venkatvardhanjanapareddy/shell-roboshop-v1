#!/bin/bash

validate(){
    if [ $1 -ne 0 ]; then
    echo "error creating $2"
    exit 1
    else 
    echo "Successfully created $2 instance"
    fi
}

instance=$(
aws ec2 run-instances \
    --image-id ami-0055977a6e828a4f4 \
    --instance-type t3.micro \
    --security-groups "roboshop-common" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roboshop-common}]' \
    --query "Instances[0].InstanceId" \
    --output text
)

validate "$?" "roboshop-common"

echo "The roboshop-common instance is created"