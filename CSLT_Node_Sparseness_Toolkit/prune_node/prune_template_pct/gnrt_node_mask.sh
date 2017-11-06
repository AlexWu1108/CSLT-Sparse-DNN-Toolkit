#!/bin/bash

tr_1=`awk 'NR==2 {print $2}' trs`
tr_2=`awk 'NR==4 {print $2}' trs`
tr_3=`awk 'NR==6 {print $2}' trs`
tr_4=`awk 'NR==8 {print $2}' trs`
tr_5=`awk 'NR==10 {print $2}' trs`
tr_6=`awk 'NR==12 {print $2}' trs`
tr_7=`awk 'NR==14 {print $2}' trs`

awk -f prune.awk -v tr=${tr_1} logfile="layer1_mask.txt" layer1.txt
awk -f prune.awk -v tr=${tr_2} logfile="layer2_mask.txt" layer2.txt
awk -f prune.awk -v tr=${tr_3} logfile="layer3_mask.txt" layer3.txt
awk -f prune.awk -v tr=${tr_4} logfile="layer4_mask.txt" layer4.txt
awk -f prune.awk -v tr=${tr_5} logfile="layer5_mask.txt" layer5.txt
awk -f prune.awk -v tr=${tr_6} logfile="layer6_mask.txt" layer6.txt
awk -f prune.awk -v tr=${tr_7} logfile="layer7_mask.txt" layer7.txt
