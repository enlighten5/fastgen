#!/bin/bash
rm -rf corpus
RUST_LOG=info ../target/release/fastgen --sync_afl -i input_objdump -o corpus -t ./objdump.tracko1 -- ./objdump.fastsock -D @@

