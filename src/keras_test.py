from keras.models import Sequential, load_model, Model
import pickle
import time
import tqdm
if __name__ == "__main__":
    print("begin_load_models")
    objs = pickle.load(open("test_imgs2.pickle", "rb"))
    dataPath = "/home/szh-920/workspace/master_graduate/data"
    all_model = load_model('{0}/models/lenet_relu_model_all.hdf5'.format(dataPath))

    st = time.time()
    print(st)
    weights = objs[2]
    train_x = objs[0] 
    train_y = objs[1]
    idx = 0
    for oneImg in tqdm.tqdm(train_x):
        all_model.predict([oneImg])
    ed = time.time()
    print(ed - st)

