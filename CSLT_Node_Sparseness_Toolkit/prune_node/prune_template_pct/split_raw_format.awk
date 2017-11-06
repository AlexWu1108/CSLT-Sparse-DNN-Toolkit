#!/bin/awk -f

# input: an unknown file ( usually final_orig.mdl, or any file with the same format as final.mdl file )
# output: layer1, layer2, layer3, ... layer7
# note: the format of layer{1-7} is not perfect. We need to deal with it simply.

is_lines_to_prune_1 = ((NR>=1 && NR<=2397));

is_lines_to_prune_2 = ((NR>=2398 && NR<=12432));

is_lines_to_prune_3 = ((NR>=12433 && NR<=15870));

is_lines_to_prune_4 = ((NR>=15871 && NR<=15871));

BEGIN{
}

{
  if(is_lines_to_prune_1) {
    print $0 >> "cstt_1";
  }
  
  if(is_lines_to_prune_2) {
    print $0 >> "cstt_2";
  }

  if(is_lines_to_prune_3) {
    print $0 >> "cstt_3";
  }

  if(is_lines_to_prune_4) {
    print $0 >> "cstt_4";
  }
}

END{
}
