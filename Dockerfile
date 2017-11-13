FROM ubuntu
MAINTAINER imai@leapmind.io

# common
RUN apt update
RUN apt install g++ make python3.5-dev python3-setuptools curl git -y
RUN ln -s /usr/bin/python3.5 /usr/bin/python
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python
RUN pip install setuptools
RUN mkdir workspace

# utility
RUN apt install vim ssh -y

# tvm / nnvm
RUN apt install xz-utils -y
RUN pip install numpy scipy
RUN mkdir /workspace/llvm
RUN wget http://releases.llvm.org/5.0.0/clang+llvm-5.0.0-linux-x86_64-ubuntu16.04.tar.xz -O /workspace/llvm/llvm.tar.xz
RUN cd /workspace/llvm/; tar Jxf /workspace/llvm/llvm.tar.xz -C /workspace/llvm; \
  cp -pr /workspace/llvm/clang+llvm-5.0.0-linux-x86_64-ubuntu16.04/* /usr/local
RUN apt install cmake libblas-dev liblapack-dev libtinfo-dev libz-dev -y
RUN cd workspace; \
  git clone --recursive https://github.com/dmlc/nnvm
COPY config.mk /workspace/nnvm/tvm/make
RUN cd /workspace/nnvm/tvm; make
RUN export PYTHONPATH=/workspace/nnvm/tvm/python:/workspace/nnvm/tvm/topi/python:${PYTHONPATH}; \
  echo 'export PYTHONPATH=/workspace/nnvm/tvm/python:/workspace/nnvm/tvm/topi/python:${PYTHONPATH}' >> ~/.bashrc
RUN cd /workspace/nnvm/tvm/python; python setup.py install --user
RUN cd workspace/nnvm; make
RUN export PYTHONPATH=/workspace/nnvm/python:${PYTHONPATH}; \
  echo 'export PYTHONPATH=/workspace/nnvm/python:${PYTHONPATH}' >> ~/.bashrc
RUN cd workspace/nnvm/python; python setup.py install --user

# tvm
#RUN apt install libtinfo-dev zlib1g-dev llvm -y
#RUN cd /workspace/nnvm/tvm/topi/python; python setup.py install --user

# onnx
RUN apt install protobuf-compiler libprotobuf-dev -y
RUN pip install onnx==0.2.0
#RUN cd workspace; git clone --recursive https://github.com/onnx/onnx.git
#RUN cd /workspace/onnx; \
#  git checkout tags/v0.2; \
#  python setup.py install

# pytorch
RUN pip install pyyaml
RUN cd workspace; \
  git clone --recursive https://github.com/pytorch/pytorch
RUN cd /workspace/pytorch; \
  python setup.py install
# RUN pip install http://download.pytorch.org/whl/cu75/torch-0.2.0.post3-cp35-cp35m-manylinux1_x86_64.whl
RUN pip install torchvision

# mxnet
RUN pip install mxnet==0.11.0
RUN apt install graphviz -y
RUN pip install mxnet-mkl==0.11.0

# test
RUN mkdir /workspace/test
COPY import.py /workspace/test
COPY export.py /workspace/test
