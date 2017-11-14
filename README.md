[![Codecov](https://img.shields.io/badge/version-1.0-blue.svg?style=flat-square)]()  [![Codecov](https://img.shields.io/badge/build-passing-brightgreen.svg?style=flat-square)]()  [![Codecov](https://img.shields.io/badge/powered%20by-CSLT-green.svg?style=flat-square)]() 

![](icon/sparse_neural_network.jpg)

# CSDT: Sparse Deep Neural Network Toolkit

## Introduction

**CSLT Sparse DNN Tookit (CSDT)** is a toolkit for implementation and exploration of sparse deep neural networks in speech recogniton. It's built on [Kaldi](https://github.com/kaldi-asr/kaldi) Speech Recognition Toolkit and it's released for further research on sparse deep neural networks.

The toolkit is developed by Yanqing Wang, supervised by Dong Wang, at Center for Speech and Language Technologies, Research Institute of Information Technology, Tsinghua University.

Please note that the documentations will be pretty helpful for you to use the toolkits correctly.

## Structure

The tookit consists of 5 parts:

**CSLT Connection Sparseness Toolkit (CCST)**: a toolkit for implementation of connection sparseness of deep neural networks in speech recogniton based on Kaldi.

**CSLT Node Sparseness Tookit (CNST)**:  a toolkit for implementation of node sparseness of deep neural networks in speech recognition based on Kaldi.

**CSLT DNN Ensembling Tookit (CDET)**: a toolkit for making an ensemble of four deep neural networks (must in specified format).

**CSLT Exclusive DNN Tookit (CEDT)**: a toolkit for construction of four deep neural networks, whose structures are mutually exclusive and collectively exhaustive.

**Supplement to Kaldi Source Code**: a folder containing source files of commands based on Kaldi ASR toolkit. This Kaldi-based Command will help you to implement sparse deep neural networks based on Kaldi. To use the source files correctly, you should follow 'readme.txt' in that folder.

## Documentation

The introduction and the usage of the toolkit, CSDT, is covered by CSLT Technical Report 20170002, 20170003, 20170004 written by Yanqing Wang, Zhiyuan Tang and Dong Wang. You can read it to get aware of our previous work and the detailed information of CSLT Sparse DNN Tookit (CSDT).


## Contact

Yanqing Wang (wangyanqingchn@163.com)
