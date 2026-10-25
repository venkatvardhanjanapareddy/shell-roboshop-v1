#!/bin/bash

user=(id -u)
# check user
if [ $user -ne 0 ];then
echo "Run with Sudo access"
exit 1;
fi


# log dir, file
logs_folder="/var/log/roboshop-v1"
logs_file="$logs_folder/${0}.log"

mkdir -p $logs_folder

domain_name="vardhandaws.online"

scripts_directory="$(dirname $(realpath "$0"))"

# colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


# timestamp
timestamp(){
    date "+%F %T"
}

# validate
validate(){
    if [ $1 -ne 0 ]; then
    echo -e "$(timestamp) [ERROR]::${R}ERROR${N}:: $2" | tee -a $logs_file
    exit 1
    else
    echo -e "$(timestamp) [INFO]::${G}SUCCESS${N}:: $2" | tee -a $logs_file
    fi
}

echo "$(timestamp) [INFO]::Script Started Execution" | tee -a $logs_file

dnf module disable nginx -y &>> $logs_file
dnf module enable nginx:1.26 -y &>> $logs_file
dnf install nginx -y &>> $logs_file
validate $? "Install Nginx"
 
systemctl enable nginx &>> $logs_file
systemctl start nginx &>> $logs_file
validate $? "Enable and Start Nginx"

rm -rf /usr/share/nginx/html/*
validate $? "Removing html files from /usr/share/nginx/html/"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $logs_file
validate $? "Downloading frontend zip" 

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $logs_file
validate $? "Unzipping files in /usr/share/nginx/html"

sed -i "s/MYDOMAIN/$domain_name/g" $scripts_directory/roboshop.conf
cp $scripts_directory/roboshop.conf /etc/nginx/default.d/roboshop.conf
validate $? "Copying oroboshop.conf"

nginx -t &>> $logs_file
validate $? "Checking conf syntax for nginx"

systemctl restart nginx &>> $logs_file
validate $? "Restart Nginx"

echo "$(timestamp) [INFO]::Script completed execution in $SECONDS seconds"
echo "$(timestamp) [INFO]::Script Completed Execution" | tee -a $logs_file