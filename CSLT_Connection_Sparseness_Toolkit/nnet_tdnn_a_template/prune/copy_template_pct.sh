#!/bin/bash

if [ $# == 0 ]; then
  echo "ERROR: Please input at least 1 number to indicate the id of the new folder!"
  exit 1;
fi

if [ $# == 1 ]; then
  id=$1;
  if [ -d prune_${id} ]; then
    echo "ERROR: prune_${id} has existed!"
    exit 1;
  fi
  cp -r prune_template_pct prune_$id;
  mv prune_${id}/strategy prune_${id}/strategy_${id}
fi

if [ $# == 2 ]; then
  id_orig=$1;
  id_new=$2;
  if [ -d prune_${id_new} ]; then
    echo "ERROR: prune_${id_new} has existed!"
    exit 1;
  fi
  cp -r prune_${id_orig} prune_${id_new};
  for x in final_new.mdl final_orig.mdl layer1 layer2 layer3 layer4 layer5 layer6 layer7 sparse_rate trs; do
    if [ -f prune_${id_new}/$x ]; then
      rm prune_${id_new}/$x;
    fi
  done
  mv prune_${id_new}/strategy* prune_${id_new}/strategy_${id_new}
fi
