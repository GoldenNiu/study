/*************************************************************************
	> File Name: hello_world.c
	> Author: 
	> Mail: 
	> Created Time: 2017年06月06日 星期二 15时51分13秒
 ************************************************************************/

#include<linux/init.h>
#include<linux/module.h>
MODULE_LICENSE("Dual BSD/GPL");

static int hello_init(void)
{
    printk(KERN_ALERT "Hello,world\n");
    return 0;
}

static void hello_exitt(void)
{
    printk(KERN_ALERT"Goodbye,crule world\n");
}

module_init(hello_init);
module_exit(hello_exitt);
