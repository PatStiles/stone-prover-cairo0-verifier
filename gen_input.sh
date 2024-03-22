#!/bin/bash

# Exit on error.
set -e

# Check if data_len argument is provided
if [ $# -ne 1 ]; then
	    echo "Usage: $0 <data_len>"
	        exit 1
fi

data_len=$1

# Generate an array of random numbers
random_numbers=()
for ((i=0; i<data_len; i++)); do
	    random_numbers+=($RANDOM)
    done

output_file=$((data_len * 32)).json

# Create JSON object using jq
jq -n --argjson data_len "$data_len" --argjson data "$(printf '%s\n' "${random_numbers[@]}" | jq -R . | jq -s 'map(tonumber)')" '{data: $data, data_len: $data_len}' > $output_file
