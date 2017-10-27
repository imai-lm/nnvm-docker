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
COPY CMakeLists.txt /workspace/nnvm/tvm/
RUN cd /workspace/nnvm/tvm; make
RUN export PYTHONPATH=/path/to/tvm/python:/path/to/tvm/topi/python:${PYTHONPATH}; \
  echo 'export PYTHONPATH=/path/to/tvm/python:/path/to/tvm/topi/python:${PYTHONPATH}' >> ~/.bashrc
RUN cd /workspace/nnvm/tvm/python; python setup.py install --user
RUN cd /workspace/nnvm/tvm/topi/python; python setup.py install --user

# onnx
RUN apt install protobuf-compiler libprotobuf-dev -y
RUN pip install onnx
#RUN cd workspace; git clone --recursive https://github.com/onnx/onnx.git
#RUN cd /workspace/onnx; \
#  git checkout tags/v0.2; \
#  python setup.py install

# pytorch
RUN apt update
RUN apt install cmake -y
RUN cd workspace; \
  git clone https://github.com/xianyi/OpenBLAS
RUN cd /workspace/OpenBLAS; \
  make NO_AFFINITY=1 USE_OPENMP=1; make PREFIX=/opt/OpenBLAS install
RUN export LD_LIBRARY_PATH=/opt/OpenBLAS/lib=$LD_LIBRARY_PATH; \
  echo 'export LD_LIBRARY_PATH=/opt/OpenBLAS/lib:$LD_LIBRARY_PATH;' >> ~/.bashrc
RUN pip install pyyaml
RUN cd workspace; \
  git clone --recursive https://github.com/pytorch/pytorch
RUN cd /workspace/pytorch; \
  export CMAKE_LIBRARY_PATH=/opt/OpenBLAS/include:/opt/OpenBLAS/lib:$CMAKE_LIBRARY_PATH; \
  python setup.py install
RUN pip install torchvision

# mxnet
RUN pip install mxnet==0.11.0
RUN apt install graphviz -y
RUN pip install mxnet-mkl==0.11.0

# test
RUN mkdir /workspace/test
COPY import.py /workspace/test
COPY export.py /workspace/test
