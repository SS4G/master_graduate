
import cv2
import numpy as np
import sys
import os
from functools import reduce
sys.path.append('/home/szh-920/workspace')
#sys.path.append('.')
from master_graduate.logging import ColorLogging
import master_graduate.src.pre_proc_code.video_split_cat as vsc
import master_graduate.src.pre_proc_code.preprocess_imgs as primg

if __name__ == "__main__":
    jobName = "test00"
    dataPath = "/home/szh-920/workspace/master_graduate/data"          # 所有的数据的根目录
    srcVideoFile = "{0}/video_data/pre_source_1.mp4".format(dataPath)  # 要分析的视频所在的根目录
    srcImagesPath = "{0}/video_frames/pre_source_1".format(dataPath)   # 视频分帧厚度存储目录
    videoOutBasePath = "{0}/video_frames/{job_name}".format(dataPath, job_name=jobName)
    processedVideoPath = "{0}/video_data/{job_name}".format(dataPath, job_name=jobName)

    # 保证要写入的目录本来是不存在的 避免覆盖掉有用的数据
    # 存放大量图片的路径需要事先不存在 存放视频的路径需要存在
    if os.path.exists(srcImagesPath):
        os.system("rm -rf {0}".format(srcImagesPath))

    if os.path.exists(videoOutBasePath):
        os.system("rm -rf {0}".format(videoOutBasePath))

    if os.path.exists(videoOutBasePath):
        os.system("rm -rf {0}".format(processedVideoPath))
    os.makedirs(processedVideoPath)

    #开始处理
    #将视频文件处理成图像帧
    vsc.video2Images(srcVideoFile, srcImagesPath)
    # 逐帧处理图像
    primg.processImages(srcImagesPath, outputBasePath=videoOutBasePath)
    # 将不同的帧分别合并成视频
    for dir in os.listdir(videoOutBasePath):
        ColorLogging.info("merging {0}".format(dir))
        #basename = os.path.basename(dir)
        if "09" not in dir:
            vsc.images2Video("{0}/{1}".format(videoOutBasePath.rstrip("/"), dir), "{0}/pre_source_1_{1}.avi".format(processedVideoPath, dir), fps=30)