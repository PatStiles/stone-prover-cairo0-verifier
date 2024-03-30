#!/bin/bash

# Show executed shell commands
set -o xtrace
# Exit on error.
set -e

chmod +w gen_input.sh
chmod +w sha256_bench.sh
chmod +w keccak_bench.sh

data_len=$(($1 / 32))

./gen_input.sh "$data_len"
./sha256_bench.sh $1 > sha256_bench_$1.txt
./keccak_bench.sh $1 > keccak_bench_$1.txt
