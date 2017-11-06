#!/bin/awk -f

# input: an unknown file ( usually final_orig.mdl, or any file with the same format as final.mdl file )
# output: layer1, layer2, layer3, ... layer7
# note: the format of layer{1-7} is not perfect. We need to deal with it simply.

is_lines_to_prune_1 = ((NR>=24695 && NR<=26694));

is_lines_to_prune_2 = ((NR>=26702 && NR<=30131));

is_lines_to_prune_3 = ((NR>=30140 && NR<=32139));

is_lines_to_prune_4 = ((NR>=32147 && NR<=34146));

is_lines_to_prune_5 = ((NR>=34154 && NR<=36153));

is_lines_to_prune_6 = ((NR>=36161 && NR<=38160));

is_lines_to_prune_7 = ((NR>=38168 && NR<=40167));

BEGIN{
}

{
  if(is_lines_to_prune_1) {
    print $0 >> "layer1";
  }
  
  if(is_lines_to_prune_2) {
    print $0 >> "layer2";
  }

  if(is_lines_to_prune_3) {
    print $0 >> "layer3";
  }

  if(is_lines_to_prune_4) {
    print $0 >> "layer4";
  }

  if(is_lines_to_prune_5) {
    print $0 >> "layer5";
  }

  if(is_lines_to_prune_6) {
    print $0 >> "layer6";
  }

  if(is_lines_to_prune_7) {
    print $0 >> "layer7";
  }
}

END{
}
