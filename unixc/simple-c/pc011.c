/*************************************************************************
	> File Name: pc011.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月18日 星期四 14时57分19秒
 ************************************************************************/

#include<stdio.h>
int main()
{
    int day;
    int result;
    day = 10;
    result = 1;
    for(; day > 1;)
    {
        day--;
        result = 2*(result + 1);
        printf("%d %d\n", day, result);
    }
    return 0;
}
