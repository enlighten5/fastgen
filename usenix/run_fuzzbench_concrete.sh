target=$1
pro=$2
opt=$3
find "/out/real_seeds/${pro}_reduced" -name "id*" | while read line; do
  { 
    SYMCC_NO_SYMBOLIC_INPUT=1 ${target} ./${pro}.native ${opt} ${line} 1>/dev/null 2>/dev/null;
    # if [ $? -ne 0 ]; then
    #     echo "Error: Fail to run ${pro} with ${line}"
    #     exit 1
    # fi
  } 2>&1
done
