/*************************************************************************
	> File Name: pc019.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月23日 星期二 14时28分06秒
 ************************************************************************/

#include<stdio.h>

int insert_sort(int a[], int p, int q)
{
    int key, i, j;
    for(i=p; i<=q; i++)
    {
        key = a[p+1];
        for(j=i-1; j>=0 && a[j]>key; j--)
        {
            a[j+1] = a[j];
        }
        a[j+1] = key;
        printf("%d\n",j);
    }
}

int main()
{
    int a[50],i;
    printf("input 10 nums\n");
    for(i=1; i<10; i++)
        scanf("%d",&a[i]);
    insert_sort(a, 1, 10);
    for(i=1; i<10; i++)
        printf("%d ", a[i]);
    return 0;
}
