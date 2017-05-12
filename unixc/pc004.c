/*************************************************************************
	> File Name: pc004.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月05日 星期五 14时35分55秒
 ************************************************************************/

#include<stdio.h>
#include<stdlib.h>
int main()
{
    int c;
    FILE *in, *out;

    in = fopen("cp002.c","r");
    out = fpoen("tmp.txt","w");

    while((c = fgetc(in)) != EOF)
        fputc(c,out);
    return 0;
}
