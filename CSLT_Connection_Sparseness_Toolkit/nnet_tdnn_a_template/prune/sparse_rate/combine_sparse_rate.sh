#!/bin/bash

if [ $# != 1 ]; then
  echo "ERROR: please input max_id";
  exit 1;
fi

max_id=$1;

if [ -f sparse_rate ]; then
  rm sparse_rate;
fi

if [ -f sparse_rate_format ]; then
  rm sparse_rate_format;
fi

for((x=1;x<=$max_id;x++))
do
  cp ../prune_${x}/sparse_rate ./sparse_rate_${x};
  cp ../prune_${x}/sparse_rate_format ./sparse_rate_format_${x};
  
  sed -i 1i\==========================start_${x}=========================== sparse_rate_${x};
  sed -i '$ a ============================end=============================' sparse_rate_${x};
  sed -i ' ' sparse_rate_${x};

  cat sparse_rate_${x} >> /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/sparse_rate/sparse_rate;
  cat sparse_rate_format_$x >> /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/sparse_rate/sparse_rate_format;
done
