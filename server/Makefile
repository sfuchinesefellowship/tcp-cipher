ifndef CXX
CXX = g++
endif

INCPATH = -I../src 
CFLAGS = -std=c++11 -msse2 -lpthread -O3 -ggdb -Wall -finline-functions $(INCPATH) 


server: server.o  encrypt.o

server.o: 
    $(CXX) $(CFLAGS) -c server.cpp ../src/TCPServer.cpp ../src/TCPClient.cpp

encrypt.o:
    $(CXX) $(CFLAGS) -c encrypt.cpp


clean :  
	rm edit *.o  







