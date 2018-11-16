"""
- 该文件中的代码 processImage 实现了处理一张图片的功能 中间的处理结果会被写到对应的目录中
"""
import cv2
import numpy as np
import sys
import os
import tqdm
from functools import reduce
sys.path.append('/home/szh-920/workspace')

from master_graduate.logging import ColorLogging

def pathCheck(inputFile=None, inputPath=None, outputFile=None, outputPath=None):
    """
    检查输入文件是否存在 输出路径是否存在
    :return:
    """
    #输入文件要求存在而且不能是文件夹
    if inputFile is not None:
        if isinstance(inputFile, str):
            assert os.path.exists(inputFile) and os.path.isfile(inputFile), ColorLogging.colorStr("invalid input file or input not exists","red")
        elif isinstance(inputFile, list):
            assert all([os.path.exists(i) and os.path.isfile(i) for i in inputFile]), ColorLogging.colorStr("invalid input file or input not exists","red")
        elif isinstance(inputFile, dict):
            assert all([os.path.exists(i) and os.path.isfile(i) for i in inputFile.values()]), ColorLogging.colorStr("invalid input file or input not exists","red")

    #输入路径要求存在且是文件夹
    if inputPath is not None:
        if isinstance(inputPath, str):
            assert os.path.exists(inputPath) and os.path.isdir(inputPath), ColorLogging.colorStr("invalid input path or input not exists", "red")
        elif isinstance(inputPath, list):
            assert all([os.path.exists(i) and os.path.isdir(i) for i in inputPath]), ColorLogging.colorStr("invalid input path or input not exists", "red")
        elif isinstance(inputPath, dict):
            assert all([os.path.exists(i) and os.path.isdir(i) for i in inputPath.values()]), ColorLogging.colorStr("invalid path or input not exists", "red")

    if outputFile is not None:
        if isinstance(outputFile, str):
            outputFile = os.path.dirname(outputFile)
            assert os.path.exists(outputFile) and os.path.isdir(outputFile), ColorLogging.colorStr("invalid output path or output not exists", "red")
        elif isinstance(outputFile, list):
            outputFile = [os.path.dirname(i) for i in outputFile]
            assert all([os.path.exists(i) and os.path.isdir(i) for i in outputFile]), ColorLogging.colorStr("invalid output path or output not exists", "red")
        elif isinstance(outputFile, dict):
            outputFile = [os.path.dirname(i) for i in outputFile.values()]
            assert all([os.path.exists(i) and os.path.isdir(i) for i in outputFile]), ColorLogging.colorStr("invalid path or output not exists", "red")

    #输入路径要求存在且是文件夹
    if outputPath is not None:
        if isinstance(outputPath, str):
            assert os.path.exists(outputPath) and os.path.isdir(outputPath), ColorLogging.colorStr("invalid output path or output not exists", "red")
        elif isinstance(outputPath, list):
            assert all([os.path.exists(i) and os.path.isdir(i) for i in outputPath]), ColorLogging.colorStr("invalid output path or output not exists", "red")
        elif isinstance(outputPath, dict):
            assert all([os.path.exists(i) and os.path.isdir(i) for i in outputPath.values()]), ColorLogging.colorStr("invalid path or output not exists", "red")

def getMinRectangel(con):
    assert all([len(i.shape) == 2 for i in con]), ColorLogging.colorStr("invalid countors", "blue")

    con = np.concatenate(con, axis=0)

    x_max = np.max(con[:,0])
    x_min = np.min(con[:,0])
    y_max = np.max(con[:,1])
    y_min = np.min(con[:,1])
    return np.array([[x_min, y_max], [x_min, y_min], [x_max, y_min], [x_max, y_max],])

def processImage(imgFile, outputPaths):
    """
    :param imgFile: 单个的图片文件路径
    :param outputPaths: 输出路径组 分别将图片输出到不同的路径
    :param logOpen: 是否打开日志输出 默认关闭
    :return:
    """
    # 二值化门限设定
    BINARY_THRESOLD = 100 # 二值化门限
    AREA_THRESOLD = 800   # 面积过滤门限
    LEFT_SCALE = 0.7      # 比例过滤下限
    RIGHT_SCALE = 1.3     # 比例过滤上限
    DILATE_ITERATION = 5  # 膨胀操作迭代数
    ERODE_ITERATION = 1   # 腐蚀操作迭代数

    # HSV阈值参数设定
    # HSV值域 H[0,180] s[0, 255] v[0, 255]
    # blue      H[97.5, 117.5]      S[64, 255]      V[38, 255]
    # red       H[0, 10]U[170, 180] S[26, 255]      V[38, 255]
    # yellow    H[12, 32]           S[69, 255]      V[38, 255]

    blue_lower = np.array([97, 50, 38])
    blue_upper = np.array([120, 255, 255])

    #fake red0
    #red_lower0 = np.array([97, 50, 38])
    #red_upper0 = np.array([120, 255, 255])
    # fake red1
    #red_lower1 = np.array([97, 50, 38])
    #red_upper1 = np.array([120, 255, 255])

    red_lower0 = np.array([0, 26, 38])
    red_upper0 = np.array([3, 255, 255])
    #
    red_lower1 = np.array([175, 26, 38])
    red_upper1 = np.array([179, 255, 255])

    yellow_lower = np.array([12, 69, 38])
    yellow_upper = np.array([32, 255, 255])

    # 预先检查各类路径是否合理
    imgId = os.path.basename(imgFile).split(".")[0]

    #加载原图
    img = cv2.imread(imgFile)
    #cv2.imwrite('./imgs/00_img.jpg',img)

    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['01_hsv'].rstrip('/'), imgId), hsv)

    # 提取蓝色区域
    mask_blue = cv2.inRange(hsv, blue_lower, blue_upper)
    #cv2.imwrite("{0}/{1}.jpg".format(outputPaths['02_0_blue_mask'].rstrip('/'), imgId), mask_blue)
    # 提取红色区域
    mask_red0 = cv2.inRange(hsv, red_lower0, red_upper0)
    mask_red1 = cv2.inRange(hsv, red_lower1, red_upper1)
    func_or = np.frompyfunc(lambda x, y: 255 if x > 0 or y > 0 else 0, 2, 1)

    mask_red = func_or(mask_red0, mask_red1).astype(np.uint8)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['02_1_red_mask'].rstrip('/'), imgId), mask_red)
    # 提取黄色区域
    mask_yellow = cv2.inRange(hsv,yellow_lower, yellow_upper)
    #cv2.imwrite("{0}/{1}.jpg".format(outputPaths['02_2_yellow_mask'].rstrip('/'), imgId), mask_yellow)
    # 将所有过滤出来的区域求和 然后统一处理
    # 求或函数 如果任意一值 大于0 那么最后值为255
    #mask_added = np.minimum(reduce(func_or, [mask_blue, mask_yellow, mask_red,]), 255)
    mask_added = np.minimum(reduce(func_or, [mask_red,]), 255)
    mask_added = mask_added.astype(np.uint8)

    #模糊
    blurred=cv2.blur(mask_added, (9,9))
    #cv2.imwrite("{0}/{1}.jpg".format(outputPaths['03_blur'].rstrip('/'), imgId), blurred)
    #二值化
    ret,binary=cv2.threshold(blurred, BINARY_THRESOLD, 255, cv2.THRESH_BINARY)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['04_binary'].rstrip('/'), imgId), binary)

    # 使区域闭合无空隙
    # 创建一个闭合空间的算子
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (21, 7))

    closed = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['05_closed'].rstrip('/'), imgId), closed)

    #腐蚀和膨胀
    '''
    腐蚀操作将会腐蚀图像中白色像素，以此来消除小斑点，
    而膨胀操作将使剩余的白色像素扩张并重新增长回去。
    '''
    erode=cv2.erode(closed,None,iterations=ERODE_ITERATION)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['06_erode'].rstrip('/'), imgId), erode)
    dilate=cv2.dilate(erode,None,iterations=DILATE_ITERATION)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['07_dilated'].rstrip('/'), imgId), dilate)

    # 查找轮廓
    image, contours, hierarchy=cv2.findContours(dilate.copy(), cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)

    res = img.copy()
    for conIdx, con in enumerate(contours):
        #轮廓转换为矩形 返回的对象是(中心点, 长宽, 旋转角)
        rect=cv2.minAreaRect(con)
        #矩形转换为box
        # box是裁剪出来的矩形的四个定点的坐标 使用np.int0 取整数
        #box_0 = np.uint64(cv2.boxPoints(rect))

        box = np.uint64(getMinRectangel(con))

        #计算矩形的行列的边界

        height = box[0][1] - box[1][1]
        width = box[3][0] - box[0][0]

        #if abs(h1 - h2) / abs(l1 - l2)
        #在原图画出目标区域
        #cv2.drawContours 参数 (目标图像, 轮廓点集组)
        if width > 0 and height > 0 and LEFT_SCALE < float(height) / width < RIGHT_SCALE and height * width > AREA_THRESOLD:
            cv2.drawContours(res,[box],-1,(0,0,255),2)
        #cv2.drawContours(res, con, -1, (0, 255, 0), 2)

    #显示画了标志的原图
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['08_signed_img'].rstrip('/'), imgId) ,res)

def processImages(srcImagePath, outputBasePath, subsample=None):
    """
    这个函数中的 路径组
    :param subsample 如果是一个整数 N 那么表示均匀按照顺序抽样 1/N
    :param srcImagePath:
    :param outputBasePaths: 中间结果帧的输出目录
    :return:
    """
    assert not os.path.exists(outputBasePath), ColorLogging.colorStr("processed output base path {0} alreay exists".format(outputBasePath), "red")
    os.makedirs(outputBasePath)
    pathCheck(inputPath=srcImagePath, outputPath=outputBasePath)
    
    videoFramePaths = {
        "01_hsv":           "{0}/01_hsv".format(outputBasePath),
        #"02_0_blue_mask":   "{0}/02_0_blue_mask".format(outputBasePath),
        "02_1_red_mask":    "{0}/02_1_red_mask".format(outputBasePath),
        #"02_2_yellow_mask": "{0}/02_2_yellow_mask".format(outputBasePath),
        #"03_blur":          "{0}/03_blur".format(outputBasePath),
        "04_binary":        "{0}/04_binary".format(outputBasePath),
        "05_closed":        "{0}/05_closed".format(outputBasePath),
        "06_erode":         "{0}/06_erode".format(outputBasePath),
        "07_dilated":       "{0}/07_dilated".format(outputBasePath),
        "08_signed_img":    "{0}/08_signed_img".format(outputBasePath),
        #"09_sign":          "{0}/09_sign".format(outputBasePath),
    }

    for dir in videoFramePaths.values():
        ColorLogging.info("create folder {0}".format(dir))
        os.makedirs(dir)

    idx = 0
    for img in tqdm.tqdm(sorted(os.listdir(srcImagePath))):
        idx += 1
        if subsample is not None and (idx - 1) % subsample != 0:
            continue
        processImage("{0}/{1}".format(srcImagePath.rstrip('/'), img), videoFramePaths)



if __name__ == "__main__":
    dataPath = "/home/szh-920/workspace/master_graduate/data"
    videoFrameBase = "{0}/test_one_img".format(dataPath)
    videoFramePaths = {
        "01_hsv":           "{0}/01_hsv".format(videoFrameBase),
        "02_0_blue_mask":   "{0}/02_0_blue_mask".format(videoFrameBase),
        "02_1_red_mask":    "{0}/02_1_red_mask".format(videoFrameBase),
        "02_2_yellow_mask": "{0}/02_2_yellow_mask".format(videoFrameBase),
        "03_blur":          "{0}/03_blur".format(videoFrameBase),
        "04_binary":        "{0}/04_binary".format(videoFrameBase),
        "05_closed":        "{0}/05_closed".format(videoFrameBase),
        "06_erode":         "{0}/06_erode".format(videoFrameBase),
        "07_dilated":       "{0}/07_dilated".format(videoFrameBase),
        "08_signed_img":    "{0}/08_signed_img".format(videoFrameBase),
        "09_sign":          "{0}/09_sign".format(videoFrameBase),
    }

    if os.path.exists(videoFrameBase):
        os.system("rm -rf {0}".format(videoFrameBase))

    for dir in videoFramePaths.values():
        print(dir)
        os.makedirs(dir)
    imgFile = "/home/szh-920/workspace/master_graduate/src/pre_proc_code/imgs/00_img.jpg"
    processImage(imgFile, outputPaths=videoFramePaths)