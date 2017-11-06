#!/bin/bash

# rename

for subnet_id in {1..4}; do
  for layer_name in affine1 affine2 affine3 affine4 affine5 affine6 \
                    nonlin1 nonlin2 nonlin3 nonlin4 nonlin5 nonlin6 \
                    renorm1 renorm2 renorm3 renorm4 renorm5 renorm6 \
                    final-affine final-fixed-scale final-log-softmax; do
    sed -i '1,$s/'"$layer_name"'/'"$layer_name"'_'"$subnet_id"'/g' subnet_${subnet_id}.mdl
  done
done

# split

awk 'NR>=1&&NR<=24327{print}' subnet_1.mdl > part1.txt
awk 'NR>=24307&&NR<=24327{print}' subnet_2.mdl > part2.txt
awk 'NR>=24307&&NR<=24327{print}' subnet_3.mdl > part3.txt
awk 'NR>=24307&&NR<=24327{print}' subnet_4.mdl > part4.txt

awk 'NR>=24331&&NR<=40173{print}' subnet_1.mdl > part6.txt
awk 'NR>=24694&&NR<=40173{print}' subnet_2.mdl > part7.txt
awk 'NR>=24694&&NR<=40173{print}' subnet_3.mdl > part8.txt
awk 'NR>=24694&&NR<=40173{print}' subnet_4.mdl > part9.txt

# merge

if [ -f final.mdl ]; then
  rm final.mdl;
fi

for num in {1..10}; do
  cat part${num}.txt >> final.mdl
done
