target=$1
pro=$2
seed=$3
mkdir -p ${pro}_outseeds
SYMCC_INPUT_FILE=$seed SYMCC_ENABLE_LINEARIZATION=1 SYMCC_OUTPUT_DIR=${pro}_outseeds ${target} ./${pro}.native ${seed};
