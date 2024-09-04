#!/bin/bash

read -p "Enter username to search in system: " user

#user=$1 Arguments version (example: ./test.sh *argument)

if grep $user /etc/passwd
then
	echo "User '$user' Exists."
else
	echo "User '$user' doesn't Exist."
fi
