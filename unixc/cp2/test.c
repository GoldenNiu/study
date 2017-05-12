/*************************************************************************
	> File Name: test.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月08日 星期一 17时15分10秒
 ************************************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int main()
{
    //char a[50], b[50];
    char a[50] = "hello";
    //strcpy(a, "hello");
    strcat(a, "world\n");
    puts(a);
   // printf("\n%s",a);
    return 0;
}
