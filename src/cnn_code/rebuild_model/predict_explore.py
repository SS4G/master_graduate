import h5py
import numpy as np
from keras.models import Sequential, load_model
import pickle
from keras.layers import Dense,Flatten,Conv2D,MaxPool2D
from keras.optimizers import SGD
from keras.utils import to_categorical
import os
import sys

if __name__ == "__main__":
    model = load_model('data/lenet5_relu_model.h5')
    f = open("data/jpgs_np_arrays_dataset.pickle", "rb")
    dataset = pickle.load(f)
    f.close()

    train_x = dataset["train_x"]
    train_y = dataset["train_y"]
    test_x = dataset["test_x"]
    test_y = dataset["test_y"]

    print(train_x.shape, test_x.shape)
    print(train_y.shape, test_y.shape)

    score_train = model.evaluate(train_x, train_y)[1] # 第二位置为准确率
    score_test = model.evaluate(test_x, test_y)[1]
    print("train_score:{0}".format(score_train))
    print("test_score:{0}".format(score_test))
