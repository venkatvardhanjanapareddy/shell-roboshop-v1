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
dnf install nodejs -y &>> $logs_file
validate $? "Installing Nodejs"

id -u "roboshop" &>> $logs_file
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Adding roboshop system user"
else 
echo -e "$(timestamp) [INFO]::roboshop user already exists.. ${Y}SKIPPING${N}"
fi

rm -rf /app
validate $? "Deleting /app if exists"

mkdir -p /app
curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> $logs_file
validate $? "Installing Catalogue resource zip file"

cd /app
unzip /tmp/catalogue.zip &>> $logs_file
validate $? "Extracting Catalogue files to /app dir"

npm install &>> $logs_file
validate $? "Installing dependencies"

sed -i "s/MYDOMAIN/$domain_name/" $scripts_folder/catalogue.service # replacing with domain name
cp $scripts_folder/catalogue.service /etc/systemd/system/catalogue.service
validate $? "Setting catalogue.service file"

systemctl daemon-reload
systemctl enable catalogue &>> $logs_file
systemctl start catalogue
validate $? "Enable and Start Catalogue"

cp $scripts_folder/mongo.repo /etc/yum.repos.d/mongo.repo &>> $logs_file
validate $? "Copying mongo.repo file"

dnf install mongodb-mongosh -y &>> $logs_file
validate $? "Installing mongodb client"

product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()')
validate $? "Checking product count $product_count"

# mongosh --host "mongodb.$domain_name" </app/db/master-data.js
# validate $? "Loading master data"

echo "$(timestamp) [INFO]::Script completed execution in $SECONDS seconds"
echo "$(timestamp) [INFO]::Script Completed Execution"