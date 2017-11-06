# To run this script, run in terminal: nohup bash ./run_several_pct.sh > ../../../../log4/1.out &
# In most conditions, you need to change the paras in three places: max_id, x, x

max_id=12;

# generate final_new.mdl in each folders
for x in {12..12}; do
{
  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune_node/prune_${x};
  cp ../baseline/final_v_baseline_format.raw .
  nnet3-calc-onorm --binary=false final_v_baseline_format.raw onorm.txt
  bash split.sh
  python find_pct.py
  bash gnrt_node_mask.sh
  nnet3-prune-node --binary=false final_v_baseline_format.raw layer2_mask.txt layer3_mask.txt layer4_mask.txt layer5_mask.txt layer6_mask.txt layer7_mask.txt final_new_format.raw
  bash make_raw_from_format.sh
  bash change_raw_to_mdl.sh
  bash sparse_rate_layer.sh &
}
done
#
## decode and find wer
#for x in {10..10}; do
#{
#  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune_node/prune_${x};
#  
#  # copy log.txt as final.mdl
#  cp final_new.mdl ../../final.mdl;
#
#  # decode
#  echo "----- start decoding now -----"
#  cd /work7/wangyanqing/kaldi/egs/wsj/s5;
#  ./run_tdnn_3_decode.sh;
#  echo "----- end decoding now ------"
#
#  # 
#  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3;
#  bash ./new_decode_file_node.sh ${x};
#}
#done
#
## combine the strategies to a file
#  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune_node/strategy;
#  bash combine.sh $max_id;
# 
## combine the best_wer to a file
#  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3;
#  bash combine_best_wer.sh $max_id;
#
## combine sparse_rate to a file
#  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune_node/sparse_rate;
#  bash combine_sparse_rate.sh $max_id;
#
## combination of the final results
#  cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune_node/results;
#  
#  if [ -f strategy ]; then
#    rm strategy;
#  fi
#
#  cp ../strategy/strategy ./strategy
#  
#  if [ -f best_wer ]; then
#    rm best_wer;
#  fi
#
#  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/best_wer ./best_wer
#
#  if [ -f sparse_rate ]; then
#    rm sparse_rate;
#  fi
#
#  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune_node/sparse_rate/sparse_rate ./sparse_rate;
#
#  if [ -f sparse_rate_format ]; then
#    rm sparse_rate_format;
#  fi
#
#  cp /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune_node/sparse_rate/sparse_rate_format ./sparse_rate_format
#
## combination of "results_format"
#cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/prune/results;
#bash combine_format.sh
