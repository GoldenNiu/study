/*************************************************************************
	> File Name: quick_sort.c
	> Author: 
	> Mail: 
	> Created Time: 2017年06月05日 星期一 16时40分21秒
 ************************************************************************/

#include<stdio.h>

void quick_sort(int a[], int left, int right)
{
    int i,j,key;
    i = left;
    j = right;
    key = a[left];
    while(i<j)
    {
        while(i<j && a[j] > key)
            {
                j--;
            }
        a[i] = a[j];
        while(i<j && a[i] < key)
            {
                i++;
            }
        a[j] = a[i];
    }
    a[i] = key;
    if(left < i)
        quick_sort(a, left, j-1);
    if(i < right)
        quick_sort(a, j+1, right);
}


int main()
{
    int i;
    int arrary[10] = {
        99, 45, 12, 36, 69,
        22, 62, 796, 4, 696
    };
    for(i=0; i<10; i++)
        printf("%3d\t ", arrary[i]);
    printf("\n");
    quick_sort(arrary, 0, 9);
    for(i=0; i<10; i++)
        printf("%3d\t ", arrary[i]);
    printf("\n");
    return 0;
}
