'''
该文件中的函数用于将视频拆分为图片 与从图片组合成视频
'''

import cv2
import os
import tqdm
import sys
sys.path.append('/home/szh-920/workspace')

from master_graduate.logging import ColorLogging

def video2Images(videoFile, imagePath, resize=None):
    """
    :param videoFile: 视频文件 需要全路径
    :param imagePath: 图片文件输出的全路径
    :param resize: width height
    :return:
    """
    # 创建一个新的空目录
    imagePath.rstrip("/")
    assert not os.path.exists(imagePath), ColorLogging.colorStr("image already exists", "red")

    os.makedirs(imagePath)

    assert os.path.exists(videoFile),  ColorLogging.colorStr("video file {0} not exists".format(videoFile), "red")

    cap = cv2.VideoCapture(videoFile)
    i = 0

    frameCnt = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    ColorLogging.warn("video has {0} frames".format(frameCnt))

    if not cap.isOpened():
        ColorLogging.error("open file failed!")
    else:
        for i in tqdm.tqdm(range(frameCnt)):
            ret, frame = cap.read()
            if ret:
                #frame = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
                if resize is None:
                    cv2.imwrite('{0}/%08d.jpg'.format(imagePath) % (i, ), frame)
                else:
                    cv2.imwrite('{0}/%08d.jpg'.format(imagePath) % (i,), cv2.resize(frame, resize))
            else:
                cap.release()
                break
        ColorLogging.debug("finish. {0} frames saved!".format(frameCnt))
    ColorLogging.debug("video {0} to imgs succeed!".format(videoFile))

def images2Video(imagePath, videoFile, fps=30):
    """
    :param imagePath: 图片存储的路径 路径下面的图片 应该是 00000000.jpg -> xxxxxxxx.jpg
    :param videoFile:
    :param fps:
    :return:
    """
    imagePath = imagePath.rstrip("/")
    assert os.path.exists(imagePath) and os.path.isdir(imagePath), ColorLogging.colorStr("image output path invalidFolderPath or not exists", "red")
    assert os.path.exists(os.path.dirname(videoFile)), ColorLogging.colorStr("video output path not exists", "red")
    assert os.path.exists("{0}/%08d.jpg".format(imagePath) % 0), "path {0} is empty!!".format(imagePath)

    testFrame = cv2.imread("{0}/%08d.jpg".format(imagePath) % 0)
    frameHeight = testFrame.shape[0]
    frameWidth = testFrame.shape[1]
    frameDepth = testFrame.shape[2]

    #fps = 30  # 保存视频的FPS，可以适当调整
    # 可以用(*'DVIX')或(*'X264'),如果都不行先装ffmepg: sudo apt-get install ffmepg

    fourcc = cv2.VideoWriter_fourcc(*'MJPG')
    videoWriter = cv2.VideoWriter(videoFile, fourcc, fps, (frameWidth,frameHeight))

    jpgAmount = len(os.listdir(imagePath))
    ColorLogging.debug("{0} pictures is merging".format(jpgAmount))
    for i in tqdm.tqdm(range(jpgAmount)):
        frame = cv2.imread("{0}/%08d.jpg".format(imagePath) % i)
        videoWriter.write(frame)
    videoWriter.release()
    ColorLogging.info("{0} pictures merged".format(jpgAmount))

if __name__ == "__main__":
    dataPath = "/home/szh-920/workspace/master_graduate/data"
    video2Images("{0}/video_data/test_video.mp4".format(dataPath), "{0}/video_frames/test_video2".format(dataPath))
    images2Video("{0}/video_frames/test_video2".format(dataPath), "{0}/video_data/test_video3.avi".format(dataPath), fps=30)
