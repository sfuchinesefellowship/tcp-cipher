#include <iostream>
#include <signal.h>
#include "TCPClient.h"
#include <string>

TCPClient tcp;

void sig_exit(int s)
{
	tcp.exit();
	exit(0);
}

int main(int argc, char *argv[])
{
	signal(SIGINT, sig_exit);

	tcp.setupBind("127.0.0.1",9998);
	while(1)
	{
		string Msg = "This is the message from client!";

		srand(time(NULL));
		tcp.Send(Msg);
		string rec = tcp.receive();
		if( rec != "" )
		{
			cout << "Server Response:" << rec << endl;
		}
		sleep(1);
	}
	return 0;
}
