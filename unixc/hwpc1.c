/*************************************************************************
	> File Name: hwpc1.c
	> Author: 
	> Mail: 
	> Created Time: 2017年04月25日 星期二 22时34分12秒
 ************************************************************************/

#include<stdio.h>
int main()
{
    int a,b,c,d;
    a = 10;
    b = a++;
    c = ++a;
    d = 10*a++;
    printf("b,c,d:%d,%d,%d\n",b, c, d);
    return 0;
}