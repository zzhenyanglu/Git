Thanks for reviewing my homework 1. This home work is fairly much, and reviewing codes line by line maybe not realistic, so I'm writting down things that I think is very important to know. Please take a look if you have enough time to do so. Also, please 
look at method and function definitions in the homework. 


how to test validation_curve(): 
    
    1. assume you want to test accuracy of depth = 6 with first 7 variables and you
       want to see predicting accuracy rate when predict label =1 in target column 
        
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
                 computer will be dead for hours, because it takes so so long to do so
                 
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