# Wlan Configuration
ENABLE_SP := false
WLAN_GEN3_CHIPS := CONSYS_6797 CONSYS_6759 CONSYS_6758 CONSYS_6775 CONSYS_6771
WLAN_GEN4M_CHIPS := CONSYS_6765 CONSYS_6761 CONSYS_3967 CONSYS_6779 CONSYS_6768 CONSYS_6785
ifeq ($(ENABLE_SP), false)
    wlan_patch_folder := vendor/mediatek/proprietary/hardware/connectivity/firmware/wlan
else
    WLAN_SP_PATH := vendor/mediatek/proprietary/hardware/connectivity/firmware/wlan_sp*
    wlan_patch_folder := $(wildcard $(WLAN_SP_PATH))
endif

ifeq ($(strip $(MTK_COMBO_CHIP)), MT7668)
    wlan_drv_config_folder := vendor/mediatek/proprietary/hardware/connectivity/wlan/drv_config
endif

ifeq ($(strip $(MTK_COMBO_CHIP)), MT6632)
    MY_SRC_FILE := WIFI_RAM_CODE_$(MTK_COMBO_CHIP)
else ifeq ($(strip $(MTK_COMBO_CHIP)), MT6630)
    MY_SRC_FILE := WIFI_RAM_CODE_$(MTK_COMBO_CHIP)
else ifeq ($(strip $(MTK_COMBO_CHIP)), MT7668)
    MY_SRC_FILE := WIFI_RAM_CODE_$(MTK_COMBO_CHIP).bin
else
    # remove prefix and subffix chars, only left numbers.
    WLAN_CHIP_ID := $(patsubst consys_%,%,$(patsubst CONSYS_%,%,$(strip $(MTK_COMBO_CHIP))))
    WIFI_WMT := y
    WIFI_EMI := y
    # WLAN_CHIP_ID exist
    ifneq ($(strip $(WLAN_CHIP_ID)),)
        # If your chip will share the same ram code with other chips, and the ram code name is not WIFI_RAM_CODE_SOC, \
          please give a specific chip id to WLAN_CHIP_ID, it will override the previous value of WLAN_CHIP_ID \
          for example:
        WLAN_6759_SERIES := 6758 6775 6771
        WLAN_6755_SERIES := 6757 6763 6739
        WLAN_6765_SERIES := 6765 6761
        WLAN_CONNAC_SERIES := $(WLAN_6765_SERIES) 3967 6779 6768 6785
        ifneq ($(filter $(WLAN_6755_SERIES), $(WLAN_CHIP_ID)),)
            WLAN_CHIP_ID := 6755
        else ifneq ($(filter $(WLAN_6759_SERIES), $(WLAN_CHIP_ID)),)
            WLAN_CHIP_ID := 6759
        else ifneq ($(filter $(WLAN_CONNAC_SERIES), $(WLAN_CHIP_ID)),)
            WIFI_HIF := axi
            WLAN_BRANCH_1_SERIES := $(WLAN_6765_SERIES) 3967 6768 6785
            WLAN_BRANCH_2_SERIES := 6779
            ifneq ($(filter $(WLAN_BRANCH_2_SERIES), $(WLAN_CHIP_ID)),)
                WIFI_CHIP:= CONNAC2X2
                WIFI_BRANCH_NAME := 2_0
            else
                WIFI_CHIP:= CONNAC
                WIFI_BRANCH_NAME := 1_0
            endif
            # 1:1X1_L, 2:1X1_P, 3:2X2_P
            WLAN_IP_SET_1_SERIES := $(WLAN_6765_SERIES)
            WLAN_IP_SET_2_SERIES := 3967 6785
            WLAN_IP_SET_3_SERIES := 6779
            ifneq ($(filter $(WLAN_IP_SET_3_SERIES), $(WLAN_CHIP_ID)),)
                WIFI_IP_SET := 3
            else ifneq ($(filter $(WLAN_IP_SET_2_SERIES), $(WLAN_CHIP_ID)),)
                WIFI_IP_SET := 2
            else
                WIFI_IP_SET := 1
            endif
            WIFI_ECO_VER := 1

            ifneq ($(filter 6768, $(WLAN_CHIP_ID)),)
                WIFI_FLAVOR := a
            else ifneq ($(filter 6779, $(WLAN_CHIP_ID)),)
                ifeq ($(strip $(MTK_CONSYS_ADIE)), MT6631)
                    WIFI_FLAVOR := a
                else
                    WIFI_FLAVOR :=
                endif
            else ifneq ($(filter 6785, $(WLAN_CHIP_ID)),)
                WIFI_FLAVOR := a
            else
                WIFI_FLAVOR :=
            endif
            ifneq ($(filter $(WLAN_6765_SERIES), $(WLAN_CHIP_ID)),)
                WLAN_CHIP_ID := 6765
            endif
            MY_SRC_FILE := WIFI_RAM_CODE_soc$(WIFI_BRANCH_NAME)_$(WIFI_IP_SET)$(WIFI_FLAVOR)_$(WIFI_ECO_VER).bin
            WIFI_ROM_EMI_FILE := soc$(WIFI_BRANCH_NAME)_ram_wifi_$(WIFI_IP_SET)$(WIFI_FLAVOR)_$(WIFI_ECO_VER)_hdr.bin
        endif
        ifneq ($(wildcard $(wlan_patch_folder)/WIFI_RAM_CODE_$(WLAN_CHIP_ID)),)
            MY_SRC_FILE := WIFI_RAM_CODE_$(WLAN_CHIP_ID)
        endif
    endif
endif

ifneq ($(strip $(MY_SRC_FILE)),)
    PRODUCT_COPY_FILES += $(wlan_patch_folder)/$(MY_SRC_FILE):$(TARGET_COPY_OUT_VENDOR)/firmware/$(MY_SRC_FILE)
else
    $(error no firmware for project=$(MTK_TARGET_PROJECT), combo_chip=$(MTK_COMBO_CHIP), WLAN_CHIP_ID=$(WLAN_CHIP_ID))
endif

ifeq ($(strip $(MTK_COMBO_CHIP)), MT6632)
    MY_SRC_FILE := WIFI_RAM_CODE2_$(strip $(MTK_COMBO_CHIP))
    PRODUCT_COPY_FILES += $(wlan_patch_folder)/$(MY_SRC_FILE):$(TARGET_COPY_OUT_VENDOR)/firmware/$(MY_SRC_FILE)
endif

ifeq ($(strip $(MTK_COMBO_CHIP)), MT7668)
    MY_SRC_FILE := WIFI_RAM_CODE2_SDIO_$(strip $(MTK_COMBO_CHIP)).bin
    PRODUCT_COPY_FILES += $(wlan_patch_folder)/$(MY_SRC_FILE):$(TARGET_COPY_OUT_VENDOR)/firmware/$(MY_SRC_FILE)
    PRODUCT_COPY_FILES += $(wlan_drv_config_folder)/mt7668_wifi.cfg:$(TARGET_COPY_OUT_VENDOR)/firmware/wifi.cfg:mtk
    PRODUCT_COPY_FILES += $(wlan_drv_config_folder)/TxPwrLimit_MT76x8.dat:$(TARGET_COPY_OUT_VENDOR)/firmware/TxPwrLimit_MT76x8.dat:mtk
    PRODUCT_COPY_FILES += $(wlan_drv_config_folder)/EEPROM_MT7668.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/EEPROM_MT7668.bin:mtk
endif

ifneq ($(strip $(WIFI_ROM_EMI_FILE)),)
    PRODUCT_COPY_FILES += $(wlan_patch_folder)/$(WIFI_ROM_EMI_FILE):$(TARGET_COPY_OUT_VENDOR)/firmware/$(WIFI_ROM_EMI_FILE)
endif

ifeq ($(MTK_TC10_FEATURE),yes)
    PRODUCT_PACKAGES += WIFI
endif

# for decoupled kernel object (.ko) of wifi driver
ifneq ($(filter MT6630, $(MTK_COMBO_CHIP)),)
PRODUCT_PACKAGES += wlan_drv_gen3.ko
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.wlan.gen=gen3
endif

ifneq ($(filter MT6632, $(MTK_COMBO_CHIP)),)
PRODUCT_PACKAGES += wlan_drv_gen4.ko
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.wlan.gen=gen4
endif

ifneq ($(filter MT7668, $(MTK_COMBO_CHIP)),)
PRODUCT_PACKAGES += wlan_drv_gen4_mt7668.ko
PRODUCT_PACKAGES += wlan_drv_gen4_mt7668_prealloc.ko
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.wlan.gen=gen4_mt7668
endif

ifneq ($(filter $(WLAN_GEN3_CHIPS), $(MTK_COMBO_CHIP)),)
DUTINFO_NAME := 6631_gen3
PRODUCT_PACKAGES += wlan_drv_gen3.ko
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.wlan.gen=gen3
else ifneq ($(filter $(WLAN_GEN4M_CHIPS), $(MTK_COMBO_CHIP)),)
    ifneq ($(filter 6779, $(WLAN_CHIP_ID)),)
        ifeq ($(strip $(MTK_CONSYS_ADIE)), MT6631)
            DUTINFO_NAME := 6631_gen4m
        else
            DUTINFO_NAME := 6635_gen4m
        endif
    else
        DUTINFO_NAME := 6631_gen4m
    endif
PRODUCT_PACKAGES += wlan_drv_gen4m.ko
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.wlan.gen=gen4m
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 1}, {{AP}, 1}, {{P2P}, 1}}
else ifneq ($(filter CONSYS_%, $(MTK_COMBO_CHIP)),)
DUTINFO_NAME := 6625_gen2
PRODUCT_PACKAGES += wlan_drv_gen2.ko
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.wlan.gen=gen2
endif

ifeq ($(filter MT7668, $(MTK_COMBO_CHIP)),)
PRODUCT_PACKAGES += wmt_chrdev_wifi.ko
endif

PRODUCT_PACKAGES += wlan_assistant

# sigma tool
SIGMA_SRC_DIR := vendor/mediatek/proprietary/hardware/connectivity/wlan/sigma/mediatek
SIGMA_OUT_DIR := $(PRODUCT_OUT)/testcases/sigma
PRODUCT_PACKAGES += libwfadut_static
PRODUCT_PACKAGES += wfa_dut
PRODUCT_PACKAGES += wfa_ca
PRODUCT_PACKAGES += wfa_con
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,$(SIGMA_SRC_DIR)/release,$(SIGMA_OUT_DIR))
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,$(SIGMA_SRC_DIR)/DUTInfo/$(DUTINFO_NAME),$(SIGMA_OUT_DIR)/DUTInfo)
