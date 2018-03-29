#include <iostream>
#include "TCPServer.h"

TCPServer tcp;

void * loop(void * m)
{
        pthread_detach(pthread_self());
	while(1)
	{
		srand(time(NULL));
		string str = tcp.getMessage();
		if( str != "" )
		{
			cout << "Message:" << str << endl;
			tcp.Send(" [client message Received at Server: "+str+"] ");
			tcp.clean();
		}
		usleep(1000);
	}
	tcp.detach();
}

int main()
{
	pthread_t msg;
	tcp.setupBind(9998);
	if( pthread_create(&msg, NULL, loop, (void *)0) == 0)
	{
		tcp.receive();
	}
	return 0;
}
