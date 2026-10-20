#!/bin/bash

user_id=$( id -u ) #get user id

# Declare log folder and file path

logs_folder="/var/log/roboshop-shellv1"
logs_file="${logs_folder}/${0}.log"

# sudo user condition

if [ $user_id -ne 0 ]; then
        echo "Try with sudo access"
        exit 1
    else
        echo "Script started"
fi

mkdir -p $logs_folder

# colors

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


# validate function

validate(){
    if [ $1 -ne 0 ]; then 
         echo -e "${R}Error${N} in $2"
         exit 1
    else 
        echo -e "${G}SUCCESS${N}: $2"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo repo"

dnf install mongodb-org -y &>> $logs_file
validate $? "Installing Mongodb server"

systemctl enable mongodb &>> $logs_file
systemctl start mongodb &>> $logs_file
validate $? "Enable and start mongodb"

sed -i 's/127.0.0.1/0.0.0.0' /etc/mongod.conf

systemctl restart mongodb
validate $? "Restarting Mongodb"