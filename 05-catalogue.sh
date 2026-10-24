#!/bin/bash
user=$(id -u)

if [ $user -ne 0 ]; then
echo "Run with Sudo access"
exit 1
fi

logs_folder="/var/log/roboshop-v1"
logs_file="$logs_folder/$0.log"

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

echo "$(timestamp) [INFO]::Script Started Execution"

dnf module disable nodejs -y &>> $logs_file
dnf module enable nodejs:24 -y &>> $logs_file
dnf install nodejs -y &>> $logs_file
validate $? "Installing Nodejs"

id -u "roboshop" &>> $logs_file
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Adding roboshop system user"
else 
echo -e "$(timestamp) [INFO]::roboshop user already exists.. ${Y}SKIPPING${N}"
fi

mkdir -p /app
curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> $logs_file
validate $? "Installing Catalogue resource zip file"

cd /app
unzip /tmp/catalogue.zip
validate $? "Extracting Catalogue files to /app dir"


echo "$(timestamp) [INFO]::Script completed execution in $SECONDS seconds"
echo "$(timestamp) [INFO]::Script Completed Execution"