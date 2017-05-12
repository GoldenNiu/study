/*************************************************************************
	> File Name: hello.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月08日 星期一 22时34分20秒
 ************************************************************************/

#include<stdio.h>
int main()
{
    char *a;
    a = "hello";
    printf("%s \n", a);
    int *b;
    int c;
    c = 2;
    b = &c;
    printf("%d\n", b);
    printf("%d\n", *b);
    return 0;
}
