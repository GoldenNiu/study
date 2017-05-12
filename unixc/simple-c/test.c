/*************************************************************************
	> File Name: test.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月09日 星期二 22时31分32秒
 ************************************************************************/

#include<stdio.h>

int main()
{
    int i,sum;
    int array[4] = {1, 2, 3, 4};
    sum = sizeof(array)/sizeof(int);
    for( i = 0; i < sum; i++)
    {
        printf("%d\n", *(array+i));
    }
    return 0;
}
