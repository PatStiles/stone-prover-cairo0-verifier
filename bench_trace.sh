#!/bin/bash

# Show executed shell commands
set -o xtrace
# Exit on error.
set -e

chmod +w gen_input.sh
chmod +w sha256_bench.sh
chmod +w keccak_bench.sh


./gen_input.sh 32
./gen_input.sh 64
./gen_input.sh 128
./gen_input.sh 256
./gen_input.sh 512
./gen_input.sh 1024
./gen_input.sh 2048
./gen_input.sh 4096

./sha256_bench.sh 16384 > 2_17.txt
./sha256_bench.sh 32768 > 2_18.txt
./sha256_bench.sh 65536 > 2_19.txt
./sha256_bench.sh 131072 > 2_20.txt

./keccak_bench.sh 1024 > 2_17.txt
./keccak_bench.sh 2048 > 2_18.txt
./keccak_bench.sh 4096 > 2_19.txt
./keccak_bench.sh 16384 > 2_20.txt
