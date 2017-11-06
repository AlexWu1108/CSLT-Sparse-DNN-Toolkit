#!/bin/bash

if [ $# != 1 ]; then
  echo "ERROR: Please input max id!"
  exit 1;
fi

max_id=$1

for((x=1;x<=$max_id;x++)){
  if [ -f strategy_${x} ]; then
    rm strategy_${x};
  fi
  
  cp ../prune_${x}/strategy_${x} strategy_${x};
}

if [ -f strategy ]; then
  rm strategy;
fi

for((x=1;x<=$max_id;x++)){
  awk -f combine.awk strategy_${x}
}
