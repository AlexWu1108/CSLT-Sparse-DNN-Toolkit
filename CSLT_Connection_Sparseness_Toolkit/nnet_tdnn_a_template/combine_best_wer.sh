# To merge the result (best WER) into a single file.

#!/bin/bash

if [ $# != 1 ]; then
  echo "ERROR: Please input max_id!";
  exit 1;
fi

max_id=$1

rm best_wer;

for ((i=1;i<=$max_id;i++))
do
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/decode_${i};

  if [ -f best_wer_${i} ]; then
    rm best_wer_${i};
  fi

  bash view_best_wer*.sh > /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/decode_${i}/best_wer_${i};
  sed -i 1i\----------start_${i}---------- best_wer_${i};
  sed -i '$ a ----------end----------' best_wer_${i};
  sed -i ' ' best_wer_${i};

  cat best_wer_${i} >> /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/best_wer;

  if [ ! -f best_wer_$i ]; then
    echo "----------start_${i}----------" >> /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/best_wer;
    echo "%WER -" >> /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/best_wer;
    echo "----------end----------" >> /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/best_wer;
  fi

done
