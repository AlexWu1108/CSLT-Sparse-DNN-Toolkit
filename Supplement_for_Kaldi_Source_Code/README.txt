This is a folder containing source files of commands based on Kaldi ASR toolkit. This Kaldi-based Command will help you to implement sparse deep neural networks based on Kaldi. To use the source files correctly, you should follow the steps below:

1. add the code in src/nnet3 into the corresponding files in your Kaldi tookit (instead of just copying the files to the corresponding paths), and compile it.

2. copy the files in src/nnet3bin to the corresponding folder in your Kaldi toolkit, add the names of those command in 'Makefile', and compile it.

The introduction and the usage of the Kaldi-based Command is covered by CSLT Technical Report 20170002, 20170003, 20170004 written by Yanqing Wang, Zhiyuan Tang and Dong Wang. You can read them to get aware of our previous work and the detailed information of the Kaldi-based Commands.
