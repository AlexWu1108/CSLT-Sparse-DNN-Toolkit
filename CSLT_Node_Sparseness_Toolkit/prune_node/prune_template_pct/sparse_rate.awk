#!/bin/awk -f

# This script is to calculate the sparse rate of a mdl file.Please edit the variable is_lines_to_prune.
# You can use this script by run this line in terminal: awk -f sparse_rate.awk <FILENAME of mdl>
# The output is a file named "sparse_rate", you can change the name by changing the variable logfile.

# start config

# config_set_variables
logfile="sparse_rate";
logfile_format="sparse_rate_format";

# config_choose_lines_method_1
# in order: lda,affine1,final-affine,affine2,affine3,affine4,affine5,affine6 (not deal with: final-fixed-scale,left-content)
is_lines_to_prune= \
((NR>=start_line && NR<=end_line));

# config_choose_lines_method_2
#start_line=26700;
#end_line=30129;
#is_lines_to_prune=(NR>=start_line && NR<=end_line);

# end config

#start awk
BEGIN{
num_total_connections=0;
num_sparse_connections=0;
}
{
  if(is_lines_to_prune) {
    for(i=1;i<=NF;i++) {
      if($i~/([0-9])+/){
        if($i==0.0000000) {
          num_total_connections += 1;
          num_sparse_connections += 1;
        }
        else {
          num_total_connections += 1;
        }
      }
    }
  }
}
END{
  sparse_rate_multiple_100=(num_sparse_connections/num_total_connections)*100;

  printf("-------- layer ") >> logfile;
  printf(layer_num) >> logfile;
  print(" --------") >> logfile;
  printf("Total connections = %d",num_total_connections) >> logfile;
  print("") >> logfile;
  printf("Sparse connections = %d",num_sparse_connections) >> logfile;
  print("") >> logfile;
  printf("Sparse Rate = %.4f%",sparse_rate_multiple_100) >> logfile;
  print("") >> logfile;

  printf("%.4f",sparse_rate_multiple_100) >> logfile_format;
  if(layer_num==7) {
    print("") >> logfile_format;
  }
  else {
    printf(" ") >> logfile_format;
  }
}

#end awk
