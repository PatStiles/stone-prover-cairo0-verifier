#!/bin/bash

# Show executed shell commands
set -o xtrace
# Exit on error.
set -e

cd stone-prover/e2e_test

echo "Compiling Keccak Benchmark"
cairo-compile ../../keccak/keccak.cairo --output ../../keccak/keccak_compiled.json --proof_mode

echo "Generating Proof"
cairo_run_output=$(cairo-run     --program=../../keccak/keccak_compiled.json     --layout=recursive --program_input=../../$1.json --air_public_input=../../keccak/public_input.json     --air_private_input=../../keccak/private_input.json     --trace_file=../../keccak/trace.json     --memory_file=../../keccak/memory.json     --print_output     --proof_mode --print_info)

echo "$cairo_run_output"

trace_length=$(echo "$cairo_run_output" | grep -o 'Number of steps: [0-9]\+' | cut -d ' ' -f 4)

echo "Trace Length: $trace_length"

# Compute new last_layer_degree_bound with fixed sum(fri_steps) = 12
res=$(echo "l($trace_length)/l(2) + 4 - 12" | bc -l)
res_round=$(printf "%.0f" "$res")
last_layer_degree_bound=$(echo "2^($res_round)" | bc -l)

# Modify the JSON field of ./keccak/cpu_air_params.json
jq --arg last_layer_degree_bound $last_layer_degree_bound '.stark.fri.last_layer_degree_bound = ($last_layer_degree_bound|tonumber)' /home/ubuntu/stone-prover-cairo0-verifier/keccak/cpu_air_params.json > tmp_file.json && mv tmp_file.json /home/ubuntu/stone-prover-cairo0-verifier/keccak/cpu_air_params.json

echo "Benchmarking Stone Prover constraining Keccak on $1 bytes"
hyperfine -r 1 './cpu_air_prover     --out_file=../../keccak/keccak_proof.json     --private_input_file=../../keccak/private_input.json --public_input_file=../../keccak/public_input.json     --prover_config_file=../../keccak/cpu_air_prover_config.json --parameter_file=../../keccak/cpu_air_params.json     --generate_annotations' --show-output 

echo "Benchmarking Stone Air Verifier for Keccak on $1 bytes"
hyperfine -r 1 './cpu_air_verifier --in_file=../../keccak/keccak_proof.json' --show-output

cd ../../
cd cairo-lang
jq '{ proof: . }' ../keccak/keccak_proof.json > cairo_verifier_input.json

echo "Compiling Cairo Verifier for recursive layout"
cairo-compile --cairo_path=./src src/starkware/cairo/cairo_verifier/layouts/all_cairo/cairo_verifier.cairo --output cairo_verifier.json --no_debug_info

echo "Benchmarking Cairo Verifier for Keccak on $1 bytes"
hyperfine -r 1 'cairo-run --program=cairo_verifier.json --layout=recursive --program_input=cairo_verifier_input.json --trace_file=cairo_verifier_trace.json --memory_file=cairo_verifier_memory.json --print_output' --show-output
cd ..
