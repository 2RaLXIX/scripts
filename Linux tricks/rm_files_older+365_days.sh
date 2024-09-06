#!/bin/bash

find . -type f -mtime +365 -exec rm -f {} \;
find . -type d -mtime +365 -exec rm -rf {} \;

echo "Files older than 1 year were successfully deleted."
