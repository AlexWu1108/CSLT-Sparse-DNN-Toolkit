file_raw=$1
file_mdl=$2

sed -i '$d' $file_raw

cat change_raw_mdl/hmm.mdl $file_raw change_raw_mdl/last_line.mdl > $file_mdl
