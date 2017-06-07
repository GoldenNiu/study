/*************************************************************************
	> File Name: pc017.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月23日 星期二 00时32分46秒
 ************************************************************************/
 //notice:at the last of scanf function no "space"
#include<stdio.h>
int arrary[] = 
{
    31,28,31,30,31,30,
    31,31,30,31,30,31
};

int select_year(int a)
{
    if(a%100 == 0)
        if(a%400 == 0)
            return 1;
        else
            return 0;
    else
        if(a%4 == 0)
            return 1;
        else
            return 0;
}

int sum_month(int i)
{
    int j = 0;
    int sum = 0;
    for(;j < (i-1); j++)
    {
        sum += arrary[j];    
    }
    return sum;
}

int sum_year(int a)
{
    int i, sum;
    for(i=2011, sum=0; i<a; i++)
    {
        sum += 365 + select_year(i);
    }
    //printf("sum_year %d\n", sum);
    return sum;
}


int main()
{
    int year, month, day;
    int result, sum_day, flag;
    scanf("%d %d %d", &year, &month, &day);
    flag = (select_year(year) && (month > 2))?1:0;
    sum_day = sum_month(month) + day + flag;
    result = sum_day + sum_year(year);
    printf("%d\n",result);
    if((result%5 == 0) || (result%5 == 4))
        {
            printf("resting\n");
        }
    else
        {
            printf("fishing\n");
        }
    return 0;
}
