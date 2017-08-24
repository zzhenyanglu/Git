"""

how to test validation_curve(): 
    
    1. assume you want to test accuracy of depth = 6 with first 7 variables:  
        
       a = validation_curve(directory, min_depth = 5,max_depth = 6, \
                            target_classification=1, how_many_independent_var = 7))
    
    2. assume you want to compare accuracy rate from depth = 2 to depth = 22
       and you would see accuracy rate when predicting the response column = 1:
        
       a = validation_curve(directory, min_depth = 2,max_depth = 23, \
                            target_classification=1, how_many_independent_var = 7))

       * notice: it's gonna take about 13 minutes to do so on my laptop
    
       
how to test DecisionTree class:
    
    1. fit a depth of 5 model: 
       
       model = DecisionTree(max_depth=5)
       model.fit(X,y,target_classification=1, \
                 candidate_attribute_index=X.columns[0:5])
       
       * notice: when you don't specify candidate_attribute_index, you are
                 fitting all variables which is highly likely that if your
                 computer will dead, because it takes so so long to do so
                 
    2. predicting: 
        model.predict(T)
       
       * notice: the predicted value will be on the last column of T, the true
                 value will be on the second last column of T
       
    3. print model tree:
        model.print()
        
        * notice: sorry I think my tree is so ugly. I really can not find a 
                  good way to do it..
                  
    4. please take a look at function definition if neeeded.
        
    
important assumption:
    
    1. my code can only learn decision tree on one kind of labels each time
       though there are many of them. For example, calling method 
       fit(target_classification=1) of DecisionTree class can only give you
       a model to predict the chances that value of response column equals to 1
       though there are many distinct values in the response col of arrhythmia
       
    2. My code doesn't allow attribute reuse, for example, if attribute "hungry"
       already on the root of the decision tree to be fitted, it can not show 
       up in any of its descendant nodes.
      
    3. This is implicitly assumed that a left child node contains a dataset that
       has the split attribute smaller than the split value if it's continuous 
       data or has the split attribute equals self.ya. For example, if the 
       current node can be split on 16, then left node contains <=16, right node
       contains those > 16. 
       
    4. There is some randomness in DecisionTree.predict() method, if a leaf has
       mixed labels, I use uniform random generator to take a guess. For example,
       suppose there is leaf that says, 40% of the final label will be "Yes", 
       and 60% of "No", then if a random number is 0.38, then I would say it's
       a "Yes", because 0.38 < 0.4. So when predicting, the model will give 
       random results from time to time. BUT, after many many rounds of testing,
       I can guarantee that as the max_depth increase, the accuracy rate of my 
       DecisionTree model give better and better results when predicting. As you
       can also verify by running it.
       
running time statistics:
    
    1. the speed of DecisionTree class relies heavily on how many independent
       variables to be included. Based on my own testing, first 5 variables of 
       "arrhythmia.csv" takes about 30 seconds to fit a model with max_depth = 
       5. first 10 variables takes 2 minutes to do the same, on my laptop. 
       
    2. It took about 10 minutes to fit tree with 6 variables from depth 2 to 22
       It took about 31 minutes to run first 10 variables from depth =2 to 23, 
       which also shows that the algorithm in question 1, which splits continuous 
       data column is not O(n^2),though having this many variable does not improve 
       predicting accuracy much. To my very satisfication, my laptop does not 
       crashed when running 10 variables with depth from 2 to 23.  
    
predicting accuracy statistics:
    
    1. I think the accuracy does not improve as the number of independent variables
       increase. I compared 5 variables to 10 with tree depth fixed, the number
       did not improve much
       
    2. The predicting accuracy improves a lot first with tree depth increases, 
       then it sticks around around 90% as depth goes up further on my own test, 
       with some up and down, which I think caused by the randomness in 
       predict() method. 
    
    3. The number of variables to include comes into play like this: When the 
       number of variables is around 5-8, as the number of depth goes up, the 
       predict accuracy increases first and goes down to 80% then. When the 
       number of variables is above 10, as the number of depth goes up, the 
       predict accuracy increases up to 90% first but then drops to 60%. Maybe 
       this behavior results from the fact that the model is overfit when it has
       so many depth. 
       
"""

import math
import numpy as np
import pandas as pd
import os
import gc
import time

# this class simulate a binary tree structure to remember the fitted model
class treenode():
    def __init__(self,attribute_index = None, gain = 0, split = None, value = None, left_child = None, right_child = None, X=None, y=None):
        
        """
        attribute_index: The index of feature splitted at this point.
        split: If the attribute is continuous, split is on which value we split.
        value: If the node is leaf, set it.
        left_child: linked child node
        right_child: 
        """
        
        self.attribute_index = attribute_index
        self.split = split
        self.value = value
        self.left_child = left_child
        self.right_child = right_child
        self.gain = gain
        
        # store the unfitted data, just for my own debugging 
        self.X = X
        self.y = y
    
# each instance of DecisionTree can only be used to fit a single model, don't 
# fit twice with same instance. 

class DecisionTree():
    
    def __init__(self, max_depth=3):
        self.max_depth = max_depth
        
        # self.root is the binary tree structure that stores the 
        # fitted model.
        self.root = None
        
        # assume label column contains only two kinds of labels
        # ya is one
        # yb is the other
        self.ya =None ;
        self.yb =None ;
        
        self.max_depth = max_depth;
        
        # ya is the target classification in label column
        self.target_classification=None;
       
        
    # target_classification is the label you want to learn 
    # candidate_attribute_index is a index instatnce specifying
    # which columns to use as indepedent variables. 
    
    # this method is a wrapper than calls _tree_learning(), 
    # which is the recursive function to build model. 
    
    # it returns a treenode instance to self.root, which can be seen by 
    # self.print()
    
    def fit(self, X,y,target_classification, candidate_attribute_index=None):  
        
        # what's candidate_attributes
        if candidate_attribute_index is None:
            candidate_attribute_index = X.columns

        self.target_classification  = target_classification
        
        # error checking 
        if X.empty or len(candidate_attribute_index) == 0 or self.target_classification is None: 
            print("Can not build Decision Tree on empty dataset or no candidate index")
            return 

        # if we only want to fit based on specific attributes, then just keep 
        # those in question. 
             
        X = X[candidate_attribute_index]

        # fill missing with most common values
        for i in candidate_attribute_index:
            if X[i].isnull().values.any():
                X[i] = X[i].fillna(X[i].value_counts().idxmax()) 

        
        for i in range(len(y)):
            #print(y[0])
            if y[i] !=  self.target_classification:
                y[i] = self.target_classification+1

        # reindex                
        index_count = X.shape[1] + 1
        dataset = pd.concat([X[candidate_attribute_index],y],axis=1)
        
        dataset.columns =[i for i in range(index_count)]

        self.ya,self.yb = y.unique()
        self.root = self._tree_learning(dataset,current_depth=1)
        
        return self.root
    
            
    # label column is always the last column in dataset
    # this function return a treenode object to self.root
    
    def _tree_learning(self,dataset, parent_dataset=None, last_split_on=None,current_depth = None):
        
        if dataset.empty:
            return
        
        if current_depth >= self.max_depth:
            
            n = len(parent_dataset[parent_dataset[parent_dataset.columns[-1]]==self.yb])
            p = len(parent_dataset[parent_dataset[parent_dataset.columns[-1]]==self.ya])

            if n == 0 and p == 0:
                print(parent_dataset)
                
            value = p/(p+n)
            
            return treenode(attribute_index = last_split_on, value = value)
            
        # if the current dataset is empty return.
        if len(dataset.columns)==1:

            n = len(dataset[dataset[dataset.columns[0]]==self.yb])
            p = len(dataset[dataset[dataset.columns[0]]==self.ya])
         
            value = p/(p+n)

            return treenode(attribute_index = last_split_on,value = value)   

            
        # attributes set is empty
        elif len(dataset.columns) ==2 and len(dataset[dataset.columns[0]].unique())==1:

            n = len(dataset[dataset[dataset.columns[1]]==self.yb])
            p = len(dataset[dataset[dataset.columns[1]]==self.ya])
         
            value = p/(p+n)

            return treenode(value = value,split = last_split_on)
     
            
        # all examples have the same classification
        elif len(dataset.iloc[:,-1].unique()) ==1:
 
            n = len(parent_dataset[parent_dataset[parent_dataset.columns[-1]]==self.yb])
            p = len(parent_dataset[parent_dataset[parent_dataset.columns[-1]]==self.ya])

            if n == 0 and p == 0:
                print(parent_dataset)
                
            value = p/(p+n)
            
            return treenode(attribute_index = last_split_on, value = value)

        else: 
            
            # factor[0] = information gain,
            # factor[1] = split index
            # factor[2] = split value
            factor = self.most_important(dataset)
            
            # this column is a categorical value
            if type(factor[2]) == list:
                # left takes positive value             
                left_node = self._tree_learning(dataset[dataset[factor[1]] == factor[2][0]].iloc[:,dataset.columns!=factor[1]],dataset,last_split_on=factor[1],current_depth=current_depth+1)
                right_node = self._tree_learning(dataset[dataset[factor[1]] != factor[2][0]].iloc[:,dataset.columns!=factor[1]],dataset,last_split_on=factor[1],current_depth=current_depth+1)
            
            # continuous value
            else:            
                left_node = self._tree_learning(dataset[dataset[factor[1]] <= factor[2]].iloc[:,dataset.columns!=factor[1]],dataset,last_split_on=factor[1],current_depth=current_depth+1)
                right_node = self._tree_learning(dataset[dataset[factor[1]] > factor[2]].iloc[:,dataset.columns!=factor[1]],dataset,last_split_on=factor[1],current_depth=current_depth+1)
            
            return treenode(attribute_index=factor[1],gain = factor[0], split=factor[2],left_child = left_node, right_child = right_node)        
    
    # predict values based on self.root
    # the predicted values are stored on
    # the last column of input T
    # this function calls predict_traverse()
    # and returns T with the last column as predicted
    # value
    
    def predict(self, T):
        
        # last column stores the predicted values
        T[T.shape[1]] = pd.Series([])

        T.index = [i for i in range(T.shape[0])]
        
        for i in range(T.shape[0]):
            T.ix[i]=self.predict_traverse(self.root,T.ix[i])      
            
    
    def predict_traverse(self,tree,a):

        if tree is None:
            return 
        
        # if this is internal node
        elif tree.value is None:
           
            # if categorical data
            if type(tree.split) == list:
                
                if a[tree.attribute_index] == tree.split[0]:
                    return self.predict_traverse(tree.left_child,a)
                else:
                    return self.predict_traverse(tree.right_child,a)                
                
            # if continuous data
            else:
                # if <= split, go to left tree
                if a[tree.attribute_index] <= tree.split:
                    return self.predict_traverse(tree.left_child,a)
                else:
                    return self.predict_traverse(tree.right_child,a)
        
        # if this is leaf
        else: 
            if np.random.random() <= tree.value :
                return a.set_value(a.shape[0]-1,self.ya)
                
            else:
                return a.set_value(a.shape[0]-1,self.yb)
            
        
    # this method prints out the fitted binary decision tree
    # PLEASE pardon me for printing out in a ugly way, I don't 
    # really have an idea of how a pretty way to do it should 
    # look like
    # This method is a wrapper that calls tree_traverse(), which
    # is an recursive function to print out self.root
    
    # this function returns a ugly binary tree. 
    
    def print(self):
        print("               DESCRIPTION                         ")
        print("-------------------------------------------------- ")
        print("MAX DEPTH: ", self.max_depth)
        print("RULE: Decision tree being fitted is always binary  ")
        print("      left child is smaller than the split value of")
        print("      parent node if it's a continous value, or the")
        print("      first value of list, if it's a binary value ")
        print("      -> denote depth of the current tree node, so")
        print("      -> is depth 2, ->-> denote a depth of 3, etc.")
        print("-------------------------------------------------- \n")
        
        self.tree_traverse(self.root)    
    
    # "->" means one more level of tree
    def tree_traverse(self,node = None,indent = "->"):
        
        if node is None:
            print("Tree is empty")
            
        else:
            if node.value is not None:
                print(node.value)
                
            else:
                print ("split index[%s] by value %s " % (node.attribute_index, node.split))

                print ("%s %s: " % (indent,"left node"),end="")
                self.tree_traverse(node.left_child,indent + "->")

                print ("%s %s: " % (indent,"right node"),end="")
                self.tree_traverse(node.right_child,indent + "->")

                
    # this method assumes  the last column in dataset is the class attribute
    # this is the core method of this class, it loop through indepedent (X) 
    # variables and tells which one is the best to divide. 
    # this method can handles both categorical and continuous data type.
    
    # it returns current best column(index) to split 
    def most_important(self,dataset):
    
        best_split = None
        max_gain = -math.inf
        split_col = None

        for i in dataset.columns[0:-1]:

            # if the column is continuous
            if dataset[i].dtype in ('int64','float64'):
                
                dataset = dataset.sort_values(i,ascending=[1])
                dataset.index = range(0,len(dataset))
                
                for j in range(len(dataset[i])-1):
                    
                    if dataset.iloc[:,-1][j] != dataset.iloc[:,-1][j+1]:
                        #print (dataset.iloc[:,-1][j], dataset.iloc[:,-1][j+1],j)
                        split = (dataset[i][j]+dataset[i][j+1])/2                        
                        gain = self.information_gain_continuous(dataset[i], dataset.iloc[:,-1],split)
                        
                        if max_gain < gain:
                            max_gain = gain
                            best_split = j
                            split_col = i                            
                            
            # if the column is binary 
            else: 
                gain = self.information_gain_category(dataset[i],dataset.iloc[:,-1])
                
                if max_gain < gain:
                    max_gain = gain
                    best_split = list(dataset[i].unique())
                    split_col = i
        
                    
        if type(best_split) == list:
            
            return max_gain, split_col, best_split
            
        else:
      
            best_split = dataset[split_col][best_split]
            
            return max_gain, split_col, best_split    
            
    # assume y contains only two unique values
    #        x is categorical data. 
    # this function calculates information gain  
    # of a column that has categorical data
    
    # it returns information gain value
    def information_gain_category(self,x,y):
         
        p = y[y==self.ya].count()
        n = y[y==self.yb].count()
        
        sum = self.entropy(p,p+n)
        z = pd.concat([x,y],axis=1,names=['x','y'])
        
        for i in x.unique():  
            
            pk =  z[z[z.columns[0]] ==i][z[z.columns[1]] == self.ya].count()[z.columns[0]]
            pn =  z[z[z.columns[0]] ==i][z[z.columns[1]] == self.yb].count()[z.columns[1]]
    
            sum = sum - (pk+pn)/(p+n)*self.entropy(pk,pk+pn)

        return sum 
        
    # assume z contains both x and y, which are
    # independent and dependent variables.
    # split is a value on which we split x. 
    
    # this method needs modification if we are fitting 
    # a Decision tree that's not binary. 
    
    # it returns information gain value
    def information_gain_continuous(self,x,y,split):
        
        z = pd.concat([x,y],axis=1,names=['x','y'])
                
        p = z[z.columns[1]][z[z.columns[1]]==self.ya].count()
        n = z[z.columns[1]][z[z.columns[1]]==self.yb].count()
        
        sum = self.entropy(p,p+n)
                                
        pk =  z[z[z.columns[0]] <= split][z[z.columns[1]] == self.ya].count()[z.columns[1]]
        pn =  z[z[z.columns[0]] <= split][z[z.columns[1]] == self.yb].count()[z.columns[1]]
        
        sum = sum - (pk+pn)/(p+n)*self.entropy(pk,pk+pn)

        pk =  z[z[z.columns[0]] > split][z[z.columns[1]] == self.ya].count()[z.columns[1]]
        pn =  z[z[z.columns[0]] > split][z[z.columns[1]] == self.yb].count()[z.columns[1]]
  
        return sum - (pk+pn)/(p+n)*self.entropy(pk,pk+pn) 
    
    # this is a toy method to calculate entropy
    # notice this method's parameter n and p
    # which are nominator and denominator
    # it returns entropy(n/d)
    
    def entropy(self,n,d):
    
        if d == 0 or n==d or n ==0:
            return 0
    
        else: 
            p = n/d
            return -(p*math.log2(p) + (1-p)*math.log2(1-p))

# working dir
directory = 'C:\\Users\\zheny\\Dropbox\\courses\\machine learning(53111)\\lecture1\\'


# how_many_independent_var: specifies how many variables starting from the first one
# to choose to fit on.

# min_depth: minimum depth to loop from
# max_depth: max depth allowed

# min_depth = 2, max_depth =22, will fit Decision Tree with depth from 2 to 21,
# which is 22 different depth in total.

def validation_curve(directory, min_depth = 5,max_depth = 6, target_classification, how_many_independent_var = 7):
    
    # settings begin: 
    file = os.path.join(directory,"arrhythmia.csv")
    pdf = os.path.join(directory,"validation.pdf")
    
    if os.path.isfile(file) == False:
        print("File Does Not EXIST!")
        return
        
    raw = pd.read_csv(file, na_values=['?'],sep=',', header=None)    
    share = int(len(raw)/3)
 
    # step 1: shuffle records and partition
    raw.sample(frac=1).reset_index(drop=True)

    partition1 = raw[0:share].reset_index(drop=True)
    partition2 = raw[share:share*2].reset_index(drop=True)
    partition3 = raw[share*2:].reset_index(drop=True)    
    
    # record depth, train_accuracy, test accuracy
    stats=[]
    
    # settings ends:
        
        
    # step 2: vary depth from min_depth to max_depth
    for max_depth in range(min_depth,max_depth):
        
        # first fold of 3-fold 
        train = pd.concat([partition1,partition2],axis=0).reset_index(drop=True)
        test = partition3
        train_accuracy = 0
        test_accuracy = 0
    
        model = DecisionTree(max_depth)
        model.fit(train.iloc[:,0:-1],train.iloc[:,-1],target_classification=target_classification,candidate_attribute_index=train.columns[0:how_many_independent_var])

        # test train set
        model.predict(train)
        train_accuracy = train_accuracy + sum(train.iloc[:,-1] == train.iloc[:,-2])/train.shape[0]
        
        # test test set
        model.predict(test)
        test_accuracy = test_accuracy + sum(test.iloc[:,-1] == test.iloc[:,-2])/test.shape[0]
        
        del(model)
        del(train)
        del(test)
        gc.collect()        
         
        # second fold of 3-fold 
        
        train = pd.concat([partition1,partition3],axis=0).reset_index(drop=True)
        test = partition2
        
        model = DecisionTree(max_depth)
        model.fit(train.iloc[:,0:-1],train.iloc[:,-1],target_classification=target_classification,candidate_attribute_index=train.columns[0:how_many_independent_var])

                # test train set
        model.predict(train)
        train_accuracy = train_accuracy + sum(train.iloc[:,-1] == train.iloc[:,-2])/train.shape[0]
        
        # test test set
        model.predict(test)
        test_accuracy = test_accuracy + sum(test.iloc[:,-1] == test.iloc[:,-2])/test.shape[0]
        
        del(model)
        del(train)
        del(test)
        gc.collect() 
        
        # third fold of 3-fold 
        train = pd.concat([partition2,partition3],axis=0).reset_index(drop=True)
        test = partition1
        
        model = DecisionTree(max_depth)
        model.fit(train.iloc[:,0:-1],train.iloc[:,-1],target_classification=target_classification,candidate_attribute_index=train.columns[0:how_many_independent_var])

        # test train set
        model.predict(train)
        train_accuracy = train_accuracy + sum(train.iloc[:,-1] == train.iloc[:,-2])/train.shape[0]
        
        # test test set
        model.predict(test)
        test_accuracy = test_accuracy + sum(test.iloc[:,-1] == test.iloc[:,-2])/test.shape[0]
        
        del(model)
        del(train) 
        del(test)
        gc.collect() 
        
        stats.append([max_depth,train_accuracy/3,test_accuracy/3])
        
    stats = pd.DataFrame(stats)
    stats.columns=['max_depth','training dataset accuracy','test dataset accuracy']
    pic = stats.plot(x=[stats.columns[0]],y=[stats.columns[1],stats.columns[2]],legend="Max_depth VS Predicting Accuracy").get_figure()
    pic.savefig(pdf)
    
    return stats

before = time.time()
a = validation_curve(directory, min_depth = 2,max_depth = 23,target_classification=1, how_many_independent_var = 10)
print("time eplased: ", time.time() - before, "Seconds")