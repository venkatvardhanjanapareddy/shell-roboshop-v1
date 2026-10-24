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

echo "$(timestamp) [INFO]::Script Started Execution"

dnf module disable nodejs -y &>> $logs_file
dnf module enable nodejs:24 -y &>> $logs_file
dnf module start nodejs -y &>> $logs_file
validate $? "Installing nodejs:24"

id roboshop
if [ $? -ne 0 ]; then 
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
echo "System user roboshop already exists.. ${Y}SKIPPING${N}"
fi

rm -rf /app &>> $logs_file
validate $? "Removing old code"

mkdir /app
validate $? "Creating /app directory"

curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip &>> $logs_file
validate $? "Downloading user zip file"

cd /app
unzip /tmp/user.zip &>> $logs_file
validate $? "Unzipping files to app directory"

npm install &>> $logs_file
validate $? "Installing node packages"

sed -i "s/MYDOMAIN/$domain_name/" user.service &>> $logs_file

cp "$scripts_folder/user.service" /etc/systemd/system/user.service
validate $? "Setting user.service file"

systemctl daemon-reload
systemctl enable user &>> $logs_file
systemctl start user
validate $? "Enable and Start User"

echo "$(timestamp) [INFO]::Script completed execution in $SECONDS seconds"
echo "$(timestamp) [INFO]::Script Completed Execution" | tee -a $logs_file