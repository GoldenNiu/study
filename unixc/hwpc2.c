/*************************************************************************
	> File Name: hwpc2.c
	> Author: 
	> Mail: 
	> Created Time: 2017年04月25日 星期二 22时42分51秒
 ************************************************************************/

#include<stdio.h>

void initial_array(int n, int *arr)
{
    int i;
    for(i = 0; i <= n; i++)
    {
        *(arr + i) = i;
    }
}

//void shift(int)

void delete(int n, int *arr)
{
    int i,j,k;
    i=j=0;
    for(; (i+j+1) <= n; i++)
    {
        if((i+j+1)%3 == 0)
        {
            j++;
        }
        *(arr + i) = *(arr + i + j);
    }
    printf("i:%d j:%d \n", i, j);
    for(k = 0; k < i; k++)
    {
        printf("%d\t",*(arr + k));
    }
    printf("last%d\n",*(arr+i));
}

int compute(int i,int n)
{
    int j;
    for(j=0;3*j+i < n;j++);
        printf("%d\t",3*j+i);
    compute(i+1,n);
}

int main()
{
    int st,n;
    st=2;
    printf("enter n:\n");
    scanf("%d",&n);
    int arr1[n];
    initial_array(n, arr1);
//    delete(n,arr1);
    compute(st,n);
    return 0;
}
