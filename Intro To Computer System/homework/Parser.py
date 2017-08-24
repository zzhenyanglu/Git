import os.path
import sys
from sys import platform
import tokenize
from xml.etree.ElementTree import Element, SubElement, tostring,ElementTree, parse
from xml.dom import minidom

##########################################################################

# Begin - Functions Definition

##########################################################################

# this function output a clean version of the raw .jack file without comments
# called XXX.parsed, XXX is the name of raw .jack file


def stripcomments(file_path_in='', file_path_out = ''):

    # Read the input file
    infile=open(file_path_in,'r')

    # Write the output file if the program is permitted to do so
    if os.path.isfile(file_path_out):
        os.remove(file_path_out)
    outfile=open(file_path_out,'a')

    in_comment = False

    for i in infile.readlines():

        line =i.strip()

        if line[0:2] == '/*':
            if line[-2:] == '*/':
                continue
            else:
                in_comment = True

        if line[0:2] == '*/':
            in_comment = False
            continue



        # if blank line or comments, skip it
        if (line =='' or line[0:2] == '//') and in_comment == False:
            continue


        # otherwise, continue to process spaces and tabs
        elif in_comment == False:
           line_len = len(line)
           for i in range(line_len-1):
               if line[i:min(line_len,i+2)] == '//':
                   line = line[0:i]
                   break
            
           line=line.strip('\t') 
           line=line+'\n'
           outfile.write(line)


    infile.close()
    outfile.close()


# read in a .jack file and then output a .XML file with tokens written in as
# XML trees
def tokenizer(file_path_in='', file_path_out = ''):

    lexical_element = {'class':'keyword','constructor':'keyword','function':'keyword',\
                       'method':'keyword','field':'keyword','static':'keyword',\
                       'var':'keyword','int':'keyword','char':'keyword','boolean':'keyword',\
                       'void':'keyword','true':'keyword','false':'keyword','null':'keyword',\
                       'this':'keyword','let':'keyword','do':'keyword','if':'keyword',\
                       'else':'keyword','while':'keyword','return':'keyword','{':'symbol',\
                       '}':'symbol','(':'symbol',')':'symbol','[':'symbol',']':'symbol',\
                       '.':'symbol',',':'symbol',';':'symbol','+':'symbol','-':'symbol',\
                       '*':'symbol','&':'symbol','|':'symbol','<':'symbol','>':'symbol',\
                       '=':'symbol','-':'symbol','/':'symbol','~':'symbol'}

    # create a token handler called "token"
    infile = open(file_path_in,'r')
    tokens=tokenize.generate_tokens(infile.readline)

    # Write the output file if the program is permitted to do so
    if os.path.isfile(file_path_out):
        os.remove(file_path_out)
    outfile=open(file_path_out,'a')

    root = Element('tokens') 

    for token in tokens:

        current_token = token[1]

        # if current_token is a \t or \n, skip it
        if current_token in ('\n','','\t'):
            continue

        # if the current token is a keyword or symbol
        elif lexical_element.has_key(current_token):
           child=SubElement(root,lexical_element[current_token])
           child.text=' '+current_token+' '

        # if current_token is numeric value / identifier / string literals
        else:

           # if current_token is string 
           if current_token[0] == '"':
               child=SubElement(root,'stringConstant')
               child.text=' '+current_token.strip('"')+' '

           # if numeric
           elif current_token.isdigit():
               child=SubElement(root,'integerConstant')
               child.text=' '+current_token+' '
               
           # if alpha
           else:
               child=SubElement(root,'identifier')
               child.text=' '+current_token+ ' '

    # output XML
    xml_out = tostring(root)
    pretty_xml = minidom.parseString(xml_out)

    # NOTICE: THE FOLLOWING LINE IS TO GET RID OF <?xml version="1.0" ?>
    # OUTPUT BY xml.dom.minidom.toprettyxml() to the first line of the .xml,
    # this is an very annoying feature coming along with this python libary,
    # which always outpuf <?xml version="1.0" ?> to the first line xml created
    # by toprettyxml() function. 

    final_xml = pretty_xml.toprettyxml(indent='')[23:]
    outfile.write(final_xml)

    infile.close()
    outfile.close()    

    # delete.parsed file
    if os.path.isfile(file_path_in):
       os.remove(file_path_in)  



def CompileClassVarDec(parent_element, start_pos):
    sub_tree=SubElement(parent_element, 'classVarDec')
    current_pos = start_pos

    # loop through token_list starting from start_pos
    # if ';' encoutered, break it, otherwise append 
    # tokens to the parent tree Element

    
    for current_pos in range(current_pos, len(token_list)):

        if token_list[current_pos] == ' ; ':
            child = SubElement(sub_tree, category_list[current_pos])
            child.text = token_list[current_pos]
            break
        
        else:
            child = SubElement(sub_tree, category_list[current_pos])
            child.text = token_list[current_pos]
    
    
    #print tostring(parent_element)
    

def CompileParameterList(parent_element, start_pos):
    sub_tree_paralist = SubElement(parent_element, 'parameterList')
    current_pos = start_pos


    for current_pos in range(current_pos, len(token_list)):

        if token_list[current_pos] == ' ) ':
            break
        
        else:
            child = SubElement(sub_tree_paralist, category_list[current_pos])
            child.text = token_list[current_pos]
    



def CompileVarDec(parent_element, start_pos):
    sub_sub_tree=SubElement(parent_element, 'varDec')
    current_pos= start_pos

    for current_pos in range(current_pos, len(token_list)):

        if token_list[current_pos] == ' ; ':
            child = SubElement(sub_sub_tree, category_list[current_pos])
            child.text = token_list[current_pos]
            break
        
        else:
            child = SubElement(sub_sub_tree, category_list[current_pos])
            child.text = token_list[current_pos]


# some.some(x,y,z)
def CompileSubroutineCall(parent_element, start_pos):
    current_pos = start_pos

    
    for current_pos in range(current_pos, current_pos + 4):
        if token_list[current_pos] == ' ( ' :
            child = SubElement(parent_element, category_list[current_pos])
            child.text = token_list[current_pos]
            break
        
        else:
            child = SubElement(parent_element, category_list[current_pos])
            child.text = token_list[current_pos]

    current_pos = current_pos +1
    CompileExpressionList(parent_element, current_pos)
    
    child = SubElement(parent_element, 'symbol')
    child.text = ' ) '


    
def CompileDo(parent_element,start_pos):
    sub_tree_do=SubElement(parent_element, 'doStatement')
    current_pos= start_pos
    

    # keyword 'do'
    child = SubElement(sub_tree_do, category_list[current_pos])
    child.text = token_list[current_pos]

    current_pos = current_pos+1
 
    CompileSubroutineCall(sub_tree_do, current_pos)
 
    # handle ';'
    child = SubElement(sub_tree_do, 'symbol')
    child.text = ' ; '

        


def CompileTerm(parent_element,start_pos):

    sub_tree_term=SubElement(parent_element, 'term')
    current_pos= start_pos    

    child = SubElement(sub_tree_term, category_list[current_pos])
    child.text = token_list[current_pos]

    #print token_list[current_pos]
    current_pos = current_pos +1

    # (-i)
    if token_list[current_pos-1] == ' ( ':
        CompileExpression(sub_tree_term,current_pos)

        child = SubElement(sub_tree_term, 'symbol')
        child.text = ' ) '

    # if ' - '        
    elif token_list[current_pos-1] == ' - ':
        CompileTerm(sub_tree_term,current_pos)

    # if ' ~ '
    elif token_list[current_pos-1] == ' ~ ':
        CompileTerm(sub_tree_term,current_pos)

    # if like a[i] 
    elif token_list[current_pos] == ' [ ':
        child = SubElement(sub_tree_term, category_list[current_pos])
        child.text = token_list[current_pos]
        current_pos = current_pos +1

        # handle inside a[ ]        
        CompileExpression(sub_tree_term,current_pos)

        # handle ' ] '
        for current_pos in range(current_pos, len(token_list)):
            if token_list[current_pos] == ' ] ':
                break

        child = SubElement(sub_tree_term, category_list[current_pos])
        child.text = token_list[current_pos]
        return

    # subroutine call a.b(c)
    elif token_list[current_pos] == ' . ':
        
        # .b(
        for current_pos in range(current_pos, current_pos+3):
            child = SubElement(sub_tree_term, category_list[current_pos])
            child.text = token_list[current_pos]

        # c
        current_pos = current_pos +1        
        CompileExpressionList(sub_tree_term, current_pos)

        # )
        child = SubElement(sub_tree_term, 'symbol')
        child.text = ' ) '
        return


    # if the term is just a identifier or keyword
    elif token_list[current_pos] == ' ) ':
        return
        
    

# x,y,z
def CompileExpressionList(parent_element,start_pos):
    sub_tree_explist=SubElement(parent_element, 'expressionList')
    current_pos= start_pos

    if token_list[current_pos] == ' ) ':
        return
    
    while(current_pos< len(token_list)):
        #print token_list[current_pos]
        if token_list[current_pos] == ' , ':
            child = SubElement(sub_tree_explist, category_list[current_pos])
            child.text = token_list[current_pos]

        elif category_list[current_pos] in ('identifier','stringConstant','integerConstant',\
                                            'keyword') or token_list[current_pos] == ' ( ':
            CompileExpression(sub_tree_explist, current_pos)

            for current_pos in range( current_pos, len(token_list)):
                if token_list[current_pos] == ' ) ':
                    if token_list[current_pos+1] == ' ; ':
                        return
                elif token_list[current_pos] == ' , ':
                    child = SubElement(sub_tree_explist, 'symbol')
                    child.text = ' , '
                    break
            
        elif token_list[current_pos] == ' ) ':
            return

        current_pos = current_pos + 1 



def CompileExpression(parent_element,start_pos):
    sub_tree_exp=SubElement(parent_element, 'expression')
    current_pos= start_pos
    brace_count = 0
    tilde_brace_count = 0

    # call CompileTerm

    while(current_pos< len(token_list)):

        # print token_list[current_pos]
        
        if token_list[current_pos] in (' + ', ' * ',' / ',' & ',' | ',\
                                       ' < ', ' > ', ' = '):

            child = SubElement(sub_tree_exp, category_list[current_pos])
            child.text = token_list[current_pos]

            # unary ' ~ '
        elif token_list[current_pos] == ' ~ ':
            CompileTerm(parent_element= sub_tree_exp, start_pos = current_pos)
            
            for current_pos in range( current_pos, len(token_list)):
                if token_list[current_pos] == ' ( ':
                    tilde_brace_count = tilde_brace_count+1
                elif token_list[current_pos] == ' ) ':
                    if tilde_brace_count <= 1:
                       tilde_brace_count = 0
                       return
                    elif tilde_brace_count > 1:
                       tilde_brace_count = tilde_brace_count -1
                elif token_list[current_pos] in (' ) ',' ; ',' { ', ' [ '):
                    return

        elif token_list[current_pos] == ' - ':
            # op ' - '
            if token_list[current_pos-1] != ' ( ':
                child = SubElement(sub_tree_exp, category_list[current_pos])
                child.text = token_list[current_pos]
                
            #  unary ' - '
            else:
                CompileTerm(parent_element= sub_tree_exp, start_pos = current_pos)
                current_pos = current_pos + 1 

        elif token_list[current_pos] in (' ) ', ' ] ', ' ; ', ' , '):
            return
        
        elif category_list[current_pos] in ('identifier','keyword'):
            CompileTerm(parent_element= sub_tree_exp, start_pos = current_pos)
            
            for current_pos in range( current_pos, len(token_list)):
                if token_list[current_pos] in (' ) ', ' ] ', ' ; ', ' , '): 
                    return
                if token_list[current_pos] in (' + ',' - ',' * ',\
                                               ' / ',' & ',' | ',' < ', ' > ',' = '):
                    child = SubElement(sub_tree_exp, category_list[current_pos])
                    child.text = token_list[current_pos]
                    break

        elif category_list[current_pos] in ('stringConstant', 'integerConstant'):
            CompileTerm(parent_element= sub_tree_exp, start_pos = current_pos)
            return

        # (j)
        elif token_list[current_pos] == ' ( ':

            CompileTerm(sub_tree_exp, current_pos)

            for current_pos in range( current_pos, len(token_list)):
                if token_list[current_pos] == ' ( ':
                    brace_count = brace_count + 1
                if token_list[current_pos] == ' ) ':
                    if brace_count <= 1:
                       brace_count = 0
                       break
                    elif brace_count > 1:
                       brace_count = brace_count -1
            
        current_pos = current_pos + 1 



  
def CompileLet(parent_element,start_pos):
    sub_tree_let=SubElement(parent_element, 'letStatement')
    current_pos= start_pos


    # handle 'let' and varName
    for current_pos in range(current_pos,current_pos+2):
        child = SubElement(sub_tree_let, category_list[current_pos])
        child.text = token_list[current_pos]

    current_pos = current_pos +1
        
    if token_list[current_pos] ==' [ ':
        child = SubElement(sub_tree_let, category_list[current_pos])
        child.text = token_list[current_pos]

        # lvalue of let
        CompileExpression(parent_element = sub_tree_let, start_pos = current_pos+1)
        current_pos = current_pos+2

    
    # IF NEXT char is ']'
    if token_list[current_pos] ==' ] ':
        child = SubElement(sub_tree_let, category_list[current_pos])
        child.text = token_list[current_pos]
        current_pos = current_pos+1

    
    if token_list[current_pos] == ' = ':
        child = SubElement(sub_tree_let, category_list[current_pos])
        child.text = token_list[current_pos]


    current_pos = current_pos+1
    # rvalue call CompileExpression
    
        
    CompileExpression(parent_element=sub_tree_let,start_pos=current_pos)

    # handle ';'
    for current_pos in range(current_pos,len(token_list)):
        if token_list[current_pos] == ' ; ':
            child = SubElement(sub_tree_let, category_list[current_pos])
            child.text = token_list[current_pos]
            return
        


def CompileIF(parent_element,start_pos):
    sub_tree_if=SubElement(parent_element, 'ifStatement')
    current_pos= start_pos

    
    # handle 'if' and '('
    for current_pos in range(current_pos, current_pos+2):
        child = SubElement(sub_tree_if, category_list[current_pos])
        child.text = token_list[current_pos]

    
    # handle expression inside if( )
    current_pos = current_pos+1
    CompileExpression(sub_tree_if, current_pos)
    brace_count = 1
    
    # Skip Expression body
    for current_pos in range(current_pos,len(token_list)):
        if token_list[current_pos] ==' { ':
            break

    current_pos = current_pos -1
          
    # handle ')' and '{'
    for current_pos in range(current_pos, current_pos+2):
        child = SubElement(sub_tree_if, category_list[current_pos])
        child.text = token_list[current_pos]


    # call CompileStatements  
    current_pos = current_pos+1
    CompileStatement(sub_tree_if, current_pos)


    # handle "}"
    child = SubElement(sub_tree_if, 'symbol')
    child.text = ' } '


    for current_pos in range(current_pos,len(token_list)):
        # if there is ' else ' statement trailing
        # go handle that

        if token_list[current_pos] ==' else ':
            break

        elif token_list[current_pos] == ' } ':
            if brace_count == 0:
                return
            else:
                brace_count = brace_count -1
        elif token_list[current_pos] == ' { ':
            brace_count = brace_count + 1
            
        
    # handle 'else' and '{'
    for current_pos in range(current_pos, current_pos+2):
        child = SubElement(sub_tree_if, category_list[current_pos])
        child.text = token_list[current_pos]

    current_pos = current_pos+1
    CompileStatement(sub_tree_if, current_pos)

    # hadnle '}'
    child = SubElement(sub_tree_if, 'symbol')
    child.text = ' } '




        
def CompileWhile(parent_element,start_pos):
    sub_tree_while=SubElement(parent_element, 'whileStatement')
    current_pos= start_pos


    # handle 'while' and '('
    for current_pos in range(current_pos, current_pos+2):
        child = SubElement(sub_tree_while, category_list[current_pos])
        child.text = token_list[current_pos]

    current_pos = current_pos +1
    #print token_list[current_pos]

    CompileExpression(sub_tree_while, current_pos)

    # Skip Expression body
    for current_pos in range(current_pos,len(token_list)):
        if token_list[current_pos] ==' ) ':
            break

    #print token_list[current_pos]
    # handle ')' and '{'
    for current_pos in range(current_pos, current_pos+2):
        child = SubElement(sub_tree_while, category_list[current_pos])
        child.text = token_list[current_pos]
    
    current_pos = current_pos +1
    #print token_list[current_pos]
                      
    # call CompileStatements              
    CompileStatement(sub_tree_while, current_pos)

    child = SubElement(sub_tree_while, 'symbol')
    child.text = ' } '
    
    

def CompileReturn(parent_element,start_pos):
    sub_tree_return = SubElement(parent_element, 'returnStatement')
    current_pos = start_pos

    # handle keyword 'return '

    child = SubElement(sub_tree_return, category_list[current_pos])
    child.text = token_list[current_pos]

    current_pos = current_pos +1

    if token_list[current_pos] != ' ; ':
        CompileExpression(sub_tree_return, current_pos)   

    # handle  symbol ' ; ' 
    for current_pos in range(current_pos,len(token_list)):
        if token_list[current_pos] == ' ; ':
            child = SubElement(sub_tree_return, category_list[current_pos])
            child.text = token_list[current_pos]
            break


def CompileStatement(parent_element,start_pos):       

    # Call CompileStatement
    sub_tree_statements=SubElement(parent_element, 'statements')
    current_pos = start_pos
    brace_count = -1

    while(current_pos<=len(token_list)):            
       
        # CompileDo
        if token_list[current_pos] == ' do ':
            CompileDo(sub_tree_statements,current_pos)
        
        # CompileLet
        elif token_list[current_pos] == ' let ':
            CompileLet(sub_tree_statements,current_pos)
            
        # CompileWhile
        elif token_list[current_pos] == ' while ':
            CompileWhile(sub_tree_statements,current_pos)

            # skip all the statements within while{ }
            for current_pos in range(current_pos, len(token_list)):

                if token_list[current_pos] == ' { ':
                    brace_count = brace_count+1
                
                if token_list[current_pos] == ' } ':

                    if brace_count <= 0:
                        #print token_list[current_pos]
                        break
                    
                    else:
                        brace_count = brace_count-1                  
            brace_count = -1
            
        # CompileIF
        elif token_list[current_pos] == ' if ':
   
            CompileIF(sub_tree_statements,current_pos)

            for current_pos in range(current_pos, len(token_list)):
                    
                if token_list[current_pos] == ' } ':
                    break
                     
            current_pos = current_pos + 1 
            
            # if there is else statement
            if token_list[current_pos] == ' else ':
                for current_pos in range(current_pos, len(token_list)):                     
                    if token_list[current_pos] == ' } ':
                        break
                        
            else:
                current_pos = current_pos - 1  
            #print token_list[current_pos],current_pos
            #print token_list[current_pos+1],current_pos+1
            
        # CompileReturn
        elif token_list[current_pos] ==' return ':

            CompileReturn(sub_tree_statements, current_pos)        
            break

        elif token_list[current_pos] == ' } ':
            break
        
        current_pos = current_pos +1


def CompileSubroutineDec(parent_element, start_pos):
    sub_tree_subdec=SubElement(parent_element, 'subroutineDec')

    current_pos = start_pos

    # handle everything all the way until '('
    for current_pos in range(current_pos, len(token_list)):

        if token_list[current_pos] == ' ( ':
            child = SubElement(sub_tree_subdec, category_list[current_pos])
            child.text = token_list[current_pos]
            break
        
        else:
            child = SubElement(sub_tree_subdec, category_list[current_pos])
            child.text = token_list[current_pos]

    
    # call CompileParameterList
    current_pos = current_pos + 1
    CompileParameterList(parent_element=sub_tree_subdec, start_pos=current_pos)


    # repos current_pos
    for current_pos in range(current_pos, len(token_list)):
        if token_list[current_pos] == ' ) ':
            break

    # handle ')'
    child = SubElement(sub_tree_subdec, category_list[current_pos])
    child.text = token_list[current_pos]
    current_pos = current_pos +1
    
    CompileSubroutineBody(parent_element=sub_tree_subdec, start_pos=current_pos)   

      
   


def CompileSubroutineBody(parent_element,start_pos):
    sub_tree_subroutinebody=SubElement(parent_element, 'subroutineBody')
    current_pos= start_pos

    # count "{" to decide the end of body
    brace_count = 0


    # for "{"
    child = SubElement(sub_tree_subroutinebody, category_list[current_pos])
    child.text = token_list[current_pos]

    current_pos = current_pos +1

    # Call CompileVarDec IF THERE IS ANY Var Declaration
    
    for current_pos in range(current_pos, len(token_list)):

        # case 1 - var dec
        if token_list[current_pos] == ' var ':
            CompileVarDec(parent_element=sub_tree_subroutinebody,start_pos=current_pos)
        
        elif token_list[current_pos] in (' return ',' let ',\
                                         ' while ',' if ', ' do '):
            break

        # count how many "{" we have seen to decide if
        # that's the end of statements
        elif token_list[current_pos] ==' { ':
            brace_count = brace_count +1
            continue

        elif token_list[current_pos] == ' } ':
            if brace_count == 0 :
                break
            else:
                brace_count = brace_count - 1


    # call CompileStatement 
    CompileStatement(parent_element=sub_tree_subroutinebody, start_pos = current_pos)
    
    # for '}'
    child = SubElement(sub_tree_subroutinebody, 'symbol')
    child.text = ' } '

    




def CompileClass(parent_element, start_pos):
    current_pos = start_pos 

    # handle 'class' , classname and '{'                
    for current_pos in range(current_pos, current_pos+3):
        child = SubElement(parent_element, category_list[current_pos])
        child.text = token_list[current_pos]

    # repos to the next token 
    current_pos = current_pos + 1
                      
    # handle class members 
    for current_pos in range(current_pos, len(token_list)):

              
        # CASE 1 - if the current token indicates a class var declaration
        if token_list[current_pos] in (' static ',' field '):
            
            CompileClassVarDec(parent_element=parent_element, start_pos=current_pos)

        # CASE 2 - if the current token indicates a subroutine declaration
        elif token_list[current_pos] in (' constructor ',' function ',' method '):
            
            CompileSubroutineDec(parent_element=parent_element, start_pos=current_pos)


    child = SubElement(parent_element, 'symbol')
    child.text = ' } '

    #print tostring(parent_element)    

def CompileEngine(file_path_in, file_path_out):     

    # root_in is the XML tree output by
    # tokenizerm, aka, the output of step one
    # of the project
    
    tree_in = parse(file_path_in)
    root_in = tree_in.getroot()

    # convert the XML read in into 2 lists
    # one contains the tokens, the other contains
    # what kind of token it is, respectively


    # I KNOW THIS IS UGLY, AND IF THERE IS NEXT TIME
    # THEN I WILL BUILD A OBJECT-ORIENTED STRUCTURE
    # WITH A CLASS 
    global token_list
    token_list =[]

    global category_list
    category_list=[]

    for i in root_in.iter():
        token_list.append(i.text)
        category_list.append(i.tag)

    # skip the first token because it's '<token>'
    token_list=token_list[1:]
    category_list=category_list[1:]

    # initiate a XML tree, pass it to CompileClass
    # root_out contains the final output XML tree
    root_out = Element('class')

    # call CompileClass
    CompileClass(parent_element=root_out,start_pos=0)

    xml_out = tostring(root_out, method = 'html')
    
    pretty_xml = minidom.parseString(xml_out)

    
    # NOTICE: THE FOLLOWING LINE IS TO GET RID OF <?xml version="1.0" ?>
    # OUTPUT BY xml.dom.minidom.toprettyxml() to the first line of the .xml,
    # this is an very annoying feature coming along with this python libary,
    # which always outpuf <?xml version="1.0" ?> to the first line xml created
    # by toprettyxml() function. 

    final_xml = pretty_xml.toprettyxml(indent='  ')[23:]

    if os.path.isfile(file_path_out):
        os.remove(file_path_out)
    outfile=open(file_path_out,'a')

    outfile.write(final_xml)
    outfile.close()



##########################################################################

# Begin - Functions Definition

##########################################################################




##########################################################################

# Begin - main function

##########################################################################


# PLEASE INPUT PROGRAME PARAMETERS

if len(sys.argv) == 2:
    dir_path=sys.argv[1]
else:
    print "Paser.py TAKES EXACTLY 1 ARGUMENT!"


    

# if it is relative path get the current working directory
if dir_path == '' or dir_path == './':
    dir_path = os.getcwd()

# IF THE SPECIFIED PARAMETER IS A DIRECTORY AND IT EXSITS
if os.path.isdir(dir_path):

    print "directory you specified is " + dir_path + "\n"

    # ~/XML/xxx.xml
    out_file_dir = os.path.join(dir_path,'XML')    

    if os.path.isdir(out_file_dir) == False:
        os.mkdir(out_file_dir)

    
    # LOOP THRU THE DIRECTORY AND TRANSLATE ALL .JACK FILES
    for i in os.walk(dir_path).next()[2]:
        
        # IF THE CURRENT FILE IS .JACK
        if i.find(".jack") ==-1:
            continue
        
        else:
            print "found " + i +" countinue.."

            # create input file name and output file name xxx.parsed xxx.xml xxxT.xml
            file_path_in = os.path.join(dir_path, i)
            file_out_parsed = i.split('.')[0] +'.parsed'
            file_out_txml = i.split('.')[0] +'T.xml'
            file_out_xml = i.split('.')[0] +'.xml'

            # create path for output files
            path_out_parsed = os.path.join(out_file_dir,file_out_parsed)  
            path_out_txml = os.path.join(out_file_dir,file_out_txml)
            path_out_xml = os.path.join(out_file_dir,file_out_xml)
            
        

            # kick off the program for each .jack file found
            stripcomments(file_path_in, path_out_parsed)
            tokenizer(path_out_parsed,path_out_txml)
            CompileEngine(path_out_txml, path_out_xml)
            
        
    
# IF THE SPECIFIED PARAMETER IS A FILE AND IT EXSITS

elif  os.path.isfile(dir_path):
    print "found " + dir_path +" continue..."
    
    file_name = os.path.basename(dir_path)
    file_dir = os.path.dirname(dir_path)
    out_file_dir = os.path.join(file_dir,'XML')
    file_out_parsed = file_name.split('.')[0] +'.parsed'
    file_out_txml = file_name.split('.')[0] +'T.xml'
    file_out_xml = file_name.split('.')[0] +'.xml'
    path_out_parsed = os.path.join(out_file_dir,file_out_parsed)  
    path_out_txml = os.path.join(out_file_dir,file_out_txml)
    path_out_xml = os.path.join(out_file_dir,file_out_xml)
    

    if os.path.isdir(out_file_dir) == False:
        os.mkdir(out_file_dir)

    stripcomments(dir_path, path_out_parsed)
    tokenizer(path_out_parsed,path_out_txml)
    CompileEngine(path_out_txml, path_out_xml)    
    

# IF INCORRECT FILE OR DIRECTORY PATH
else:
    print "directory or file "+dir_path+" does not exist!"


##########################################################################

# End - main function

##########################################################################
