FROM ubuntu
MAINTAINER imai@leapmind.io

RUN apt update
RUN apt install g++ make python3.5-dev python3-setuptools curl git -y
RUN ln -s /usr/bin/python3.5 /usr/bin/python
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python
RUN mkdir workspace

# nnvm
RUN pip install numpy scipy
RUN cd workspace; \
  git clone --recursive https://github.com/dmlc/nnvm
RUN cd workspace/nnvm; make
RUN export PYTHONPATH=/workspace/nnvm/python:${PYTHONPATH}; \
  echo 'export PYTHONPATH=/workspace/nnvm/python:${PYTHONPATH}' >> ~/.bashrc
RUN cd workspace/nnvm/python; python setup.py install --user

# tvm
RUN apt install libtinfo-dev zlib1g-dev llvm -y
RUN cd /workspace/nnvm/tvm; make
RUN export PYTHONPATH=/path/to/tvm/python:/path/to/tvm/topi/python:${PYTHONPATH}; \
  echo 'export PYTHONPATH=/path/to/tvm/python:/path/to/tvm/topi/python:${PYTHONPATH}' >> ~/.bashrc
RUN cd /workspace/nnvm/tvm/python; python setup.py install --user
RUN cd /workspace/nnvm/tvm/topi/python; python setup.py install --user

# onnx
RUN apt install protobuf-compiler libprotobuf-dev -y
RUN pip install onnx

# pytorch
RUN pip install git+https://github.com/pytorch/pytorch
RUN pip install torchvision

# mxnet
RUN pip install mxnet==0.11.0
RUN apt install graphviz -y
RUN pip install mxnet-mkl==0.11.0
