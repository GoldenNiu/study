/*************************************************************************
	> File Name: pc013.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月19日 星期五 11时29分48秒
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
        return   1;
    }

}

int main()
{
    int a, b, result;
    int i = 0;
    scanf("%d %d", &a, &b);
    result = compute(a, b);
    printf("%d",result);
    //every loop %10 or directly %1000
    /*for( ; i < 3; i++)
    {
        printf("%d\t",(result%10));
        result = result/10;
    }*/
    printf("%03d\n", (result%1000));
    return 0;
}
