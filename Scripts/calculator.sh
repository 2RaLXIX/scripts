#!/bin/bash

while true
  do
    echo "====================================================="
    echo "Select one of the options bellow:"
    echo "1. Add"
    echo "2. Substract"
    echo "3. Multiply"
    echo "4. Divide"
    echo "5. Quit"

  read -p "Enter your choice: " choice
    if [ $choice -eq 1 ]
      then    
        read -p "Enter sum Number 1: " number1
        read -p "Enter sum number 2: " number2
        Answer=$(( $number1 + $number2 ))
	echo "================================"
	echo "$number1 + $number2 = $Answer"
    elif [ $choice -eq 2 ]
      then 
        read -p "Enter sub Number 1: " number1
        read -p "Enter sub Number 2: " number2
        Answer=$(( $number1 - $number2 ))
	echo "================================"
	echo "$number1 - $number2 = $Answer"
    elif [ $choice -eq 3 ]
      then    
        read -p "Enter mul Number 1: " number1
        read -p "Enter mul Number 2: " number2
        Answer=$(( $number1 * $number2 ))
	echo "================================"
	echo "$number1 * $number2 = $Answer"
    elif [ $choice -eq 4 ]
      then
        read -p "Enter div Number 1: " number1
        read -p "Enter div Number 2: " number2
        Answer=$(( $number1 / $number2 ))
	echo "================================"
	echo "$number1 / $number2 = $Answer"
    elif [ $choice -eq 5 ]
      then    
        break
    else
      echo "====================================================="
      echo "Please select one of the options bellow: from 1 to 5."
    fi      
done
