/*************************************************************************
    > File Name: endian.c
    > Author: golden
    > Mail:  
    > Created Time: 2017年06月20日 星期二 15时45分03秒
 ************************************************************************/

#include<stdio.h>

int main()
{
    short int x;
    x = 0x1234;
    char y, z;
    y = ((char *)&x)[0];
    z = ((char *)&x)[1];
    printf("y%x z%x\n",y ,z);
    return 0;
}
