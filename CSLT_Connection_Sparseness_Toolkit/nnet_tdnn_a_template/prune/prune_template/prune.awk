#!/bin/awk -f

# start config

# config_set_logfile
logfile="final_new.mdl";

# config_choose_lines_method_1
# in order: lda,affine1,final-affine,affine2,affine3,affine4,affine5,affine6 (not deal with: final-fixed-scale,left-content)

is_lines_to_prune= \
((NR>=24695 && NR<=26694)) || \
((NR>=26702 && NR<=30131)) || \
((NR>=30140 && NR<=32139)) || \
((NR>=32147 && NR<=34146)) || \
((NR>=34154 && NR<=36153)) || \
((NR>=36161 && NR<=38160)) || \
((NR>=38168 && NR<=40167));

# config_choose_lines_method_2
#start_line=26700;
#end_line=30129;
#is_lines_to_prune=(NR>=start_line && NR<=end_line);

# end config

#start awk
BEGIN{
}
{
  if(is_lines_to_prune) {
    printf("  ") > logfile;
    for (i=1;i<=NF;i++){
      # save
      if($i=="]") {
        printf($i) > logfile;
      }
#      else if($i>=0.15 || $i<=-0.15) { # prune abs
#      else if($i>=0.15 || $i<=0) { # prune positive values
#      else if($i>=0 || $i<=-0.15) { # prune negative values
        printf($i) > logfile;
        printf(" ") > logfile;
      }
      # cut
      else {
        printf("0.0000000") > logfile;
        printf(" ") > logfile;
      }
    } 
    print("") > logfile;
  }
  else {
   print($0) > logfile; 
  }
}
END{
}
#end awk
