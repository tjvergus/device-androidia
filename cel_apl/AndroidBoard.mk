# ----------------- BEGIN MIX-IN DEFINITIONS -----------------
# Mix-In definitions are auto-generated by mixin-update
##############################################################
# Source: device/intel/mixins/groups/slot-ab/true/AndroidBoard.mk
##############################################################
make_ramdisk_dir:
	@mkdir -p $(PRODUCT_OUT)/root/metadata

$(PRODUCT_OUT)/ramdisk.img: make_ramdisk_dir
##############################################################
# Source: device/intel/mixins/groups/firststage-mount/true/AndroidBoard.mk
##############################################################
FIRST_STAGE_MOUNT_CFG_FILE := $(TARGET_DEVICE_DIR)/extra_files/firststage-mount/config.asl

$(FIRSTSTAGE_MOUNT_SSDT): $(FIRST_STAGE_MOUNT_CFG_FILE) $(IASL)
	$(hide) $(IASL) -p $(@:.aml=) $(FIRST_STAGE_MOUNT_CFG_FILE);
##############################################################
# Source: device/intel/mixins/groups/vendor-partition/true/AndroidBoard.mk
##############################################################
include $(CLEAR_VARS)
LOCAL_MODULE := vendor-partition
LOCAL_REQUIRED_MODULES := toybox_static
include $(BUILD_PHONY_PACKAGE)

RECOVERY_VENDOR_LINK_PAIRS := \
	$(PRODUCT_OUT)/recovery/root/vendor/bin/getprop:toolbox_static \

RECOVERY_VENDOR_LINKS := \
	$(foreach item, $(RECOVERY_VENDOR_LINK_PAIRS), $(call word-colon, 1, $(item)))

$(RECOVERY_VENDOR_LINKS):
	$(hide) echo "Creating symbolic link on $(notdir $@)"
	$(eval PRV_TARGET := $(call word-colon, 2, $(filter $@:%, $(RECOVERY_VENDOR_LINK_PAIRS))))
	$(hide) mkdir -p $(dir $@)
	$(hide) mkdir -p $(dir $(dir $@)$(PRV_TARGET))
	$(hide) touch $(dir $@)$(PRV_TARGET)
	$(hide) ln -sf $(PRV_TARGET) $@

ALL_DEFAULT_INSTALLED_MODULES += $(RECOVERY_VENDOR_LINKS)
##############################################################
# Source: device/intel/mixins/groups/config-partition/true/AndroidBoard.mk
##############################################################
INSTALLED_CONFIGIMAGE_TARGET := $(PRODUCT_OUT)/config.img

selinux_fc := $(TARGET_ROOT_OUT)/file_contexts.bin

make_oem_config_dir:
	@mkdir -p $(PRODUCT_OUT)/root/mnt/vendor
	@mkdir -p $(PRODUCT_OUT)/root/mnt/vendor/oem_config
	@mkdir -p $(PRODUCT_OUT)/recovery/root/mnt/vendor
	@mkdir -p $(PRODUCT_OUT)/recovery/root/mnt/vendor/oem_config

$(PRODUCT_OUT)/ramdisk.img: make_oem_config_dir

$(INSTALLED_CONFIGIMAGE_TARGET) : PRIVATE_SELINUX_FC := $(selinux_fc)
$(INSTALLED_CONFIGIMAGE_TARGET) : $(MKEXTUSERIMG) $(MAKE_EXT4FS) $(E2FSCK) $(selinux_fc) bootimage make_oem_config_dir
	$(call pretty,"Target config fs image: $(INSTALLED_CONFIGIMAGE_TARGET)")
	@mkdir -p $(PRODUCT_OUT)/config
	$(hide)	PATH=$(HOST_OUT_EXECUTABLES):$$PATH \
		$(MKEXTUSERIMG) -s \
		$(PRODUCT_OUT)/config \
		$(PRODUCT_OUT)/config.img \
		ext4 \
		oem_config \
		$(BOARD_CONFIGIMAGE_PARTITION_SIZE) \
		$(PRIVATE_SELINUX_FC)

INSTALLED_RADIOIMAGE_TARGET += $(INSTALLED_CONFIGIMAGE_TARGET)

selinux_fc :=
##############################################################
# Source: device/intel/mixins/groups/factory-partition/true/AndroidBoard.mk
##############################################################
INSTALLED_FACTORYIMAGE_TARGET := $(PRODUCT_OUT)/factory.img
selinux_fc := $(TARGET_ROOT_OUT)/file_contexts.bin

$(INSTALLED_FACTORYIMAGE_TARGET) : PRIVATE_SELINUX_FC := $(selinux_fc)
$(INSTALLED_FACTORYIMAGE_TARGET) : $(MKEXTUSERIMG) $(MAKE_EXT4FS) $(E2FSCK) $(selinux_fc)
	$(call pretty,"Target factory fs image: $(INSTALLED_FACTORYIMAGE_TARGET)")
	@mkdir -p $(PRODUCT_OUT)/factory
	$(hide)	$(MKEXTUSERIMG) -s \
		$(PRODUCT_OUT)/factory \
		$(PRODUCT_OUT)/factory.img \
		ext4 \
		factory \
		$(BOARD_FACTORYIMAGE_PARTITION_SIZE) \
		$(PRIVATE_SELINUX_FC)

INSTALLED_RADIOIMAGE_TARGET += $(INSTALLED_FACTORYIMAGE_TARGET)

selinux_fc :=

.PHONY: factoryimage
factoryimage: $(INSTALLED_FACTORYIMAGE_TARGET)

make_dir_ab_factory:
	@mkdir -p $(PRODUCT_OUT)/vendor/factory

$(PRODUCT_OUT)/ramdisk.img: make_dir_ab_factory
##############################################################
# Source: device/intel/mixins/groups/variants/default/AndroidBoard.mk
##############################################################
# flashfile_add_blob <blob_name> <path> <mandatory> <var_name>
# - Delete ::variant:: from <path>
# - If the result does not exists and <mandatory> is set, error
# - If <var_name> is set, put the result in <var_name>
# - Add the pair <result>:<blob_name> in BOARD_FLASHFILES_FIRMWARE
define flashfile_add_blob
$(eval blob := $(subst ::variant::,,$(2))) \
$(if $(wildcard $(blob)), \
    $(if $(4), $(eval $(4) := $(blob))) \
    $(eval BOARD_FLASHFILES_FIRMWARE += $(blob):$(1)) \
    , \
    $(if $(3), $(error $(blob) does not exist)))
endef

##############################################################
# Source: device/intel/mixins/groups/boot-arch/project-celadon/AndroidBoard.mk.1
##############################################################
GPT_INI2BIN := ./$(INTEL_PATH_COMMON)/gpt_bin/gpt_ini2bin.py
#GPT_INI2BIN := ./device/intel/common/gpt_bin/gpt_ini2bin.py

$(BOARD_GPT_BIN): $(TARGET_DEVICE_DIR)/gpt.ini
	$(hide) $(GPT_INI2BIN) $< > $@
	$(hide) echo GEN $(notdir $@)
##############################################################
# Source: device/intel/mixins/groups/boot-arch/project-celadon/AndroidBoard.mk.2
##############################################################
src_loader_file := $(PRODUCT_OUT)/efi/kernelflinger.efi
tgt_loader_file := $(PRODUCT_OUT)/loader.efi

define generate_flashfiles
$(shell cp $(src_loader_file) $(tgt_loader_file))
zip -qj $(1) $(2) $(tgt_loader_file)
endef

ifneq ($(BUILD_NUMBER),)
out_flashfiles := $(PRODUCT_OUT)/$(TARGET_PRODUCT)-flashfiles-$(BUILD_NUMBER).zip
else
out_flashfiles := $(PRODUCT_OUT)/$(TARGET_PRODUCT).flashfiles.$(TARGET_BUILD_VARIANT).$(USER).zip
endif


$(PRODUCT_OUT)/efi/startup.nsh: $(TARGET_DEVICE_DIR)/extra_files/boot-arch/$(@F)
	$(ACP) $(TARGET_DEVICE_DIR)/extra_files/boot-arch/$(@F) $@
	sed -i '/#/d' $@

$(PRODUCT_OUT)/efi/unlock_device.nsh: $(TARGET_DEVICE_DIR)/extra_files/boot-arch/$(@F)
	$(ACP) $(TARGET_DEVICE_DIR)/extra_files/boot-arch/$(@F) $@
	sed -i '/#/d' $@

$(PRODUCT_OUT)/efi/efivar_oemlock: $(TARGET_DEVICE_DIR)/$(@F)
	$(ACP) $(TARGET_DEVICE_DIR)/$(@F) $@

#$(out_flashfiles): $(BOARD_FLASHFILES) | $(ACP)
#	$(call generate_flashfiles,$@, $^)


#.PHONY: flashfiles_simple
#flashfiles_simple: $(out_flashfiles)

##############################################################
# Source: device/intel/mixins/groups/boot-arch/project-celadon/AndroidBoard.mk
##############################################################
# Rules to create bootloader zip file, a precursor to the bootloader
# image that is stored in the target-files-package. There's also
# metadata file which indicates how large to make the VFAT filesystem
# image

ifeq ($(TARGET_UEFI_ARCH),i386)
efi_default_name := bootia32.efi
LOADER_TYPE := linux-x86
else
efi_default_name := bootx64.efi
LOADER_TYPE := linux-x86_64
endif

# (pulled from build/core/Makefile as this gets defined much later)
# Pick a reasonable string to use to identify files.
ifneq "" "$(filter eng.%,$(BUILD_NUMBER))"
# BUILD_NUMBER has a timestamp in it, which means that
# it will change every time.  Pick a stable value.
FILE_NAME_TAG := eng.$(USER)
else
FILE_NAME_TAG := $(BUILD_NUMBER)
endif

BOARD_FIRST_STAGE_LOADER := $(PRODUCT_OUT)/efi/kernelflinger.efi
BOARD_EXTRA_EFI_MODULES :=

$(call flashfile_add_blob,capsule.fv,$(INTEL_PATH_HARDWARE)/fw_capsules//::variant::/$(BIOS_VARIANT)/capsule.fv,,BOARD_SFU_UPDATE)
$(call flashfile_add_blob,ifwi.bin,$(INTEL_PATH_HARDWARE)/fw_capsules//::variant::/$(BIOS_VARIANT)/ifwi.bin,,EFI_IFWI_BIN)
$(call flashfile_add_blob,ifwi_dnx.bin,$(INTEL_PATH_HARDWARE)/fw_capsules//::variant::/$(BIOS_VARIANT)/ifwi_dnx.bin,,EFI_IFWI_DNX_BIN)
$(call flashfile_add_blob,firmware.bin,$(INTEL_PATH_HARDWARE)/fw_capsules//::variant::/$(BIOS_VARIANT)/emmc.bin,,EFI_EMMC_BIN)
$(call flashfile_add_blob,afu.bin,$(INTEL_PATH_HARDWARE)/fw_capsules//::variant::/$(BIOS_VARIANT)/afu.bin,,EFI_AFU_BIN)
$(call flashfile_add_blob,dnxp_0x1.bin,$(INTEL_PATH_HARDWARE)/fw_capsules//::variant::/$(BIOS_VARIANT)/dnxp_0x1.bin,,DNXP_BIN)
$(call flashfile_add_blob,cfgpart.xml,$(INTEL_PATH_HARDWARE)/fw_capsules//::variant::/$(BIOS_VARIANT)/cfgpart.xml,,CFGPART_XML)
$(call flashfile_add_blob,cse_spi.bin,$(INTEL_PATH_HARDWARE)/fw_capsules//::variant::/$(BIOS_VARIANT)/cse_spi.bin,,CSE_SPI_BIN)


ifneq ($(EFI_IFWI_BIN),)
$(call dist-for-goals,droidcore,$(EFI_IFWI_BIN):$(TARGET_PRODUCT)-ifwi-$(FILE_NAME_TAG).bin)
endif

ifneq ($(EFI_IFWI_DNX_BIN),)
$(call dist-for-goals,droidcore,$(EFI_IFWI_DNX_BIN):$(TARGET_PRODUCT)-ifwi_dnx-$(FILE_NAME_TAG).bin)
endif

ifneq ($(EFI_AFU_BIN),)
$(call dist-for-goals,droidcore,$(EFI_AFU_BIN):$(TARGET_PRODUCT)-afu-$(FILE_NAME_TAG).bin)
endif

ifneq ($(BOARD_SFU_UPDATE),)
$(call dist-for-goals,droidcore,$(BOARD_SFU_UPDATE):$(TARGET_PRODUCT)-sfu-$(FILE_NAME_TAG).fv)
endif

ifneq ($(CALLED_FROM_SETUP),true)
ifeq ($(wildcard $(BOARD_SFU_UPDATE)),)
$(warning BOARD_SFU_UPDATE not found, OTA updates will not provide a firmware capsule)
endif
ifeq ($(wildcard $(EFI_EMMC_BIN)),)
$(warning EFI_EMMC_BIN not found, flashfiles will not include 2nd stage EMMC firmware)
endif
ifeq ($(wildcard $(EFI_IFWI_BIN)),)
$(warning EFI_IFWI_BIN not found, IFWI binary will not be provided in out/dist/)
endif
ifeq ($(wildcard $(EFI_AFU_BIN)),)
$(warning EFI_AFU_BIN not found, AFU IFWI binary will not be provided in out/dist/)
endif
endif

ifeq ($(BOARD_HAS_USB_DISK),true)
ifeq ($(FLASHFILE_VARIANTS),)
BOARD_USB_DISK_IMAGES = $(PRODUCT_OUT)/install-usb.img
else
BOARD_USB_DISK_IMAGE_PFX = $(PRODUCT_OUT)/install-usb
$(foreach var,$(FLASHFILE_VARIANTS), \
	$(eval BOARD_USB_DISK_IMAGES += $(BOARD_USB_DISK_IMAGE_PFX)-$(var).img))
endif
endif

# We stash a copy of BIOSUPDATE.fv so the FW sees it, applies the
# update, and deletes the file. Follows Google's desire to update all
# bootloader pieces with a single "fastboot flash bootloader" command.
# Since it gets deleted we can't do incremental updates of it, we keep
# a copy as capsules/current.fv for this purpose.
intermediates := $(call intermediates-dir-for,PACKAGING,bootloader_zip)
bootloader_zip := $(intermediates)/bootloader.zip
$(bootloader_zip): intermediates := $(intermediates)
$(bootloader_zip): efi_root := $(intermediates)/root
$(bootloader_zip): \
		$(TARGET_DEVICE_DIR)/AndroidBoard.mk \
		$(BOARD_FIRST_STAGE_LOADER) \
		$(BOARD_EXTRA_EFI_MODULES) \
		$(BOARD_SFU_UPDATE) \
		| $(ACP) \

	$(hide) rm -rf $(efi_root)
	$(hide) rm -f $@
	$(hide) mkdir -p $(efi_root)/capsules
	$(hide) mkdir -p $(efi_root)/EFI/BOOT
	$(foreach EXTRA,$(BOARD_EXTRA_EFI_MODULES), \
		$(hide) $(ACP) $(EXTRA) $(efi_root)/)
ifneq ($(BOARD_SFU_UPDATE),)
	$(hide) $(ACP) $(BOARD_SFU_UPDATE) $(efi_root)/BIOSUPDATE.fv
	$(hide) $(ACP) $(BOARD_SFU_UPDATE) $(efi_root)/capsules/current.fv
endif
	$(hide) $(ACP) $(BOARD_FIRST_STAGE_LOADER) $(efi_root)/loader.efi
	$(hide) $(ACP) $(BOARD_FIRST_STAGE_LOADER) $(efi_root)/EFI/BOOT/$(efi_default_name)
	$(hide) echo "Android-IA=\\EFI\\BOOT\\$(efi_default_name)" > $(efi_root)/manifest.txt
ifeq ($(BOARD_BOOTOPTION_FASTBOOT),true)
	$(hide) echo "Fastboot=\\EFI\\BOOT\\$(efi_default_name);-f">> $(efi_root)/manifest.txt
endif
	$(hide) (cd $(efi_root) && zip -qry ../$(notdir $@) .)

bootloader_info := $(intermediates)/bootloader_image_info.txt
$(bootloader_info):
	$(hide) mkdir -p $(dir $@)
	$(hide) echo "size=$(BOARD_BOOTLOADER_PARTITION_SIZE)" > $@
	$(hide) echo "block_size=$(BOARD_BOOTLOADER_BLOCK_SIZE)" >> $@

INSTALLED_RADIOIMAGE_TARGET += $(bootloader_zip) $(bootloader_info)

# Rule to create $(OUT)/bootloader image, binaries within are signed with
# testing keys

bootloader_bin := $(PRODUCT_OUT)/bootloader
$(bootloader_bin): \
		$(bootloader_zip) \
		$(IMG2SIMG) \
		$(BOOTLOADER_ADDITIONAL_DEPS) \
		$(INTEL_PATH_BUILD)/bootloader_from_zip \

	$(hide) $(INTEL_PATH_BUILD)/bootloader_from_zip \
		--size $(BOARD_BOOTLOADER_PARTITION_SIZE) \
		--block-size $(BOARD_BOOTLOADER_BLOCK_SIZE) \
		$(BOOTLOADER_ADDITIONAL_ARGS) \
		--zipfile $(bootloader_zip) \
		$@

droidcore: $(bootloader_bin)

.PHONY: bootloader
bootloader: $(bootloader_bin)
$(call dist-for-goals,droidcore,$(bootloader_bin):$(TARGET_PRODUCT)-bootloader-$(FILE_NAME_TAG))

$(call dist-for-goals,droidcore,$(INTEL_PATH_BUILD)/testkeys/testkeys_lockdown.txt:test-keys_efi_lockdown.txt)
$(call dist-for-goals,droidcore,$(INTEL_PATH_BUILD)/testkeys/unlock.txt:efi_unlock.txt)

fastboot_usb_bin := $(PRODUCT_OUT)/fastboot-usb.img
$(fastboot_usb_bin): \
		$(bootloader_zip) \
		$(BOOTLOADER_ADDITIONAL_DEPS) \
		$(INTEL_PATH_BUILD)/bootloader_from_zip \

	$(hide) $(INTEL_PATH_BUILD)/bootloader_from_zip \
		$(BOOTLOADER_ADDITIONAL_ARGS) \
		--zipfile $(bootloader_zip) \
		--extra-size 10485760 \
		--bootable \
		$@

# Build when 'make' is run with no args
droidcore: $(fastboot_usb_bin)

.PHONY: fastboot-usb
fastboot-usb: $(fastboot_usb_bin)

$(call dist-for-goals,droidcore,$(fastboot_usb_bin):$(TARGET_PRODUCT)-fastboot-usb-$(FILE_NAME_TAG).img)
$(call dist-for-goals,droidcore,device/intel/build/testkeys/testkeys_lockdown.txt:test-keys_efi_lockdown.txt)
$(call dist-for-goals,droidcore,device/intel/build/testkeys/unlock.txt:efi_unlock.txt)
ifeq ($(TARGET_BOOTLOADER_POLICY),$(filter $(TARGET_BOOTLOADER_POLICY),static external))
# The bootloader policy is not built but is provided statically in the
# repository or in $(PRODUCT_OUT)/.
else
# Bootloader policy values are generated based on the
# TARGET_BOOTLOADER_POLICY value and the
# $(INTEL_PATH_BUILD)/testkeys/{odm,OAK} keys.  The OEM must provide
# its own keys.
GEN_BLPOLICY_OEMVARS := $(INTEL_PATH_BUILD)/generate_blpolicy_oemvars
TARGET_ODM_KEY_PAIR := $(INTEL_PATH_BUILD)/testkeys/odm
TARGET_OAK_KEY_PAIR := $(INTEL_PATH_BUILD)/testkeys/OAK

$(BOOTLOADER_POLICY_OEMVARS):
	$(GEN_BLPOLICY_OEMVARS) -K $(TARGET_ODM_KEY_PAIR) \
		-O $(TARGET_OAK_KEY_PAIR).x509.pem -B $(TARGET_BOOTLOADER_POLICY) \
		$(BOOTLOADER_POLICY_OEMVARS)
endif


# Used for efi update
$(PRODUCT_OUT)/vendor.img: $(PRODUCT_OUT)/vendor/firmware/kernelflinger.efi
$(PRODUCT_OUT)/vendor/firmware/kernelflinger.efi: $(PRODUCT_OUT)/efi/kernelflinger.efi
	$(ACP) $(PRODUCT_OUT)/efi/kernelflinger.efi $@

make_bootloader_dir:
	@mkdir -p $(PRODUCT_OUT)/root/bootloader

$(PRODUCT_OUT)/ramdisk.img: make_bootloader_dir
##############################################################
# Source: device/intel/mixins/groups/sepolicy/enforcing/AndroidBoard.mk
##############################################################
include $(CLEAR_VARS)
LOCAL_MODULE := sepolicy-areq-checker
LOCAL_REQUIRED_MODULES := sepolicy

#
# On user builds, enforce that open tickets are considered violations.
#
ifeq ($(TARGET_BUILD_VARIANT),user)
LOCAL_USER_OPTIONS := -i
endif

LOCAL_POST_INSTALL_CMD := $(INTEL_PATH_SEPOLICY)/tools/capchecker $(LOCAL_USER_OPTIONS) -p $(INTEL_PATH_SEPOLICY)/tools/caps.conf $(TARGET_ROOT_OUT)/sepolicy

include $(BUILD_PHONY_PACKAGE)
##############################################################
# Source: device/intel/mixins/groups/trusty/true/AndroidBoard.mk
##############################################################
TOS_IMAGE_TARGET := $(TRUSTY_BUILDROOT)/evmm_lk_pkg.bin

INTERNAL_PLATFORM := ikgt
LOCAL_MAKE := make

# Build the evmm_pkg.bin and lk.bin
.PHONY: $(TOS_IMAGE_TARGET)
$(TOS_IMAGE_TARGET):
	@echo "making lk.bin.."
	$(hide) (cd $(TOPDIR)trusty && $(TRUSTY_ENV_VAR) $(LOCAL_MAKE) sand-x86-64)
	@echo "making tos image.."
	$(hide) (cd $(TOPDIR)vendor/intel/fw/evmm/$(INTERNAL_PLATFORM) && $(TRUSTY_ENV_VAR) $(LOCAL_MAKE))

#tos partition is assigned for trusty
INSTALLED_TOS_IMAGE_TARGET := $(PRODUCT_OUT)/tos.img
TOS_SIGNING_KEY := $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VERITY_SIGNING_KEY).pk8
TOS_SIGNING_CERT := $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VERITY_SIGNING_KEY).x509.pem

.PHONY: tosimage
tosimage: $(INSTALLED_TOS_IMAGE_TARGET)

ifeq (true,$(BOARD_AVB_ENABLE)) # BOARD_AVB_ENABLE == true
$(INSTALLED_TOS_IMAGE_TARGET): $(TOS_IMAGE_TARGET) $(MKBOOTIMG) $(AVBTOOL)
	@echo "mkbootimg to create boot image for TOS file: $@"
	$(hide) $(MKBOOTIMG) --kernel $(TOS_IMAGE_TARGET) --output $@
	$(hide) $(AVBTOOL) add_hash_footer \
		--image $@ \
		--partition_size $(BOARD_TOSIMAGE_PARTITION_SIZE) \
		--partition_name tos $(INTERNAL_AVB_SIGNING_ARGS)
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --include_descriptors_from_image $(INSTALLED_TOS_IMAGE_TARGET)
$(PRODUCT_OUT)/vbmeta.img: $(INSTALLED_TOS_IMAGE_TARGET)
else
$(INSTALLED_TOS_IMAGE_TARGET): $(TOS_IMAGE_TARGET) $(MKBOOTIMG) $(BOOT_SIGNER)
	@echo "mkbootimg to create boot image for TOS file: $@"
	$(hide) $(MKBOOTIMG) --kernel $(TOS_IMAGE_TARGET) --output $@
	$(if $(filter true,$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SUPPORTS_BOOT_SIGNER)),\
		@echo "sign prebuilt TOS file: $@" &&\
		$(BOOT_SIGNER) /tos $@ $(TOS_SIGNING_KEY) $(TOS_SIGNING_CERT) $@)
endif

INSTALLED_RADIOIMAGE_TARGET += $(INSTALLED_TOS_IMAGE_TARGET)

make_dir_ab_tos:
	@mkdir -p $(PRODUCT_OUT)/root/tos

$(PRODUCT_OUT)/ramdisk.img: make_dir_ab_tos
##############################################################
# Source: device/intel/mixins/groups/project-celadon/default/AndroidBoard.mk
##############################################################
droid: flashfiles
	-$(hide) $(ACP) $(out_flashfiles) $(DIST_DIR)
##############################################################
# Source: device/intel/mixins/groups/graphics/mesa/AndroidBoard.mk
##############################################################
ifneq ($(TARGET_BOARD_PLATFORM),kabylake)
I915_FW_PATH := ./$(INTEL_PATH_VENDOR)/ufo/gen9_dev/x86_64_media/vendor/firmware/i915
else
I915_FW_PATH := ./$(INTEL_PATH_VENDOR)/ufo/gen9_dev/x86_64_media_kbl/vendor/firmware/i915
endif
#list of i915/huc_xxx.bin i915/dmc_xxx.bin i915/guc_xxx.bin
$(foreach t, $(patsubst $(I915_FW_PATH)/%,%,$(wildcard $(I915_FW_PATH)/*)) ,$(eval I915_FW += i915/$(t)) $(eval $(LOCAL_KERNEL) : $(PRODUCT_OUT)/vendor/firmware/i915/$(t)))

_EXTRA_FW_ += $(I915_FW)

##############################################################
# Source: device/intel/mixins/groups/wlan/iwlwifi/AndroidBoard.mk
##############################################################
#LOCAL_KERNEL_PATH := $(abspath $(PRODUCT_OUT)/obj/kernel) is not defined yet
#$(abspath $(PRODUCT_OUT)/obj/kernel)/copy_modules: iwlwifi
##############################################################
# Source: device/intel/mixins/groups/kernel/gmin64/AndroidBoard.mk.1
##############################################################
LOAD_MODULES_IN += $(TARGET_DEVICE_DIR)/extra_files/kernel/load_kernel_modules.in
##############################################################
# Source: device/intel/mixins/groups/kernel/gmin64/AndroidBoard.mk
##############################################################
ifneq ($(wildcard $(INTEL_PATH_PREKERNEL)/$(TARGET_KERNEL_ARCH)/kernel), )
TARGET_PREBUILT_KERNEL := $(INTEL_PATH_PREKERNEL)/$(TARGET_KERNEL_ARCH)/kernel
endif

ifneq ($(TARGET_PREBUILT_KERNEL), )

TARGET_PREBUILT_KERNEL_MODULE := $(INTEL_PATH_PREKERNEL)/modules
LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)

$(PRODUCT_OUT)/kernel: $(LOCAL_KERNEL) $(wildcard $(TARGET_PREBUILT_KERNEL_MODULE)/*)
	  $(hide) echo "Copy prebuilt kernel from $(LOCAL_KERNEL) into $@"
	  $(hide) cp $(LOCAL_KERNEL) $@
	  $(hide) echo "Copy modules from $(TARGET_PREBUILT_KERNEL_MODULE) into $(PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)"
	  $(hide) mkdir -p $(PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)
	  $(hide) cp -r $(TARGET_PREBUILT_KERNEL_MODULE)/* $(PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)/

# kernel modules must be copied before ramdisk is generated
$(PRODUCT_OUT)/ramdisk.img: $(PRODUCT_OUT)/kernel

.PHONY: kernel
kernel: $(PRODUCT_OUT)/kernel

else

LOCAL_KERNEL_PATH := $(PRODUCT_OUT)/obj/kernel
KERNEL_INSTALL_MOD_PATH := .
LOCAL_KERNEL := $(LOCAL_KERNEL_PATH)/arch/x86/boot/bzImage
LOCAL_KERNEL_MODULE_TREE_PATH := $(LOCAL_KERNEL_PATH)/lib/modules
KERNELRELEASE := $(shell cat $(LOCAL_KERNEL_PATH)/include/config/kernel.release)

KERNEL_CCACHE := $(realpath $(CC_WRAPPER))

#remove time_macros from ccache options, it breaks signing process
KERNEL_CCSLOP := $(filter-out time_macros,$(subst $(comma), ,$(CCACHE_SLOPPINESS)))
KERNEL_CCSLOP := $(subst $(space),$(comma),$(KERNEL_CCSLOP))


ifeq ($(DEV_BKC_KERNEL), true)
  LOCAL_KERNEL_SRC := 
  KERNEL_CONFIG_PATH := 
  EXT_MODULES := 
  DEBUG_MODULES := 

else ifeq ($(MLT_KERNEL), true)
  LOCAL_KERNEL_SRC := 
  KERNEL_CONFIG_PATH := 
  EXT_MODULES := 
  DEBUG_MODULES := 

else
  LOCAL_KERNEL_SRC := kernel/lts2018
  EXT_MODULES := 
  DEBUG_MODULES := 
  KERNEL_CONFIG_PATH := kernel/project-celadon/config/celadon/android/non-embargoed
endif

EXTMOD_SRC := ../modules
EXTERNAL_MODULES := $(EXT_MODULES)

KERNEL_DEFCONFIG := $(KERNEL_CONFIG_PATH)/$(TARGET_KERNEL_ARCH)_defconfig
ifneq ($(TARGET_BUILD_VARIANT), user)
  KERNEL_DEBUG_DIFFCONFIG += $(wildcard $(KERNEL_CONFIG_PATH)/debug_diffconfig)
  ifneq ($(KERNEL_DEBUG_DIFFCONFIG),)
    KERNEL_DIFFCONFIG += $(KERNEL_DEBUG_DIFFCONFIG)
  else
    KERNEL_DEFCONFIG := $(LOCAL_KERNEL_SRC)/arch/x86/configs/$(TARGET_KERNEL_ARCH)_debug_defconfig
  endif
  EXTERNAL_MODULES := $(EXT_MODULES) $(DEBUG_MODULES)
endif # variant not eq user

KERNEL_CONFIG := $(LOCAL_KERNEL_PATH)/.config

ifeq ($(TARGET_BUILD_VARIANT), eng)
  KERNEL_ENG_DIFFCONFIG := $(wildcard $(KERNEL_CONFIG_PATH)/eng_diffconfig)
  ifneq ($(KERNEL_ENG_DIFFCONFIG),)
    KERNEL_DIFFCONFIG += $(KERNEL_ENG_DIFFCONFIG)
  endif
endif

KERNEL_MAKE_OPTIONS = \
    SHELL=/bin/bash \
    -C $(LOCAL_KERNEL_SRC) \
    O=$(abspath $(LOCAL_KERNEL_PATH)) \
    ARCH=$(TARGET_KERNEL_ARCH) \
    INSTALL_MOD_PATH=$(KERNEL_INSTALL_MOD_PATH) \
    CROSS_COMPILE="$(KERNEL_CCACHE) $(YOCTO_CROSSCOMPILE)" \
    CCACHE_SLOPPINESS=$(KERNEL_CCSLOP)

KERNEL_MAKE_OPTIONS += \
    EXTRA_FW="$(_EXTRA_FW_)" \
    EXTRA_FW_DIR="$(abspath $(PRODUCT_OUT)/vendor/firmware)"

KERNEL_CONFIG_DEPS = $(strip $(KERNEL_DEFCONFIG) $(KERNEL_DIFFCONFIG))

CHECK_CONFIG_SCRIPT := $(LOCAL_KERNEL_SRC)/scripts/diffconfig
CHECK_CONFIG_LOG :=  $(LOCAL_KERNEL_PATH)/.config.check

KERNEL_DEPS := $(shell find $(LOCAL_KERNEL_SRC) \( -name *.git -prune \) -o -print )

# Before building final defconfig with debug diffconfigs
# Check that base defconfig is correct. Check is performed
# by comparing generated .config with .config.old if it exists.
# On incremental build, remove the old .config.old before checking.
# If differences are observed, display a help message
# and stop kernel build.
# If a .config is already present, save it before processing
# the check and restore it at the end
$(CHECK_CONFIG_LOG): $(KERNEL_DEFCONFIG) $(KERNEL_DEPS) | yoctotoolchain
	$(hide) mkdir -p $(@D)
	-$(hide) [[ -e $(KERNEL_CONFIG) ]] && mv -f $(KERNEL_CONFIG) $(KERNEL_CONFIG).save
	$(hide) rm -f $(KERNEL_CONFIG).old
	$(hide) cat $< > $(KERNEL_CONFIG)
	$(hide) $(MAKE) $(KERNEL_MAKE_OPTIONS) olddefconfig
	$(hide) if [[ -e  $(KERNEL_CONFIG).old ]] ; then \
	  $(CHECK_CONFIG_SCRIPT) $(KERNEL_CONFIG).old $(KERNEL_CONFIG) > $@ ;  fi;
	-$(hide) [[ -e $(KERNEL_CONFIG).save ]] && mv -f $(KERNEL_CONFIG).save $(KERNEL_CONFIG)
	$(hide) if [[ -s $@ ]] ; then \
	  echo "CHECK KERNEL DEFCONFIG FATAL ERROR :" ; \
	  echo "Kernel config copied from $(KERNEL_DEFCONFIG) has some config issue." ; \
	  echo "Final '.config' and '.config.old' differ. This should never happen." ; \
	  echo "Observed diffs are :" ; \
	  cat $@ ; \
	  echo "Root cause is probably that a dependancy declared in Kconfig is not respected" ; \
	  echo "or config was added in Kconfig but value not explicitly added to defconfig." ; \
	  echo "Recommanded method to generate defconfig is menuconfig tool instead of manual edit." ; \
	  exit 1;  fi;

.PHONY: menuconfig xconfig gconfig

menuconfig xconfig gconfig: $(CHECK_CONFIG_LOG)
	$(hide) xterm -e $(MAKE) $(KERNEL_MAKE_OPTIONS) $@
	$(hide) cp -f $(KERNEL_CONFIG) $(KERNEL_DEFCONFIG)
	@echo ===========
	@echo $(KERNEL_DEFCONFIG) has been modified !
	@echo ===========

$(KERNEL_CONFIG): $(KERNEL_CONFIG_DEPS) | yoctotoolchain $(CHECK_CONFIG_LOG)
	$(hide) cat $(KERNEL_CONFIG_DEPS) > $@
	@echo "Generating Kernel configuration, using $(KERNEL_CONFIG_DEPS)"
	$(hide) $(MAKE) $(KERNEL_MAKE_OPTIONS) olddefconfig </dev/null

$(PRODUCT_OUT)/kernel: $(LOCAL_KERNEL) $(LOCAL_KERNEL_PATH)/copy_modules
	$(hide) cp $(LOCAL_KERNEL) $@

# kernel modules must be copied before vendorimage is generated
$(PRODUCT_OUT)/vendor.img: $(LOCAL_KERNEL_PATH)/copy_modules

# Copy modules in directory pointed by $(KERNEL_MODULES_ROOT)
# First copy modules keeping directory hierarchy lib/modules/`uname-r`for libkmod
# Second, create flat hierarchy for insmod linking to previous hierarchy
$(LOCAL_KERNEL_PATH)/copy_modules: $(LOCAL_KERNEL)
	@echo Copy modules from $(LOCAL_KERNEL_PATH)/lib/modules/$(KERNELRELEASE) into $(PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)
	$(hide) rm -rf $(PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)
	$(hide) rm -rf $(TARGET_RECOVERY_ROOT_OUT)/$(KERNEL_MODULES_ROOT)
	$(hide) mkdir -p $(PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)
	$(hide) cd $(LOCAL_KERNEL_PATH)/lib/modules/$(KERNELRELEASE) && for f in `find . -name '*.ko' -or -name 'modules.*'`; do \
		cp $$f $(PWD)/$(PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)/$$(basename $$f) || exit 1; \
		mkdir -p $(PWD)/$(PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)/$(KERNELRELEASE)/$$(dirname $$f) ; \
		ln -s /$(KERNEL_MODULES_ROOT_PATH)/$$(basename $$f) $(PWD)/$(PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)/$(KERNELRELEASE)/$$f || exit 1; \
		done
	$(hide) touch $@
#usb-init for recovery
	$(hide) mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/$(KERNEL_MODULES_ROOT)
	$(hide) for f in dwc3.ko dwc3-pci.ko xhci-hcd.ko xhci-pci.ko; do \
		find $(LOCAL_KERNEL_PATH)/lib/modules/ -name $$f -exec cp {} $(TARGET_RECOVERY_ROOT_OUT)/$(KERNEL_MODULES_ROOT)/ \; ;\
		done
#mei for recovery
	$(hide) for f in mei.ko mei-me.ko; do \
		find $(LOCAL_KERNEL_PATH)/lib/modules/ -name $$f -exec cp {} $(TARGET_RECOVERY_ROOT_OUT)/$(KERNEL_MODULES_ROOT)/ \; ;\
		done

ifeq ($(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SUPPORTS_VERITY), true)
DM_VERITY_CERT := $(LOCAL_KERNEL_PATH)/verity.x509
$(DM_VERITY_CERT): $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VERITY_SIGNING_KEY).x509.pem $(OPENSSL)
	$(transform-pem-cert-to-der-cert)
$(LOCAL_KERNEL): $(DM_VERITY_CERT)
endif

$(LOCAL_KERNEL): $(MINIGZIP) $(KERNEL_CONFIG) $(BOARD_DTB) $(KERNEL_DEPS) | yoctotoolchain
	$(MAKE) $(KERNEL_MAKE_OPTIONS)
	$(MAKE) $(KERNEL_MAKE_OPTIONS) modules
	$(MAKE) $(KERNEL_MAKE_OPTIONS) INSTALL_MOD_STRIP=1 modules_install


# disable the modules built in parallel due to some modules symbols has dependency,
# and module install depmod need they be installed one at a time.

PREVIOUS_KERNEL_MODULE := $(LOCAL_KERNEL)

define bld_external_module

$(eval MODULE_DEPS_$(2) := $(shell find kernel/modules/$(1) \( -name *.git -prune \) -o -print ))

$(LOCAL_KERNEL_PATH)/build_$(2): $(LOCAL_KERNEL) $(MODULE_DEPS_$(2)) $(PREVIOUS_KERNEL_MODULE)
	@echo BUILDING $(1)
	@mkdir -p $(LOCAL_KERNEL_PATH)/../modules/$(1)
	$(hide) $(MAKE) $$(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/$(1) V=1 $(ADDITIONAL_ARGS_$(subst /,_,$(1))) modules
	@touch $$(@)

$(LOCAL_KERNEL_PATH)/install_$(2): $(LOCAL_KERNEL_PATH)/build_$(2) $(PREVIOUS_KERNEL_MODULE)
	@echo INSTALLING $(1)
	$(hide) $(MAKE) $$(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/$(1) INSTALL_MOD_STRIP=1 modules_install
	@touch $$(@)

$(LOCAL_KERNEL_PATH)/copy_modules: $(LOCAL_KERNEL_PATH)/install_$(2)

$(eval PREVIOUS_KERNEL_MODULE := $(LOCAL_KERNEL_PATH)/install_$(2))
endef


# Check external module path
$(foreach m,$(EXTERNAL_MODULES),$(if $(findstring .., $(m)), $(error $(m): All external kernel modules should be put under kernel/modules folder)))

$(foreach m,$(EXTERNAL_MODULES),$(eval $(call bld_external_module,$(m),$(subst /,_,$(m)))))



# Add a kernel target, so "make kernel" will build the kernel
.PHONY: kernel
kernel: $(LOCAL_KERNEL_PATH)/copy_modules $(PRODUCT_OUT)/kernel

endif

##############################################################
# Source: device/intel/mixins/groups/audio/project-celadon/AndroidBoard.mk
##############################################################
pfw_rebuild_settings := true
# Target specific audio configuration files
include $(INTEL_PATH_COMMON)/audio/AndroidBoard.mk
##############################################################
# Source: device/intel/mixins/groups/flashfiles/ini/AndroidBoard.mk
##############################################################
ff_intermediates := $(call intermediates-dir-for,PACKAGING,flashfiles)

# We need a copy of the flashfiles configuration ini in the
# TFP RADIO/ directory
ff_config := $(ff_intermediates)/flashfiles.ini
$(ff_config): $(FLASHFILES_CONFIG) | $(ACP)
	$(copy-file-to-target)

$(call add_variant_flashfiles,$(ff_intermediates))

INSTALLED_RADIOIMAGE_TARGET += $(ff_config)


$(call flashfile_add_blob,extra_script.edify,$(TARGET_DEVICE_DIR)/flashfiles/::variant::/extra_script.edify)

# We take any required images that can't be derived elsewhere in
# the TFP and put them in RADIO/provdata.zip.
ff_intermediates := $(call intermediates-dir-for,PACKAGING,flashfiles)
provdata_zip := $(ff_intermediates)/provdata.zip
provdata_zip_deps := $(foreach pair,$(BOARD_FLASHFILES),$(call word-colon,1,$(pair)))
ff_root := $(ff_intermediates)/root

define copy-flashfile
$(hide) $(ACP) -fp $(1) $(2)

endef

define deploy_provdata
$(eval ff_var := $(subst provdata,,$(basename $(notdir $(1)))))
$(hide) rm -f $(1)
$(hide) rm -rf $(ff_intermediates)/root$(ff_var)
$(hide) mkdir -p $(ff_intermediates)/root$(ff_var)
$(foreach pair,$(BOARD_FLASHFILES$(ff_var)), \
	$(call copy-flashfile,$(call word-colon,1,$(pair)),$(ff_intermediates)/root$(ff_var)/$(call word-colon,2,$(pair))))
$(hide) zip -qj $(1) $(ff_intermediates)/root$(ff_var)/*
endef

ifneq ($(FLASHFILE_VARIANTS),)
provdata_zip :=
$(foreach var,$(FLASHFILE_VARIANTS), \
	$(eval provdata_zip += $(ff_intermediates)/provdata_$(var).zip) \
	$(eval BOARD_FLASHFILES_$(var) := $(BOARD_FLASHFILES)) \
	$(eval BOARD_FLASHFILES_$(var) += $(BOARD_FLASHFILES_FIRMWARE_$(var))) \
	$(eval provdata_zip_deps += $(foreach pair,$(BOARD_FLASHFILES_FIRMWARE_$(var)),$(call word-colon,1,$(pair)))))
else
$(eval BOARD_FLASHFILES += $(BOARD_FLASHFILES_FIRMWARE))
$(eval provdata_zip_deps += $(foreach pair,$(BOARD_FLASHFILES_FIRMWARE),$(call word-colon,1,$(pair))))
endif

$(provdata_zip): $(provdata_zip_deps) | $(ACP)
	$(call deploy_provdata,$@)


INSTALLED_RADIOIMAGE_TARGET += $(provdata_zip)

##############################################################
# Source: device/intel/mixins/groups/gptbuild/true/AndroidBoard.mk
##############################################################
gptimage_size ?= 14G

raw_config := none
raw_factory := none
tos_bin := none
multiboot_bin := none

.PHONY: none
none: ;

.PHONY: $(INSTALLED_CONFIGIMAGE_TARGET).raw
$(INSTALLED_CONFIGIMAGE_TARGET).raw: $(INSTALLED_CONFIGIMAGE_TARGET) $(SIMG2IMG)
	$(SIMG2IMG) $< $@

.PHONY: $(INSTALLED_FACTORYIMAGE_TARGET).raw
$(INSTALLED_FACTORYIMAGE_TARGET).raw: $(INSTALLED_FACTORYIMAGE_TARGET) $(SIMG2IMG)
	$(SIMG2IMG) $< $@

ifdef INSTALLED_CONFIGIMAGE_TARGET
raw_config := $(INSTALLED_CONFIGIMAGE_TARGET).raw
endif

ifdef INSTALLED_FACTORYIMAGE_TARGET
raw_factory := $(INSTALLED_FACTORYIMAGE_TARGET).raw
endif

.PHONY: $(GPTIMAGE_BIN)
ifeq ($(strip $(TARGET_USE_TRUSTY)),true)
ifeq ($(strip $(TARGET_USE_MULTIBOOT)),true)
$(GPTIMAGE_BIN): tosimage multiboot
multiboot_bin = $(INSTALLED_MULTIBOOT_IMAGE_TARGET)
else
$(GPTIMAGE_BIN): tosimage
endif
tos_bin = $(INSTALLED_TOS_IMAGE_TARGET)
endif

$(GPTIMAGE_BIN): \
	bootloader \
	bootimage \
	systemimage \
	vbmetaimage \
	vendorimage \
	$(SIMG2IMG) \
	$(raw_config) \
	$(raw_factory)

	$(hide) rm -f $(INSTALLED_SYSTEMIMAGE).raw
	$(hide) rm -f $(INSTALLED_USERDATAIMAGE_TARGET).raw

	$(SIMG2IMG) $(INSTALLED_SYSTEMIMAGE) $(INSTALLED_SYSTEMIMAGE).raw
	$(SIMG2IMG) $(INSTALLED_VENDORIMAGE_TARGET) $(INSTALLED_VENDORIMAGE_TARGET).raw

	$(INTEL_PATH_BUILD)/create_gpt_image.py \
		--create $@ \
		--block $(BOARD_FLASH_BLOCK_SIZE) \
		--table $(TARGET_DEVICE_DIR)/gpt.ini \
		--size $(gptimage_size) \
		--bootloader $(bootloader_bin) \
		--bootloader2 $(bootloader_bin) \
		--tos $(tos_bin) \
		--multiboot $(multiboot_bin) \
		--boot $(INSTALLED_BOOTIMAGE_TARGET) \
		--vbmeta $(INSTALLED_VBMETAIMAGE_TARGET) \
		--system $(INSTALLED_SYSTEMIMAGE).raw \
		--vendor $(INSTALLED_VENDORIMAGE_TARGET).raw \
		--config $(raw_config) \
		--factory $(raw_factory)


.PHONY: gptimage
gptimage: $(GPTIMAGE_BIN)
##############################################################
# Source: device/intel/mixins/groups/device-type/car/AndroidBoard.mk
##############################################################
# Car device required kernel diff config
#KERNEL_CAR_DIFFCONFIG = $(wildcard $(KERNEL_CONFIG_PATH)/car_diffconfig)
#KERNEL_DIFFCONFIG += $(KERNEL_CAR_DIFFCONFIG)
# ------------------ END MIX-IN DEFINITIONS ------------------
