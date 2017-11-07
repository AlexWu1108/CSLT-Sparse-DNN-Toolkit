// Copyright 2012-2015  Johns Hopkins University (author:  Daniel Povey)

// See ../../COPYING for clarification regarding multiple authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// MERCHANTABLITY OR NON-INFRINGEMENT.
// See the Apache 2 License for the specific language governing permissions and
// limitations under the License.

#include "base/kaldi-common.h"
#include "util/common-utils.h"
#include "nnet3/nnet-nnet.h"
#include "hmm/transition-model.h"
#include "tree/context-dep.h"
#include <fstream>
#include "nnet3/nnet-simple-component.h"

int main(int argc, char *argv[]) {
  try {
    using namespace kaldi;
    using namespace kaldi::nnet3;
    typedef kaldi::int32 int32;

    const int MAX_NODE_NUM = 2000;

    const char *usage =
        "Pruning node according to trs.\n"
        "\n"
        "Usage:\n"
        "e.g.:\n"
        " nnet3-prune-node orig.raw mask_1.txt mask_2.txt mask_3.txt mask_4.txt mask_5.txt mask_6.txt mask_7.txt new.raw\n";

    bool binary_write = true;
    int32 srand_seed = 0;

    ParseOptions po(usage);
    po.Register("binary", &binary_write, "Write output in binary mode");
    po.Register("srand", &srand_seed, "Seed for random number generator");

    po.Read(argc, argv);
    srand(srand_seed);

    if (po.NumArgs() != 8) {
      po.PrintUsage();
      exit(1);
    }

    std::string nnet_str = po.GetArg(1); // egs raw nnet
    std::string mask_str[6];
    for(int id = 0; id <= 5; id++){
      mask_str[id] = po.GetArg(id+2); // thresholds
    }
    std::string new_raw_str = po.GetArg(8); // orig raw nnet

    Nnet nnet_orig;
    Nnet nnet_new;

    ReadKaldiObject(nnet_str, &nnet_orig); // read orig
    KALDI_LOG << "Read raw neural net";


    //std::ofstream ofile("ofile.txt");
    //for(int n = 0; mask[n]!=0; n++) {
    //  ofile << mask[n];
    //}

    // set the component id to prune, 100 refers to none.
    int before_node_id[6] = {1, 4, 7, 10, 13, 16};
    int after_node_id[6] = {4, 7, 10, 13, 16, 19};

    for(int x = 0; x <= 5; x++) {

      std::ofstream ofile("print_x.txt");
      ofile<<x<<"\n";
      ofile.close();

      // read mask, -1 refers to prune.
      std::ifstream in_mask(mask_str[x]);
      int i = 0;
      int mask[MAX_NODE_NUM] = {0};
      while (!in_mask.eof())
      {
	    in_mask >> mask[i];
        i++;
      }
      in_mask.close();

      // prune the last node
      if(before_node_id[x]!=100) {
        AffineComponent* last_component = static_cast<AffineComponent *>(nnet_orig.GetComponent(before_node_id[x]));
        CuMatrix<BaseFloat> last_linear = last_component->LinearParams();
        int node_num = last_linear.NumRows();
        for(int node_id=0; node_id < node_num; node_id++) {
          if(mask[node_id]==-1) {
            last_linear = last_component->LinearParams();
            Matrix<BaseFloat> last_linear_mat = last_linear.Mat();
            last_linear_mat.SetRowZero(node_id);
            CuMatrix<BaseFloat> last_linear_new(last_linear.NumRows(),last_linear.NumCols());
            last_linear_new.CopyFromMat(last_linear_mat);
            CuVector<BaseFloat> last_bias = last_component->BiasParams();
            last_component->SetParams(last_bias.Vec(),last_linear_new.Mat());
          }
        }
      }

      // prune the next node
      if(after_node_id[x]!=100) {
        AffineComponent* next_component = static_cast<AffineComponent *>(nnet_orig.GetComponent(after_node_id[x]));
        CuMatrix<BaseFloat> next_linear = next_component->LinearParams();
        int node_num = next_linear.NumCols();
        for(int node_id=0; node_id < node_num; node_id++) {
          if(mask[node_id]==-1) {
            next_linear = next_component->LinearParams();
            Matrix<BaseFloat> next_linear_mat = next_linear.Mat();
            next_linear_mat.SetColZero(node_id);
            CuMatrix<BaseFloat> next_linear_new(next_linear.NumRows(),next_linear.NumCols());
            next_linear_new.CopyFromMat(next_linear_mat);
  
            CuVector<BaseFloat> next_bias = next_component->BiasParams();
            next_component->SetParams(next_bias.Vec(),next_linear_new.Mat());
          }
        }
      }

      WriteKaldiObject(nnet_orig, new_raw_str, binary_write);

    } 
    
    
    return 0;
  } catch(const std::exception &e) {
    std::cerr << e.what() << '\n';
    return -1;
  }
}


/*
Test script:

cat <<EOF | nnet3-init --binary=false - foo.raw
component name=affine1 type=NaturalGradientAffineComponentWithFixedZero input-dim=72 output-dim=59
component name=relu1 type=RectifiedLinearComponent dim=59
component name=final_affine type=NaturalGradientAffineComponentWithFixedZero input-dim=59 output-dim=298
component name=logsoftmax type=SoftmaxComponent dim=298
input-node name=input dim=18
component-node name=affine1_node component=affine1 input=Append(Offset(input, -4), Offset(input, -3), Offset(input, -2), Offset(input, 0))
component-node name=nonlin1 component=relu1 input=affine1_node
component-node name=final_affine component=final_affine input=nonlin1
component-node name=output_nonlin component=logsoftmax input=final_affine
output-node name=output input=output_nonlin
EOF

cat <<EOF | nnet3-init --binary=false foo.raw -  bar.raw
component name=affine2 type=NaturalGradientAffineComponentWithFixedZero input-dim=59 output-dim=59
component name=relu2 type=RectifiedLinearComponent dim=59
component name=final_affine type=NaturalGradientAffineComponentWithFixedZero input-dim=59 output-dim=298
component-node name=affine2 component=affine2 input=nonlin1
component-node name=relu2 component=relu2 input=affine2
component-node name=final_affine component=final_affine input=relu2
EOF

rm foo.raw bar.raw

 */
