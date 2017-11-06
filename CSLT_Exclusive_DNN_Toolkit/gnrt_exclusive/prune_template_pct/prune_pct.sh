#!/bin/bash

# generate layer{1-7} and deal with the data format

for ((x=1;x<=7;x++)) {
  if [ -f layer$x ]; then
    rm layer$x
  fi
}

awk -f split.awk final_orig_format.mdl

for ((x=1;x<=7;x++)) {
  sed -i 's/.$//' layer$x
}
sed -i 's/.$//' layer7

# generate trs, in which threshold of +/- values are recorded.

if [ -f trs ]; then
  rm trs
fi

python find_pct.py

# find thresholds in file 'trs'

p_1=`awk 'NR==2 {print $3}' trs`
n_1=`awk 'NR==3 {print $3}' trs`
p_2=`awk 'NR==5 {print $3}' trs`
n_2=`awk 'NR==6 {print $3}' trs`
p_3=`awk 'NR==8 {print $3}' trs`
n_3=`awk 'NR==9 {print $3}' trs`
p_4=`awk 'NR==11 {print $3}' trs`
n_4=`awk 'NR==12 {print $3}' trs`
p_5=`awk 'NR==14 {print $3}' trs`
n_5=`awk 'NR==15 {print $3}' trs`
p_6=`awk 'NR==17 {print $3}' trs`
n_6=`awk 'NR==18 {print $3}' trs`
p_7=`awk 'NR==20 {print $3}' trs`
n_7=`awk 'NR==21 {print $3}' trs`

# prune the mdl file according to the thresholds

awk -f prune.awk \
-v p_1=$p_1 n_1=$n_1 \
p_2=$p_2 n_2=$n_2 \
p_3=$p_3 n_3=$n_3 \
p_4=$p_4 n_4=$n_4 \
p_5=$p_5 n_5=$n_5 \
p_6=$p_6 n_6=$n_6 \
p_7=$p_7 n_7=$n_7 \
./final_orig_format.mdl;

