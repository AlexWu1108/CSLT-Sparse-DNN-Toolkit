#!/bin/awk -f

#config

#end config

#start awk
BEGIN{
  first=1;
  combine_file="strategy";
}
{
  if(first==1) {
    printf("--------------------") >> combine_file;
    printf(" start of %s ",FILENAME) >> combine_file;
    print("--------------------") >> combine_file;
    first = 0;
  }
  print($0) >> combine_file;
}
END{
  printf("--------------------") >> combine_file;
  printf(" end of %s ",FILENAME) >> combine_file;
  print("--------------------") >> combine_file;
  print("") >> combine_file;
}
#end awk

