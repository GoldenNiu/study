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

#define MAX_TEXT 512
struct my_msg_st {
    long int my_msg_type;
    char some_text[MAX_TEXT];
};

int main()
{
    int running = 1;
    int msgid;
    struct my_msg_st some_data;
    char buffer[BUFSIZ];
    
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
        printf("endter some text:");
        fgets(buffer, BUFSIZ, stdin);
        some_data.my_msg_type = 1;
        strcpy(some_data.some_text, buffer);

        if(msgsnd(msgid, (void *)&some_data, MAX_TEXT, 0) == -1)
        {
            fprintf(stderr, "msgsnd failed\n");
            exit(EXIT_FAILURE);
        }
        if(strncmp(buffer, "end", 3) == 0)
        {
            running = 0;
        }
    }

    exit(EXIT_SUCCESS);
}

