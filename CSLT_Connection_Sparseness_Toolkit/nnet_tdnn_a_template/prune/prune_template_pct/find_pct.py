#!/usr/bin/env python

# input: layer{1-7} ( after generated by split.awk, they need to be dealt with the format before being used as the input of this script )
# output: file trs, in which thresholds are recorded

import numpy as np
import math
import linecache

pct = 0.2

logfile = file("trs", 'w')

for i in range(1,8):
  print i

  tmp = 'layer{n}'
  tmp2 = tmp.format(n=i)
  layer = np.loadtxt(tmp2)
    
  print layer.shape
  layer = layer.flatten()
  print "layer.shape[0]:",layer.shape[0]

  # positive part
  positive_id = np.where(layer>0)[0]
  positive_subarray = layer[positive_id]
  print "positive_subarray.shape:",positive_subarray.shape[0]
  n_positive = positive_subarray.shape[0] * (1-pct) # prune n value
  ind = np.argpartition(positive_subarray, -n_positive)[-n_positive:] # the max n values
  positive_tr = positive_subarray[ind][0]
  print >> logfile, tmp2
  print >> logfile, "positive threshold:", positive_tr

  # negative part
  negative_id = np.where(layer<0)[0]
  negative_subarray = layer[negative_id]
  n_negative = negative_subarray.shape[0] * (pct) + 1 # save n value
  ind = np.argpartition(negative_subarray, -n_negative)[-n_negative:] # the max n values
  negative_tr = negative_subarray[ind][0]
  print >> logfile, "negative threshold:", negative_tr

  print "n_positive:",n_positive
  print "n_negative:",n_negative

#layer1 = np.loadtxt('layer1');
#
#a = np.array([[10, 4, 7], [3, 2, 1]])
#print a
#b = np.percentile(a,20,axis=1)
#print b
#print b.shape
#c = a.flatten()
#print c
#
#ind = np.argpartition(c, -3)[-3:]
#d=c[ind]
#print d
