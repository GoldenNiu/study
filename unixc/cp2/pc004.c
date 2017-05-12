/*************************************************************************
	> File Name: pc004.c
	> Author: 
	> Mail:
    > Function:creat a file,and input some texts and cat it
	> Created Time: 2017年05月08日 星期一 16时32分34秒
 ************************************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int main()
{
    FILE *fp;
    char fl[50];
    char outcmd[50] = "cat ";
    printf("input file\n");
    scanf("%s", fl);
   // fp = fopen("1.txt", "w+");
    fp = fopen(fl, "w+");
    fprintf(fp, "my love\n");
    fputs("is lovely girl\n", fp);
    fclose(fp);
    strcat(outcmd, fl);
    puts(outcmd);
    system(outcmd);
    return 0;
}
