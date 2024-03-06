#!/bin/bash

# Show executed shell commands
set -o xtrace
# Exit on error.
set -e

chmod +x sha256_bench.sh
chmod +x keccak_bench.sh

./sha256_bench.sh $1
./keccak_bench.sh $1
