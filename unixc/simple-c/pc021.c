/*************************************************************************
	> File Name: pc021.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月23日 星期二 23时34分49秒
 ************************************************************************/

//notice: swap function , using of pointer
//bubble sort i=>nums of compare loop n-1
//j=>nums of compare is n-j

#include<stdio.h>

int temp;
void swap(int *p, int *q)
{
   // int temp;
    temp = *p;
    *p = *q;
    *q = temp;
}

int main()
{
    int a[10]=
    {
        66,32,23,45,5,
        15,69,46,37,25
    };
    int i, j;
    for(i=0; i<10; i++)
        printf("%2d ",a[i]);
    printf("\n");
   for(i=1; i<10;i++)
    {
        for(j=0;j<10-i;j++)
        {
            if(a[j]>a[j+1])
            {
                swap(a+j, a+j+1);
            }
        }
    }
    for(i=0; i<10; i++)
        printf("%2d ",a[i]);
    printf("\n");
    return 0;
}
