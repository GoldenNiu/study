/*************************************************************************
	> File Name: pc014.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月19日 星期五 14时50分50秒
 ************************************************************************/
//define a arrary[] => day's num of every month
//better than use switch-case
//add judgment of leap year

#include<stdio.h>

const int arrary[] = 
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

int main()
{
    int year, month, day;
    int result;
    printf("input yymmdd\n");
    scanf("%d %d %d", &year, &month, &day);
   /* result = 30*(month-1)+ day;
    switch(month)
    {
        case 1:
            printf("%d", result);
            break;
        case 2:
            printf("%d", result+1);
            break;
        case 3:
            printf("%d", result-1);
            break;
        case 4:
            printf("%d", result);
            break;
        case 5:
            printf("%d", result);
            break;
        case 6:
            printf("%d", result+1);
            break;
        case 7:
            printf("%d", result+1);
            break;
        case 8:
            printf("%d", result+2);
            break;
        case 9:
            printf("%d", result+2);
            break;
        case 10:
            printf("%d", result+2);
            break;
        case 11:
            printf("%d", result+3);
            break;
        case 12:
            printf("%d", result+3);
            break;
        default:
            printf("error");
            break;
    }*/

    /*if(select_year(year))
    {
        if(month > 2)
        {
            result = day + sum_month(month) + 1;
           // printf("day is %d\n", result);
        }
        else
        {
            result = day + sum_month(month);    
        }
    }
    else
    {
        result = day + sum_month(month);
    }*/
    int flag;
    flag = (select_year(year) && (month > 2))?1:0;
    result = day + sum_month(month) + flag;
    printf("day is%d\n", result);
    return 0;
}
