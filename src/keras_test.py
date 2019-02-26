from keras.models import Sequential, load_model, Model
import pickle
import h5py
import time
import tqdm
if __name__ == "__main__":
    print("begin_load_models")
    dataPath = "D:/workspace/explain_cnn/master_graduate/data"
    all_model = load_model('{0}/models/lenet_relu_model_all.hdf5'.format(dataPath))
    #model = h5py.File('{0}/models/lenet_relu_model_all.hdf5'.format(dataPath), "r")
    objs = h5py.File("{0}/data_set/dataSet.hdf5".format(dataPath), "r")
    st = time.time()
    print(st)
    #weights =
    train_x = objs["/train_x"]
    train_y = objs["/train_y"]
    idx = 0
    for oneImg in tqdm.tqdm(train_x):
        all_model.predict([oneImg])
    ed = time.time()
    print(ed - st)
import os
os.open()
os.read()
os.write()