#!/usr/bin/env python
#-*- coding:utf-8 -*-
# Power by Fu Hao
# 2017-08-25 22:16:28

import numpy as np

array = np.loadtxt("layer2_mask.txt")

print(np.sum(array==-1))

print array.shape
