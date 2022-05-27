#!/bin/bash
jplag_dir="jplag"
jplag_result_dir="jplag_result"
if [ ! -d "$jplag_dir" ]; then
  mkdir $jplag_dir
fi
for i in */; do
  i=${i%%/}
  echo "${i}"
  if [ "${i}" == $jplag_dir -o "${i}" == "build" -o "${i}" == "testbench" -o "${i}" == $jplag_result_dir ]; then
    continue
  fi
  cp -r "${i}" $jplag_dir
done
java -jar jplag-2.12.1.jar -s -l c/c++ -r $jplag_result_dir $jplag_dir
