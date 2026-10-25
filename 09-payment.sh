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

dnf install python3.14 python3.14-pip -y
validate $? "Installing python3.14"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Creating roboshop system user"
else 
echo -e "$(timestamp) [INFO]::System user exists.. ${Y}SKIPPING${N}"
fi

rm -rf /app
validate $? "Removing old code"

mkdir /app
validate $? "Creating /app dir"

curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip
validate $? "Donwloading payment zip in /tmp dir"

cd /app
unzip /tmp/payment.zip
validate $? "Unzipping files in /app dir"

python3.14 -m venv /app/.venv
validate $? "Installing depedencies, libraries"

/app/.venv/bin/pip install -r requirements.txt
validate $? "Installing requirements.txt"

sed -i "s/MYDOMAIN/$domain_name/g" $scripts_folder/payment.service
cp $scripts_folder/payment.service /etc/systemd/system/payment.service
validate $? "Copying the payment.service file"

systemctl daemon-reload
systemctl enable payment
systemctl start payment
validate $? "Enable and Restart Payment"


echo "$(timestamp) [INFO]::Script completed execution in $SECONDS seconds"
echo "$(timestamp) [INFO]::Script Completed Execution" | tee -a $logs_file