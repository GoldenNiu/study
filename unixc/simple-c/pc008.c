/*************************************************************************
	> File Name: pc008.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月12日 星期五 16时39分39秒
 ************************************************************************/

#include<stdio.h>

int main()
{
    int num, sum;
    char ch;
    num = 0;
    sum = 0;
    while((ch=getchar()) != '\n')
    {
        if(ch >= '0' && ch <= '9')
        num = 10*num + ch - '0';
        if(ch == ' ')
        {
            sum = sum + num;
            num = 0;
        }
    }
    printf("%d\n",sum + num);
    return 0;
}
