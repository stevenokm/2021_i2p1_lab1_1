#!/bin/bash
oc="grade.csv"
prefix="lab1_1"
# remember to change both run.bash and CMakeList.txt files to the correct lab name
testbench="testbench/"
build_dir="build/"
jplag_dir="jplag/"
jplag_result_dir="jplag_result/"

cd ${testbench}
if1_list=( `ls -d ${prefix}_*.in` )
if1_count=${#if1_list[@]}
#if2_list=( `ls -d ${prefix}_p2_*.in` )
#if2_count=${#if2_list[@]}
#golden_of1=( ${if1_list[@]/.in/.out} )
echo ${if1_list[@]} $if1_count
#echo ${if2_list[@]} $if2_count
#echo ${golden_of1[@]} ${#golden_of1[@]}
cd ${OLDPWD}

OIFS="$IFS"
IFS=$'\n'
dir_list=( `ls -1 -d */` )
#dir_list=( "${dir_list[@]/$testbench}" )
#dir_list=( "${dir_list[@]/$build_dir}" )
#dir_list=( "${dir_list[@]/$jplag_dir}" )
#dir_list=( "${dir_list[@]/$jplag_result_dir}" )
#dir_list=( "${dir_list[@]/.git}" )
dir_count=${#dir_list[@]}
echo ${dir_list[@]} $dir_count
IFS="$OIFS"
#for i in "${dir_list[@]}"; do
#  echo $i
#done
#exit

echo "build cpp"
if [ ! -d $build_dir ]; then
  mkdir $build_dir
fi
cd $build_dir
cmake ..
make -k
cd ${OLDPWD}
#exit

rm $oc
printf "SID, Correctness, Format\n" > $oc
for i in "${dir_list[@]}"; do
  if [[ \
    "${i}" == "${testbench}" || \
    "${i}" == "${build_dir}" || \
    "${i}" == "${jplag_dir}" || \
    "${i}" == "${jplag_result_dir}" || \
    "${i}" == ".git" ]]; then
    continue
  fi

  i=${i%%/*}
  i_list=( ${i} )
  p1_1c=0
  p1_1f=0
  p1_ca=0
  p1_cf=0
  error_list=""

  student_exe="${build_dir}/${prefix}_${i_list[0]}"
  echo "eval ${student_exe}"
  if [ ! -f $student_exe ]; then
    echo "$student_exe not exist, skip."
    for file in ${if1_list[@]}; do
      error_list="${error_list}, ${file}"
    done
  else
    for file in ${if1_list[@]}; do
      if1=$file
      of1="$i/${if1/.in/.out}"
      log1="$i/${if1/.in/.log}"
      if1="${testbench}/${file}"
      golden_of1="${if1/.in/.out}"
      echo "$student_exe < $if1 | tr -d \ n > $of1; diff -w -B -i $golden_of1 $of1 > $log1"
      ${student_exe} < "${if1}" 2> "${log1}" | tr -d '\n' > "${of1}"
      diff -w -B -i $golden_of1 "${of1}" >> "${log1}"
      if [ $? == 0 ]; then 
        p1_1c=80; p1_1f=10;
        p1_ca=$(( $p1_ca + $p1_1c ))
        p1_cf=$(( $p1_cf + $p1_1f ))
      else
        error_list="${error_list}, ${file}"
      fi
    done
  fi

  p1_ca=$(( $p1_ca / $if1_count ))
  p1_cf=$(( $p1_cf / $if1_count ))
  echo $i, $p1_ca, $p1_cf $error_list >> $oc 
done
