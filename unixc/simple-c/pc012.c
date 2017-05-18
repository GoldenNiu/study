/*************************************************************************
	> File Name: pc012.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月18日 星期四 15时55分53秒
 ************************************************************************/

#include<stdio.h>

int compute(int x, int y)
{
    if(y > 0)
    {
        return x*(compute(x,y-1));
    }
    else
    {
        return   x = 1;
    }
}

int main()
{
    float price = 0.8;
    int num, day,result;
    float money;
    num = 2;
    day = 1;
    result = 1;
    while(result < 100)
    {
        day++;
        //result = compute(num, day);
        result*=2;
        printf("%d %d\n", day, result);
    }
    printf("%d",result);
    return 0;
}
