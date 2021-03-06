#!/bin/awk -f

is_lines_to_prune_1 = ((NR>=1 && NR<=2397));
is_lines_to_prune_2 = ((NR>=2398 && NR<=5835));
is_lines_to_prune_3 = ((NR>=5836 && NR<=15870));
is_lines_to_prune_4 = ((NR>=15871 && NR<=15871));

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
