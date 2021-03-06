// nnet3bin/nnet3-init.cc

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

    const char *usage =
        "Add 2 nnet (only linear_params_ of each affine).\n"
        "note: biases are averaged.\n"
        "Usage:  nnet3-init [options] <raw-nnet-1> <raw-nnet-2> <raw-nnet-out>\n"
        "e.g.:\n"
        " nnet3-init --binary=false all_layer.config nnet_1.raw nnet_2.raw new.raw\n";

    bool binary_write = false;
    int32 srand_seed = 0;

    ParseOptions po(usage);
    po.Register("binary", &binary_write, "Write output in binary mode");
    po.Register("srand", &srand_seed, "Seed for random number generator");

    po.Read(argc, argv);
    srand(srand_seed);

    if (po.NumArgs() != 4) {
      po.PrintUsage();
      exit(1);
    }

    std::string config_rxfilename = po.GetArg(1);
    std::string nnet_1_rxfilename = po.GetArg(2);
    std::string nnet_2_rxfilename = po.GetArg(3); 
    std::string new_nnet_wxfilename = po.GetArg(4);

    Nnet nnet_1;
    Nnet nnet_2;
    Nnet nnet_new;

    ReadKaldiObject(nnet_1_rxfilename, &nnet_1); 
    ReadKaldiObject(nnet_2_rxfilename, &nnet_2); 
    KALDI_LOG << "Read raw neural nets";

    // use config to init nnet
    {
      bool binary;
      Input ki(config_rxfilename, &binary);
      KALDI_ASSERT(!binary && "Expect config file to contain text.");
      nnet_new.ReadConfig(ki.Stream());
    }

    // mask the nnet
    for(int x = 1; x <= 19; x+=3) {
      // calc the mask
      CuMatrix<BaseFloat> linear_1 = static_cast<AffineComponent *>(nnet_1.GetComponent(x))->LinearParams();
      CuMatrix<BaseFloat> linear_2 = static_cast<AffineComponent *>(nnet_2.GetComponent(x))->LinearParams();
      CuVector<BaseFloat> bias_1 = static_cast<AffineComponent *>(nnet_1.GetComponent(x))->BiasParams();
      CuVector<BaseFloat> bias_2 = static_cast<AffineComponent *>(nnet_2.GetComponent(x))->BiasParams();
  
      AffineComponent* this_component = static_cast<AffineComponent *>(nnet_new.GetComponent(x));
      linear_1.AddMat(1.0, linear_2);
      bias_1.AddVec(1.0,bias_2);
  
      //CuMatrix<BaseFloat> mat_constant(linear_1.NumRows(),linear_1.NumCols());
      //mat_constant.Set(0.5);
      //linear_1.MulElements(mat_constant);

      CuVector<BaseFloat> bias_constant(bias_1.Dim());
      bias_constant.Set(0.5);
      bias_1.MulElements(bias_constant);
 
      this_component->SetParams(bias_1.Vec(),linear_1.Mat());
    } 
    //std::vector<std::string> names = nnet.GetComponentNames(); 
    //std::ofstream ofile("/work7/wangyanqing/names");
    //ofile<<names;
    //ofile.close();
    
    // write the nnet
    WriteKaldiObject(nnet_new, new_nnet_wxfilename, binary_write);
    KALDI_LOG << "Initialized raw neural net and wrote it to "
              << new_nnet_wxfilename;
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
