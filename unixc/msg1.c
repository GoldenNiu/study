/*************************************************************************
	> File Name: msg1.c
	> Author: 
	> Mail: 
	> Created Time: 2017年04月20日 星期四 15时33分46秒
 ************************************************************************/

#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<errno.h>
#include<unistd.h>

#include<sys/msg.h>

struct my_msg_st {
    long int my_msg_type;
    char some_text[BUFSIZ];
};

int main()
{
    int running = 1;
    int msgid;
    struct my_msg_st some_data;
    long int msg_to_receive = 0;
    
    //creat ipc
    msgid = msgget((key_t)1234, 0666 | IPC_CREAT);
    if (msgid == -1)
    {
        fprintf(stderr, "msgget failed with error: %d\n",errno);
        exit(EXIT_FAILURE);
    }

    //get msg from ipc until find end
    while(running)
    {
        if(msgrcv(msgid, (void *)&some_data, BUFSIZ, 
                 msg_to_receive, 0) == -1)
        {
            fprintf(stderr, "msgrcv failed with error: %d\n",errno);
            exit(EXIT_FAILURE);
        }
        if(strncmp(some_data.some_text, "end", 3) == 0)
        {
            running = 0;
        }
    }

    if(msgctl(msgid, IPC_RMID, 0) == -1)
    {
        fprintf(stderr, "msgctl(IPC_RMID) failed\n");
        exit(EXIT_FAILURE);
    }
    exit(EXIT_SUCCESS);
}

