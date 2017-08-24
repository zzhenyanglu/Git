from sas7bdat import *
import os
import pandas as pd
import time
import sqlalchemy as mssql

class canoli():

   def __init__(self,file_path,*query):
       print 
       '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n',\
       ' COGENSIA INNOVATION PROJECT REPLICATE SAS MACROS ON PYTHON           \n',\
       ' WE CURRENTLY SUPPORT CSV PDM SAS7BDAT(BETA)                          \n',\
       ' YOUR DATA PATH SHOULD BE INDENTICAL C:/FELIXLU/HAHA.PDM              \n',\
       ' YOUR PATH:                                                           \n',\
       '            %s    \n' %(file_path)                                       ,\
       '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n',\
       ' HAHAHAHA \n'
       if str(type(file_path)).find("DataFrame") > 0: 
           self.the_data = file_path
           self.file_path = str(file_path.size) + "values"
           self.file_type = "DataFrame"
       
       elif file_path.strip().split(".")[0].lower() == "base":
           self.file_path = "P:/CACDIRECT/DATA/BASE_DEMO/B/" + file_path.strip().split(".")[1].lower() +".sas7bdat"
           self.file_type = "sas7bdat"
           
           try:
               self.read_in_object = SAS7BDAT(os.path.abspath(self.file_path))
               self.the_data = self.read_in_object.to_data_frame()
           except:
               pass
           
       elif file_path.strip().lower() == "cogensia_movers":
           engine = mssql.create_engine('mssql://mmattingly:BearDown_15@216.157.38.64/CAC_DIRECT')
           connection = engine.connect()
           self.file_path ="cogensia_movers"
           self.file_type = "mssql"
           
           if len(query) ==0:
               print "The file you are trying to query is too big, spare me please!" 
           else:    
               self.the_data = pd.read_sql_query(sql = query[0],con=engine)           
           
       elif os.path.isfile(file_path):
         
           try: 
              self.file_path = file_path
              self.file_type = file_path.split(".",2)[1]

              if self.file_type not in ("txt","pdm","sas7bdat","csv"):
                  print "File type does not support for %s" % (self.file_type) 
           
              elif self.file_type == "pdm": 
                  self.the_data =  pd.read_csv(filepath_or_buffer = self.file_path, \
                                            parse_dates= True, keep_date_col = True,sep="|")
            
              elif self.file_type == "sas7bdat":
                  self.read_in_object = SAS7BDAT(os.path.abspath(self.file_path))
                  self.the_data = self.read_in_object.to_data_frame()
               
              elif self.file_type == "csv":
                  self.the_data =  pd.read_csv(filepath_or_buffer = self.file_path, \
                                            parse_dates= True, keep_date_col = True)
           except Exception as msg:
              print msg 
            
    
   def qc(self):
       if self.file_type =="mssql":
           report_header["FILE_NAME"] = "cogensia_movers"
           report_header["FILE_TYPE"] = self.file_type
           report_header["PATH"] = self.file_path
           report_header["SIZE"] = "unknown"
           report_header["RECENT_ACCESS_DATE"] = "unknown"
           report_header["MODIFIED_DATE"] = "unknown"
           report_header["CREATION_DATE"] = "unknown"
           
       elif str(type(file_path)).find("DataFrame") > 0: 
           report_header["FILE_NAME"] = "DataFrame"
           report_header["FILE_TYPE"] = self.file_type
           report_header["PATH"] = self.file_path
           report_header["SIZE"] = "unknown"
           report_header["RECENT_ACCESS_DATE"] = "unknown"
           report_header["MODIFIED_DATE"] = "unknown"
           report_header["CREATION_DATE"] = "unknown"            
       
       else:
       # report_draft = [len(self.the_data.columns)][attributes]
           report_header["FILE_NAME"] = self.file_path.split(".")[0].split("/")[-1]
           report_header["FILE_TYPE"] = self.file_type
           report_header["PATH"] = self.file_path
           report_header["SIZE"] = str(os.stat(self.file_path).st_size/1048576.0)+" MB" 
           report_header["RECENT_ACCESS_DATE"] = time_ctime(os.stat(self.file_path).st_atime)
           report_header["MODIFIED_DATE"] = time_ctime(os.stat(self.file_path).st_mtime)
           report_header["CREATION_DATE"] = time_ctime(os.stat(self.file_path).st_ctime)
           
       report_header["NUMBER_OF_OBSSERVATION"] = self.the_data.shape[0]
       report_header["NUMBER_OF_VARIABLES"] = self.the_data.shape[1]
       
       for col in self.the_date.columns:
           # NOTE 1 - try to determine type of the current columnm       
           col_type = 'Numeric' 
           try: self.the_data[col].max()/1.0 
           except Exception: col_type = 'Character'
    
           # NOTE 2 - if type of the column is numeric then give me min max mean med 
           if col_type =='Numeric':
               col_max = self.the_data[col].max()
               col_min = self.the_data[col].min()
               col_mean = self.the_data[col].mean()
               col_med = self.the_data[col].median()
           else:
               col_max = None
               col_min = None
               col_mean = None
               col_med = None
           
           #NOTE 3 - try to get a nonzero and nonmissing example value of the current column
           sample = self.the_data[col].head(500)
           nmiss_sample = sample[sample.notnull()]
           nzero_nmiss_sample = nmiss_sample[nmiss_sample != 0][1]
           
           # NOTE 4 - how many levels
           col_level = len(a['Sales'].unique()) 
           
           # NOTE 5 - if levels smaller than 8 then print it out 
           if col_level < 8:
              value_dist = self.the_data[col].value_counts().to_dict()
           else: value_dist = {}
                 
           #create report body
           report_body[col] = {"N_OBS":report_header["NUMBER_OF_OBSSERVATION"],\
                               "N_missing":sum(self.the_data[col].notnull()==False),\
                               "N_zero":sum(self.the_data[col]==0),\
                               "Numeric_or_Character":col_type,\
                               "Python_format":type(self.the_data[col][0]),\
                               "Levels":col_level,\
                               "Value_sample":nzero_nmiss_sample,\
                               "Maximum":col_max,\
                               "Minimum":col_min,\
                               "Mean":col_mean,\
                               "Median":col_med,\
                               "level_frequency":value_dist,\
                              }
       return report_header,report_body
    
    
    def _is_numeric(self,column):
        col_type = True
        
        try: 
            self.the_data[column][self.the_data[column].notnull()][0]/1.0
        except Exception:
            col_type = False
            
        return col_type
        
    def nobs(self):
        return self.the_data.shape[0]
        
         
    def _fillmiss(self,column,value_to_fill):
        if value_to_fill == "mean":
            self.the_data[column][self.the_data[column].isnull()] = self.the_data[column].mean()
        if value_to_fill == "median":
            self.the_data[column][self.the_data[column].isnull()] = self.the_data[column].median()
        if value_to_fill in ("ffill","bfill"):
            self.the_data[column].fillna(method=value_to_fill,inplace =True)
            
    def fillmiss(columns=[],value="mean"):
        if len(columns) == 0:
            for i in self.the_data.columns:
                if self._is_numeric(i):
                    self._fillmiss(column=i,value_to_fill = value)
        else:
            for i in columns:            
                if self._is_numeric(i):
                    self._fillmiss(column=i,value_to_fill = value)        
                
    def _outlier(self,column):
        upbound = ha.describe(percentiles=[.01,.99])[0]["99%"]
        lowbound = ha.describe(percentiles=[.01,.99])[0]["1%"]
        
        self.the_data[column][self.the_data[column] > upbound] = upbound
        self.the_data[column][self.the_data[column] < lowbound] = lowbound   
        
    def outliers(self,columns=[]):
        if len(columns) == 0:
            for i in self.the_data.columns:
                if self._is_numeric(i):
                    self._outlier(column=i)
        else:
            for i in columns:            
                if self._is_numeric(i):
                    self._outlier(column=i)
    def col_hist(self,column,bin):
        self.the_data[column].hist(bins=bin)
    
    def sort(self,by_col=[],ascend=True):
        self.the_data.sort_index(by=by_col,ascending = ascend,inplace = True)
    
    def freq(self,column):
        counts = self.the_data[column].value_counts()
        percent = self.the_data[column].value_counts()/len(self.the_data)
        cum_sum = self.the_data[column].value_counts().cumsum()/len(self.the_data)
        
        freq_report = pd.concat([counts,percent,cum_sum],axis=1)
        
    def tval(self,keep_col =[],val_size=0.4,val_sampl_name,exp_sampl_name):

        universe = self.the_data.drop(keep_col,axis=1)
        universe["seed"] = pd.Series(np.random.random(len(self.the_data)))
        threshold = universe["seed"].quantile(q=0.4)
        
        val_sample = universe[universe["seed"]<threshold]
        exp_sample = universe[universe["seed"]<threshold]

        val_sampl_name = canoli(file_path=val_sample)
        exp_sampl_name = canoli(file_path=exp_sample)
        
    def __repr__(self):        
        print self.the_data
        
    def crosstab(self,col_a,col_b,tab_type="count"):
        if tab_type =="count":
            pd.crosstab(self.the_data[col_a],self.the_data[col_b])  
        elif tab_type =="percent":
            pd.crosstab(self.the_data[col_a],self.the_data[col_b]).apply(lambda r.astype("float"): r.astype("float")/r.sum(), axis=1)  
    
    def flat(self,path,cols_output,delimiter):
        self.DataFrame.to_csv(path_or_buf=path,sep=delimiter,columns=cols_output)
        
    def proc_content(self):
        contents = pd.DataFrame(self.the_data.columns)         
        contents.columns=["variables"]
        
        for i in contents["variables"]:
            if self.the_data._is_numeric(i):
                type_list.append("numeric")
            else:
                type_list.append("character")
        
        contents["variable_type"] = type_list
            
        return contents 
        
        a=SAS7BDAT(os.path.abspath("C:/Users/felixlu/Desktop/v12.sas7bdat")).to_data_frame()        
        
        
        
    def parsimony(self,inplace=False,keep_clean=1, keep_keys=1, keep_pieces=1, pname_form=2, pname1=, pname2=, paddr_form=2, paddr1=, paddr2=, pstate=, pzip=,ptestobs=10):
        
        experiment = self.the_data.head(ptestobs)
        
        #  PREP NAME/ADDR
        
        if paddr_form ==2:
            experiment["paddr"] = experiment[paddr1].str.strip().str.upper() + " " +  experiment[paddr2].str.strip().str.upper()
        elif paddr_form == 1:
            experiment["paddr"] = experiment[paddr1].str.strip().str.upper()
            
        if pname_form ==2:
            experiment["pname"] = experiment[pname1].str.strip().str.upper() + " " +  experiment[pname2].str.strip().str.upper()
        elif pname_form == 1:
            experiment["pname"] = experiment[pname1].str.strip().str.upper()        
        
        experiment["mk_scf"] = experiment[pzip].str.slice(0,3)
        experiment["st_scf"] = experiment[pstate] +"_"+ experiment["mk_scf"] 
        
        # REMOVE COMMA EXCESSIVE BLANKS 
        experiment["name_c"] = experiment["pname"].str.replace(" +"," ").str.strip().str.replace(",","").str.replace("*","").str.replace(".","").str.replace("'","")
         
        # NOW COMPRESS OUT THE COMMA AND COUNT THE NUMBER OF WORDS
        experiment["namect"] = experiment["name_c"].str.split(" ").apply(lambda r:len(r))
        
        # GET FIVE NAMES
        try:
            experiment["name1"] = experiment["name_c"].str.split(" ").apply(lambda r:r[0])
        except IndexError:
            experiment["name1"] = " "          
            
        try:
            experiment["name2"] = experiment["name_c"].str.split(" ").apply(lambda r:r[1])
        except IndexError:
            experiment["name2"] = " " 
        
        try:
            experiment["name3"] = experiment["name_c"].str.split(" ").apply(lambda r:r[2])
        except IndexError:
            experiment["name3"] = " " 
            
        try:
            experiment["name4"] = experiment["name_c"].str.split(" ").apply(lambda r:r[3])
        except IndexError:
            experiment["name4"] = " " 
        
        try:
            experiment["name5"] = experiment["name_c"].str.split(" ").apply(lambda r:r[4])
        except IndexError:
            experiment["name5"] = " " 
            
        experiment["suffix"] = experiment["name_c"].str.split(" ").apply(lambda r:r[-1])
        
        #SUFFIX 

        experiment["suffix"][experiment["suffix"].str.contains('JR','SR','SENIOR','PHD','PROF','PROFESSOR','I','II','III','IV','V','DDS','MD','CPA','CAPTAIN','DO','FR) ==False] =" "          
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
   

