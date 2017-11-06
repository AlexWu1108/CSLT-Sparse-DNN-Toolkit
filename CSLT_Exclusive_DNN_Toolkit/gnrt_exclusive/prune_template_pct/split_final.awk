#!/bin/awk -f

is_lines_to_prune_1 = ((NR>=1 && NR<=26700));
is_lines_to_prune_2 = ((NR>=26701 && NR<=36735));
is_lines_to_prune_3 = ((NR>=36736 && NR<=40173));
is_lines_to_prune_4 = ((NR>=40174 && NR<=40174));

BEGIN{
}

{
  if(is_lines_to_prune_1) {
    print $0 >> "final_orig_tmp_1";
  }
  if(is_lines_to_prune_2) {
    print $0 >> "final_orig_tmp_2";
  }
  if(is_lines_to_prune_3) {
    print $0 >> "final_orig_tmp_3";
  }
  if(is_lines_to_prune_4) {
    print $0 >> "final_orig_tmp_4";
  }
}

END{
}
