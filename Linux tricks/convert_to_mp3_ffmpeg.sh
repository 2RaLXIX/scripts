#!/bin/bash
#
input_file=$1
output_file=$2

ffmpeg -i "$input_file" -b:a 320k -vn "$output_file"
