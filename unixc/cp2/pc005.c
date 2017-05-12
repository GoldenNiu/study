/*************************************************************************
	> File Name: pc005.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月09日 星期二 16时52分09秒
 ************************************************************************/

#include<stdio.h>

int square(int a)
{
    int s;
    s = a*a;
    return s;
}
int main()
{
    int a;
    printf("input a:\n");
    scanf("%d", &a);
    printf("%d", square(a));
    return 0;
}
