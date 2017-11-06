#!/bin/awk -f

logfile="strategy_format"

BEGIN{
  i=1;
}
{
  if(i%4==2){
    printf($1) > logfile;
    printf(" ") > logfile;
    strategy=$2;
    if(match(strategy,"pct")!=0){
      tr=$3;
      printf("pct ") > logfile;
      printf(tr) > logfile;
      print(" ") > logfile;
    }
    else if(match(strategy,"abs")!=0){
      n1=index(strategy,"<");
      tr=substr(strategy,5,15);
      printf("abs ") > logfile;
      printf(tr) > logfile;
      print(" ") > logfile;
    }
    else if(match(strategy,"0<value")!=0){
      tr=substr(strategy,9,15);
      printf("+ ") > logfile;
      printf(tr) > logfile;
      print(" ") > logfile;
    }
    else{
      n1=index(strategy,"value")-2;
      tr=substr(strategy,2,n1-1);
      printf("- ") > logfile;
      printf(tr) > logfile;
      print(" ") > logfile;
    }
  }
  i=i+1;
}
END{
}

