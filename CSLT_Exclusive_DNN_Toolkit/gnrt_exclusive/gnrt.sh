# prepare: ${x}.raw ( dir: /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/configs/init_randomly )
# change para in /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/configs/init_randomly/prune/prune_template_pct/find_pct.py to 0.75

x=27

# 1st subnet

cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/configs/init_randomly/prune
bash gnrt_random_prune.sh $x
cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/gnrt_exclusive
nnet3-am-copy --binary=false --raw=true /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/nnet_tdnn_a_3/configs/init_randomly/prune/prune_${x}/new.mdl nnet_1.raw

# 2nd subnet

nnet3-init-sparse-opposite --binary=false all_layer.config nnet_1.raw nnet_tmp_1.raw
bash change_raw_mdl.sh nnet_tmp_1.raw nnet_tmp_1.mdl
bash change_final_format.sh nnet_tmp_1.mdl
cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/gnrt_exclusive/prune_50%
cp ../nnet_tmp_1.mdl ./final_orig.mdl
if [ -f final_new.mdl ]; then
  rm final_new.mdl
fi
bash prune_pct.sh
cd ..
nnet3-am-copy --binary=false --raw=true prune_50%/final_new.mdl nnet_tmp_2.raw
bash change_final_format_2.sh nnet_tmp_2.raw
nnet3-init-sparse --binary=false all_layer.config nnet_tmp_2.raw nnet_2.raw

# 3rd subnet

nnet3-add --binary=false all_layer.config nnet_1.raw nnet_2.raw nnet_tmp_3.raw
nnet3-init-sparse-opposite --binary=false all_layer.config nnet_tmp_3.raw nnet_tmp_4.raw
bash change_raw_mdl.sh nnet_tmp_4.raw nnet_tmp_4.mdl
bash change_final_format.sh nnet_tmp_4.mdl
cd /work7/wangyanqing/kaldi/egs/wsj/s5/exp/nnet3/gnrt_exclusive/prune_25%
cp ../nnet_tmp_4.mdl ./final_orig.mdl
if [ -f final_new.mdl ]; then
  rm final_new.mdl
fi
bash prune_pct.sh
cd ..
nnet3-am-copy --binary=false --raw=true prune_25%/final_new.mdl nnet_tmp_5.raw
bash change_final_format_2.sh nnet_tmp_5.raw
nnet3-init-sparse --binary=false all_layer.config nnet_tmp_5.raw nnet_3.raw

# 4th subnet

nnet3-add --binary=false all_layer.config nnet_1.raw nnet_3.raw nnet_tmp_6.raw
nnet3-add --binary=false all_layer.config nnet_tmp_6.raw nnet_2.raw nnet_tmp_7.raw
nnet3-init-sparse-opposite --binary=false all_layer.config nnet_tmp_7.raw nnet_4.raw

# change format

for x in {1..4}; do
  bash change_raw_mdl.sh nnet_${x}.raw nnet_${x}.mdl
  bash change_final_format.sh nnet_${x}.mdl
done

