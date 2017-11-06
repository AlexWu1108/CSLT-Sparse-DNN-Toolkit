#!/bin/bash

if [ -f final_v_baseline_format.raw ]; then
  rm final_v_baseline_format.raw;
fi

awk -f split_raw.awk final_v_baseline.raw

cat cstt_1 cstt_3 cstt_2 cstt_4 >> final_v_baseline_format.raw

rm cstt_1 cstt_2 cstt_3 cstt_4
