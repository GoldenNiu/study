/*************************************************************************
	> File Name: test1.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月23日 星期二 23时49分08秒
 ************************************************************************/

#include<stdio.h>

void swap(int *a, int *b)
{
    int temp;
    temp = *a;
    *a = *b;
    *b = temp;
}
int main()
{
    int a=2;
    int b=3;
    swap(&a,&b);
    printf("%d %d\n", a,b);
    return 0;
}
