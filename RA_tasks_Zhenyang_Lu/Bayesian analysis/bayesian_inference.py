import pandas as pd
import numpy as np
from datetime import datetime
import re 


# Description: 
#   The following code implements a bayesian model to predict if the chunks has has_space value as 1 
#   using the basic idea from this link: 
#           https://en.wikipedia.org/wiki/Naive_Bayes_spam_filtering
#   The final prediction is based on "Combining individual probabilities" section of the wikipedia page.

#   Keyword from the wikipedia used in the following code
#       P(S) probability any given chunk has space
#       P(H) probability any given chunk has NO space
#       P(S|W_i) probability any given chunk has space given the word W_i in the chunk
#       P(H|W_i) probability any given chunk is has space given the word W_i in the chunk
#       P(W_i|S) probability the word W_i appears in a has space chunk


# Parameters description of class bayesian_filtering: 
#    word_size_threshold: 
#         if word_size_threshold=4, then if a word has count less than 4 throughout
#         the trading data, we don't use it to predict 
#    word_significance_threshold: 
#         if word_size_threshold=0.2, it means a word has P(S|W_i) larger than 0.2 
#         and smaller than 1-0.2 = 0.8, we don't use it to predict, because it does not
#         have enough predicting power. we use this to filter out keywords like "are", "is"
#         which shows up a lot in both has_space and has_no_space chunks.
#    confidence_level: 
#         this is just a confidence level that we accept a chunk to be has_space, this value
#         applies to the first formula in "Combining individual probabilities" section of the 
#         wikipedia page mentioned above. which means if p is larger than confidence_level, then
#         we say it has space. 


class bayesian_filtering():
    
    def __init__(self,word_size_threshold=4,word_significance_threshold=0.2, confidence_level = 0.1):
        self.word_significance = {}
        self.confidence_level = confidence_level
        self.word_size_threshold = word_size_threshold
        # a threashold for P_s_w, namely we don't keep those words that don't help us make a decision
        self.word_significance_threshold = word_significance_threshold
        self.dictionary = {}
        
        
    # filter out non-ascii character, before we build word dictionary
    def filter_non_unicode(self,s):
        return "".join(str.lower(i) for i in re.sub(r'[^\x00-\x7f]',r'',s) if not (ord(i) >= 33 and ord(i) <=47) and not (ord(i) >= 58 and ord(i) <=64) )


    # X: training data,
    # y: actual tag values. 1 means the chunk has space, 0 no space
    def fit(self,X,y):
        
        if X.shape[0] != y.shape[0]:
            raise ValueError
        
        # parsing chunk column and construct word dictionary
        for i in range(X.shape[0]):
            parsed_str = self.filter_non_unicode(str(X.iloc[i]))
            has_space = y.iloc[i]
            
            for word in parsed_str.split(" "):
                try: 
                    self.dictionary[word][has_space] = self.dictionary[word][has_space] +1
                except: 
                    self.dictionary[word] = [0,0]
                    self.dictionary[word][has_space] = self.dictionary[word][has_space] +1
          
        #  P_s is : P(S) probability any given chunk has space
        #   P(H) probability any given chunk has NO space
        num_of_has_space = sum(y)
        total_chunk = X.shape[0]
        P_h = X.shape[0]
        P_s = sum(y)*1.0/X.shape[0]
        P_h = 1-P_s
        
        # P_w_s is : P(W_i|S) probability the word W_i appears in a has space chunk
        # P_w_h is P(W_i|H) probability the word W_i appears in a not has space chunk
        # first we need to filter out the keys that only shows up less than word_size_threshold times
        # second we nedd to keep STRONG indicting keys, which means, P(W_i|S) is larger than 1- word_probability_threshold 
        #        or smaller than word_probability_threshold
        # third we need to remove those keys with 1 or 0 spaciousness, because it's gonna cause invalid values when predict
        # result will be like we only use useful words to predict. 
        
        # self.word_significance, is the dict that contains only words we use to predict !
        
        for key in self.dictionary.keys():
            if sum(self.dictionary[key]) >= self.word_size_threshold:
                p_ws, p_wh = self.dictionary[key][1]*1.0/num_of_has_space*P_s, self.dictionary[key][0]*1.0/(total_chunk-num_of_has_space)*P_h
                current_word_significance = p_ws/(p_ws+p_wh)
                
                if (current_word_significance >= 1 - self.word_significance_threshold and current_word_significance<1.0) or (current_word_significance <= self.word_significance_threshold and current_word_significance >0.0):
                    self.word_significance[key] = p_ws/(p_ws+p_wh)


    def predict(self,X):
        result = []
        
        if len(self.dictionary) ==0:
            print "Haven't fit model yet!"
            raise ValueError
        
        # parsing chunk column
        for i in range(X.shape[0]):
            parsed_str = self.filter_non_unicode(str(X.iloc[i]))

            sum_1,sum_2 = 1,1
            
            for word in parsed_str.split(" "):
                try:
                    sum_1 = sum_1 * self.word_significance[word]
                    sum_2 = sum_2 * (1- self.word_significance[word])
                except:
                    pass
            
            if sum_1/(sum_1+sum_2)> 1-self.confidence_level:
                result.append(1)   
            else:
                result.append(0)
    
        result = pd.DataFrame(result)
        return result
     
        
    # print out model stats and return model parameters
    def compare(self,y_predict,y_actual):
        
        if y_predict.shape[0] != y_actual.shape[0]:
            print "Size of y_predict and y_actual must be the same!"
            raise ValueError

        y_predict = y_predict.iloc[:,0] if len(y_predict) ==1 else y_predict 
        y_actual = y_actual.iloc[:,0] if len(y_actual.shape) != 1 else y_actual    
        y = pd.concat([y_predict,y_actual],axis=1)
        
        print "             Prediction Summary          "
        print " ----------------------------------------"
        print "Model Arguments: "
        print "                model confidence level: " , str(self.confidence_level)
        print "                Minimum frequency to accept a word : ",str(self.word_size_threshold)
        print "                Minimum significance level to accept a word: ", str(self.word_significance_threshold)
        print "Accuracy rate: " ,str(sum(y.iloc[:,0] == y.iloc[:,1])/(len(y)*1.0) )  ,"\n"     
        
        # return a map object that contains the current model parameters and predict accuracy
        return {"accuracy":sum(y.iloc[:,0] == y.iloc[:,1])/(len(y)*1.0),"confidence_level":self.confidence_level,"word_size_threshold":self.word_size_threshold,"word_significance_threshold":self.word_significance_threshold}
    
    
    
    
    
    
# main()    
if __name__ == "__main__":
    
    
    csv_file = './ra_data_classifier.csv'
    
    # create sample to fit and predict
    data_file = pd.read_csv(csv_file)
    y_actual = data_file.iloc[:,-1]
    X = data_file.iloc[:,1]
    
    best_model = None
    
    # SEARCHING FOR THE BEST MODEL PARAMETERS
    for word_size_word_size_threshold in range(3,10):
        for word_significance_threshold in range(5,30,3):
            for confidence_level in range(1,20,2):
                
                model = bayesian_filtering(word_size_threshold = word_size_word_size_threshold , word_significance_threshold = word_significance_threshold * 0.01 , confidence_level = confidence_level*0.01)
                model.fit(X,y_actual)
                y_predict=model.predict(X)
                current_model = model.compare(y_predict,y_actual) 
                
                if not best_model or current_model["accuracy"] > best_model["accuracy"] :
                    best_model = current_model
    
    print "\nBest model: ", best_model
    print "\nThis is probably the model you want to use!" 


