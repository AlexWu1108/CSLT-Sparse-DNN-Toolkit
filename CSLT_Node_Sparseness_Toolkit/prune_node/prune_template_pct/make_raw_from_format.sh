#!/bin/bash

if [ -f final_new.raw ]; then
  rm final_new.raw;
fi

awk -f split_raw_format.awk final_new_format.raw

cat cstt_1 cstt_3 cstt_2 cstt_4 >> final_new.raw

rm cstt_1 cstt_2 cstt_3 cstt_4
