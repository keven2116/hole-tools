#
# report bug to send email keven@ongoingcre.com.
#
#

CP					:=cp
X86_ROOTFS_SIZE		:=500M
X86_BOOT_SIZE		:=10
ROOTFS_SIZE			:=500
X86_IMAGE_SIZE		:=600
X86_ROOTFS_IMAGE	:=root.ext4
X86_ROOTFS		 	:=$(shell pwd)/targets/rootfs
X86_ROOTFS_CPIO		:=$(shell pwd)/targets/rootfs/rootfs.cpio
X86_IMAGE_NAME		:=hole-dist.img
X86_VDI_NAME		:=hole-dist.vdi
X86_VMDK_NAME		:=hole-dist.vmdk
X86_DEVICE_MAP		:=grub2/device.map
X86_ROOT_GRUB		:=root.grub
GEN_IMAGE			:=gen_image_generic.sh
X86_KERNEL_VMLINUXZ :=root.grub/boot/vmlinuz
KERNEL_BZIMAGE		:=$(shell pwd)/targets/img/x86_64/bzImage

img:
ifeq ($(X86_ROOTFS_CPIO),$(wildcard $(X86_ROOTFS_CPIO)))
	$(shell cd $(X86_ROOTFS) && sudo cpio -i < rootfs.cpio)
endif
	@make_ext4fs  -l $(X86_ROOTFS_SIZE) -m 0 -J $(X86_ROOTFS_IMAGE) $(X86_ROOTFS)
	$(CP) -fpR $(KERNEL_BZIMAGE) $(X86_KERNEL_VMLINUXZ)
	@echo '(hd0) $(shell pwd)/$(X86_IMAGE_NAME)' > $(X86_DEVICE_MAP)
	./gen_image_generic.sh  $(X86_IMAGE_NAME) $(X86_BOOT_SIZE) $(X86_ROOT_GRUB)  $(ROOTFS_SIZE) $(X86_ROOTFS_IMAGE) $(X86_IMAGE_SIZE)
	@grub-bios-setup  -m "$(X86_DEVICE_MAP)" -d "grub2" -r "hd0,msdos1" "$(X86_IMAGE_NAME)"

vdi: 
	@qemu-img	convert -O vdi $(X86_IMAGE_NAME) $(X86_VDI_NAME)
vmdk: 
	@qemu-img	convert -O vmdk $(X86_IMAGE_NAME) $(X86_VMDK_NAME)

all:img
ifeq ($(X86_ROOTFS_CPIO),$(wildcard $(X86_ROOTFS_CPIO)))
	@echo 'exists'
else
	$(shell cd $(X86_ROOTFS) && sudo find ./ | cpio -H newc -o > ../rootfs.cpio)
	$(shell cd $(X86_ROOTFS) && sudo rm -rf *)
	$(shell cd $(X86_ROOTFS) && sudo mv ../rootfs.cpio .)
endif

clean:
	@rm -rf $(X86_VDI_NAME) $(X86_VMDK_NAME) $(X86_IMAGE_NAME) $(X86_ROOTFS_IMAGE) $(X86_ROOTFS_CPIO) $(KERNEL_BZIMAGE)

help:
	@echo 'Welcome to using Makefile Generate hole-dist minios:'
	@echo ' all			- Build all Generate all img file to be using'
	@echo ' img			- Generate img file to be using qmeu-system'
	@echo ' vmdk			- Generate vmdk virtual hard file to be using virtualbox && vmware'
	@echo ' vdi			- Generate vdi virtual hard file to using virtualbox && vmware'
	@echo ' clean			- Clean all targets'
	@echo 'Execute "make" or "make all" to build all targets marked with [*]'
	@echo 'For further info see the ./README file'
	@echo 'Report Bugs Eamilt to keven@ongoingcre.com or accsess Github[github.com/bjwrkj/hole-v]'
