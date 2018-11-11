# -*- coding: utf-8 -*-
"""
Created on Mon Oct 30 19:44:02 2017

@author: user
"""

from __future__ import print_function
# 导入numpy库， numpy是一个常用的科学计算库，优化矩阵的运算
import numpy as np
np.random.seed(1337)


# 导入mnist数据库， mnist是常用的手写数字库
# 导入顺序模型
from keras.models import Sequential
# 导入全连接层Dense， 激活层Activation 以及 Dropout层
from keras.layers.core import Dense, Dropout, Activation




# 设置batch的大小
batch_size = 100
# 设置类别的个数
nb_classes = 10
# 设置迭代的次数
nb_epoch = 20

'''
下面这一段是加载mnist数据，网上用keras加载mnist数据都是用
(X_train, y_train), (X_test, y_test) = mnist.load_data()
但是我用这条语句老是出错：OSError: [Errno 22] Invalid argument
'''
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

X_train, Y_train = mnist.train.images,mnist.train.labels
X_test, Y_test = mnist.test.images, mnist.test.labels
X_train = X_train.reshape(-1, 28, 28,1).astype('float32')
X_test = X_test.reshape(-1,28, 28,1).astype('float32')

#打印训练数据和测试数据的维度
print(X_train.shape,X_test.shape,Y_train.shape,Y_test.shape)

#修改维度
X_train = X_train.reshape(55000,784)
X_test = X_test.reshape(10000,784)
print(X_train.shape,X_test.shape,Y_train.shape,Y_test.shape)



# keras中的mnist数据集已经被划分成了55,000个训练集，10,000个测试集的形式，按以下格式调用即可

# X_train原本是一个60000*28*28的三维向量，将其转换为60000*784的二维向量

# X_test原本是一个10000*28*28的三维向量，将其转换为10000*784的二维向量

# 将X_train, X_test的数据格式转为float32存储
X_train = X_train.astype('float32')
X_test = X_test.astype('float32')
# 归一化
X_train /= 255
X_test /= 255
# 打印出训练集和测试集的信息
print(X_train.shape[0], 'train samples')
print(X_test.shape[0], 'test samples')

#Y_train = np_utils.to_categorical(Y_train, nb_classes)
#Y_test = np_utils.to_categorical(Y_test, nb_classes)

# 建立顺序型模型
model = Sequential()
'''
模型需要知道输入数据的shape，
因此，Sequential的第一层需要接受一个关于输入数据shape的参数，
后面的各个层则可以自动推导出中间数据的shape，
因此不需要为每个层都指定这个参数
'''

# 输入层有784个神经元
# 第一个隐层有512个神经元，激活函数为ReLu，Dropout比例为0.2
model.add(Dense(500, input_shape=(784,)))
model.add(Activation('relu'))
model.add(Dropout(0.2))

# 第二个隐层有512个神经元，激活函数为ReLu，Dropout比例为0.2
model.add(Dense(500))
model.add(Activation('relu'))
model.add(Dropout(0.2))

# 输出层有10个神经元，激活函数为SoftMax，得到分类结果
model.add(Dense(10))
model.add(Activation('softmax'))

# 输出模型的整体信息
# 总共参数数量为784*512+512 + 512*512+512 + 512*10+10 = 669706
model.summary()

model.compile(loss='categorical_crossentropy',
              optimizer='adam',
              metrics=['accuracy'])

history = model.fit(X_train, Y_train,
                    batch_size = 200,
                    epochs = 20,
                    verbose = 1,
                    validation_data = (X_test, Y_test))

score = model.evaluate(X_test, Y_test, verbose=0)


# 输出训练好的模型在测试集上的表现
print('Test score:', score[0])
print('Test accuracy:', score[1])