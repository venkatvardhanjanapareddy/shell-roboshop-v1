#!/bin/bash

user=$(id -u)

R="\e[31m"
G="\e[32m"
B="\e[33m"
N="\e[0m"

if [ $user -ne 0 ]; then 
    echo -e "${R}ERROR::${N} Try with sudo access"
    exit 1
else 
    echo "Script Started running"
fi
