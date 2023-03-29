target=$1
pro=$2
opt=$3
count=0
mkdir -p ${pro}_outseeds

if [[ "$target" == "mode_switch_symsan" || "$target" == "clb_symsan" ]]; then
  find "/out/real_seeds/${pro}_reduced" -name "id*" | while read line; do
    { 
      TAINT_OPTIONS="taint_file=\"${line}\"" ${target} ./${pro}.native ${opt} ${line} &> /dev/null;
      count=$((count+1))
      if [ $count -eq 100 ]; then
          break
      fi
      # if [ $? -ne 0 ]; then
      #     echo "Error: Fail to run ${pro} with ${line}"
      #     exit 1
      # fi
    } 2>&1
  done
else
  find "/out/real_seeds/${pro}_reduced" -name "id*" | while read line; do
    { 
      SYMCC_INPUT_FILE=$line SYMCC_ENABLE_LINEARIZATION=1 SYMCC_OUTPUT_DIR=${pro}_outseeds ${target} ./${pro}.native ${opt} ${line} 1>/dev/null 2>/dev/null;
      count=$((count+1))
      if [ $count -eq 100 ]; then
          break
      fi
      # if [ $? -ne 0 ]; then
      #     echo "Error: Fail to run ${pro} with ${line}"
      #     exit 1
      # fi
    } 2>&1
  done
fi