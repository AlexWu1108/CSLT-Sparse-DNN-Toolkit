#!/bin/bash

if [ -f strategy_format ]; then
  rm strategy_format
fi

if [ -f best_wer_format ]; then
  rm best_wer_format
fi

awk -f deal_strategy.awk strategy
awk -f deal_best_wer.awk best_wer

# combine to file "result_format"

if [ -f result_format ]; then
  rm result_format;
fi

paste -d " " strategy_format sparse_rate_format best_wer_format > "result_format"
