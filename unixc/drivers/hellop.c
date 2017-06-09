/*************************************************************************
	> File Name: hello_world.c
	> Author: 
	> Mail: 
	> Created Time: 2017年06月06日 星期二 15时51分13秒
 ************************************************************************/

#include<linux/init.h>
#include<linux/module.h>
#include<linux/moduleparam.h>
MODULE_LICENSE("Dual BSD/GPL");


static char *whom = "world";
static int howmany = 1;
module_param(whom, charp, S_IRUGO);
module_param(howmany, int, S_IRUGO);
static int hello_init(void)
{
    int i;
    for(i = 0; i < howmany; i++)    
        printk(KERN_ALERT "(%d)Hello,%s\n", i, whom);
    return 0;
}

static void hello_exitt(void)
{
    printk(KERN_ALERT"Goodbye,crule world\n");
}

module_init(hello_init);
module_exit(hello_exitt);
