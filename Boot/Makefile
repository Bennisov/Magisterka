include ConfigMakefile

CURRENT_DIR = $(shell pwd)
SOURCE_DIR=images/linux/

all: rebuild

rebuild: get_design build

build: build_petalinux package

update_bitstream: get_bitstream package

initialize:
	@echo "------------------------------------------------------------------------------------------------------"
	@echo "Gutsy Ferret project Petalinux Makefile"
	@echo "> Project initialization - get XSA and bitstream from the project for the first time from "$(FIRMWARE_PROJECT)
	@echo "------------------------------------------------------------------------------------------------------"
	petalinux-config --get-hw-description $(FIRMWARE_PROJECT)/ 

get_xsa:
	@echo "------------------------------------------------------------------------------------------------------"
	@echo "Gutsy Ferret project Petalinux Makefile"
	@echo "> Taking XSA from "$(FIRMWARE_PROJECT)
	@echo "------------------------------------------------------------------------------------------------------"
	petalinux-config --get-hw-description $(FIRMWARE_PROJECT)/ --silentconfig

get_bitstream:
	@echo "------------------------------------------------------------------------------------------------------"
	@echo "Gutsy Ferret project Petalinux Makefile"
	@echo "> Taking bitstream from "$(FIRMWARE_PROJECT)
	@echo "------------------------------------------------------------------------------------------------------"
	mkdir -p $(SOURCE_DIR)
	cp $(FIRMWARE_PROJECT)/$(FIRMWARE_PROJECT_NAME).runs/$(VIVADO_IMPLEMENTATION)/*.bit $(SOURCE_DIR)/system.bit

get_design: get_bitstream get_xsa


edit_device_tree:
	$(EDITOR) ./project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

configure:
	petalinux-config

configure_uboot:
	petalinux-config -c u-boot

configure_kernel:
	petalinux-config -c kernel

build_petalinux:
	@echo "------------------------------------------------------------------------------------------------------"
	@echo "Gutsy Ferret project Petalinux Makefile"
	@echo "> Building Petaliux project"
	@echo "------------------------------------------------------------------------------------------------------"
	petalinux-build

package:
	@echo "------------------------------------------------------------------------------------------------------"
	@echo "Gutsy Ferret project Petalinux Makefile"
	@echo "> Creating package with FSBL from Petaliux"
	@echo "------------------------------------------------------------------------------------------------------"
	petalinux-package boot --format BIN --fsbl ./$(SOURCE_DIR)/$(TARGET_ARCH)_fsbl.elf --fpga ./$(SOURCE_DIR)/system.bit --u-boot --force

package_vitis:
	@echo "------------------------------------------------------------------------------------------------------"
	@echo "Gutsy Ferret project Petalinux Makefile"
	@echo "> Creating package with FSBL from Vitis. Project output path is:"
	@echo "------------------------------------------------------------------------------------------------------"
	ls -lrt $(VITIS_FSBL_PATH)
	petalinux-package boot --format BIN --fsbl $(VITIS_FSBL_PATH) --fpga ./$(SOURCE_DIR)/system.bit --u-boot --force

copy_sd:
	@echo "------------------------------------------------------------------------------------------------------"
	@echo "Gutsy Ferret project Petalinux Makefile"
	@echo "> Copy result files to "$(SD_MOUNT_DIRECTORY)
	@echo "------------------------------------------------------------------------------------------------------"
	cp $(SOURCE_DIR)/BOOT.BIN $(SOURCE_DIR)/?mage* $(SOURCE_DIR)/?ystem.* $(SOURCE_DIR)/u-boot.bin $(SOURCE_DIR)/vmlinux $(SOURCE_DIR)/boot.scr $(SD_MOUNT_DIRECTORY)
	sync

# copy_target:
# 	cp $(SOURCE_DIR)/BOOT.BIN $(SOURCE_DIR)/?mage* $(SOURCE_DIR)/?ystem.* $(SOURCE_DIR)/u-boot.bin $(SOURCE_DIR)/vmlinux $(SOURCE_DIR)/boot.scr TARGET/

clean:
	@echo "------------------------------------------------------------------------------------------------------"
	@echo "Gutsy Ferret project Petalinux Makefile"
	@echo "> Cleaning Petaliux project"
	@echo "------------------------------------------------------------------------------------------------------"
	petalinux-build -x mrproper -f

fresh:
	petalinux-build -x mrproper

finish:
	petalinux-devtool finish linux-xlnx $(CURRENT_DIR)/project-spec/meta-user

decompile_devicetree:
	dtc -I dtb -O dts -o system.dts images/linux/system.dtb

targz_patch_files:
	@echo "------------------------------------------------------------------------------------------------------"
	@echo "Gutsy Ferret project Petalinux Makefile"
	@echo "> Creating tgz archive of Trenz TE specific FSBL patch files from "$(VITIS_SOURCES_PATH)
	@echo "------------------------------------------------------------------------------------------------------"
	cd $(VITIS_SOURCES_PATH) && tar -czvf te_patch.tgz te_iic_define_te0808.h te_iic_platform.c te_iic_platform.h te_si534x.c te_si534x.h te_Si5345-Registers.h te_uart.c te_uart.h te_xfsbl_hooks.c te_xfsbl_hooks.h te_xfsbl_hooks_te0808.c te_xfsbl_hooks_te0808.h

.PHONY: build
