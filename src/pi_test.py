import numpy as np
import pickle
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
    return max(x)

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
    
if __name__ == "__main__":
    objs = pickle.load(open("test_imgs2.pickle", "rb"))
    weights = objs[2]
    train_x = objs[0]
    train_y = objs[1]
    for idx, oneImg in enumerate(imgs):
        tmp_img = conv2DLayer(oneImg, weights["conv1_k"], weights["conv1_b"], activeFunc=relu)
        tmp_img = maxPool2DLayer(tmp_img, (2, 2))
        tmp_img = conv2DLayer(tmp_img, weights["conv2_k"], np.array(weights["conv2_b"], activeFunc=relu)
        tmp_img = maxPool2DLayer(tmp_img, (2, 2))
        tmp_img = flattenLayer(tmp_img)
        tmp_img = denseLayer(tmp_img, kernal=weights["dense1_k"]), bias=np.array(weights["dense1_b"]))
        tmp_img = denseLayer(tmp_img, kernal=weights["dense2_k"]), bias=np.array(weights["dense2_b"]))
        tmp_img = denseLayer(tmp_img, kernal=weights["dense3_k"]), bias=np.array(weights["dense3_b"]), activeFunc=softmax)
        

