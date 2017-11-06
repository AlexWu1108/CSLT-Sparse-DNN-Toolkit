#!/usr/bin/env python

import numpy as np
import math

total_connections = 0

for i in range(1,8):
  print "###########",i,"###########"

  tmp = 'layer{n}'
  tmp2 = tmp.format(n=i)
  layer = np.loadtxt(tmp2)
    
  print "layer.shape:",layer.shape
  
  number_in_this_layer = layer.shape[0]*layer.shape[1]
  print "num in layer",i,":",number_in_this_layer
  
  total_connections += number_in_this_layer

print "###########","total","###########"
print "total num in this nnet:",total_connections
