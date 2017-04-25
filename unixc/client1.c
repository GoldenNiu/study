/*************************************************************************
	> File Name: client1.c
	> Author: 
	> Mail: 
	> Created Time: 2017年04月20日 星期四 16时43分05秒
 ************************************************************************/

#include<sys/types.h>
#include<sys/socket.h>
#include<stdio.h>
#include<sys/un.h>
#include<unistd.h>
#include<stdlib.h>

int main()
{
    int sockfd;
    int len;
    struct sockaddr_un address;
    int result;
    char ch = 'A';

    //creat a socket for client 
    sockfd = socket(AF_UNIX, SOCK_STREAM, 0);
    //according to server to name socket
    address.sun_family = AF_UNIX;
    strcpy(address.sun_path, "server_socket");
    len = sizeof(address);
    //connect socket to server's socket
    result = connect(sockfd, (struct sockaddr *)&address, len);

    if(result == -1)
    {
        perror("oops:client1");
        exit(1);
    }
    //write/read through sockfd
    write(sockfd, &ch, 1);
    read(sockfd, &ch, 1);
    printf("char from server = %c\n", ch);
    close(sockfd);
    exit(0);
}

