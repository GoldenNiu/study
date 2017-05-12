/*************************************************************************
	> File Name: pc006.c
	> Author: 
	> Mail: 
	> Created Time: 2017年05月09日 星期二 17时00分27秒
 ************************************************************************/

#include<stdio.h>
#include<string.h>
int main()
{
    char a = '*';
    printf("%c%2c%2c%2c%2c\n", a, a, a, a, a);
    printf("%c%8c\n", a, a);
    printf("%c%8c\n", a, a);
    printf("%c%8c\n", a, a);
    printf("%c%2c%2c%2c%2c\n", a, a, a, a, a);
    printf("\n");

    char rectangle_1[] = 
        "* * * * *\n"
        "*       *\n"
        "*       *\n"
        "*       *\n"
        "* * * * *\n";
    puts(rectangle_1);
    printf("\n%s\n",rectangle_1);

    char *rectangle_2[] = {
        "* * * * *",
        "*       *",
        "*       *",
        "*       *",
        "* * * * *",
    };
    int i, sum;
    sum = sizeof(rectangle_2);
    printf("%d\n", sum);
    for(i=0 ; i < sum/sizeof(*rectangle_2); i++)
    {
        printf("%s\n", *(rectangle_2+i));
    }
    return 0;
}
