#!/bin/bash

# Show executed shell commands
set -o xtrace
# Exit on error.
set -e

chmod +x gen_input.sh
chmod +x sha256_bench.sh
chmod +x keccak_bench.sh

data_len=$(($1 / 32))

./gen_input.sh "$data_len"
./sha256_bench.sh $1
./keccak_bench.sh $1
