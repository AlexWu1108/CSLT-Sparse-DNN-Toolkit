#!/bin/awk -f

# input: outside paras: p_{1-7} & n_{1-7}
# output: logfile("final_new.mdl")

# start config

# config_set_logfile
logfile="final_new.mdl";

# config_choose_lines_method_1
# in order: affine1,final-affine,affine2,affine3,affine4,affine5,affine6 (not deal with: final-fixed-scale,left-content)
is_lines_to_prune_1 = ((NR>=24695 && NR<=26694));
#is_lines_to_prune_1 = ((NR>=2 && NR<=3));

is_lines_to_prune_2 = ((NR>=26702 && NR<=30131));
#is_lines_to_prune_2 = ((NR>=4 && NR<=5));

is_lines_to_prune_3 = ((NR>=30140 && NR<=32139));

is_lines_to_prune_4 = ((NR>=32147 && NR<=34146));

is_lines_to_prune_5 = ((NR>=34154 && NR<=36153));

is_lines_to_prune_6 = ((NR>=36161 && NR<=38160));

is_lines_to_prune_7 = ((NR>=38168 && NR<=40167));

# config_choose_lines_method_2
#start_line=26700;
#end_line=30129;
#is_lines_to_prune=(NR>=start_line && NR<=end_line);

# end config

#start awk
BEGIN{
}
{
  if(is_lines_to_prune_1) {
    printf("  ") > logfile;
    for (i=1;i<=NF;i++){
      if($i=="]") {
        printf($i) > logfile;
      }
      # save
      else if($i>=p_1 || $i<=n_1) {
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
  else if(is_lines_to_prune_2) {
    printf("  ") > logfile;
    for (i=1;i<=NF;i++){
      if($i=="]") {
        printf($i) > logfile;
      }
      # save
      else if($i>=p_2 || $i<=n_2) {
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
  else if(is_lines_to_prune_3) {
    printf("  ") > logfile;
    for (i=1;i<=NF;i++){
      if($i=="]") {
        printf($i) > logfile;
      }
      # save
      else if($i>=p_3 || $i<=n_3) {
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
  else if(is_lines_to_prune_4) {
    printf("  ") > logfile;
    for (i=1;i<=NF;i++){
      if($i=="]") {
        printf($i) > logfile;
      }
      # save
      else if($i>=p_4 || $i<=n_4) {
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
  else if(is_lines_to_prune_5) {
    printf("  ") > logfile;
    for (i=1;i<=NF;i++){
      if($i=="]") {
        printf($i) > logfile;
      }
      # save
      else if($i>=p_5 || $i<=n_5) {
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
  else if(is_lines_to_prune_6) {
    printf("  ") > logfile;
    for (i=1;i<=NF;i++){
      if($i=="]") {
        printf($i) > logfile;
      }
      # save
      else if($i>=p_6 || $i<=n_6) {
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
  else if(is_lines_to_prune_7) {
    printf("  ") > logfile;
    for (i=1;i<=NF;i++){
      if($i=="]") {
        printf($i) > logfile;
      }
      # save
      else if($i>=p_7 || $i<=n_7) {
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
