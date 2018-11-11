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
    return np.maximum(mat, 0) # elemenwise

def conv(src, kernal):
    """
    计算两个大小相同的矩阵的对应位置的乘积并求和
    :param src: (row, col, depth)
    :param kernal: (row, col, depth)
    :return:
    """
    assert len(src.shape) == 3 and len(kernal.shape) == 3 and src.shape == kernal.shape, "src shape invalid"
    return (src * kernal).sum() # 两个三维矩阵对应位置的元素逐个求乘积 最后求和

def conv2d(src, kernal):
    """
    要求原始图像和 卷积核 深度相同
    :param src: (row, col, depth)
    :param kernal: (row, col, depth)
    :return:
    """
    srcShape = src.shape
    kernalShape = kernal.shape

    # 形状匹配验证
    assert len(kernalShape) == 3 and \
           len(srcShape) == 3 and \
           srcShape[0] >= kernalShape[0] and \
           srcShape[1] >= kernalShape[1] and \
           srcShape[2] == kernalShape[2], "kernal shape invalid"


    resultRows = srcShape[0] - kernalShape[0] + 1
    resultCols = srcShape[1] - kernalShape[1] + 1
    resMat = np.zeros((resultRows, resultCols), dtype=np.float64)
    for rStart in range(resultRows):
        for cStart in range(resultCols):
            oneSrc = src[rStart: rStart + kernalShape[0], cStart: cStart+ kernalShape[1]]
            resMat[rStart][cStart] = conv(oneSrc, kernal)
    return resMat

def maxPool2D(src, windowSize=(2, 2)):
    """
    :param src: (row, col, depth)
    :param size:
    :return: (row, col, depth)
    """
    assert len(windowSize) == 2, "invalid size"
    rowShape = src.shape[0]
    colShape = src.shape[1]

    for r in range(0, rowShape, windowSize[0]):
        for c in range(0, colShape, windowSize[1]):


def conv2DLayer(src, kernal, bias, activeFunc=relu):
    kernals = [kernal[:, :, :, i] for i in range(kernal.shape[3])]
    res = []
    for oneKernal, oneBias in zip(kernals, bias):
        res.append(activeFunc(conv2d(src, oneKernal) + oneBias))
    return np.stack(res, axis=-1)

def getDiff(mat1, mat2):
    assert mat1.shape == mat2.shape, "two array shape should be same"
    return abs(mat1 - mat2).sum()

def

if __name__ == "__main__":
    #载入模型文件
    dataPath = "/home/szh-920/workspace/master_graduate/data"
    all_model = load_model('{0}/models/lenet_relu_model_all.hdf5'.format(dataPath))
    with h5py.File("{0}/data_set/dataSet.hdf5".format(dataPath), "r") as data_f:
        train_x = data_f["/train_x"]
        train_y = data_f["/train_y"]
        print(type(train_x))
        print(type(train_y))
        oneImg = np.array(train_x)[1]
    conv2d_1_Model = load_model("{0}/models/layer0_conv2d_1.hdf5".format(dataPath))
    conv2d_1_layer_ModelOutput = conv2d_1_Model.predict(np.array([oneImg]))

    print(conv2d_1_layer_ModelOutput.shape)




    #conv2d_1_layer_model_output = conv2d_1_layer_model.predict(test_imgs)
    #kernals, bias = layers["conv2d_1"].get_weights()





