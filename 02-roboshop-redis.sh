#!/bin/bash
user_id=$(id -u)

# Declare log folder and file path

logs_folder="/var/log/roboshop-v1"
logs_file="${logs_folder}/${0}.log"

# sudo user condition

if [ $user_id -ne 0 ]; then
        echo "Try with sudo access"
        exit 1
    else
        echo "Script started"
fi

timestamp(){
    date "+%F %T"
}

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

echo "${timestamp} [INFO] =====Script Started Execution===== " | tee -a $logs_file

dnf module disable redis -y &>> $logs_file
dnf module enable redis:7 -y &>> $logs_file
validate $? "Enabling redis:7"

dnf install redis -y &>> $logs_file
validate $? "Installing redis" 

sed -i -e 's/127.0.0.1/0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "Allowing remote connection to redis"

systemctl enable redis &>> $logs_file
systemctl start redis
validate $? "Enable and start redis"

echo "${timestamp} [INFO] =====Script Completed Execution===== " | tee -a $logs_file