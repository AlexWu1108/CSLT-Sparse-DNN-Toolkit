#!/bin/bash

awk 'NR==1{print}' onorm.txt > layer1.txt
awk 'NR==2{print}' onorm.txt > layer2.txt
awk 'NR==3{print}' onorm.txt > layer3.txt
awk 'NR==4{print}' onorm.txt > layer4.txt
awk 'NR==5{print}' onorm.txt > layer5.txt
awk 'NR==6{print}' onorm.txt > layer6.txt
awk 'NR==7{print}' onorm.txt > layer7.txt
