#!/bin/bash
#
i=$1
for (( i; i >= 0; i -- ))
do
	echo "Count $i"
	sleep 1
done

