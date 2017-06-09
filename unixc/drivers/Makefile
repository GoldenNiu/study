obj-m := hellop.o
KERNELDR := /usr/src/linux-headers-4.4.0-31-generic 
PWD := $(shell pwd)
modules:
	$(MAKE) -C $(KERNELDR) M=$(PWD) modules
modules_install:
	$(MAKE) -C $(KERNELDR) M=$(PWD) modules_install
clean :
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions
