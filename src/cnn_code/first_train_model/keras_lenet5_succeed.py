

import pandas as pd
import numpy as np
import cv2
import h5py
#from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense,Flatten,Conv2D,MaxPool2D
from keras.optimizers import SGD
from keras.utils import to_categorical
import os
from sklearn.model_selection import train_test_split
from tensorflow.examples.tutorials.mnist import input_data
from tqdm import tqdm
import pickle

def show_levels_of_hdf5(root_h5obj, indent=0, index='/'):
    if hasattr(root_h5obj, 'keys'):
        keys = list(root_h5obj.keys())
        for key in keys:
            print(indent * "  " + str(key))
            show_levels_of_hdf5(root_h5obj[key], indent + 1, index=index + key)
    else:
        print("type :  " + indent * "  " + str(type(root_h5obj)))
        print("value:  " + str(root_h5obj))
        print("index:  " + index)


#mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

#_train, y_train = mnist.train.images,mnist.train.labels
#x_test, y_test = mnist.test.images, mnist.test.labels

DST_SIZE = (35, 35, 1)
CLASS_NUM = 43
ACT_FUNC = 'tanh'#'sigmoid'#'relu'#'tanh'

# #### 标准的形式 x_trainReshaped.shape (55000, 28, 28, 1) amount height width channel

names = pd.read_csv("./data/unstandard_file.csv")
blacklistSet = names["Filename"]

notype = {22,36,40,20,21, 39, 24,  29,   32,   42,   41,   27,   37,   19,   0}


imgList = []
imageDir = ".\\GTSRB_train_jpgs\\"

label = []
for file in tqdm(os.listdir(imageDir)):
    if ".jpg" not in file:
        continue
    imgtype = int(file.split("#")[0])
    if file not in blacklistSet:
        label.append(imgtype)
        mat = cv2.resize(cv2.cvtColor(cv2.imread(imageDir + file), cv2.COLOR_BGR2GRAY), (DST_SIZE[0], DST_SIZE[1]))
        mat = mat.reshape(DST_SIZE)
        imgList.append(mat) 
xset = np.array(imgList)
yset = np.array(label)

z = np.std(xset)

xset = xset / z


print(xset.shape, yset.shape)

yset_onehot=to_categorical(yset,num_classes=CLASS_NUM)


train_x, test_x, train_y, test_y = train_test_split(xset, yset_onehot, test_size=0.1, random_state=42)

dictx = {}
dictx["train_x"] = train_x
dictx["test_x"] = test_x
dictx['train_y'] = train_y
dictx['test_y'] = test_y
f = open("params_explore_000.dat", "wb")
pickle.dump(f, dictx)
f.close()

print("train_x", train_x.shape)
print("train_y", train_y.shape)
print("test_x", test_x.shape)
print("test_y", test_y.shape)



# create model
model=Sequential()
model.add(Conv2D(filters=6, kernel_size=(5,5), padding='valid', input_shape=DST_SIZE, activation="relu"))
model.add(MaxPool2D(pool_size=(2,2)))
model.add(Conv2D(filters=16, kernel_size=(5,5), padding='valid', activation="relu"))
model.add(MaxPool2D(pool_size=(2,2)))

#池化后变成16个4x4的矩阵，然后把矩阵压平变成一维的，一共256个单元。
model.add(Flatten())

#下面就是全连接层了
model.add(Dense(120, activation="relu"))
model.add(Dense(84, activation="relu"))
model.add(Dense(CLASS_NUM, activation='softmax'))
#compile model

#事实证明，对于分类问题，使用交叉熵(cross entropy)作为损失函数更好些
model.compile(
    loss='categorical_crossentropy',
    optimizer=SGD(lr=0.1),
    metrics=['accuracy']
)

#train model
model.fit(train_x, train_y,
          batch_size=120,
          epochs=20, 
          verbose = 1,
          validation_data = (test_x, test_y))

#evaluate model

score = model.evaluate(test_x,test_y)
print("Total loss on Testing Set:", score[0])
print("Accuracy of Testing Set:", score[1])

model.save('params_explore_000_model.h5')

import json
model.to_json() #生成对应的模型结构




