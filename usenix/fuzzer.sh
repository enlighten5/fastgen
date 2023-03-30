num_seeds=$1
target=$2
pro=$3
opt=$4
RUST_LOG=info /fastgen/target/release/fastgen -i /out/real_seeds/${pro}_reduced/ -s ${num_seeds} -o corpus_${pro} -t /usr/bin/${target}-- /usr/bin/${target} ./${pro}.native ${opt} @@
