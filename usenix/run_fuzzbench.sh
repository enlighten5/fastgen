target=$1
dir=$2
pro=$3
opt=$4
mkdir -p ${pro}_outseeds
find ${dir} -name "id*" | while read line; do
  { SYMCC_INPUT_FILE=$line SYMCC_ENABLE_LINEARIZATION=1 SYMCC_OUTPUT_DIR=${pro}_outseeds ${target} ./${pro}.native ${opt} ${line} 1>/dev/null 2>/dev/null; } 2>&1
done
