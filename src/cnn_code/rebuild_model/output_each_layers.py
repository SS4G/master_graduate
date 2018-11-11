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

class ColorLogging:
    """
        分级别答应不同颜色的日志
    """

    def __init__(self):
        pass

    @staticmethod
    def getTimeStr():
        import datetime as dt
        return dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    @staticmethod
    def colorStr(str0, color="yellow", highlight=True):
        """
        -------------------------------------------
        -------------------------------------------
        字体色     |       背景色     |      颜色描述
        -------------------------------------------
        30        |        40       |       黑色
        31        |        41       |       红色
        32        |        42       |       绿色
        33        |        43       |       黃色
        34        |        44       |       蓝色
        35        |        45       |       紫红色
        36        |        46       |       青蓝色
        37        |        47       |       白色
        -------------------------------------------
        :param info:
        :param color:
        :return:
        """
        colorStr = {
            "red":      '\033[{highlight};31;40m {str0} \033[0m',
            "green":    '\033[{highlight};32;40m {str0} \033[0m',
            "yellow":   '\033[{highlight};33;40m {str0} \033[0m',
            "blue":     '\033[{highlight};34;40m {str0} \033[0m',
            "purple":   '\033[{highlight};35;40m {str0} \033[0m',
            "greenblue":'\033[{highlight};36;40m {str0} \033[0m',
            "white":    '\033[{highlight};37;40m {str0} \033[0m',
        }

        return colorStr[color].format(highlight= 1 if highlight else 0, str0=str0)

    @staticmethod
    def debug(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="DEBUG", time=ColorLogging.getTimeStr(), info=info), color="blue"))

    @staticmethod
    def info(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="INFO", time=ColorLogging.getTimeStr(), info=info), color="green"))

    @staticmethod
    def warn(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="WARNING", time=ColorLogging.getTimeStr(), info=info), color="yellow"))

    @staticmethod
    def error(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="ERROR", time=ColorLogging.getTimeStr(), info=info), color="red"))

    @staticmethod
    def critical(info):
        if not isinstance(info, str):
            info = str(info)
        print(ColorLogging.colorStr("{level}: {time} {info}".format(level="CRITICAL", time=ColorLogging.getTimeStr(), info=info), color="purple"))


def relu(mat):
    return np.maximum(mat, 0)

def conv(src, kernal):
    """
    计算两个大小相同的矩阵的对应位置的乘积并求和
    :param src: (row, col, depth)
    :param kernal: (row, col, depth)
    :return:
    """
    return (src * kernal).sum()

def conv2d(src, kernal):
    srcShape = src.shape
    kernalShape = kernal.shape
    assert len(kernalShape) == 3, "kernal shape invalid"
    assert kernalShape[2] == srcShape[2], "source and kernal depth does not match"
    resultRows = srcShape[0] - kernalShape[0] + 1
    resultCols = srcShape[1] - kernalShape[1] + 1
    resMat = np.zeros((resultRows, resultCols), dtype=np.float64)
    for rStart in range(resultRows):
        for cStart in range(resultCols):
            srcs = src[rStart: rStart + kernalShape[0], cStart: cStart+ kernalShape[1]]
            resMat[rStart][cStart] = conv(srcs, kernal)
    return resMat

def maxPool2D(src, size=(2, 2)):
    assert len(size) == 2, "invalid size"


def conv2DLayer(src, kernal, bias, activeFunc=relu):
    kernals = [kernal[:, :, :, i] for i in range(kernal.shape[3])]
    res = []
    for oneKernal, oneBias in zip(kernals, bias):
        res.append(conv2d(src, oneKernal) + oneBias)
    return activeFunc(np.array(res))

def getDiff(mat1, mat2):
    assert mat1.shape == mat2.shape, "two array shape should be same"
    return abs(mat1 - mat2).sum()


if __name__ == "__main__":
    #载入模型文件
    model = load_model('data/models/lenet_relu_model_all.hdf5')

    #f = h5py.File("data/dataSet.hdf5", "r")

    conv2d_1_layer = model.get_layer("conv2d_1")
    max_pooling2d_1_layer = model.get_layer("max_pooling2d_1")
    conv2d_2_layer = model.get_layer("conv2d_2")
    max_pooling2d_2_layer = model.get_layer("max_pooling2d_2")
    dense_1_layer = model.get_layer("dense_1")
    dense_2_layer = model.get_layer("dense_2")
    dense_3_layer = model.get_layer("dense_3")

    conv2d_1_layer_model = Model(inputs=model.input, outputs=conv2d_1_layer.output)
    max_pooling2d_1_layer_model = Model(inputs=model.input, outputs=max_pooling2d_1_layer.output)
    conv2d_2_layer_model = Model(inputs=model.input, outputs=conv2d_2_layer.output)
    max_pooling2d_2_layer_model = Model(inputs=model.input, outputs=max_pooling2d_2_layer.output)
    dense_1_layer_model = Model(inputs=model.input, outputs=dense_1_layer.output)
    dense_2_layer_model = Model(inputs=model.input, outputs=dense_2_layer.output)
    dense_3_layer_model = Model(inputs=model.input, outputs=dense_3_layer.output)


    conv2d_1_layer_model.save("data/models/layer0_conv2d_1.hdf5")
    max_pooling2d_1_layer_model.save("data/models/layer1_max_pooling2d_1.hdf5")
    conv2d_2_layer_model.save("data/models/layer2_conv2d_2.hdf5")
    max_pooling2d_2_layer_model.save("data/models/layer3_max_pooling2d_2.hdf5")
    dense_1_layer_model.save("data/models/layer4_dense_1.hdf5")
    dense_2_layer_model.save("data/models/layer5_dense_2.hdf5")
    dense_3_layer_model.save("data/models/layer6_dense_3.hdf5")



    #conv2d_1_layer_model_output = conv2d_1_layer_model.predict(test_imgs)
    #max_pooling2d_1_layer_model_output = max_pooling2d_1_layer_model.predict(test_imgs)
    #conv2d_2_layer_model_output = conv2d_2_layer_model.predict(test_imgs)
    #max_pooling2d_2_layer_model_output = max_pooling2d_2_layer_model.predict(test_imgs)
    #dense_1_layer_model_output = dense_1_layer_model.predict(test_imgs)
    #dense_2_layer_model_output = dense_2_layer_model.predict(test_imgs)
    #dense_3_layer_model_output = dense_3_layer_model.predict(test_imgs)

    #ColorLogging.warn("l0- input_layer:          output shape {0}".format(test_imgs.shape))
    #ColorLogging.warn("l1- conv2d_1_layer        output shape {0}".format(conv2d_1_layer_model_output.shape))
    #ColorLogging.warn("l2- max_pooling2d_1_layer output shape {0}".format(max_pooling2d_1_layer_model_output.shape))
    #ColorLogging.warn("l3- conv2d_2_layer        output shape {0}".format(conv2d_2_layer_model_output.shape))
    #ColorLogging.warn("l4- max_pooling2d_2_layer output shape {0}".format(max_pooling2d_2_layer_model_output.shape))
    #ColorLogging.warn("l5- dense_1_layer         output shape {0}".format(dense_1_layer_model_output.shape))
    #ColorLogging.warn("l6- dense_2_layer         output shape {0}".format(dense_2_layer_model_output.shape))
    #ColorLogging.warn("l7- dense_3_layer         output shape {0}".format(dense_3_layer_model_output.shape))

    #output_mats = {}
    #output_mats["input"] = test_imgs
    #output_mats["conv2d_1"] = conv2d_1_layer_model_output
    #output_mats["max_pooling2d_1"] = max_pooling2d_1_layer_model_output
    #output_mats["conv2d_2"] = conv2d_2_layer_model_output
    #output_mats["max_pooling2d_2"] = max_pooling2d_2_layer_model_output
    #output_mats["dense_1_layer"] = dense_1_layer_model_output
    #output_mats["dense_2_layer"] = dense_2_layer_model_output
    #output_mats["dense_3_layer"] = dense_3_layer_model_output

    #layers = {}
    #layers["conv2d_1"] = conv2d_1_layer
    #layers["max_pooling2d_1"] = max_pooling2d_1_layer
    #layers["conv2d_2"] = conv2d_2_layer
    #layers["max_pooling2d_2"] = max_pooling2d_2_layer
    #layers["dense_1_layer"] = dense_1_layer
    #layers["dense_2_layer"] = dense_2_layer
    #layers["dense_3_layer"] = dense_3_layer

    # 保存中间结果的输出
    #with open("data/each_layer_output_mats.pickle", "wb") as f:
    #    pickle.dump(output_mats, f)

    #kernals, bias = layers["conv2d_1"].get_weights()
#
    #print(kernals.dtype)
    #print(bias.dtype)
#
    #print("bias shape: {0}".format(bias.shape))
    #print("kernals shape: {0}".format(kernals.shape))
#
    #my_conv_res = np.stack(conv2DLayer(test_imgs[0], kernals, bias), axis=2)
    #keras_res = output_mats["conv2d_1"][0]
    #print("my_conv_res shape: {0}".format(my_conv_res.shape))
    #print("keras conv_1 shape {0}".format(keras_res.shape))
#
    #print("------")
    #print(keras_res)
    #print("-----")
    #print(my_conv_res)


    #f.close()





