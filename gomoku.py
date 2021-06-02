import numpy as np
import socket
import time
import sys

recv_buffer = 20000

class straight_five():
    
    def __init__(self, role, connect, board_size, winning_size):
        self.board_size = board_size
        self.winning_size = winning_size
        self.connect = connect  
        self.has_winner = False
        self.winner = None
        
        # chicken is -1 x duck is 1 o
        self.players = ['chicken','duck']
        
        if role in self.players:
            self.role = role
        
        else:
            print('Player must be either chiken or duck')
            quit()
        
        self.launch_board()
                       
        
    def update_board(self,board):
        self.board= board
            
        
    def send_board(self, last_move):       
        self.connect.send(last_move + "|" + self.board.tostring())
        
        
    def receive_board(self):
        print("Waiting for opponent to play..")
        
        msg=self.connect.recv(recv_buffer).split("|")
        print("Opponent has made a move at "+ msg[0] +"\n")
        
        board = np.fromstring(msg[1])
        board = board.reshape(self.board_size,self.board_size)
        
        self.update_board(board)
        
    
    def launch_board(self):
        self.board= np.zeros([self.board_size,self.board_size])
    
    
    def print_board(self):
        
        current_row =" "
        
        for i in range(self.board_size):
            current_row = current_row + ( " " if i/10==0 else str(i/10) )+" " 
             
        current_row = current_row +"\n "
        for i in range(self.board_size):
            current_row = current_row + str(i%10)+" " 
                     
        current_row = current_row +"\n"
                
        for i in range(len(self.board)): 
            current_row = current_row +"|"
            for j in self.board[i]:                
                if j == 0:
                    current_row = current_row + "_|"
                elif j == 1:
                    current_row = current_row + "o|"
                else:
                    current_row = current_row + "x|"
                    
            if i <10:        
                current_row = current_row + str(i) +"\n"   
            else: 
                current_row = current_row + str(i) +"\n" 
                
        print(current_row)
        
        
    def check_winner(self):
        # check horizontal
        for i in range(self.board.shape[0]):
           
            for j in range(self.board_size-self.winning_size+1):
                if sum(self.board[i][0+j:self.winning_size+j]) == self.winning_size:
                    self.has_winner = True
                    self.winner = 'duck'
                    
                elif sum(self.board[i][0+j:self.winning_size+j]) == -self.winning_size:
                    self.has_winner = True
                    self.winner = 'chicken'
        
        # check vertical
        for i in range(self.board.shape[0]): 
            for j in range(self.board_size-self.winning_size+1):
                if sum(self.board[:,i][0+j:self.winning_size+j])  == self.winning_size:
                    self.has_winner = True
                    self.winner = 'duck'
                    
                elif sum(self.board[:,i][0+j:self.winning_size+j]) == -self.winning_size:
                    self.has_winner = True
                    self.winner = 'chicken'
                
        # diagonal
        for i in range(self.board.shape[0]):
            for j in range(self.board.shape[1]):
                sums = 0
                
                for k in range(self.winning_size):
                    
                    if i+k <= self.board.shape[0]-1 and j+k <= self.board.shape[1]-1:
                        sums = sums + self.board[i+k][j+k]
                    else: 
                        break
                        
                if sums == self.winning_size:
                    self.has_winner = True
                    self.winner = 'duck' 
                    
                elif sums == -self.winning_size:
                    self.has_winner = True
                    self.winner = 'chicken' 
                    
                else:
                    i = i + 1
            j = j + 1
                   
        # diagonal
        for i in range(self.board.shape[0]):
            for j in range(self.board.shape[1]):
                sums = 0
                
                for k in range(self.winning_size):
                    
                    if i+k <= self.board.shape[0]-1 and j+k <= self.board.shape[1]-1:
                        sums = sums + self.board[i+k][j+k]
                    else: 
                        break
                if sums == self.winning_size:
                    self.has_winner = True
                    self.winner = 'duck'
                                   
                elif sums == -self.winning_size:
                    self.has_winner = True
                    self.winner = 'chicken'
                
                else:
                    j = j + 1
            i = i + 1
       
        
        # reverse diagonal
        for i in range(self.board.shape[0]):
            for j in range(self.board.shape[1]):
                sums = 0
                
                for k in range(self.winning_size):                   
                    if i-k <= self.board.shape[1]-1 and j+k <= self.board.shape[1]-1:
                        sums = sums + self.board[i-k][j+k]
                    else:
                        break
                    
                if sums == self.winning_size:
                    self.has_winner = True
                    self.winner = 'duck'
                                   
                elif sums == -self.winning_size:
                    self.has_winner = True
                    self.winner = 'chicken'                   
                else:
                    i = i +1        
            j = j - 1
                
            
        # reverse diagonal
        for i in range(self.board.shape[0]):
            for j in range(self.board.shape[1]):
                sums = 0
                
                for k in range(self.winning_size):                   
                    if i-k >= 0 and j+k <= self.board.shape[1]-1:
                        sums = sums + self.board[i-k][j+k]
                    else:
                        break
                    
                if sums == self.winning_size:
                    self.has_winner = True
                    self.winner = 'duck'               
                elif sums == -self.winning_size:
                    self.has_winner = True
                    self.winner = 'chicken'
                else:
                    i = i - 1        
            j = j + 1
            

        if self.has_winner:
            
            if self.winner is None:
                print(" Somebody has won!")
            else:
                print(self.winner +" has won!")
                
            return True       
        return False
        
                    
    def play(self):

        move = raw_input("Please input your next move, like 5,5:\n")    
        
        if move =="0":
            sys.quit()
        
        if move.find(",") >-1:
            move = move.split(",")
        elif move.find(".") >-1:
            move = move.split(".")
        elif move.find(" ") >-1:
            move = move.split(" ")
        else:
            print("Please specify your move like 1,2\n")
            self.play()
            return
        
        move = [int(move[0]),int(move[1])]    
            
        if move[0] >= self.board_size or move[1] >= self.board_size or move[0] <0 or move[1] < 0:
            print("Move out of board size!")
            self.play()
            return
        
        elif type(move) not in (tuple,list):
            print("Please specify your move like 1,2\n")
            self.play()
            return
        
        elif self.board[move[0]][move[1]] == 0 :      
            
            if self.role == "chicken":
                self.board[move[0]][move[1]] = -1
            else:
                self.board[move[0]][move[1]] = 1
                
        elif self.board[move[0]][move[1]] in (-1,1) :
            print(str(move[0]) +" "+ str(move[1]) + " has been taken, choose another one\n")
            self.play()
            return
        
        else:
            print("Unknown command, please try again")
            self.play()
            return
        
        print("You have made a move at "+ str(move[0]) + ","+ str(move[1]) + ", opponent turn now\n")
        self.send_board(str(move[0]) + ","+ str(move[1]))
        self.print_board()

            
def client(hostname):

    print("Attempting to connect to "+hostname)
    sock = socket.socket()
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    host = socket.gethostbyname(hostname)
    port = 20078
    
    sock= socket.socket()
    
    try: 
        sock.connect((host,port))
    except:
        print("Unable to connect to "+host)
        return 
    
    print("Successfully connect to "+hostname)
    sock.send("Hello from "+socket.gethostname())
    print("Opponent says:" )
    print(sock.recv(recv_buffer))
    
    return sock
                                           


def server():
    
    sock = socket.socket()
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    host = socket.gethostname()
    port = 20078
    sock.bind((host, port))
    sock.listen(1000)
    
    print("Waiting for player to join..")
    client_sock, client_address = sock.accept()   
    print("Opponent has connected!")
    client_sock.send('Hello from '+ host)
    
    print("Opponent says: ")
    print(client_sock.recv(recv_buffer))
    
    return client_sock
    

def initiate_game():
    
    print("Hello!" )
    print("Welcome to Straight Five........")
    print("COPYRIGHTS Reserved by QRM, 2017 July 18")    
    
    host_type = input("1. Hosting a game\n2. Joining a game\n")
    
    if host_type == 1:
        
        board_size = 0
        winning_size = 0
        
        while True:    
            
            board_size = input("Specify a size of board:\n")
            
            if board_size <=20 and board_size >=5:                
                break
            else:
                print("Size of board must be between 5 and 10!")
                continue
            
        while True:    
            winning_size = input("Specify a winning number:\n")
            
            if winning_size <board_size and winning_size >0:
                break    
            print("Winning can not be smaller or larger than " + str(board_size))
        
        connect = server()
        
        print("Size of board is " + str(board_size))
        print("Winning number is " + str(winning_size))
        
        # send confirmation
        connect.send("Begin|"+str(board_size)+"|"+str(winning_size))
            
        message_back = connect.recv(recv_buffer)
        
        if message_back.startswith("Initialization done"):
            print("you are playing as duck!(x)\n")
            game = straight_five('duck', connect, board_size, winning_size)
        
        # sync up with two sides
        for i in range(3):
            print("Game will start in "+ str(3-i)+ " second(s)..")
            time.sleep(1)
        
    elif host_type == 2:
        
        hostname = raw_input("Please specify host name: ")
        connect = client(hostname)
        if connect is not None:
            print("Waiting for opponent to initialize..." )
        else:
            return 
        
        initial = connect.recv(recv_buffer)
        if initial.startswith("Begin"):
            _,board_size,winning_size = initial.split("|")
            connect.send("Initialization done")
            print("Size of board is " + board_size)
            print("Winning number is " + winning_size)
            print("you are playing as chicken!(o)\n")
            game = straight_five('chicken', connect, int(board_size), int(winning_size))
        
        else:
            print("Fail to recognize initialization message..\n")
            return
        
        # sync up with two sides
        for i in range(3):
            print("Game will start in " + str(3-i)+ " second(s)..")
            time.sleep(1)          
    return game



def main():
    
    game = initiate_game()    
    
    if game.role == 'duck':
        game.print_board()
        game.play()
         
        
    while not game.check_winner():
        
        game.receive_board()
        game.print_board()
        
        if not game.check_winner():       
            game.play()
            
    response = input("Press 1 to restart the game, other keys to quit..")
    
    if response ==1:
        main()
    
    
main()