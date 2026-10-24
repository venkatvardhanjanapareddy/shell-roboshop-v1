#!/bin/bash

user=$(id -u)

logs_folder="/var/log/roboshop-v1"
logs_file="$logs_folder/$0.log"


R="\e[31m"
G="\e[32m"
B="\e[33m"
N="\e[0m"

if [ $user -ne 0 ]; then 
    echo -e "${R}ERROR::${N} Try with sudo access"
    exit 1
else 
    echo "$(timestamp)::Script Started Execution"
fi

mkdir -p $logs_folder

timestamp(){
    date "+%F %T"
}

validate(){
    if [ $1 -ne 0 ]; then 
    echo -e "${R}ERROR::${N} $2" | tee -a $logs_file
    else
    echo -e "${G}SUCCESS::${N} $2" | tee -a $logs_file
    fi
}

dnf module enable mysql:8.4 -y &>> $logs_file
dnf install mysql-server -y &>> $logs_file
validate $? "Installing Mysql Server"

systemctl enable mysqld &>> $logs_file
systemctl start mysqld &>> $logs_file
validate $? "Enable and Start mysqld"

echo "$(timestamp)::Script Completed Execution"