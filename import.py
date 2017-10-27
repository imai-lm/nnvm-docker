import numpy as np
import nnvm
import nnvm.compiler
import onnx
import tvm
from tvm.contrib import graph_runtime, util


model = onnx.load('alexnet.proto')
sym, params = nnvm.frontend.from_onnx(model)

target = 'llvm'
# shape_dict = {'data': (1,1)}
graph, lib, params = nnvm.compiler.build(sym, target, params=params, dtype="float32")
module = graph_runtime.create(graph, lib, tvm.cpu(0))

lib.export_library("deploy.dylib")
with open("deploy.json", "w") as fo:
    fo.write(graph.json())
with open("deploy.params", "wb") as fo:
    fo.write(nnvm.compiler.save_param_dict(params))
