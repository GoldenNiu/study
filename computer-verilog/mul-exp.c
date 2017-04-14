/*************************************************************************
	> File Name: mul-exp.c
	> Author: 
	> Mail: 
	> Created Time: 2017年04月14日 星期五 15时17分33秒
 ************************************************************************/

#include<stdio.h>
#include<unistd.h>
#include<stdlib.h>

unsigned int mul16(unsigned int x, unsigned int y)
{
    unsigned int a, b, c;
    unsigned int i;//counter
    a = x;//multiplicand
    b = y;//multiplier
    c = 0;
    for (i = 0; i < 16; i++)
    {
        if ((b & 1) == 1)
        {
            c += a;
        }
        a = a << 1;//shift a 1-bit left
        b = b >> 1;//shift b 1-bit right
    }
    return(c);
}

