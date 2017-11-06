# change final.raw
awk -f change_final_format_2/split_final_2.awk $1

cat final_orig_tmp_1 final_orig_tmp_3 final_orig_tmp_2 final_orig_tmp_4 > $1

for num in {1..4}; do
  rm final_orig_tmp_${num}
done
