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

def processImage(imgFile, outputPaths):
    """
    :param imgFile: 单个的图片文件路径
    :param outputPaths: 输出路径组 分别将图片输出到不同的路径
    :param logOpen: 是否打开日志输出 默认关闭
    :return:
    """
    # 二值化门限设定
    binary_thresold = 127

    # HSV阈值参数设定
    blue_lower = np.array([97, 50, 50])
    blue_upper = np.array([120, 255, 255])

    red_lower = np.array([100, 50, 50])
    red_upper = np.array([124, 255, 255])

    yellow_lower = np.array([100, 50, 50])
    yellow_upper = np.array([124, 255, 255])

    # 预先检查各类路径是否合理
    imgId = os.path.basename(imgFile).split(".")[0]

    #加载原图
    img = cv2.imread(imgFile)
    #cv2.imwrite('./imgs/00_img.jpg',img)

    hsv = cv2.cvtColor(img,cv2.COLOR_BGR2HSV)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['01_hsv'].rstrip('/'), imgId), hsv)

    # 提取蓝色区域
    mask_blue = cv2.inRange(hsv,blue_lower,blue_upper)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['02_0_blue_mask'].rstrip('/'), imgId), mask_blue)
    # 提取红色区域
    mask_red = cv2.inRange(hsv,red_lower, red_upper)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['02_1_red_mask'].rstrip('/'), imgId), mask_red)
    # 提取黄色区域
    mask_yellow = cv2.inRange(hsv,yellow_lower, yellow_upper)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['02_2_yellow_mask'].rstrip('/'), imgId), mask_yellow)

    # 将所有过滤出来的区域求和 然后统一处理
    # 求或函数 如果任意一值 大于0 那么最后值为255
    func_or = np.frompyfunc(lambda x, y: 255 if x > 0 or y > 0 else 0, 2, 1)
    mask_added = np.minimum((func_or(func_or(mask_blue, mask_yellow),mask_red)), 255)
    mask_added = mask_added.astype(np.uint8)

    #模糊
    blurred=cv2.blur(mask_added, (9,9))
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['03_blur'].rstrip('/'), imgId), blurred)
    #二值化
    ret,binary=cv2.threshold(blurred, binary_thresold, 255, cv2.THRESH_BINARY)
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
    erode=cv2.erode(closed,None,iterations=4)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['06_erode'].rstrip('/'), imgId), erode)
    dilate=cv2.dilate(erode,None,iterations=4)
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['07_dilated'].rstrip('/'), imgId), dilate)

    # 查找轮廓
    image, contours, hierarchy=cv2.findContours(dilate.copy(), cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)

    #print(type(image), image.shape)

    #print('轮廓个数：',len(contours))
    i=0
    res = img.copy()
    for conIdx, con in enumerate(contours):
        #轮廓转换为矩形 返回的对象是(中心点, 长宽, 旋转角)
        rect=cv2.minAreaRect(con)
        #矩形转换为box
        # box是裁剪出来的矩形的四个定点的坐标 使用np.int0 取整数
        box = np.int64(cv2.boxPoints(rect))

        #在原图画出目标区域
        #cv2.drawContours 参数 (目标图像, 轮廓点集组)
        cv2.drawContours(res,[box],-1,(0,0,255),2)
        #cv2.drawContours(res, con, -1, (0, 255, 0), 2)

        #计算矩形的行列的边界
        h1=max([box][0][0][1],[box][0][1][1],[box][0][2][1],[box][0][3][1])
        h2=min([box][0][0][1],[box][0][1][1],[box][0][2][1],[box][0][3][1])
        l1=max([box][0][0][0],[box][0][1][0],[box][0][2][0],[box][0][3][0])
        l2=min([box][0][0][0],[box][0][1][0],[box][0][2][0],[box][0][3][0])

        #加上防错处理，确保裁剪区域无异常
        if h1-h2>0 and l1-l2>0:
            #裁剪矩形区域
            temp=img[h2:h1,l2:l1]
            i=i+1
            #显示裁剪后的标志
            cv2.imwrite("{0}/{1}_{2}.jpg".format(outputPaths['09_sign'].rstrip('/'), imgId, conIdx),temp)
    #显示画了标志的原图
    cv2.imwrite("{0}/{1}.jpg".format(outputPaths['08_signed_img'].rstrip('/'), imgId) ,res)

def processImages(srcImagePath, outputBasePath):
    """
    这个函数中的 路径组
    :param srcImagePath:
    :param outputBasePaths: 中间结果帧的输出目录
    :return:
    """
    assert not os.path.exists(outputBasePath), "processed output base path alreay exists"
    os.makedirs(outputBasePath)
    pathCheck(inputPath=srcImagePath, outputPath=outputBasePath)
    
    videoFramePaths = {
        "01_hsv":           "{0}/01_hsv".format(outputBasePath),
        "02_0_blue_mask":   "{0}/02_0_blue_mask".format(outputBasePath),
        "02_1_red_mask":    "{0}/02_1_red_mask".format(outputBasePath),
        "02_2_yellow_mask": "{0}/02_2_yellow_mask".format(outputBasePath),
        "03_blur":          "{0}/03_blur".format(outputBasePath),
        "04_binary":        "{0}/04_binary".format(outputBasePath),
        "05_closed":        "{0}/05_closed".format(outputBasePath),
        "06_erode":         "{0}/06_erode".format(outputBasePath),
        "07_dilated":       "{0}/07_dilated".format(outputBasePath),
        "08_signed_img":    "{0}/08_signed_img".format(outputBasePath),
        "09_sign":          "{0}/09_sign".format(outputBasePath),
    }

    for dir in videoFramePaths.values():
        ColorLogging.info("create folder {0}".format(dir))
        os.makedirs(dir)

    for img in tqdm.tqdm(sorted(os.listdir(srcImagePath))):
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