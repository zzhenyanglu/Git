from __future__ import print_function

import tensorflow as tf

import sys

import cifar10

cifar10.maybe_download_and_extract()

images_train, cls_train, labels_train = cifar10.load_training_data()

images_test, cls_test, labels_test = cifar10.load_test_data()
# alpha
learning_rate = 1e-3

#1e-2 500 0.27

#1e-2 seed = 10000 0.29

#1e-2 seed = 50000 0.24

#1e-3 seed = 50000 0.22

#1e-3 reached 0.37
#iterations
steps = 1500
#batch
batch_size = 100

batches_per_epoch = int (50000 / batch_size)
# image_size
img_size = 32

num_channels = 3
# lable_numbers
n_classes = 10

x = tf.placeholder(tf.float32, shape=[None, img_size, img_size, num_channels], name='x')

y = tf.placeholder(tf.float32, shape=[None, n_classes], name='y')
# conv_layer
def conv2d(x, W, b, strides=1):
    # Conv2D wrapper, with bias and relu activation
    x = tf.nn.conv2d(x, W, strides=[1, strides, strides, 1], padding='SAME')
    x = tf.nn.bias_add(x, b)
    return tf.nn.relu(x)
# pool_layer
def maxpool2d(x, k=2):
    # MaxPool2D wrapper
    return tf.nn.max_pool(x, ksize=[1, k, k, 1], strides=[1, k, k, 1],
                          padding='SAME')

def build_cnn(x, weights, biases):

    # Conv1
    conv1 = conv2d(x, weights['wc1'], biases['bc1'])
    print(conv1.shape)

    # Conv2
    conv2 = conv2d(conv1, weights['wc2'], biases['bc2'])
   
    # pool1
    pool1 = maxpool2d(conv2, k=2)

    # Conv3
    conv3 = conv2d(pool1, weights['wc3'], biases['bc3'])

    # conv4
    conv4 = conv2d(conv3, weights['wc4'], biases['bc4'])

    # pool2
    pool2 = maxpool2d(conv4, k=2)

    # conv5
    conv5 = conv2d(pool2, weights['wc5'], biases['bc5'])

    # pool3
    pool3 = maxpool2d(conv5, k=2)


    # Fully connected layer
    # Reshape conv5 output to fit fully connected layer input
    fc1 = tf.reshape(pool3, [-1, 4*4*256])
    #print(fc1.shape)
    fc1 = tf.add(tf.matmul(fc1, weights['wfc1']), biases['bfc1'])
    fc1 = tf.nn.relu(fc1)
    
    # fc2, i.e. out
    fc2 = tf.add(tf.matmul(fc1,weights['wfc2']),biases['bfc2'])
    # Output, class prediction
    out = tf.nn.softmax(fc2)

    return fc2,out


weights = {
    # 5x5 conv, 1 input, 32 outputs
    'wc1': tf.Variable(tf.random_normal([3, 3, 3, 64])),
    # 5x5 conv, 32 inputs, 64 outputs
    'wc2': tf.Variable(tf.random_normal([3, 3, 64, 64])),
    # 5x5 conv, 1 input, 32 outputs
    'wc3': tf.Variable(tf.random_normal([3, 3, 64, 128])),
    # 5x5 conv, 32 inputs, 64 outputs
    'wc4': tf.Variable(tf.random_normal([3, 3, 128, 128])),
    # 5x5 conv, 32 inputs, 64 outputs
    'wc5': tf.Variable(tf.random_normal([3, 3, 128, 256])),
    # fully connected, 7*7*64 inputs, 1024 outputs
    'wfc1': tf.Variable(tf.random_normal([4*4*256, 256])),
    # 1024 inputs, 10 outputs (class prediction)
    'wfc2': tf.Variable(tf.random_normal([256, n_classes]))
}

biases = {
    'bc1': tf.Variable(tf.random_normal([64])),
    'bc2': tf.Variable(tf.random_normal([64])),
    'bc3': tf.Variable(tf.random_normal([128])),
    'bc4': tf.Variable(tf.random_normal([128])),
    'bc5': tf.Variable(tf.random_normal([256])),
    'bfc1': tf.Variable(tf.random_normal([256])),
    'bfc2': tf.Variable(tf.random_normal([n_classes]))
}

# Construct model
# final_layer, y_hat
fc2,pred = build_cnn(x, weights, biases)

# Define loss and optimizer
cost = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=fc2, labels=y))
optimizer = tf.train.AdamOptimizer(learning_rate=learning_rate).minimize(cost)

# Evaluate model
correct_pred = tf.equal(tf.argmax(pred, 1), tf.argmax(y, 1))
accuracy = tf.reduce_mean(tf.cast(correct_pred, tf.float32))
correct_num = tf.reduce_sum(tf.cast(correct_pred, tf.float32))

# Initializing the variables
init = tf.global_variables_initializer()

# Create a saver.
saver = tf.train.Saver(tf.global_variables())

# Launch the graph

def train():
    with tf.Session() as sess:
        sess.run(init)

        #Set seed
        #tf.set_random_seed(0)

        global_step = 0 #global step

        # Keep training until reach max iterations
        while global_step < steps:
            step = global_step % batches_per_epoch  #Step within each epoch

            batch_x, batch_y = images_train[step * batch_size : (step + 1) * batch_size], labels_train[step * batch_size : (step + 1) * batch_size]
            # Run optimization op (backprop)
            #print(batch_x.shape)
            #print(batch_y.shape)

            sess.run(optimizer, feed_dict={x: batch_x, y: batch_y})

            if (step + 1) % 50 == 0: #Print Current Status
                print("Current Step: {}".format(global_step + 1))

            if (step + 1) % batches_per_epoch == 0: #Each epoch, print loss
                # Calculate loss and accuracy after one epoch
                loss = 0
                acc = 0

                for i in range(500):

                	one_loss, one_acc = sess.run([cost, accuracy], feed_dict={x: images_train[i * batch_size : (i + 1) * batch_size], y: labels_train[i * batch_size : (i + 1) * batch_size]})
                	loss += one_loss
                	acc += one_acc

                loss = loss / 500.
                acc = acc / 500.

                print("Epoch " + str((global_step + 1) / batches_per_epoch) + ", Epoch Loss= " + \
                      "{:.6f}".format(loss) + ", Training Accuracy= " + \
                      "{:.5f}".format(acc))

                saver.save(sess, './save/my-model')

            global_step += 1

        print("Train Finished!") 

def test():
    with tf.Session() as sess:
        new_saver = tf.train.import_meta_graph('./save/my-model.meta')
        new_saver.restore(sess, './save/my-model')
        #sess.run(init)
        #Test for all
        acc = 0
        for i in range(100):
        
            acc += sess.run(correct_num, feed_dict={x: images_test[i * batch_size : (i + 1) * batch_size], y: labels_test[i * batch_size : (i + 1) * batch_size]})

        print("Testing Accuracy: {}".format(acc / 10000))

def main(argv):
    if (len(sys.argv) != 2):
        print("Usage: python hw5-tf.py -train or python hw5-tf.py -test")
        return
    elif (sys.argv[1] != "-test" and sys.argv[1] != "-train"):
        print("Usage: python hw5-tf.py -train or python hw5-tf.py -test")
        return

    eval_data = "train"

    if (sys.argv[1] == "-test"):
        eval_data = "test"
        

    if (eval_data == "train"):
        train()

    else:
        test()

if __name__ == "__main__":
    main(sys.argv)

        







