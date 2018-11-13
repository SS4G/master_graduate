import cv2
import os
import tqdm

def video2Images(videoFile, imagePath):
    """
    :param videoFile: 视频文件 需要全路径
    :param imagePath: 图片文件输出的全路径
    :return:
    """
    imagePath.rstrip("/")
    cap = cv2.VideoCapture(videoFile)
    i = 0
    if not cap.isOpened():
        print("open file failed!")
    else:
        while (True):
            ret, frame = cap.read()
            if ret:
                #frame = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
                cv2.imwrite('{0}/%08d.jpg'.format(imagePath) % (i, ), frame)
                if i % 100 == 0:
                    print('{0}/%08d.jpg size {1}'.format(imagePath, frame.shape) % (i, ))
                i += 1
            else:
                cap.release()
                break
        print("finish. {0}")
    print("video {0} 2img succeed!".format(videoFile))

def images2Video(imagePath, videoFile, fps=30):
    """
    :param imagePath: 图片存储的路径 路径下面的图片 应该是 0000.jpg
    :param videoFile:
    :param fps:
    :return:
    """
    imagePath = imagePath.rstrip("/")
    fps = 30  # 保存视频的FPS，可以适当调整
    # 可以用(*'DVIX')或(*'X264'),如果都不行先装ffmepg: sudo apt-get install ffmepg
    fourcc = cv2.VideoWriter_fourcc(*'MJPG')

    testFrame = frame = cv2.imread("{0}/%08d.jpg".format(imagePath) % 0)
    frameHeight = testFrame.shape[0]
    frameWidth = testFrame.shape[1]
    frameDepth = testFrame.shape[2]
    #videoWriter = cv2.VideoWriter(videoFile, fourcc, fps, (320,240))
    videoWriter = cv2.VideoWriter(videoFile, fourcc, fps, (frameWidth,frameHeight))
    #videoWriter = cv2.VideoWriter(videoFile, -1, fps, (1280,720))

    jpgAmount = len(os.listdir(imagePath))

    for i in range(jpgAmount):
        frame = cv2.imread("{0}/%08d.jpg".format(imagePath) % i)
        videoWriter.write(frame)
    videoWriter.release()

def processOneImage(img):
    pass

def imagesProcess(inputPath, outputPath):
    """
    对一个路径下的所有图片做map操作
    :param inputPath: 图片组所在的
    :param outputPath:
    :return:
    """
    pass


if __name__ == "__main__":
    dataPath = "/home/szh-920/workspace/master_graduate/data"
    video2Images("{0}/video_data/test_video.mp4".format(dataPath), "{0}/video_frames/test_video2".format(dataPath))
    images2Video("{0}/video_frames/test_video2".format(dataPath), "{0}/video_data/test_video3.avi".format(dataPath), fps=30)
