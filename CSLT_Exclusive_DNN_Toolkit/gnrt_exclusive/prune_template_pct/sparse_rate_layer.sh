#!/bin/bash

if [ -f sparse_rate ]; then
  rm sparse_rate
fi

if [ -f sparse_rate_format ]; then
  rm sparse_rate_format
fi

# total
awk -f sparse_rate_total.awk \
./final_new.mdl;

# affine1
awk -f sparse_rate.awk \
-v start_line=24695 end_line=26694 \
layer_num=1 \
./final_new.mdl;
 
# final-affine
awk -f sparse_rate.awk \
-v start_line=26702 end_line=30131 \
layer_num=2 \
./final_new.mdl;

# affine2
awk -f sparse_rate.awk \
-v start_line=30140 end_line=32139 \
layer_num=3 \
./final_new.mdl;

# affine3
awk -f sparse_rate.awk \
-v start_line=32147 end_line=34146 \
layer_num=4 \
./final_new.mdl;

# affine4
awk -f sparse_rate.awk \
-v start_line=34154 end_line=36153 \
layer_num=5 \
./final_new.mdl;

# affine5
awk -f sparse_rate.awk \
-v start_line=36161 end_line=38160 \
layer_num=6 \
./final_new.mdl;

# affine6
awk -f sparse_rate.awk \
-v start_line=38168 end_line=40167 \
layer_num=7 \
./final_new.mdl;
