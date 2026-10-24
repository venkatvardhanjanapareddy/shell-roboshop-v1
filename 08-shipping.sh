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

alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
validate $? "Set java version 25"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh | tee -a $logs_file
source /etc/profile.d/java.sh
echo $JAVA_HOME
validate $? "Set JAVA_HOME for maven"

id roboshop &>> $logs_file
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "System user roboshop created"
else 
echo -e "System user roboshop exists.. ${Y}SKIPPING${N}"
fi

rm -rf /app
validate $? "Removing old code"

mkdir /app
validate $? "Creating /app dir"

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip &>> $logs_file
validate $? "Installing shipping zip file"

cd /app
unzip /tmp/shipping.zip &>> $logs_file
validate $? "Unzipping shipping files to app dir"

mvn clean package &>> $logs_file
validate $? "Installing dependencies"

mv target/shipping.jar shipping.jar
validate $? "moving shipping.jar file"

dnf install mysql -y &>> $logs_file
validate $? "Installing mysql client"

cities_count=$(mysql -h "mysql.$domain_name" -u root -p'RoboShop@1' -sN -e "SELECT COUNT(*) FROM cities.cities;") 2>> $logs_file
if [ -z "$cities_count" ] || [ "$cities_count" -eq 0 ]; then
mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
validate $? "Installing master data for cities"
else 
echo -e "$(timestamp) [INFO]::Cities data exist.. ${Y}SKIPPING${N}"
fi

mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql
validate $? "Creating app user"

sed -i "s/MYDOMAIN/$domain_name" $scripts_folder/shipping.service &>> $logs_file
cp $scripts_folder/shipping.service /etc/systemd/system/shipping.service
validate $? "Setting up shipping servie file"

systemctl daemon-reload
systemctl enable shipping &>> $logs_file
systemctl start shipping &>> $logs_file
validate $? "Enbable and start shipping"

echo "$(timestamp) [INFO]::Script completed execution in $SECONDS seconds"
echo "$(timestamp) [INFO]::Script Completed Execution" | tee -a $logs_file