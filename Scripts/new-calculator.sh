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
    case $choice in
	1)
	  read -p "Enter sum Number 1: " number1
          read -p "Enter sum number 2: " number2
          Answer=$(( $number1 + $number2 ))
	  echo "================================"
	  echo "$number1 + $number2 = $Answer"
	;;
	2)
          read -p "Enter sub Number 1: " number1
          read -p "Enter sub Number 2: " number2
          Answer=$(( $number1 - $number2 ))
	  echo "================================"
	  echo "$number1 - $number2 = $Answer"
	;;
      	3)    
          read -p "Enter mul Number 1: " number1
          read -p "Enter mul Number 2: " number2
          Answer=$(( $number1 * $number2 ))
	  echo "================================"
	  echo "$number1 * $number2 = $Answer"
	;;
        4)
          read -p "Enter div Number 1: " number1
          read -p "Enter div Number 2: " number2
          Answer=$(( $number1 / $number2 ))
	  echo "================================"
	  echo "$number1 / $number2 = $Answer"
	;;
	5)
          break
	;;
        *)
          echo "====================================================="
          echo "Please select one of the options bellow: from 1 to 5."
    esac
  done
