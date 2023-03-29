mode=$1
target=$2
native_binaries=("proj" "size" "sqlite3" "vorbis" "woff2" \
                 "xml" "curl" "freetype" "lcms" "nm" \
                 "libjpeg" "re2" "readelf" "harfbuzz" \
                 "libpng" "openssl" "objdump" "openthread" \
                 "mbedtls" "json")
for bin in "${native_binaries[@]}"
do
  echo "Running ${bin} with ${target} in ${mode} mode"
  time ./run_fuzzbench_${mode}.sh ${target} ${bin} 2>&1  | grep real
done
