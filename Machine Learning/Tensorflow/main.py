import tensorflow as tf
import cifar10
import sys
import os
import time
import numpy as np

def configuration():
    # Setting up configurations:
    cifar10.maybe_download_and_extract()

    global alpha, image_size,thread_no, lable_numbers, k_size, X, y, weights,biases
    alpha = 0.001
    image_size = 32
    depth = 3
    lable_numbers = 10
    k_size = 2
    X = tf.placeholder(tf.float32, shape=[None, image_size, image_size, depth], name='X')
    y = tf.placeholder(tf.float32, shape=[None, lable_numbers], name='y')

    # initiate weights and biases according to homework specification
    weights = []
    biases= []
    weights.append(tf.Variable(tf.random_normal([3, 3, 3, 64])))
    weights.append(tf.Variable(tf.random_normal([3, 3, 64, 64])))
    weights.append(tf.Variable(tf.random_normal([3, 3, 64, 128])))
    weights.append(tf.Variable(tf.random_normal([3, 3, 128, 128])))
    weights.append(tf.Variable(tf.random_normal([3, 3, 128, 256])))
    weights.append(tf.Variable(tf.random_normal([4*4*256, 256])))

    # for final fc layer
    weights.append(tf.random_normal([256, lable_numbers]))
    
    biases.append(tf.Variable(tf.random_normal([64])))
    biases.append(tf.Variable(tf.random_normal([64])))
    biases.append(tf.Variable(tf.random_normal([128])))
    biases.append(tf.Variable(tf.random_normal([128])))
    biases.append(tf.Variable(tf.random_normal([256])))
    biases.append(tf.Variable(tf.random_normal([256])))

    # for final fc layer
    biases.append(tf.Variable(tf.random_normal([lable_numbers])))

    global final_layer,y_hat,cost,optimizer,initial_global_var,saver,\
           accurate_prediction,accuracy,number_accurate_prediction

    # build a CNN: 
    final_layer, y_hat = build_cnn(X, weights, biases)
    cost = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=final_layer, labels=y))
    optimizer = tf.train.AdamOptimizer(learning_rate=alpha).minimize(cost)

    # initialization
    initial_global_var = tf.global_variables_initializer()
    saver = tf.train.Saver(tf.global_variables())

    # model evaluator 
    accurate_prediction = tf.equal(tf.argmax(y_hat, 1), tf.argmax(y, 1))
    accuracy = tf.reduce_mean(tf.cast(accurate_prediction, tf.float32))
    number_accurate_prediction = tf.reduce_sum(tf.cast(accurate_prediction, tf.float32))


# make some aux function to call functions within tensorflow class 
def pool_layer(x, k_size=2):
    
    # print(tf.nn.max_pool(x,ksize=[1,k_size,k_size,1],strides=[1,k_size,k_size,1]))
    return tf.nn.max_pool(x,ksize=[1,k_size,k_size,1],strides=[1,k_size,k_size,1],padding='SAME')

def conv_layer(x, weights, bias, strides=1):
    # processing input array
    x = tf.nn.conv2d(x, weights, strides=[1, strides, strides, 1], padding='SAME')
    x = tf.nn.bias_add(x, bias)
    # print(x)
    return tf.nn.relu(x)

def fc_layer(input,weight,bias,size=[-1, 4*4*256]):
    # fully connected layer
    layer = tf.reshape(input, size)
    layer = tf.add(tf.matmul(layer, weight), bias)
    return tf.nn.relu(layer)

# define a CNN model
# notice: this is like a hard code function that only works for
#         the specification of the 10 layers CNN specified by
#         the homework requirement.
# returns final predict and layer for debug
                   
def build_cnn(x, weights, biases):

    # according to the specification of the question

    conv1 = conv_layer(X, weights[0], biases[0])
    conv2 = conv_layer(conv1, weights[1], biases[1])
    
    pool1 = pool_layer(conv2)
    conv3 = conv_layer(pool1, weights[2], biases[2])
    conv4 = conv_layer(conv3, weights[3], biases[3])
    pool2 = pool_layer(conv4)
    conv5 = conv_layer(pool2, weights[4], biases[4])
    pool3 = pool_layer(conv5)
    
    fc1 = fc_layer(pool3,weights[5], biases[5])

    fc2 = tf.add(tf.matmul(fc1,weights[6]),biases[6])
    result = tf.nn.softmax(fc2)

    return fc2,result


# number of batch to train on 
def train(batch = 5,iteration = 100):

    number_of_batch = 100
    batch_per_iter = int(50000/number_of_batch)
    train_images, train_cls, train_labels = cifar10.load_training_data()
    
    with tf.Session() as thread:
        thread.run(initial_global_var)
        
        for i in range(batch):
            print("Now: "+str(i)+" iteration")

            step_size = i%batch_per_iter 

            current_x, current_y = train_images[step_size*number_of_batch:(step_size + 1)\
                        *number_of_batch],train_labels[step_size*number_of_batch:(step_size+1)*number_of_batch]
            
            thread.run(optimizer, feed_dict={X: current_x, y: current_y})

            total_loss = 0.0
            total_accuracy = 0.0
            
            for j in range(iteration):
                current_loss, current_accuracy = thread.run([cost,accuracy],\
                        feed_dict={X:train_images[j*number_of_batch:(j+1)*number_of_batch],\
                        y:train_labels[j*number_of_batch:(j+1)*number_of_batch]})

                total_loss=total_loss+current_loss
                total_accuracy = total_accuracy+current_accuracy

            total_loss = total_loss/iteration
            total_accuracy = total_accuracy/iteration

            print("Batch "+ str(i)  + ", current raining Accuracy= ", total_accuracy)
        saver.save(thread, os.path.join(os.getcwd()))
          
    print("training done\n")


# to speed up, the number of images to be tested is down to 10
def test(test_image_num = 10):

    test_images, test_cls, test_labels = cifar10.load_test_data()
    number_of_batch = 100
    
    with tf.Session() as thread:

        model = tf.train.import_meta_graph(os.path.join(os.getcwd(),"model.meta"))
        model.restore(thread, os.path.join(os.getcwd(),"model"))

        accuracy = []
        
        for i in range(test_image_num):
        
            accuracy.append(thread.run(number_accurate_prediction,feed_dict={X:test_images[i*number_of_batch:(i+1)*number_of_batch],\
                            y:test_labels[i*number_of_batch:(i+1)*number_of_batch]}))

        print("prediction accuracy of the first testing images: ", np.array(accuracy)/100.0)

def main(args):

    if args[1] =="train":
        print("To illastrate the whole program, iteration and batch size has been reduce lower enough to speed up the process time.")
        configuration()                    
        train()
        
    elif args[1] == "test":
        test()

    else:
        print("This program takes 1 argument: hw5-tf.py -test/-train")
        return
                            
    return
                            
main(sys.argv)


