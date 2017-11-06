# Run this simple script to move decode-folder after decoding.

#!/bin/bash

# remember to follow a number as a parameter when using this script!
if [ $# != 1 ]; then
  echo "ERROR: Please input a number to indicate the id of the new folder!"
  exit 1;
fi

id=$1

mkdir decode_$id

mv decode_tgpr_dev93_eval92 decode_$id

cp ./decode_baseline/view_best_wer.sh decode_$id/view_best_wer_${id}.sh
