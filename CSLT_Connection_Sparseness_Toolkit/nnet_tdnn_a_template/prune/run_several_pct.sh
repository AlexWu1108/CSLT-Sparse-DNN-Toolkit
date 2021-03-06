# To run this script, run in terminal: nohup bash ./run_several_pct.sh > ../../../../log4/1.out &
# In most conditions, you need to change the paras in three places: max_id, x, x

max_id=23;

# generate final_new.mdl in each folders
for x in {20..23}; do
{
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/prune_${x};
  cp ../baseline/final_v_baseline.mdl ./final_orig.mdl
  bash prune_pct.sh;
#  awk -f sparse_rate.awk final_new.mdl
  bash sparse_rate_layer.sh;
}
done

# decode and find wer
for x in {20..23}; do
{
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/prune_${x};
  
  # copy log.txt as final.mdl
  cp final_new.mdl ../../final.mdl;

  # decode
  echo "----- start decoding now -----"
  cd /work7/wangyanqing/kaldi/egs/wsj/s5;
  ./run_tdnn_x.sh;
  echo "----- end decoding now ------"

  # 
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x;
  bash ./new_decode_file.sh ${x};
}
done

# combine the strategies to a file
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/strategy;
  bash combine.sh $max_id;
 
# combine the best_wer to a file
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x;
  bash combine_best_wer.sh $max_id;

# combine sparse_rate to a file
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/sparse_rate;
  bash combine_sparse_rate.sh $max_id;

# combination of the final results
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/results;
  
  if [ -f strategy ]; then
    rm strategy;
  fi

  cp ../strategy/strategy ./strategy
  
  if [ -f best_wer ]; then
    rm best_wer;
  fi

  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/best_wer ./best_wer

  if [ -f sparse_rate ]; then
    rm sparse_rate;
  fi

  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/sparse_rate/sparse_rate ./sparse_rate;

  if [ -f sparse_rate_format ]; then
    rm sparse_rate_format;
  fi

  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/sparse_rate/sparse_rate_format ./sparse_rate_format

# combination of "results_format"
cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_x/prune/results;
bash combine_format.sh
