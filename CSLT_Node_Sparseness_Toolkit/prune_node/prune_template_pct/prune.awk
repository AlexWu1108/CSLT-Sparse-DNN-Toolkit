#!/bin/awk -f

#start awk
BEGIN{
}
{
  for (i=1;i<=NF;i++){
    # prune
    if($i<tr) { 
      printf("-1") > logfile;
      printf(" ") > logfile;
    }
    # save
    else {
      printf("1") > logfile;
      printf(" ") > logfile;
    }
  } 
}
END{
}
#end awk
