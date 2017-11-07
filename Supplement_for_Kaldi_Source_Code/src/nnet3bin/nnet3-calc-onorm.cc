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
        "Calculate the onorm of each layer.\n"
        "\n"
        "Usage:\n"
        "e.g.:\n"
        " nnet3-calc-onorm orig.raw result_file\n";

    bool binary_write = true;
    int32 srand_seed = 0;

    ParseOptions po(usage);
    po.Register("binary", &binary_write, "Write output in binary mode");
    po.Register("srand", &srand_seed, "Seed for random number generator");

    po.Read(argc, argv);
    srand(srand_seed);

    if (po.NumArgs() != 2) {
      po.PrintUsage();
      exit(1);
    }

    std::string nnet_str = po.GetArg(1); // egs raw nnet
    std::string filename_str = po.GetArg(2); // orig raw nnet

    std::ofstream ofile(filename_str,std::ios::app);
    Nnet nnet;

    ReadKaldiObject(nnet_str, &nnet); // read orig
    KALDI_LOG << "Read raw neural net";

    //int layer_id = 0;
    for(int x = 1; x <= 19; x+=3) {

      AffineComponent* this_component = static_cast<AffineComponent *>(nnet.GetComponent(x));
      CuMatrix<BaseFloat> this_linear = this_component->LinearParams();
      this_linear.ApplyPowAbs(1);

      int node_num = this_linear.NumCols();
      int avg_num = this_linear.NumRows();

      double onorm_this_layer[MAX_NODE_NUM] = {0};
  
      for(int node_id=0; node_id < node_num; node_id++) {
        CuSubVector<BaseFloat> connection_node(this_linear,node_id);
        double onorm_this_node = (connection_node.Sum())/avg_num;
        onorm_this_layer[node_id] = onorm_this_node;
        ofile << onorm_this_layer[node_id] << " ";
        
      }
      
      ofile << "\n";

    } 
    
    ofile.close();
    //std::vector<std::string> names = nnet.GetComponentNames(); 
    //std::ofstream ofile("/work7/wangyanqing/names");
    //ofile<<names;
    //ofile.close();
    
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
