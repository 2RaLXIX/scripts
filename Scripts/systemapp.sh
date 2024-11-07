#/bin/bash

read -p "Enter application to search in system tray: " app
tray=$(ps -ef)
echo "$tray" > tray.txt
awk=$(awk '{print $8}' tray.txt)
echo "$awk" >> tray.txt 
file=tray.txt

if [ -f "$file" ]; then
	if grep -q "$app" "$file"; then
		echo "Application '$app' is loaded."
		read -p "Do you want to kill this application? (yes/no): " answer
		  if [[ $answer == "yes" ]]; then
			pkill "$app"
			echo "$app is killed."
		  elif [[ $answer == "no" ]]; then
			echo "Exiting..."
			exit 0
		  else
			echo "Invalid input, please enter either 'yes' or 'no'."
		  fi
	else
		echo "App '$app' is not loaded."
		exit 0
	fi
else
	echo "File '$file' doesn't exist."
	exit 1
fi
