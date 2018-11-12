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

def softmax(x):
    return np.exp(x) / np.sum(np.exp(x), axis=0)

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
    针对一个图像和 一个卷积核做卷积
    要求原始图像和 卷积核 深度相同
    :param src: (row, col, depth)
    :param kernal: (row, col, depth)
    :return:
    """
    srcShape = src.shape
    kernalShape = kernal.shape

    # 形状匹配验证

    #ColorLogging.debug("src {0} ker {1}".format(srcShape, kernalShape))

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

def conv2DLayer(src, kernalData, bias, activeFunc=relu):
    """
    包含有多个卷积核的卷积层
    :param src:
    :param kernalData: (row, col, depth, which_kernal)
    :param bias: 每个卷积核对应的偏置
    :param activeFunc:
    :return:
    """
    # 将kernalList数据 按照所属kernal拆分成list
    assert len(kernalData.shape) == 4, "卷积核数据尺寸不合适"

    kernalAmount = kernalData.shape[3]

    assert kernalAmount == bias.shape[0], "卷积核和个数和 偏置数量不对应"

    kernalList = [kernalData[...,i] for i in range(kernalAmount)]

    res = []
    for oneKernal, oneBias in zip(kernalList, bias):
        res.append(activeFunc(conv2d(src, oneKernal) + oneBias))
    return np.stack(res, axis=-1)

def maxPool2DLayer(src, windowSize=(2, 2)):
    """
    :param src: (row, col, depth)
    :param size:
    :return: (row, col, depth)
    """
    assert len(windowSize) == 2, "invalid size"

    depthShape = src.shape[2]
    rowStride = windowSize[0]
    colStride = windowSize[1]

    rowShape = src.shape[0] - (src.shape[0] % rowStride)
    colShape = src.shape[1] - (src.shape[1] % colStride)
    #ColorLogging.error("{0} {1}".format(rowShape, colShape))

    res = np.zeros((rowShape // rowStride, colShape // colStride, depthShape))
    #ColorLogging.debug("res.shape {0}".format(res.shape))
    for r in range(0, rowShape, rowStride):
        for c in range(0, colShape, colStride):
            #ColorLogging.debug("r {0} c {1}".format(r, c))
            arrays = np.split(src[r : r + rowStride, c : c + colStride, :], indices_or_sections=depthShape, axis=2)
            onePoolResult = np.array([np.max(arr) for arr in arrays])
            assert res[r // 2][c // 2].shape == onePoolResult.shape, "res[r][c] shape {0} onePoolResult shape {1}".format(res[r // 2][c // 2].shape, onePoolResult.shape)
            res[r // 2][c // 2] = onePoolResult
    return res

def flattenLayer(src):
    assert len(src.shape) == 3, "数据应该是3维"
    return src.reshape((src.shape[0] * src.shape[1] * src.shape[2],))



def denseLayer(src, kernal, bias, activeFunc=relu):
    """
    :param src:
    :param kernal:
    :param bias:
    :return:
    """
    assert kernal.shape[1] == bias.shape[0]
    return activeFunc(kernal.T.dot(src) + bias)


def myModel(imgs, weightsHDF5, recordHDF5File):
    """
    :param oneImg: image_Mat
    :param weightsHDF5: 模型的HDF5对象包含
    :param recordHDF5File:
    :return:
    """

    weights = weightsHDF5

    #weights.visit(ColorLogging.critical)

    layerOutputFile = h5py.File(recordHDF5File, "w")
    output = [[] for i in range(8)]
    for idx, oneImg in enumerate(imgs):
        output[0].append(conv2DLayer(oneImg, np.array(weights["conv2d_1/conv2d_1/kernel:0"]), np.array(weights["conv2d_1/conv2d_1/bias:0"]), activeFunc=relu))
        output[1].append(maxPool2DLayer(output[0][idx], (2, 2)))
        output[2].append(   conv2DLayer(output[1][idx], np.array(weights["conv2d_2/conv2d_2/kernel:0"]), np.array(weights["conv2d_2/conv2d_2/bias:0"]), activeFunc=relu))
        output[3].append(maxPool2DLayer(output[2][idx], (2, 2)))
        output[4].append(  flattenLayer(output[3][idx]))
        output[5].append(    denseLayer(output[4][idx], kernal=np.array(weights["dense_1/dense_1/kernel:0"]), bias=np.array(weights["dense_1/dense_1/bias:0"])))
        output[6].append(    denseLayer(output[5][idx], kernal=np.array(weights["dense_2/dense_2/kernel:0"]), bias=np.array(weights["dense_2/dense_2/bias:0"])))
        output[7].append(    denseLayer(output[6][idx], kernal=np.array(weights["dense_3/dense_3/kernel:0"]), bias=np.array(weights["dense_3/dense_3/bias:0"]), activeFunc=softmax))
    layerOutputFile.create_dataset("conv_2d_1_output", data=np.array(output[0]))
    layerOutputFile.create_dataset("pool_2d_1_output", data=np.array(output[1]))
    layerOutputFile.create_dataset("conv_2d_2_output", data=np.array(output[2]))
    layerOutputFile.create_dataset("pool_2d_2_output", data=np.array(output[3]))
    layerOutputFile.create_dataset("flatten_1_output", data=np.array(output[4]))
    layerOutputFile.create_dataset("dense___1_output", data=np.array(output[5]))
    layerOutputFile.create_dataset("dense___2_output", data=np.array(output[6]))
    layerOutputFile.create_dataset("dense___3_output", data=np.array(output[7]))
    layerOutputFile.close()


if __name__ == "__main__":
    #载入模型文件
    dataPath = "/home/szh-920/workspace/master_graduate/data"
    all_model = load_model('{0}/models/lenet_relu_model_all.hdf5'.format(dataPath))
    with h5py.File("{0}/data_set/dataSet.hdf5".format(dataPath), "r") as data_f:
        train_x = data_f["/train_x"]
        train_y = data_f["/train_y"]
        print(type(train_x))
        print(type(train_y))
        imgs = np.array(train_x)[1:10]

    #flatten_1 = all_model.get_layer("flatten_1")
    #layerf_Model = Model(inputs=all_model.input, outputs=flatten_1.output)
    #layerf_Model.save("{0}/models/layer4_flatten_1.hdf5".format(dataPath))

    layer0_Model = load_model("{0}/models/layer0_conv2d_1.hdf5".format(dataPath))
    layer1_Model = load_model("{0}/models/layer1_max_pooling2d_1.hdf5".format(dataPath))
    layer2_Model = load_model("{0}/models/layer2_conv2d_2.hdf5".format(dataPath))
    layer3_Model = load_model("{0}/models/layer3_max_pooling2d_2.hdf5".format(dataPath))
    layer4_Model = load_model("{0}/models/layer4_flatten_1.hdf5".format(dataPath))
    layer5_Model = load_model("{0}/models/layer5_dense_1.hdf5".format(dataPath))
    layer6_Model = load_model("{0}/models/layer6_dense_2.hdf5".format(dataPath))
    layer7_Model = load_model("{0}/models/layer7_dense_3.hdf5".format(dataPath))

    layeri_ModelOutput = imgs
    layer0_ModelOutput = layer0_Model.predict(imgs)
    layer1_ModelOutput = layer1_Model.predict(imgs)
    layer2_ModelOutput = layer2_Model.predict(imgs)
    layer3_ModelOutput = layer3_Model.predict(imgs)
    layer4_ModelOutput = layer4_Model.predict(imgs)
    layer5_ModelOutput = layer5_Model.predict(imgs)
    layer6_ModelOutput = layer6_Model.predict(imgs)
    layer7_ModelOutput = layer7_Model.predict(imgs)

    ColorLogging.info("layeri_ModelOutput shape {0}".format(layeri_ModelOutput.shape))
    ColorLogging.info("layer0_ModelOutput shape {0}".format(layer0_ModelOutput.shape))
    ColorLogging.info("layer1_ModelOutput shape {0}".format(layer1_ModelOutput.shape))
    ColorLogging.info("layer2_ModelOutput shape {0}".format(layer2_ModelOutput.shape))
    ColorLogging.info("layer3_ModelOutput shape {0}".format(layer3_ModelOutput.shape))
    ColorLogging.info("layer4_ModelOutput shape {0}".format(layer4_ModelOutput.shape))
    ColorLogging.info("layer5_ModelOutput shape {0}".format(layer5_ModelOutput.shape))
    ColorLogging.info("layer6_ModelOutput shape {0}".format(layer6_ModelOutput.shape))
    ColorLogging.info("layer7_ModelOutput shape {0}".format(layer7_ModelOutput.shape))

    with h5py.File("{0}/model_output/keras_model_output.hdf5".format(dataPath), "w") as f:
        f.create_dataset("conv_2d_1_output", data=layer0_ModelOutput)
        f.create_dataset("pool_2d_1_output", data=layer1_ModelOutput)
        f.create_dataset("conv_2d_2_output", data=layer2_ModelOutput)
        f.create_dataset("pool_2d_2_output", data=layer3_ModelOutput)
        f.create_dataset("flatten_1_output", data=layer4_ModelOutput)
        f.create_dataset("dense___1_output", data=layer5_ModelOutput)
        f.create_dataset("dense___2_output", data=layer6_ModelOutput)
        f.create_dataset("dense___3_output", data=layer7_ModelOutput)

    with h5py.File('{0}/models/lenet_relu_model_all.hdf5'.format(dataPath), "r") as f:
        myModel(imgs, f["/model_weights"], "{0}/model_output/rebuild_model_output.hdf5".format(dataPath))

    #conv2d_1_layer_model_output = conv2d_1_layer_model.predict(test_imgs)
    #kernals, bias = layers["conv2d_1"].get_weights()





