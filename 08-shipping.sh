#!/bin/bash

user=$(id -u)

if [ $user -ne 0 ]; then
echo "Run with Sudo access"
exit 1
fi

logs_folder="/var/log/roboshop-v1"
logs_file="$logs_folder/$0.log"

domain_name="vardhandaws.online"
scripts_folder=$(dirname "$(realpath "$0")")

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $logs_folder

timestamp(){
date "+%F %T"
}

validate(){
    if [ $1 -ne 0 ]; then 
    echo -e "$(timestamp) [ERROR]::${R}ERROR${N}::$2" | tee -a $logs_file
    else
    echo -e "$(timestamp) [INFO]::${G}SUCCESS${N}::$2" | tee -a $logs_file
    fi
}

echo "$(timestamp) [INFO]::Script Started Execution" | tee -a $logs_file

dnf module enable maven:3.9 -y &>> $logs_file
dnf install maven java-25-openjdk-devel -y &>> $logs_file
validate $? "Installing maven and java:25"

# alternatives --set java 


echo "$(timestamp) [INFO]::Script completed execution in $SECONDS seconds"
echo "$(timestamp) [INFO]::Script Completed Execution" | tee -a $logs_file