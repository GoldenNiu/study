/*************************************************************************
	> File Name: pc015.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月22日 星期一 16时32分24秒
 ************************************************************************/
//define a,b,c if their value is 1=> marry with X,2=>Y,3=>Z
//3 for loop to make sure a,b,c

#include<stdio.h>

int main()
{
    int a, b, c;
    for(a=1; a<=3; a++)
    {
        for(b=1; b<=3; b++)
        {
            for(c=1; c<=3; c++)
            {
                if((a!=1) && (c!=1) && (c!=3) && (a!=b) && (a!=c) && (b!=c))
                {
                    
                    printf("%d %d %d\n", a, b, c);
                    printf("%c %c %c\n", 'X'+a-1, 'X'+b-1,'X'+c-1);
                }
            }
        }
    }
    printf("%c %c %c\n", 'X'+a-1, 'X'+b-1,'X'+c-1);
    printf("%d %d %d\n", a, b,c);
    return 0;
}
