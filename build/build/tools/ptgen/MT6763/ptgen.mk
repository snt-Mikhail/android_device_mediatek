ifndef TARGET_BOARD_PLATFORM
  $(error TARGET_BOARD_PLATFORM is not defined)
endif
ifndef MTK_PTGEN_CHIP
  $(error MTK_PTGEN_CHIP is not defined)
endif
ifndef MTK_PTGEN_OUT_DIR
  $(error MTK_PTGEN_OUT_DIR is not defined)
endif

MTK_PTGEN_PERL := device/mediatek/build/build/tools/ptgen/$(MTK_PTGEN_CHIP)/ptgen.pl
MTK_PTGEN_XLS := $(wildcard device/mediatek/build/build/tools/ptgen/$(MTK_PTGEN_CHIP)/*.xls)
MTK_PTGEN_COMMAND := \
	MTK_PLATFORM=${MTK_PLATFORM} \
	PLATFORM=${MTK_PTGEN_CHIP} \
	MTK_TARGET_PROJECT=${MTK_TARGET_PROJECT} \
	TARGET_BUILD_VARIANT=${TARGET_BUILD_VARIANT} \
	BUILD_MTK_LDVT=${BUILD_MTK_LDVT} \
	MTK_NAND_PAGE_SIZE=${MTK_NAND_PAGE_SIZE} \
	MTK_YAML_SCATTER_FILE_SUPPORT=${MTK_YAML_SCATTER_FILE_SUPPORT} \
	MTK_EMMC_SUPPORT=${MTK_EMMC_SUPPORT} \
	MTK_UFS_SUPPORT=${MTK_UFS_SUPPORT} \
	MTK_LDVT_SUPPORT=${MTK_LDVT_SUPPORT} \
	MTK_EMMC_SUPPORT_OTP=${MTK_EMMC_SUPPORT_OTP} \
	MTK_UFS_OTP=${MTK_UFS_OTP} \
	MTK_SHARED_SDCARD=${MTK_SHARED_SDCARD} \
	MTK_CIP_SUPPORT=${MTK_CIP_SUPPORT} \
	MTK_FAT_ON_NAND=${MTK_FAT_ON_NAND} \
	MTK_SPI_NAND_SUPPORT=${MTK_SPI_NAND_SUPPORT} \
	MTK_NAND_UBIFS_SUPPORT=${MTK_NAND_UBIFS_SUPPORT} \
	MTK_COMBO_NAND_SUPPORT=${MTK_COMBO_NAND_SUPPORT} \
	PL_MODE=${PL_MODE} \
	MTK_PARTITION_TABLE_PLAIN_TEXT=${MTK_PARTITION_TABLE_PLAIN_TEXT} \
	MTK_ATF_SUPPORT=${MTK_ATF_SUPPORT} \
	MTK_TEE_SUPPORT=${MTK_TEE_SUPPORT} \
	MTK_PERSIST_PARTITION_SUPPORT=${MTK_PERSIST_PARTITION_SUPPORT} \
	MTK_DRM_KEY_MNG_SUPPORT=${MTK_DRM_KEY_MNG_SUPPORT} \
	MTK_BASE_PROJECT=${MTK_BASE_PROJECT} \
	PTGEN_ENV="PROJECT" \
	PTGEN_MK_OUT=${MTK_PTGEN_OUT} \
	TMP_OUT_PATH=${MTK_PTGEN_TMP_OUT} \
	OUT_DIR=${MTK_PTGEN_OUT_DIR} \
	PRELOADER_TARGET=${PRELOADER_TARGET_PRODUCT} \
	MTK_FACTORY_RESET_PROTECTION_SUPPORT=${MTK_FACTORY_RESET_PROTECTION_SUPPORT} \
	MTK_EFUSE_WRITER_SUPPORT=${MTK_EFUSE_WRITER_SUPPORT} \
	MTK_TINYSYS_SCP_SUPPORT=${MTK_TINYSYS_SCP_SUPPORT} \
	MTK_TINYSYS_SSPM_SUPPORT=${MTK_TINYSYS_SSPM_SUPPORT} \
	MTK_SIM_LOCK_POWER_ON_WRITE_PROTECT=${MTK_SIM_LOCK_POWER_ON_WRITE_PROTECT} \
	MTK_VPU_SUPPORT=${MTK_VPU_SUPPORT} \
	SPM_FW_USE_PARTITION=${SPM_FW_USE_PARTITION} \
	MTK_DTBO_FEATURE=${MTK_DTBO_FEATURE} \
	MTK_AB_OTA_UPDATER=${MTK_AB_OTA_UPDATER} \
	TARGET_COPY_OUT_ODM="${TARGET_COPY_OUT_ODM}" \
	MTK_SINGLE_BIN_MODEM_SUPPORT=${MTK_SINGLE_BIN_MODEM_SUPPORT} \
	MTK_GMO_RAM_OPTIMIZE=${MTK_GMO_RAM_OPTIMIZE} \
	MTK_BOARD_AVB_ENABLE=${BOARD_AVB_ENABLE} \
	MAIN_VBMETA_IN_BOOT=${MAIN_VBMETA_IN_BOOT} \
	MTK_RESERVE_ENG_PARTITIONS=${MTK_RESERVE_ENG_PARTITIONS} \
	MTK_DTBO_UPGRADE_FROM_ANDROID_O=${MTK_DTBO_UPGRADE_FROM_ANDROID_O} \
	PRODUCT_USE_DYNAMIC_PARTITIONS=${PRODUCT_USE_DYNAMIC_PARTITIONS} \
	PRODUCT_RETROFIT_DYNAMIC_PARTITIONS=${PRODUCT_RETROFIT_DYNAMIC_PARTITIONS} \
	TARGET_NO_RECOVERY=${TARGET_NO_RECOVERY} \
	MTK_BOARD_USES_METADATA_PARTITION=${BOARD_USES_METADATA_PARTITION} \
	$(PERL) $(MTK_PTGEN_PERL)

MTK_VENDOR_IMAGE_NAMES :=
MTK_OTA_UPDATE_LIST :=

MTK_VENDOR_IMAGE_NAMES += vendor.img
MTK_VENDOR_IMAGE_NAMES += boot.img
MTK_VENDOR_IMAGE_NAMES += userdata.img
ifeq ($(TARGET_COPY_OUT_ODM),yes)
MTK_VENDOR_IMAGE_NAMES += odm.img
endif
ifeq ($(MTK_DTBO_FEATURE),yes)
ifneq ($(MTK_DTBO_UPGRADE_FROM_ANDROID_O),yes)
MTK_VENDOR_IMAGE_NAMES += dtbo.img
MTK_OTA_UPDATE_LIST += dtbo.img:dtbo
endif
endif
ifneq ($(MTK_AB_OTA_UPDATER),yes)
MTK_VENDOR_IMAGE_NAMES += cache.img
MTK_VENDOR_IMAGE_NAMES += recovery.img
endif
ifdef PRELOADER_TARGET_PRODUCT
MTK_VENDOR_IMAGE_NAMES += preloader_$(PRELOADER_TARGET_PRODUCT).bin
MTK_OTA_UPDATE_LIST += preloader.img:preloader:preloader2
endif
ifdef LK_PROJECT
MTK_VENDOR_IMAGE_NAMES += lk.img
MTK_OTA_UPDATE_LIST += lk.img:bootloader:bootloader2
MTK_VENDOR_IMAGE_NAMES += logo.bin
endif
ifeq ($(MTK_ATF_SUPPORT),yes)
MTK_VENDOR_IMAGE_NAMES += tee.img
MTK_OTA_UPDATE_LIST += tee.img:tee1:tee2
else ifeq ($(MTK_TEE_SUPPORT),yes)
MTK_VENDOR_IMAGE_NAMES += tee.img
MTK_OTA_UPDATE_LIST += tee.img:tee1:tee2
endif
ifeq ($(SPM_FW_USE_PARTITION),yes)
MTK_VENDOR_IMAGE_NAMES += spmfw.img
MTK_OTA_UPDATE_LIST += spmfw.img:spmfw
endif
ifeq ($(MCUPM_FW_USE_PARTITION),yes)
MTK_VENDOR_IMAGE_NAMES += mcupmfw.img
MTK_OTA_UPDATE_LIST += mcupmfw.img:mcupmfw
endif
ifeq ($(MTK_TINYSYS_SCP_SUPPORT),yes)
MTK_VENDOR_IMAGE_NAMES += scp.img
endif
ifeq ($(MTK_TINYSYS_SSPM_SUPPORT),yes)
MTK_VENDOR_IMAGE_NAMES += sspm.img
endif
ifeq ($(MTK_SINGLE_BIN_MODEM_SUPPORT),yes)
MTK_VENDOR_IMAGE_NAMES += md1img.img
MTK_OTA_UPDATE_LIST += md1img.img:md1img
endif
ifeq ($(MTK_VPU_SUPPORT),yes)
MTK_VENDOR_IMAGE_NAMES += cam_vpu1.img
MTK_VENDOR_IMAGE_NAMES += cam_vpu2.img
MTK_VENDOR_IMAGE_NAMES += cam_vpu3.img
endif
MTK_VENDOR_IMAGE_NAMES += $(MTK_PLATFORM)_Android_scatter.txt

ifneq ($(CALLED_FROM_SETUP),true)
  ifeq ($(PTGEN_BUILD),false)
    $(info PTGEN_BUILD is $(PTGEN_BUILD), skip ptgen)
  else
    MTK_PTGEN_RES := $(shell $(MTK_PTGEN_COMMAND) >&2; echo $$?)
    ifneq ($(strip $(MTK_PTGEN_RES)),0)
      $(error ptgen error=$(MTK_PTGEN_RES): $(MTK_PTGEN_COMMAND))
    endif
  endif
endif
