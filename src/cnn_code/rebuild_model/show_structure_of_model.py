import h5py
import numpy as np
from keras.models import Sequential
from keras.layers import Dense,Flatten,Conv2D,MaxPool2D
from keras.optimizers import SGD
from keras.utils import to_categorical
import os
import sys

def show_levels_of_hdf5(root_h5obj, indent=0, index='/', indent_str="    "):
    if hasattr(root_h5obj, 'keys'):
        keys = list(root_h5obj.keys())
        for key in keys:
            print(indent * indent_str + str(key))
            show_levels_of_hdf5(root_h5obj[key], indent + 1, index=index + key)
    else:
        print(indent * indent_str + "type :  " + str(type(root_h5obj)))
        print(indent * indent_str + "value:  " + str(root_h5obj))
        print(indent * indent_str + "index:  " + index)

if __name__ == "__main__":
    model = h5py.File("data/lenet5_relu_model.h5")
    sys.stdout = open("model_structure.txt", "w")
    show_levels_of_hdf5(model)
