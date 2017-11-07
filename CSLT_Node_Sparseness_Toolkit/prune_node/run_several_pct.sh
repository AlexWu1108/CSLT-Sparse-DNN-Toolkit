# To run this script, run in terminal: nohup bash ./run_several_pct.sh > ../../../../log4/1.out &
# In most conditions, you need to change the paras in three places: no, first_no, last_no

max_id=no;

# generate final_new.mdl in each folders
for x in {first_no..last_no}; do
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