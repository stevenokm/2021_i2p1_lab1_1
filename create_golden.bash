#!/bin/bash

prefix="lab1_1"
testbench="testbench/"
build_dir="build/"

cd ${testbench}
if1_list=($(ls -d ${prefix}_*.in))
if1_count=${#if1_list[@]}
#if2_list=( `ls -d ${prefix}_p2_*.in` )
#if2_count=${#if2_list[@]}
#golden_of1=( ${if1_list[@]/.in/.out} )
echo ${if1_list[@]} $if1_count
#echo ${if2_list[@]} $if2_count
#echo ${golden_of1[@]} ${#golden_of1[@]}
cd ${OLDPWD}

dir_list=("TA/")
echo ${dir_list[@]}
#exit

echo "build cpp"
if [ ! -d $build_dir ]; then
  mkdir $build_dir
fi
cd $build_dir
cmake ..
make
cd ${OLDPWD}

for i in ${dir_list[@]}; do
  i=${i%%/}

  ta_exe="${build_dir}/${prefix}_${i}"
  if [ ! -f $ta_exe ]; then
    echo "$ta_exe not exist, skip."
  else
    for file in ${if1_list[@]}; do
      if1="${testbench}/${file}"
      golden_of1="${if1/.in/.out}"
      golden_log1="${if1/.in/.log}"
      echo "$ta_exe < $if1 2> $golden_log1 | tr -d \ n > $golden_of1; cat $golden_log1 >> $golden_of1"
      ${ta_exe} <$if1 2>$golden_log1 | tr -d '\n' >$golden_of1
      cat $golden_log1 >>$golden_of1
    done
  fi
done
