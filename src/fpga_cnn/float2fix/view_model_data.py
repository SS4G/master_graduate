import h5py
import numpy as np
from keras.models import Sequential, load_model, Model
import pickle
from keras.layers import Dense,Flatten,Conv2D,MaxPool2D
from keras.optimizers import SGD
from keras.utils import to_categorical
import cv2
import os
import json
import sys
from functools import reduce

if __name__ == "__main__":
    #载入模型文件
    dataPath = "/home/szh-920/workspace/master_graduate/data"
    all_model = load_model('{0}/models/lenet_relu_model_all.hdf5'.format(dataPath))

    weights = all_model.get_weights()