/*************************************************************************
	> File Name: server1.c
	> Author: 
	> Mail: 
	> Created Time: 2017年04月20日 星期四 16时53分08秒
 ************************************************************************/

#include<sys/types.h>
#include<sys/socket.h>
#include<stdio.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<unistd.h>
#include<stdlib.h>

int main()
{
    int server_sockfd, client_sockfd;
    int server_len, client_len;
    struct sockaddr_in server_address;
    struct sockaddr_in client_address;
    //rm socket before,creat unnamed server socket
    //unlink("server_socket");
    server_sockfd = socket(AF_INET, SOCK_STREAM, 0);
    //name socket
    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = htonl(INADDR_ANY);
    server_address.sin_port = htons(9734);
    server_len = sizeof(server_address);
    bind(server_sockfd, (struct sockaddr *)&server_address, server_len);
    //creat a connect line and wait client connect
    listen(server_sockfd, 5);
    while(1)
    {
        char ch;
        printf("server waiting\n");
        //accept a connectting
        client_len = sizeof(client_address);
        client_sockfd = accept(server_sockfd,
            (struct sockaddr *)&client_address, &client_len);
        //write/read client_sockfd
        read(client_sockfd, &ch, 1);
        ch++;
        write(client_sockfd, &ch, 1);
        close(client_sockfd);
    }
}

