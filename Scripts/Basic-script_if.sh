#! /bin/bash

read -p "Enter first number:" x
read -p "Enter second number:" y

if [ $x -gt $y ]
	then
	echo "$x is greater than $y"
elif [ $x -lt $y ]
	then
	echo "$x is less than $y"
#elif [ $x -eq $y ]
#then
else
	echo "$x is equal to $y"
fi

