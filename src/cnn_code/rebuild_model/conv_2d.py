import numpy as np
import cv2

if __name__ == "__main__":
    src = np.arange(27).reshape((3, 3, 3))
    kernal = np.arange(4).reshape((2, 2, 1))
    a = np.array([[1, 2, 3], [4, 5, 6]])
    res = np.array([a, a + 1, a + 2])
    print(res)
    #print(src)
    #for i in range(3):
    #   print(src[:, :, i].shape)
