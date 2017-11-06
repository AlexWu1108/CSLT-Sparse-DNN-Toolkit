for x in {1..31}; do
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/prune_$x;
  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/prune_template/sparse_rate.awk /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/prune_$x/;
  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/prune_template/sparse_rate_layer.sh /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/prune_$x/;
  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/prune_template/sparse_rate_total.awk /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/prune_$x/;
  bash sparse_rate_layer.sh
done

# combine the strategies to a file
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/strategy;
  bash combine.sh 31;

# combine the best_wer to a file
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3;
  bash combine_best_wer.sh 31;

# combine sparse_rate to a file
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/sparse_rate;
  bash combine_sparse_rate.sh 31;

# combination of the final results
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/results;

  if [ -f strategy ]; then
    rm strategy;
  fi

  cp ../strategy/strategy ./strategy

  if [ -f best_wer ]; then
    rm best_wer;
  fi

  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/best_wer ./best_wer

  if [ -f sparse_rate ]; then
    rm sparse_rate;
  fi

  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/sparse_rate/sparse_rate ./sparse_rate;

  if [ -f sparse_rate_format ]; then
    rm sparse_rate_format;
  fi

  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/sparse_rate/sparse_rate_format ./sparse_rate_format
