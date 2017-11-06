#!/bin/awk -f

logfile="best_wer_format"

BEGIN{
}
{
  if($1=="%WER"){
    print($2) > logfile;
  }
}
END{
}
