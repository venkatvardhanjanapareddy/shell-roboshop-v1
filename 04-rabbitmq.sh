#!/bin/bash

user=$(id -u)

logs_folder="/var/log/roboshop-v1"
logs_file="$logs_folder/$0.log"


R="\e[31m"
G="\e[32m"
B="\e[33m"
N="\e[0m"

timestamp(){
    date "+%F %T"
}


if [ $user -ne 0 ]; then 
    echo -e "${R}ERROR::${N} Try with sudo access"
    exit 1
fi

mkdir -p $logs_folder

validate(){
    if [ $1 -ne 0 ]; then 
    echo -e "$(timestamp) [ERROR]:: ${R}ERROR${N}:: $2" | tee -a $logs_file
    else
    echo -e "$(timestamp) [INFO]:: ${G}SUCCESS${N}:: $2" | tee -a $logs_file
    fi
}

echo "$(timestamp) [INFO]::Script Started Execution"

cp 04-rabbitmq.sh /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding rabbitMQ repo"


echo "$(timestamp) [INFO]::Script Completed Execution"