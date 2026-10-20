#!/bin/bash

# sudo user condition

user_id=$( id -u )
if [ $user_id -ne 0 ]; then
        echo "Try with sudo access"
        exit 1
    else
        echo "Script started"
fi

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
        echo -e "{G}SUCCESS${N}: $2"
    fi
}

ls -l
validate $? "Showing list"

hiuahefu
validate $? "jauhfuv"

echo "Continuing"