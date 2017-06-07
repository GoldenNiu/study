/*************************************************************************
	> File Name: pc018.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月23日 星期二 10时43分10秒
 ************************************************************************/
//notice include<math.h> sqrt() function
//a^2 is error => a*a
//when use math.h , gcc **.c -o ** -lm,emphasize -lm
#include<stdio.h>
#include<math.h>
int judge_tri(float a, float b, float c)
{
    if((a+b<=c) || (a+c<=b) || (b+c <=a))
    {
        printf("NO\n");
        return 0;
    }
    else
    {
        printf("YEs\n");
        return 1;
    }   
}

float square(float a, float b, float c)
{
    float p,s;
    p = (a+b+c)/2;
    s = (p*(p-a)*(p-b)*(p-c));
    return sqrt(s);
}

int type_tri(float a, float b, float c)
{
    if(a==b || b==c || a==c)
    {
        if(a==b==c)
        {        
            printf("Equilateral triangle\n");
        }
        else if((a*a+b*b==c*c) || (b*b+c*c==a*a) || (a*a+c*c==b*b))
        {
            printf("isosceies right angle triangle\n");
        }
        else
        {
            printf("isosceies triangle\n");
        }
    }
    else 
    {
        if((a*a+b*b==c*c) || (b*b+c*c==a*a) || (a*a+c*c==b*b))
        {
            printf("right angle triangle\n");
        } 
        else
        {            
            printf("simple triangle\n");
        }   
    }
}

int main()
{
    float a, b, c;
    scanf("%f %f %f", &a, &b, &c);
    judge_tri(a, b, c);
    type_tri(a, b,c);
    if(judge_tri(a, b, c) == 1)
        printf("%f\n",square(a, b, c));
    return 0;
}
