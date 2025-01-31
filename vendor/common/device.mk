ifdef SYS_TARGET_PROJECT
$(call inherit-product-if-exists,device/mediatek/system/common/device.mk)
else ifneq ($(filter full_%,$(TARGET_PRODUCT)),)
$(call inherit-product-if-exists,device/mediatek/system/common/device.mk)
else ifeq ($(wildcard $(MTK_TARGET_PROJECT_FOLDER)/vnd_*.mk),)
$(call inherit-product-if-exists,device/mediatek/system/common/device.mk)
endif


ifndef MTK_PLATFORM_DIR
  ifneq ($(wildcard device/mediatek/$(MTK_PLATFORM)),)
    MTK_PLATFORM_DIR := $(MTK_PLATFORM)
  else
    MTK_PLATFORM_DIR := $(shell echo $(MTK_PLATFORM) | tr '[A-Z]' '[a-z]')
  endif
endif
DEVICE_MANIFEST_FILE := $(strip $(DEVICE_MANIFEST_FILE))

# Add for Full Treble
PRODUCT_FULL_TREBLE_OVERRIDE ?= true

# At Q, AOSP supports XML audio policy configuration by default. May remove the option after Q
USE_XML_AUDIO_POLICY_CONF ?= 1

# Full Treble, new in O
ifeq ($(PRODUCT_FULL_TREBLE_OVERRIDE), true)
  PRODUCT_SHIPPING_API_LEVEL := 29
  ifneq ($(PRODUCT_SHIPPING_API_LEVEL_OVERRIDE),)
    PRODUCT_SHIPPING_API_LEVEL := $(PRODUCT_SHIPPING_API_LEVEL_OVERRIDE)
  endif
else
  PRODUCT_SHIPPING_API_LEVEL := 25
endif
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

ifeq ($(MTK_DYNAMIC_PARTITION_SUPPORT), yes)
PRODUCT_USE_DYNAMIC_PARTITIONS := true
endif

# Assign target level version
ifneq ($(call math_lt,$(PRODUCT_SHIPPING_API_LEVEL),28),)
 DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/manifest_target_level_o.xml
else ifneq ($(call math_lt,$(PRODUCT_SHIPPING_API_LEVEL),29),)
 DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/manifest_target_level_p.xml
else
 DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/manifest_target_level_q.xml
endif

ifeq ($(wildcard device/mediatek/$(MTK_PLATFORM_DIR)),)
  $(error the platform dir changed, expected: device/mediatek/$(MTK_PLATFORM_DIR), please check manually)
endif

# touch related file for copy firmware
PRODUCT_COPY_FILES += $(foreach TOUCH,$(MTK_TOUCHPANEL_FIRMWARE),\
                      $(call find-copy-subdir-files,*,vendor/mediatek/proprietary/custom/touch/$(TOUCH),$(TARGET_COPY_OUT_VENDOR)/firmware))

#MtkLatinIME

#ifeq ($(strip $(MTK_BSP_PACKAGE)), yes)
#    PRODUCT_PACKAGES += MtkLatinIME
#endif

##fbconfig for display
ifneq ($(strip $(TARGET_BUILD_VARIANT)),user)
    PRODUCT_PACKAGES += fbconfig
endif

# MediaTek framework base modules
#PRODUCT_PACKAGES += \
#    mediatek-common \
#    mediatek-framework \
#    CustomPropInterface \
#    mediatek-telephony-common \
#    mediatek-telephony-base

# Mediatek default Fwk plugin always compile as per MPlugin new design
#PRODUCT_PACKAGES += \
#    FwkPlugin

# MediaTek wifi framework host stubs
#PRODUCT_PACKAGES += mtk-wifi-service

#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
## Override the PRODUCT_BOOT_JARS to include the MediaTek system base modules for global access
#PRODUCT_BOOT_JARS += \
#    mediatek-common \
#    mediatek-framework \
#    mediatek-telephony-base \
#    mediatek-telephony-common
#endif

# Telephony
#PRODUCT_COPY_FILES += device/mediatek/config/apns-conf.xml:system/etc/apns-conf.xml:mtk
PRODUCT_COPY_FILES += vendor/mediatek/proprietary/hardware/ril/fusion/mtk-ril/mdcomm/data/vendor-apns-conf.xml:$(TARGET_COPY_OUT_VENDOR)/etc/vendor-apns-conf.xml:mtk
#PRODUCT_COPY_FILES += $(LOCAL_PATH)/spn-conf.xml:system/etc/spn-conf.xml:mtk

# Graphic Extension Deployment
#PRODUCT_PACKAGES += libged_sys
#PRODUCT_PACKAGES += libged_kpi

# DRVB
PRODUCT_PACKAGES += libmtk_drvb

# Common overlay moved from project device.mk
#DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/sd_in_ex_otg
#ifdef OPTR_SPEC_SEG_DEF
#  ifneq ($(strip $(OPTR_SPEC_SEG_DEF)),NONE)
#    OPTR := $(word 1,$(subst _,$(space),$(OPTR_SPEC_SEG_DEF)))
#    SPEC := $(word 2,$(subst _,$(space),$(OPTR_SPEC_SEG_DEF)))
#    SEG  := $(word 3,$(subst _,$(space),$(OPTR_SPEC_SEG_DEF)))
#    DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/operator/$(OPTR)/$(SPEC)/$(SEG)
#  endif
#endif
#ifneq (yes,$(strip $(MTK_TABLET_PLATFORM)))
#  ifeq (480,$(strip $(LCM_WIDTH)))
#    ifeq (854,$(strip $(LCM_HEIGHT)))
#      DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/FWVGA
#    endif
#  endif
#  ifeq (540,$(strip $(LCM_WIDTH)))
#    ifeq (960,$(strip $(LCM_HEIGHT)))
#      DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/qHD
#    endif
#  endif
#endif
#DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/navbar

# AGO
$(call inherit-product-if-exists, $(LOCAL_PATH)/ago/device.mk)

#Audio device xml
PRODUCT_COPY_FILES += \
      $(call add-to-product-copy-files-if-exists, $(MTK_TARGET_PROJECT_FOLDER)/audio_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_device.xml:mtk) \
      device/mediatek/$(MTK_PLATFORM_DIR)/audio_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_device.xml:mtk

# Audio HAL
DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_audio.xml

PRODUCT_PACKAGES += \
    android.hardware.audio@5.0-impl-mediatek \
    android.hardware.audio.effect@5.0-impl \
    android.hardware.bluetooth.audio@2.0-impl-mediatek

PRODUCT_PACKAGES += \
   android.hardware.audio@5.0-service-mediatek

# Bluetooth Audio A2DP HW module
PRODUCT_PACKAGES += \
   audio.bluetooth.default

# Audio
ifeq ($(findstring maxim, $(MTK_AUDIO_SPEAKER_PATH)), maxim)
    PRODUCT_PACKAGES += libdsm
    PRODUCT_PACKAGES += libdsmconfigparser
    PRODUCT_PACKAGES += libdsm_interface
else ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),smartpa_nxp_tfa9887)
    PRODUCT_PACKAGES += libtfa9887_interface
else ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),smartpa_nxp_tfa9890)
    PRODUCT_PACKAGES += libtfa9890_interface
else ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),smartpa_nxp_tfa9874)
    PRODUCT_PACKAGES += \
        libnxp_extamp_intf \
        libnxpsmartpaparser

    $(foreach bin,$(wildcard $(MTK_TARGET_PROJECT_FOLDER)/*.bin), \
        $(eval PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists, $(bin):$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/$(notdir $(bin)):mtk)) \
    )
    $(foreach bin,$(wildcard device/mediatek/$(MTK_PLATFORM_DIR)/smartpa_param/*.bin), \
        $(eval PRODUCT_COPY_FILES += $(bin):$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/$(notdir $(bin)):mtk) \
    )

    $(foreach bin,$(wildcard vendor/mediatek/proprietary/external/aurisys/libnxp/libnxpsmartpa/bypass_lib_param/*.bin), \
        $(eval PRODUCT_COPY_FILES += $(bin):$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/nxp_bypass_lib_param/$(notdir $(bin)):mtk) \
    )

    PRODUCT_COPY_FILES += \
        $(call add-to-product-copy-files-if-exists, $(MTK_TARGET_PROJECT_FOLDER)/tfa98xx.cnt:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/tfa98xx.cnt:mtk) \
        device/mediatek/$(MTK_PLATFORM_DIR)/smartpa_param/tfa98xx.cnt:$(TARGET_COPY_OUT_VENDOR)/firmware/tfa98xx.cnt:mtk
else ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),smartpa_mtk_mt6660)
    PRODUCT_PACKAGES += \
        librt_extamp_intf \
        libaudiosmartpamtk \
        smartpa_nvtest

    PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/mediatek/calib.dat:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/calib.dat:mtk
    PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/mediatek/calib.dat.sig:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/calib.dat.sig:mtk
    PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/mediatek/mt6660_calibration:$(TARGET_COPY_OUT_VENDOR)/bin/mt6660_calibration:mtk
    PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/custom/common/factory/res/sound/CalibrationPatternOut.wav:$(TARGET_COPY_OUT_VENDOR)/res/sound/CalibrationPatternOut.wav:mtk

    PRODUCT_COPY_FILES += \
        $(call add-to-product-copy-files-if-exists, $(MTK_TARGET_PROJECT_FOLDER)/rt_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/rt_device.xml:mtk)
    PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/mediatek/rt_mono_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/rt_device.xml:mtk

    PRODUCT_COPY_FILES += \
        $(call add-to-product-copy-files-if-exists, $(MTK_TARGET_PROJECT_FOLDER)/mt6660_param:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/mt6660_param:mtk)
    PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/mediatek/mt6660_param:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/mt6660_param:mtk

    PRODUCT_COPY_FILES += \
        $(call add-to-product-copy-files-if-exists, $(MTK_TARGET_PROJECT_FOLDER)/SmartPaVendor1_AudioParam.dat:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/SmartPaVendor1_AudioParam.dat:mtk)
    PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/mediatek/SmartPaVendor1_AudioParam.dat:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/SmartPaVendor1_AudioParam.dat:mtk

    PRODUCT_COPY_FILES += \
        $(call add-to-product-copy-files-if-exists, $(MTK_TARGET_PROJECT_FOLDER)/SmartPaVendor1_AudioParam.dat.sig:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/SmartPaVendor1_AudioParam.dat.sig:mtk)
    PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/mediatek/SmartPaVendor1_AudioParam.dat.sig:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/SmartPaVendor1_AudioParam.dat.sig:mtk
else ifeq ($(findstring smartpa, $(MTK_AUDIO_SPEAKER_PATH)),smartpa)

    PRODUCT_PACKAGES += librt_extamp_intf

    PRODUCT_COPY_FILES += \
        $(call add-to-product-copy-files-if-exists, $(MTK_TARGET_PROJECT_FOLDER)/rt_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/rt_device.xml:mtk)
    ifeq ($(MTK_AUDIO_NUMBER_OF_SPEAKER),)
        PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/richtek/rt_mono_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/rt_device.xml:mtk
    else ifeq ($(MTK_AUDIO_NUMBER_OF_SPEAKER),$(filter $(MTK_AUDIO_NUMBER_OF_SPEAKER),1))
        PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/richtek/rt_mono_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/rt_device.xml:mtk
    else ifeq ($(MTK_AUDIO_NUMBER_OF_SPEAKER),$(filter $(MTK_AUDIO_NUMBER_OF_SPEAKER),2))
        PRODUCT_COPY_FILES += \
            vendor/mediatek/proprietary/hardware/smartpa/richtek/rt_multi_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/rt_device.xml:mtk
    endif

    PRODUCT_COPY_FILES += \
        $(call add-to-product-copy-files-if-exists, $(MTK_TARGET_PROJECT_FOLDER)/rt5509_param:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/rt5509_param:mtk)
    PRODUCT_COPY_FILES += \
        device/mediatek/$(MTK_PLATFORM_DIR)/smartpa_param/rt5509_param:$(TARGET_COPY_OUT_VENDOR)/etc/smartpa_param/rt5509_param:mtk
endif

PRODUCT_COPY_FILES += $(LOCAL_PATH)/audio_em.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_em.xml:mtk

RAT_CONFIG := $(strip $(MTK_PROTOCOL1_RAT_CONFIG))
ifneq (,$(RAT_CONFIG))
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_protocol1_rat_config=$(RAT_CONFIG)
  ifneq (,$(findstring C,$(RAT_CONFIG)))
    # C2K is supported
    RAT_CONFIG_C2K_SUPPORT=yes
  endif
  ifneq (,$(findstring L,$(RAT_CONFIG)))
    # LTE is supported
    RAT_CONFIG_LTE_SUPPORT=yes
  endif
  ifneq (,$(findstring N,$(RAT_CONFIG)))
    # NR is supported
    RAT_CONFIG_NR_SUPPORT=yes
  endif
  ifneq (,$(findstring W,$(RAT_CONFIG)))
    # W is supported
    RAT_CONFIG_WCDMA_SUPPORT=yes
  endif
  ifneq (,$(findstring T,$(RAT_CONFIG)))
    # T is supported
    RAT_CONFIG_WCDMA_SUPPORT=yes
  endif
endif

ifeq ($(strip $(RAT_CONFIG_C2K_SUPPORT)),yes)
    ifeq ($(strip $(RAT_CONFIG_LTE_SUPPORT)),yes)
        ifeq ($(strip $(RAT_CONFIG_WCDMA_SUPPORT)),yes)
            ifeq ($(strip $(RAT_CONFIG_NR_SUPPORT)),yes)
                # PREF_NET_TYPE_NR_LTE_TDSCDMA_CDMA_EVDO_GSM_WCDMA (33)
                PRODUCT_PROPERTY_OVERRIDES += ro.telephony.default_network=33,33,33,33
            else
                # NETWORK_MODE_LTE_CDMA_EVDO_GSM_WCDMA (10)
                PRODUCT_PROPERTY_OVERRIDES += ro.telephony.default_network=10,10,10,10
            endif
        else
            ifeq ($(strip $(RAT_CONFIG_NR_SUPPORT)),yes)
                # PREF_NET_TYPE_NR_LTE_CDMA_EVDO (25)
                PRODUCT_PROPERTY_OVERRIDES += ro.telephony.default_network=25,25,25,25
            else
                # NETWORK_MODE_LTE_CDMA_EVDO (8)
                PRODUCT_PROPERTY_OVERRIDES += ro.telephony.default_network=8,8,8,8
            endif
        endif
    else
        # NETWORK_MODE_GLOBAL (7)
        PRODUCT_PROPERTY_OVERRIDES += ro.telephony.default_network=7,7,7,7
    endif
else
    ifeq ($(strip $(RAT_CONFIG_LTE_SUPPORT)),yes)
        ifeq ($(strip $(RAT_CONFIG_NR_SUPPORT)),yes)
            # PREF_NET_TYPE_NR_LTE_TDSCDMA_GSM_WCDMA (32)
            PRODUCT_PROPERTY_OVERRIDES += ro.telephony.default_network=32,32,32,32
        else
            # NETWORK_MODE_LTE_GSM_WCDMA (9)
            PRODUCT_PROPERTY_OVERRIDES += ro.telephony.default_network=9,9,9,9
        endif
    else
        # NETWORK_MODE_WCDMA_PREF (0)
        PRODUCT_PROPERTY_OVERRIDES += ro.telephony.default_network=0,0,0,0
    endif
endif

## For C2K CDMA feature file
ifeq ($(strip $(RAT_CONFIG_C2K_SUPPORT)),yes)
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml
endif

ifeq ($(strip $(MTK_TELEPHONY_FEATURE_SWITCH_DYNAMICALLY)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_telephony_switch=1
endif

ifeq ($(word 1,$(subst _,$(space),$(OPTR_SPEC_SEG_DEF))),OP18)
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_sos_quick_dial=1
endif


# Rat switch related properties for telephnoy

# Add for opt_md1_support
ifneq ($(strip $(MTK_MD1_SUPPORT)),)
  ifneq ($(strip $(MTK_MD1_SUPPORT)), 0)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_md1_support=$(strip $(MTK_MD1_SUPPORT))
  endif
endif

# Add for opt_md3_support
ifneq ($(strip $(MTK_MD3_SUPPORT)),)
  ifneq ($(strip $(MTK_MD3_SUPPORT)), 0)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_md3_support=$(strip $(MTK_MD3_SUPPORT))
  endif
endif

# Add for opt_c2k_lte_mode
ifeq ($(strip $(MTK_C2K_LTE_MODE)), 2)
  PRODUCT_PROPERTY_OVERRIDES +=ro.vendor.mtk_c2k_lte_mode=2
else
  ifeq ($(strip $(MTK_C2K_LTE_MODE)), 1)
    PRODUCT_PROPERTY_OVERRIDES +=ro.vendor.mtk_c2k_lte_mode=1
  else
ifeq ($(strip $(MTK_C2K_LTE_MODE)), 0)
      PRODUCT_PROPERTY_OVERRIDES +=ro.vendor.mtk_c2k_lte_mode=0
endif
  endif
endif

# Add for opt_eccci_c2k
ifeq ($(strip $(MTK_ECCCI_C2K)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_eccci_c2k=1
endif

# Add for opt_lte_support, opt_c2k_support, opt_ps1_rat
ifneq ($(strip $(MTK_PROTOCOL1_RAT_CONFIG)),)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_ps1_rat=$(strip $(MTK_PROTOCOL1_RAT_CONFIG))

  ifneq ($(findstring L,$(strip $(MTK_PROTOCOL1_RAT_CONFIG))),)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_lte_support=1
  endif

  ifneq ($(findstring C,$(strip $(MTK_PROTOCOL1_RAT_CONFIG))),)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_c2k_support=1
  endif
endif

ifeq ($(strip $(MTK_MCF_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_mcf_support=1
endif

ifeq ($(strip $(MTK_MP2_PLAYBACK_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_support_mp2_playback=1
endif

ifeq ($(strip $(MTK_AUDIO_ALAC_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_audio_alac_support=1
endif

#MTB
#PRODUCT_PACKAGES += mtk_setprop

#MMS
#ifeq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#    ifndef MTK_TB_WIFI_3G_MODE
#        PRODUCT_PACKAGES += messaging
#    else
#        ifeq ($(strip $(MTK_TB_WIFI_3G_MODE)), 3GDATA_SMS)
#            PRODUCT_PACKAGES += messaging
#        endif
#    endif
#endif
#
#ifeq ($(strip $(MTK_BSP_PACKAGE)), yes)
#    ifndef MTK_TB_WIFI_3G_MODE
#        PRODUCT_PACKAGES += messaging
#    else
#        ifeq ($(strip $(MTK_TB_WIFI_3G_MODE)), 3GDATA_SMS)
#            PRODUCT_PACKAGES += messaging
#        endif
#    endif
#endif
#
#ifdef MTK_OVERRIDES_APKS
#    ifeq ($(strip $(MTK_OVERRIDES_APKS)), yes)
#        ifndef MTK_TB_WIFI_3G_MODE
#            PRODUCT_PACKAGES += MtkMms
#            PRODUCT_PACKAGES += SoundRecorder
#            PRODUCT_PACKAGES += MtkMmsAppService
#        else
#            ifeq ($(strip $(MTK_TB_WIFI_3G_MODE)), 3GDATA_SMS)
#                PRODUCT_PACKAGES += MtkMms
#                PRODUCT_PACKAGES += SoundRecorder
#                PRODUCT_PACKAGES += MtkMmsAppService
#            endif
#        endif
#    else
#       ifeq ($(strip $(MTK_BSP_PACKAGE)), yes)
#           ifndef MTK_TB_WIFI_3G_MODE
#               PRODUCT_PACKAGES += messaging
#           else
#               ifeq ($(strip $(MTK_TB_WIFI_3G_MODE)), 3GDATA_SMS)
#                   PRODUCT_PACKAGES += messaging
#               endif
#           endif
#      endif
#    endif
#else
#    ifndef MTK_TB_WIFI_3G_MODE
#        PRODUCT_PACKAGES += MtkMms
#        PRODUCT_PACKAGES += SoundRecorder
#        PRODUCT_PACKAGES += MtkMmsAppService
#    else
#        ifeq ($(strip $(MTK_TB_WIFI_3G_MODE)), 3GDATA_SMS)
#            PRODUCT_PACKAGES += MtkMms
#            PRODUCT_PACKAGES += SoundRecorder
#            PRODUCT_PACKAGES += MtkMmsAppService
#        endif
#    endif
#endif

#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#    PRODUCT_PACKAGES += MtkBrowser
#    PRODUCT_PACKAGES += SoundRecorder
#endif

# Telephony Setting Service AOSP code will be replaced by MTK
#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/services/Telephony/Android.mk),)
#PRODUCT_PACKAGES += MtkTeleService
#endif
#endif

ifeq ($(strip $(MTK_NUM_MODEM_PROTOCOL)), 1)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.num_md_protocol=1
endif
ifeq ($(strip $(MTK_NUM_MODEM_PROTOCOL)), 2)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.num_md_protocol=2
endif
ifeq ($(strip $(MTK_NUM_MODEM_PROTOCOL)), 3)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.num_md_protocol=3
endif
ifeq ($(strip $(MTK_NUM_MODEM_PROTOCOL)), 4)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.num_md_protocol=4
endif

# Telephony begin
ifeq ($(strip $(MTK_TC1_COMMON_SERVICE)), yes)
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), ss)
        DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_tc1_ss.xml
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsds)
        DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_tc1_dsds.xml
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsda)
        DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_tc1_dsds.xml
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), tsts)
        DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_tc1_tsts.xml
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), qsqs)
        DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_tc1_qsqs.xml
    endif
else
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), ss)
        ifeq ($(strip $(MTK_OMAPI_SUPPORT)), yes)
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_ss_se$(ESE_MANIFEST).xml
        else
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_ss.xml
        endif
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsds)
        ifeq ($(strip $(MTK_OMAPI_SUPPORT)), yes)
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_dsds_se$(ESE_MANIFEST).xml
        else
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_dsds.xml
        endif
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsda)
        ifeq ($(strip $(MTK_OMAPI_SUPPORT)), yes)
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_dsds_se$(ESE_MANIFEST).xml
        else
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_dsds.xml
        endif
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), tsts)
        DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_tsts.xml
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), qsqs)
        DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_qsqs.xml
    endif
endif

# add radioconfig
DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_radioconfig.xml

#copy to telephony HIDL to /odm/etc/vintf/
ifeq ($(strip $(TARGET_COPY_OUT_ODM)),yes)
mtk_target_copy_out_odm := odm
else ifeq ($(strip $(TARGET_COPY_OUT_ODM)),no)
mtk_target_copy_out_odm := vendor/odm
else
mtk_target_copy_out_odm := $(strip $(TARGET_COPY_OUT_ODM))
endif
PRODUCT_COPY_FILES += $(LOCAL_PATH)/project_manifest/manifest_ss.xml:$(mtk_target_copy_out_odm)/etc/vintf/manifest_ss.xml:mtk
PRODUCT_COPY_FILES += $(LOCAL_PATH)/project_manifest/manifest_dsds.xml:$(mtk_target_copy_out_odm)/etc/vintf/manifest_dsds.xml:mtk
PRODUCT_COPY_FILES += $(LOCAL_PATH)/project_manifest/manifest_tsts.xml:$(mtk_target_copy_out_odm)/etc/vintf/manifest_tsts.xml:mtk
PRODUCT_COPY_FILES += $(LOCAL_PATH)/project_manifest/manifest_qsqs.xml:$(mtk_target_copy_out_odm)/etc/vintf/manifest_qsqs.xml:mtk
PRODUCT_COPY_FILES += $(LOCAL_PATH)/project_manifest/manifest_ss_se.xml:$(mtk_target_copy_out_odm)/etc/vintf/manifest_ss_se.xml:mtk
PRODUCT_COPY_FILES += $(LOCAL_PATH)/project_manifest/manifest_dsds_se.xml:$(mtk_target_copy_out_odm)/etc/vintf/manifest_dsds_se.xml:mtk
PRODUCT_COPY_FILES += $(LOCAL_PATH)/project_manifest/manifest_ss_se_ese.xml:$(mtk_target_copy_out_odm)/etc/vintf/manifest_ss_se_ese.xml:mtk
PRODUCT_COPY_FILES += $(LOCAL_PATH)/project_manifest/manifest_dsds_se_ese.xml:$(mtk_target_copy_out_odm)/etc/vintf/manifest_dsds_se_ese.xml:mtk

# callbackclient
ifeq ($(strip $(MTK_CAM_MMSDK_SUPPORT)), yes)
    ifneq ($(MTK_CAM_HAL_VERSION),)
        ifeq ($(strip $(MTK_CAM_HAL_VERSION)), 1)
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_callbackclient.xml
            PRODUCT_PACKAGES += vendor.mediatek.hardware.camera.callbackclient@1.0-impl
            PRODUCT_PACKAGES += vendor.mediatek.hardware.camera.callbackclient@1.1-impl
            PRODUCT_PROPERTY_OVERRIDES += vendor.camera.mmsdk.enable=1
        endif
    endif
endif
## Platform libs
PRODUCT_PACKAGES += libmtkcutils
PRODUCT_PACKAGES += libmtkutils
PRODUCT_PACKAGES += libmtkproperty
PRODUCT_PACKAGES += libmtkrillog
PRODUCT_PACKAGES += libmtkares
PRODUCT_PACKAGES += libmtkhardware_legacy
PRODUCT_PACKAGES += libmtksysutils
PRODUCT_PACKAGES += libmtknetutils

PRODUCT_PACKAGES += muxreport
PRODUCT_PACKAGES += mtkrild
PRODUCT_PACKAGES += mtk-ril
PRODUCT_PACKAGES += libmtkutilril
PRODUCT_PACKAGES += gsm0710muxd

ifeq ($(strip $(MTK_RIL_MODE)), c6m_1rild)
    PRODUCT_PACKAGES += libmtk-ril
    PRODUCT_PACKAGES += mtkfusionrild
    PRODUCT_PACKAGES += librilfusion
    PRODUCT_PACKAGES += libmnetlink_v104
    ifeq ($(strip $(RAT_CONFIG_C2K_SUPPORT)),yes)
        PRODUCT_PACKAGES += libvia-ril
    endif
    PRODUCT_PACKAGES += libcarrierconfig
endif

ifeq ($(strip $(MTK_CAPABILITY_CONTROL_SUPPORT)), yes)
    PRODUCT_PACKAGES += libcapctrl
endif

#PRODUCT_PACKAGES += md_minilog_util
#ifneq ($(strip $(TARGET_BUILD_VARIANT)),user)
#    PRODUCT_PACKAGES += SimRecoveryTestTool
#endif
PRODUCT_PACKAGES += libratconfig

# Remote SIM unlock
ifeq ($(strip $(SIM_ME_LOCK_MODE)), 1)
    PRODUCT_PACKAGES += libsimmelock
endif
ifeq ($(strip $(SIM_ME_LOCK_MODE)), 4)
    PRODUCT_PACKAGES += libsimlock
endif
ifeq ($(strip $(MTK_SUBSIDY_LOCK_SUPPORT)),yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_subsidy_lock_support=1
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_sim_switch_policy=2
endif
# SMB: Remote SIM unlock
ifeq ($(strip $(SIM_ME_LOCK_MODE)), 3)
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_sim_switch_policy=2
endif
# SMB: Remote SIM unlock for CXP
ifeq ($(strip $(MTK_CARRIEREXPRESS_PACK)),na)
    PRODUCT_PACKAGES += libsimmelock
    PRODUCT_PACKAGES += libsimlock
endif

ifeq ($(strip $(RAT_CONFIG_C2K_SUPPORT)),yes)
#For C2K RIL
PRODUCT_PACKAGES += \
          viarild \
          libc2kril \
          libviatelecom-withuim-ril \
          viaradiooptions \
          librpcril \
          ctclient

##Set CT6M_SUPPORT
#ifeq ($(strip $(CT6M_SUPPORT)), yes)
#PRODUCT_PACKAGES += CdmaSystemInfo
#PRODUCT_PROPERTY_OVERRIDES += ro.ct6m_support=1
#endif

##For PPPD
#PRODUCT_PACKAGES += \
#          ip-up-cdma \
#          ipv6-up-cdma \
#          link-down-cdma \
#          pppd_via

#For C2K control modules
PRODUCT_PACKAGES += \
          libc2kutils \
          flashlessd \
          statusd
endif

# MAL shared library
#PRODUCT_PACKAGES += libmdfx
#PRODUCT_PACKAGES += libmal_mdmngr
#PRODUCT_PACKAGES += libmal_nwmngr
#PRODUCT_PACKAGES += libmal_rilproxy
#PRODUCT_PACKAGES += libmal_simmngr
#PRODUCT_PACKAGES += libmal_datamngr
#PRODUCT_PACKAGES += libmal_rds
#PRODUCT_PACKAGES += libmal_epdga
#PRODUCT_PACKAGES += libmal_imsmngr
#PRODUCT_PACKAGES += libmal
#
#PRODUCT_PACKAGES += volte_imsm
#PRODUCT_PACKAGES += volte_imspa

# MAL-Dongle shared library
#PRODUCT_PACKAGES += libmd_mdmngr
#PRODUCT_PACKAGES += libmd_rilproxy
#PRODUCT_PACKAGES += libmd_simmngr
#PRODUCT_PACKAGES += libmd_datamngr
#PRODUCT_PACKAGES += libmd_nwmngr
#PRODUCT_PACKAGES += libmd

# # Volte IMS shared library
#PRODUCT_PACKAGES += volte_imspa_md

# Add for (VzW) chipset test
#ifneq ($(strip $(MTK_VZW_CHIPTEST_MODE_SUPPORT)), 0)
#PRODUCT_PACKAGES += libatch
#PRODUCT_PACKAGES += libatcputil
#PRODUCT_PACKAGES += atcp
#PRODUCT_PACKAGES += libswext_plugin
#PRODUCT_PACKAGES += libnetmngr_plugin
#
#PRODUCT_PACKAGES += liblannetmngr_core
#PRODUCT_PACKAGES += liblannetmngr_api
#PRODUCT_PACKAGES += lannetmngrd
#PRODUCT_PACKAGES += lannetmngr_test
#endif

# VoLTE Process
#ifneq ($(strip $(MTK_BUILD_IGNORE_IMS_REPO)),yes)
#    ifeq ($(strip $(MSSI_MTK_IMS_SUPPORT)),yes)
#        PRODUCT_PACKAGES += volte_xdmc
#        PRODUCT_PACKAGES += volte_core
#        PRODUCT_PACKAGES += volte_ua
#        PRODUCT_PACKAGES += volte_stack
#        PRODUCT_PACKAGES += volte_imcb
#        PRODUCT_PACKAGES += libipsec_ims_shr
#
#        # MAL Process
#        PRODUCT_PACKAGES += mtkmal
#
#        # # Volte IMS Dongle Process
#        PRODUCT_PACKAGES += volte_imsm_md
#
#    else
#        ifeq ($(strip $(MTK_EPDG_SUPPORT)),yes) # EPDG without IMS
#
#            # MAL Process
#            PRODUCT_PACKAGES += mtkmal
#
#            # # Volte IMS Dongle Process
#            #    PRODUCT_PACKAGES += volte_imsm_md
#        endif
#    endif
#endif

# VoLTE Process
ifneq ($(strip $(MTK_BUILD_IGNORE_IMS_REPO)),yes)
    ifeq ($(strip $(MTK_IMS_SUPPORT)),yes)
        PRODUCT_PACKAGES += libipsec_ims_shr
    endif
endif

## WapiCertManager
#ifeq ($(strip $(MTK_WAPI_SUPPORT)),yes)
#    PRODUCT_PACKAGES += WapiCertManager
#    PRODUCT_PACKAGES += libwapi_cert
#endif

 # include init.volte.rc
 #ifeq ($(MTK_IMS_SUPPORT),yes)
 #    ifneq ($(wildcard $(MTK_TARGET_PROJECT_FOLDER)/init.volte.rc),)
 #        PRODUCT_COPY_FILES += $(MTK_TARGET_PROJECT_FOLDER)/init.volte.rc:root/init.volte.rc
 #    else
 #        ifneq ($(wildcard $(MTK_PROJECT_FOLDER)/init.volte.rc),)
 #            PRODUCT_COPY_FILES += $(MTK_PROJECT_FOLDER)/init.volte.rc:root/init.volte.rc
 #        else
 #            PRODUCT_COPY_FILES += $(LOCAL_PATH)/init.volte.rc:root/init.volte.rc
 #        endif
 #    endif
 #endif

#include multi_init.rc in meta mode and factory mode.
PRODUCT_COPY_FILES += $(LOCAL_PATH)/multi_init.rc:$(MTK_TARGET_VENDOR_RC)/multi_init.rc

# WFCA Process
ifneq ($(strip $(MTK_BUILD_IGNORE_IMS_REPO)),yes)
    ifeq ($(strip $(MTK_WFC_SUPPORT)),yes)
      PRODUCT_PACKAGES += wfca
    endif
endif


## Hwui program binary service
#PRODUCT_PACKAGES += program_binary_service
#PRODUCT_PACKAGES += program_binary_builder
## Hwui extension
#PRODUCT_PACKAGES += libhwuiext
#

ifeq ($(strip $(MTK_PRIVACY_PROTECTION_LOCK)),yes)
#   PRODUCT_PACKAGES += PrivacyProtectionLock
    PRODUCT_PACKAGES += ppl_agent
    DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_pplagent.xml
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_privacy_protection_lock=1
endif

ifeq ($(strip $(MTK_ENGINEERMODE_APP)),yes)
DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_em.xml
PRODUCT_PACKAGES += em_hidl
endif

ifeq ($(strip $(GOOGLE_RELEASE_RIL)), yes)
    PRODUCT_PACKAGES += libril
else
    PRODUCT_PACKAGES += librilmtk
endif

#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#    PRODUCT_PACKAGES += mediatek-packages-teleservice
#    PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,vendor/mediatek/proprietary/frameworks/opt/teleservice/mediatek-packages-teleservice.xml:system/etc/permissions/mediatek-packages-teleservice.xml:mtk)
#endif
#
#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/services/Telecomm/Android.bp),)
#    PRODUCT_PACKAGES += MtkTelecom
#    PRODUCT_PACKAGES += CallRecorderService
#    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.Telecom=I
#endif
#endif
## Telephony end

# For MTK MediaProvider
# PRODUCT_PACKAGES += MtkMediaProvider

# For MTK Camera
#PRODUCT_PACKAGES += Camera
PRODUCT_PACKAGES += Panorama
PRODUCT_PACKAGES += NativePip
PRODUCT_PACKAGES += SlowMotion
PRODUCT_PACKAGES += CameraRoot
# for Advanced Camera Service
#PRODUCT_PACKAGES += mtk_advcamserver

# MediaTek Camera Hal
PRODUCT_PACKAGES += mtkcam-debug
PRODUCT_PACKAGES_DEBUG += securecamera_test
PRODUCT_PACKAGES_DEBUG += mmshal_test

# MediaTek Camera stream info plugin
PRODUCT_PACKAGES += libmtkcam_streaminfo_plugin-p1stt

# for HIDLLomoHal
PRODUCT_PACKAGES += vendor.mediatek.hardware.camera.lomoeffect@1.0-impl

# for HIDLCCAPHal
PRODUCT_PACKAGES += vendor.mediatek.hardware.camera.ccap@1.0-impl


# for HIDL BGService
ifeq ($(strip $(MTK_CAM_BGSERVICE_SUPPORT)), yes)
    DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_bgservice.xml
    PRODUCT_PACKAGES += vendor.mediatek.hardware.camera.bgservice@1.0-impl
    PRODUCT_PACKAGES += vendor.mediatek.hardware.camera.bgservice@1.1-impl
endif


PRODUCT_DEFAULT_PROPERTY_OVERRIDES += camera.disable_zsl_mode=1
PRODUCT_PROPERTY_OVERRIDES += vendor.camera.mdp.dre.enable=0
PRODUCT_PROPERTY_OVERRIDES += vendor.camera.mdp.cz.enable=0

# camera hal3 default buffer count for imgo.
# (overridable in platform-/project-level device.mk)
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.high_ram.imgo=8
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.low_ram.imgo=6
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.base.imgo=5

# camera hal3 default buffer count for rrzo.
# (overridable in platform-/project-level device.mk)
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.high_ram.rrzo=8
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.low_ram.rrzo=6
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.base.rrzo=5

# camera hal3 default buffer count for lcso.
# (overridable in platform-/project-level device.mk)
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.high_ram.lcso=8
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.low_ram.lcso=6
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.base.lcso=5

# camera hal3 default buffer count for rsso.
# (overridable in platform-/project-level device.mk)
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.high_ram.rsso=8
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.low_ram.rsso=6
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.base.rsso=5

# camera hal3 default buffer count for fd yuv.
# (overridable in platform-/project-level device.mk)
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.high_ram.fdyuv=8
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.camera3.pipeline.bufnum.min.low_ram.fdyuv=6

PRODUCT_PACKAGES += libBnMtkCodec
PRODUCT_PACKAGES += MtkCodecService
PRODUCT_PACKAGES += autokd
RODUCT_PACKAGES += \
    dhcp6c \
    dhcp6ctl \
    dhcp6c.conf \
    dhcp6cDNS.conf \
    dhcp6s \
    dhcp6s.conf \
    dhcp6c.script \
    dhcp6cctlkey \
    libifaddrs

# meta tool
include $(wildcard vendor/mediatek/proprietary/buildinfo/label.ini)
$(call inherit-product-if-exists, vendor/mediatek/proprietary/buildinfo/branch.mk)
#PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.mediatek.version.release=$(strip $(MTK_INTERNAL_BUILD_VERNO))
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mediatek.version.release=$(strip $(MTK_INTERNAL_BUILD_VERNO))

# VENDOR_SECURITY_PATCH
$(call inherit-product-if-exists, vendor/mediatek/proprietary/buildinfo/device.mk)

## To specify customer's releasekey
ifdef MTK_TARGET_PROJECT
ifneq ($(wildcard $(strip $(MTK_TARGET_PROJECT_FOLDER))/security),)
  PRODUCT_DEFAULT_DEV_CERTIFICATE := $(strip $(MTK_TARGET_PROJECT_FOLDER))/security/releasekey
else ifneq ($(wildcard device/mediatek/security),)
  PRODUCT_DEFAULT_DEV_CERTIFICATE := device/mediatek/security/releasekey
else
  ifeq ($(MTK_SIGNATURE_CUSTOMIZATION),yes)
    ifeq ($(wildcard device/mediatek/security/$(strip $(MTK_TARGET_PROJECT))),)
      $(error Please create device/mediatek/security/$(strip $(MTK_TARGET_PROJECT))/ and put your releasekey there!!)
    else
      PRODUCT_DEFAULT_DEV_CERTIFICATE := device/mediatek/security/$(strip $(MTK_TARGET_PROJECT))/releasekey
    endif
  else
#   Not specify PRODUCT_DEFAULT_DEV_CERTIFICATE and the default testkey will be used.
  endif
endif
endif

# Bluetooth Low Energy Capability
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

## Bluetooth DUN profile
#ifeq ($(MTK_BT_BLUEDROID_DUN_GW_12),yes)
#PRODUCT_PROPERTY_OVERRIDES += bt.profiles.dun.enabled=1
#PRODUCT_PACKAGES += pppd_btdun libpppbtdun.so
#endif

## Bluetooth BIP profile cover art feature
#ifeq ($(MTK_BT_BLUEDROID_AVRCP_TG_16),yes)
#  PRODUCT_PROPERTY_OVERRIDES += bt.profiles.bip.coverart.enable=1
#endif

## Bluetooth AVRCP Support Multi Player feature
#ifeq ($(MTK_BT_AVRCP_TG_MULTI_PLAYER_SUPPORT), yes)
#  PRODUCT_PROPERTY_OVERRIDES += bt.profiles.avrcp.multiPlayer.enable=1
#else
#  PRODUCT_PROPERTY_OVERRIDES += bt.profiles.avrcp.multiPlayer.enable=0
#endif

## Customer configurations
#PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,$(MTK_TARGET_PROJECT_FOLDER)/custom.conf:system/etc/custom.conf)
#PRODUCT_COPY_FILES += $(LOCAL_PATH)/custom.conf:system/etc/custom.conf

# prebuilt interface
$(call inherit-product-if-exists, vendor/mediatek/common/device-vendor.mk)

# ECC List Customization
$(call inherit-product-if-exists, vendor/mediatek/proprietary/external/EccList/EccList.mk)

## fonts
#$(call inherit-product-if-exists, frameworks/base/data/fonts/fonts.mk)
#$(call inherit-product-if-exists, external/naver-fonts/fonts.mk)
#$(call inherit-product-if-exists, external/noto-fonts/fonts.mk)
#$(call inherit-product-if-exists, external/roboto-fonts/fonts.mk)
#$(call inherit-product-if-exists, frameworks/base/data/fonts/openfont/fonts.mk)
#
## 3Dwidget
#$(call inherit-product-if-exists, vendor/mediatek/proprietary/frameworks/base/3dwidget/appwidget.mk)
#
## AAPT Config
#$(call inherit-product-if-exists, $(LOCAL_PATH)/aapt/aapt_config.mk)

#
# MediaTek Operator features configuration
#
ifdef OPTR_SPEC_SEG_DEF
  ifneq ($(strip $(OPTR_SPEC_SEG_DEF)),NONE)
    ifneq ($(wildcard vendor/mediatek/proprietary/operator/hardware/ril/fusion/Android.mk),)
        PRODUCT_PACKAGES += libmtk-rilop
        # Telephony library for op sw decouple
        ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), ss)
          DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_ss.xml
        endif
        ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsds)
          DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_dsds.xml
        endif
        ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsda)
          DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_dsds.xml
        endif
        ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), tsts)
          DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_tsts.xml
        endif
        ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), qsqs)
          DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_qsqs.xml
        endif
    endif
    #ifneq ($(wildcard vendor/mediatek/proprietary/operator/frameworks/telephony/Common/Android.bp),)
    #  PRODUCT_PACKAGES += OPCommonTelephony
    #  PRODUCT_BOOT_JARS += OPCommonTelephony
    #endif

    #ifneq ($(wildcard vendor/mediatek/proprietary/operator/packages/services/Ims/common/Android.mk),)
    #  PRODUCT_PACKAGES += mediatek-ims-wwop-common
    #  PRODUCT_PACKAGES += com.mediatek.op.ims.common.xml
    #endif
    #ifneq ($(wildcard vendor/mediatek/proprietary/operator/packages/services/Telephony/Android.mk),NONE)
    #  PRODUCT_PACKAGES += OPTeleServiceCommon
    #endif

    # To compatible with RSC deactivated project
    ifneq ($(strip $(OPTR_SPEC_SEG_DEF)),KIT)
      OPTR := $(word 1,$(subst _,$(space),$(OPTR_SPEC_SEG_DEF)))
      SPEC := $(word 2,$(subst _,$(space),$(OPTR_SPEC_SEG_DEF)))
      SEG  := $(word 3,$(subst _,$(space),$(OPTR_SPEC_SEG_DEF)))

      #$(call inherit-product-if-exists, vendor/mediatek/proprietary/operator/SPEC/$(OPTR)/$(SPEC)/$(SEG)/optr_package_config.mk)

      PRODUCT_PROPERTY_OVERRIDES += ro.vendor.operator.optr=$(OPTR)
      PRODUCT_PROPERTY_OVERRIDES += ro.vendor.operator.spec=$(SPEC)
      PRODUCT_PROPERTY_OVERRIDES += ro.vendor.operator.seg=$(SEG)
      PRODUCT_PROPERTY_OVERRIDES += persist.vendor.operator.optr=$(OPTR)
      PRODUCT_PROPERTY_OVERRIDES += persist.vendor.operator.spec=$(SPEC)
      PRODUCT_PROPERTY_OVERRIDES += persist.vendor.operator.seg=$(SEG)
    endif
  endif
endif

# Here we initializes variable MTK_REGIONAL_OP_PACK based on Carrier express pack
ifdef MTK_CARRIEREXPRESS_PACK
  ifneq ($(strip $(MTK_CARRIEREXPRESS_PACK)),no)
  ifeq ($(strip $(OPTR_SPEC_SEG_DEF)),NONE)
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), ss)
      DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_ss.xml
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsds)
      DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_dsds.xml
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsda)
      DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_dsds.xml
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), tsts)
      DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_tsts.xml
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), qsqs)
      DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_op_qsqs.xml
    endif
    #
    #ifneq ($(wildcard vendor/mediatek/proprietary/operator/frameworks/telephony/Common/Android.bp),)
    #  PRODUCT_PACKAGES += OPCommonTelephony
    #  PRODUCT_BOOT_JARS += OPCommonTelephony
    #endif
    ifneq ($(wildcard vendor/mediatek/proprietary/operator/hardware/ril/fusion/Android.mk),)
      PRODUCT_PACKAGES += libmtk-rilop
    endif
  endif

  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_carrierexpress_pack=$(strip $(MTK_CARRIEREXPRESS_PACK))
  ifeq ($(strip $(MTK_CARRIEREXPRESS_APK_INSTALL_SUPPORT)),yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_carrierexpress_inst_sup=1
  endif
  ifdef MTK_CARRIEREXPRESS_SWITCH_MODE
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_usp_switch_mode=$(strip $(MTK_CARRIEREXPRESS_SWITCH_MODE))
  endif

  endif #ifneq ($(strip $(MTK_CARRIEREXPRESS_PACK)),no)
endif #ifdef MTK_CARRIEREXPRESS_PACK

#PRODUCT_PACKAGES += DataTransfer

## MediatekDM package & lib
#ifeq ($(strip $(MTK_MDM_APP)),yes)
#    PRODUCT_PACKAGES += MediatekDM
#endif

## CTM
#ifeq ($(strip $(MTK_CTM_SUPPORT)),yes)
#PRODUCT_PACKAGES += ctm
#endif

## SmsReg package
#ifeq ($(strip $(MTK_SMSREG_APP)),yes)
#    PRODUCT_PACKAGES += SmsReg
#endif

$(call inherit-product-if-exists, vendor/mediatek/proprietary/external/voiceunlock2/voicecommand.mk)

#ifneq ($(filter yes,$(MTK_VOICE_UNLOCK_SUPPORT) $(MTK_VOICE_UI_SUPPORT) $(MTK_VOW_SUPPORT)),)
#    PRODUCT_PACKAGES += VoiceCommand
#endif
#
#ifeq ($(strip $(MTK_VOICE_UNLOCK_SUPPORT)),yes)
#    PRODUCT_PACKAGES += VoiceUnlock
#else
#    ifeq ($(strip $(MTK_VOW_SUPPORT)),yes)
#        PRODUCT_PACKAGES += VoiceUnlock
#        PRODUCT_PACKAGES += MtkVoiceWakeupInteraction
#    endif
#endif
#
#ifeq ($(strip $(RAT_CONFIG_C2K_SUPPORT)),yes)
#    PRODUCT_PACKAGES += via-plugin
#endif

ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), ss)
  PRODUCT_PROPERTY_OVERRIDES += persist.radio.multisim.config=ss
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.msimmode=ss
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.radio.max.multisim=ss
  PRODUCT_PROPERTY_OVERRIDES += ro.telephony.sim.count=1
endif
ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsds)
  PRODUCT_PROPERTY_OVERRIDES += persist.radio.multisim.config=dsds
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.msimmode=dsds
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.radio.max.multisim=dsds
  PRODUCT_PROPERTY_OVERRIDES += ro.telephony.sim.count=2
endif
ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsda)
  PRODUCT_PROPERTY_OVERRIDES += persist.radio.multisim.config=dsda
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.msimmode=dsda
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.radio.max.multisim=dsda
  PRODUCT_PROPERTY_OVERRIDES += ro.telephony.sim.count=2
endif
ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), tsts)
  PRODUCT_PROPERTY_OVERRIDES += persist.radio.multisim.config=tsts
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.msimmode=tsts
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.radio.max.multisim=tsts
  PRODUCT_PROPERTY_OVERRIDES += ro.telephony.sim.count=3
endif
ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), qsqs)
  PRODUCT_PROPERTY_OVERRIDES += persist.radio.multisim.config=qsqs
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.msimmode=qsqs
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.radio.max.multisim=qsqs
  PRODUCT_PROPERTY_OVERRIDES += ro.telephony.sim.count=4
endif

ifeq ($(strip $(MTK_AUDIO_PROFILES)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_audio_profiles=1
endif

ifeq ($(strip $(MTK_AUDENH_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_audenh_support=1
endif

# MTK_LOSSLESS_BT
ifeq ($(strip $(MTK_LOSSLESS_BT_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_lossless_bt_audio=1
endif

# MTK_LOUNDNESS
ifeq ($(strip $(MTK_BESLOUDNESS_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_besloudness_support=1
endif

# MTK_HIFIAUDIO_SUPPORT
ifeq ($(strip $(MTK_HIFIAUDIO_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_hifiaudio_support=1
endif

# MTK_BESSURROUND
ifeq ($(strip $(MTK_BESSURROUND_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_bessurround_support=1
endif

# MTK_ANC
ifeq ($(strip $(MTK_HEADSET_ACTIVE_NOISE_CANCELLATION)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_active_noise_cancel=1
endif

#ifeq ($(strip $(MTK_MEMORY_COMPRESSION_SUPPORT)), yes)
#  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_mem_comp_support=1
#endif

ifeq ($(strip $(MTK_WAPI_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_wapi_support=1
  PRODUCT_PACKAGES += libwapi
endif

ifeq ($(strip $(MTK_WAPPUSH_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_wappush_support=1
endif

ifeq ($(strip $(MTK_AGPS_APP)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_agps_app=1
endif

ifeq ($(strip $(MTK_FM_TX_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_fm_tx_support=1
endif

ifeq ($(strip $(MTK_VOICE_UI_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_voice_ui_support=1
endif

ifneq ($(MTK_AUDIO_TUNING_TOOL_VERSION),)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_audio_tuning_tool_ver=$(strip $(MTK_AUDIO_TUNING_TOOL_VERSION))
else
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_audio_tuning_tool_ver=V1
endif

#ifeq ($(strip $(MTK_DM_APP)), yes)
#  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_dm_app=1
#endif

ifeq ($(strip $(MTK_MATV_ANALOG_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_matv_analog_support=1
endif

ifeq ($(strip $(MTK_WLAN_SUPPORT)), yes)
  #PRODUCT_PACKAGES += halutil
  #PRODUCT_PACKAGES += wificond
  PRODUCT_PACKAGES += libwpa_client

  PRODUCT_PACKAGES += android.hardware.wifi@1.0-service-lazy-mediatek
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.wifi.sap.interface=ap0
else
  PRODUCT_PACKAGES += android.hardware.wifi@1.0-service
endif
ifneq ($(PLATFORM_VERSION),R)
DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_wifi.xml
else
DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_wifi_r.xml
endif

ifeq ($(strip $(MTK_GPS_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_gps_support=1
else
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_gps_support=0
endif

ifeq ($(strip $(HAVE_MATV_FEATURE)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.have_matv_feature=1
endif

ifeq ($(strip $(MTK_BT_FM_OVER_BT_VIA_CONTROLLER)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_bt_fm_over_bt=1
endif

#ifeq ($(strip $(MTK_DHCPV6C_WIFI)), yes)
#  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_dhcpv6c_wifi=1
#endif

ifeq ($(strip $(MTK_FM_SHORT_ANTENNA_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_fm_short_antenna_support=1
endif

ifeq ($(strip $(HAVE_AACENCODE_FEATURE)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.have_aacencode_feature=1
endif

#ifeq ($(strip $(MTK_CLEARMOTION_SUPPORT)),yes)
#  PRODUCT_PACKAGES += libMJCjni
#  PRODUCT_PROPERTY_OVERRIDES += \
#    persist.sys.display.clearMotion=0
#  PRODUCT_PROPERTY_OVERRIDES += \
#    persist.clearMotion.fblevel.nrm=255
#  PRODUCT_PROPERTY_OVERRIDES += \
#    persist.clearMotion.fblevel.bdr=255
#endif

ifeq ($(strip $(MTK_PHONE_VT_VOICE_ANSWER)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_phone_vt_voice_answer=1
endif

ifeq ($(strip $(MTK_PHONE_VOICE_RECORDING)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_phone_voice_recording=1
endif

ifeq ($(strip $(MTK_POWER_SAVING_SWITCH_UI_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_pwr_save_switch=1
endif

ifeq ($(strip $(MTK_FD_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_fd_support=1
endif

#DRM part
#OMA DRM
#ifeq ($(strip $(MTK_OMADRM_SUPPORT)), yes)
#    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_oma_drm_support=1
#endif

#AOSP OMA DRM implementation
#PRODUCT_PACKAGES += libfwdlockengine
PRODUCT_PROPERTY_OVERRIDES += drm.service.enabled=true
#PRODUCT_PACKAGES += libdcfdecoderjni
#PRODUCT_PACKAGES += libdrmmtkutil

#Widevine DRM
ifeq ($(strip $(MTK_WVDRM_SUPPORT)), yes)
  ifeq ($(strip $(MTK_WVDRM_L1_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_widevine_drm_l1_support=1
  else
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_widevine_drm_l3_support=1
  endif
endif

#Playready DRM
ifeq ($(strip $(MTK_PLAYREADY_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_playready_drm_support=1
endif

########
ifeq ($(strip $(MTK_DISABLE_CAPABILITY_SWITCH)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_disable_cap_switch=1
endif

ifeq ($(strip $(MTK_LOG2SERVER_APP)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_log2server_app=1
endif

ifeq ($(strip $(MTK_FM_RECORDING_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_fm_recording_support=1
endif

ifeq ($(strip $(MTK_AUDIO_APE_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_audio_ape_support=1
endif

ifeq ($(strip $(MTK_FD_FORCE_REL_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_fd_force_rel_support=1
endif

ifeq ($(strip $(MTK_BRAZIL_CUSTOMIZATION_CLARO)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.brazil_cust_claro=1
endif

ifeq ($(strip $(MTK_BRAZIL_CUSTOMIZATION_VIVO)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.brazil_cust_vivo=1
endif

ifeq ($(strip $(MTK_MTKPS_PLAYBACK_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_mtkps_playback_support=1
endif

ifeq ($(strip $(MTK_RAT_WCDMA_PREFERRED)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_rat_wcdma_preferred=1
endif

ifeq ($(strip $(MTK_SMSREG_APP)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_smsreg_app=1
endif

ifeq ($(strip $(MTK_TB_APP_CALL_FORCE_SPEAKER_ON)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_tb_call_speaker_on=1
endif

ifeq ($(strip $(MTK_EMMC_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_emmc_support=1
endif

ifeq ($(strip $(MTK_UFS_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_ufs_support=1
endif

ifeq ($(strip $(MTK_FM_50KHZ_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_fm_50khz_support=1
endif

ifeq ($(strip $(MTK_DEFAULT_WRITE_DISK)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_default_write_disk=1
endif

ifeq ($(strip $(MTK_TETHERINGIPV6_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_tetheringipv6_support=1
endif

ifeq ($(strip $(MTK_PHONE_NUMBER_GEODESCRIPTION)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_phone_number_geo=1
endif

ifeq ($(strip $(RAT_CONFIG_C2K_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_c2k_support=1
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.flashless.fsm=0
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.flashless.fsm_cst=0
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.flashless.fsm_rw=0

  # network property
   ifeq ($(strip $(RAT_CONFIG_LTE_SUPPORT)),yes)
      PRODUCT_PROPERTY_OVERRIDES += telephony.lteOnCdmaDevice=1
   endif
endif

ifeq ($(strip $(EVDO_DT_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.evdo_dt_support=1
endif

ifeq ($(strip $(EVDO_DT_VIA_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.evdo_dt_via_support=1
endif

PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_ril_mode=$(strip $(MTK_RIL_MODE))
ifneq ($(strip $(MTK_RIL_MODE)), c6m_1rild)
    PRODUCT_PACKAGES += rilproxy
    PRODUCT_PACKAGES += mtk-rilproxy
    PRODUCT_PACKAGES += lib-rilproxy
endif

PRODUCT_PROPERTY_OVERRIDES += ro.vendor.md_prop_ver=1

ifeq ($(strip $(MTK_RAT_BALANCING)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_rat_balancing=1
endif

ifeq ($(strip $(WIFI_WEP_KEY_ID_SET)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.wifi_wep_key_id_set=1
endif

ifeq ($(strip $(MTK_ENABLE_MD1)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_enable_md1=1
endif

ifeq ($(strip $(MTK_ENABLE_MD2)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_enable_md2=1
endif

ifeq ($(strip $(MTK_ENABLE_MD3)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_enable_md3=1
endif

#For SOTER
ifeq ($(strip $(MTK_SOTER_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.mtk_soter_support=1
endif

ifeq ($(strip $(MTK_NFC_ADDON_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_nfc_addon_support=1
endif

ifeq ($(strip $(MTK_BENCHMARK_BOOST_TP)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_benchmark_boost_tp=1
endif

ifeq ($(strip $(MTK_FLIGHT_MODE_POWER_OFF_MD)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_flight_mode_power_off_md=1
endif

#ifeq ($(strip $(MTK_BT_BLE_MANAGER_SUPPORT)), yes)
#  PRODUCT_PACKAGES += BluetoothLe \
#                      BLEManager
#endif

#For GattProfile
#PRODUCT_PACKAGES += GattProfile

#For BtAutoTest
#PRODUCT_PACKAGES += BtAutoTest

ifeq ($(strip $(MTK_AAL_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_aal_support=1
  PRODUCT_PACKAGES += libaal_key
endif

ifeq ($(strip $(MTK_ULTRA_DIMMING_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_ultra_dimming_support=1
endif

ifeq ($(strip $(MTK_DRE30_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_dre30_support=1
endif

ifeq ($(strip $(MTK_DRE30_SUPPORT)), yes)
  PRODUCT_PACKAGES += libdre
endif

ifneq ($(strip $(MTK_PQ_SUPPORT)), no)
    ifeq ($(strip $(MTK_PQ_SUPPORT)), PQ_OFF)
        PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_pq_support=0
    else
        ifeq ($(strip $(MTK_PQ_SUPPORT)), PQ_HW_VER_2)
            PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_pq_support=2
        else
            ifeq ($(strip $(MTK_PQ_SUPPORT)), PQ_HW_VER_3)
                PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_pq_support=3
            else
                PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_pq_support=0
            endif
        endif
    endif
endif

# pq color mode, default mode is 1 (DISP)
ifeq ($(strip $(MTK_PQ_COLOR_MODE)), OFF)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_pq_color_mode=0
else
  ifeq ($(strip $(MTK_PQ_COLOR_MODE)), MDP)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_pq_color_mode=2
  else
    ifeq ($(strip $(MTK_PQ_COLOR_MODE)), DISP_MDP)
        PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_pq_color_mode=3
    else
        PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_pq_color_mode=1
    endif
  endif
endif

ifeq ($(strip $(MTK_MIRAVISION_SETTING_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_miravision_support=1
endif

ifeq ($(strip $(MTK_MIRAVISION_IMAGE_DC_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_miravision_image_dc=1
endif

ifeq ($(strip $(MTK_BLULIGHT_DEFENDER_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_blulight_def_support=1
  PRODUCT_PACKAGES += libblulight_defender
endif

ifeq ($(strip $(MTK_CHAMELEON_DISPLAY_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_chameleon_support=1
endif

ifeq ($(strip $(MTK_TETHERING_EEM_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_tethering_eem_support=1
endif

ifeq ($(strip $(MTK_WFD_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_wfd_support=1
endif

ifeq ($(strip $(MTK_WFD_SINK_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_wfd_sink_support=1
endif

ifeq ($(strip $(MTK_WFD_SINK_UIBC_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_wfd_sink_uibc_support=1
endif

ifeq ($(strip $(MTK_CROSSMOUNT_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_crossmount_support=1
endif

ifeq ($(strip $(MTK_MULTIPLE_TDLS_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_multiple_tdls_support=1
endif

ifeq ($(strip $(MTK_IPV6_TETHER_PD_MODE)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_ipv6_tether_pd_mode=1
endif

ifeq ($(strip $(MTK_GMO_ROM_OPTIMIZE)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.gmo.rom_optimize=1
  ifeq ($(TARGET_BUILD_VARIANT), eng)
    PRODUCT_PROPERTY_OVERRIDES += ro.lmk.debug=true
  endif
endif

ifeq ($(strip $(MTK_MDM_APP)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_mdm_app=1
endif

ifeq ($(strip $(MTK_MDM_LAWMO)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_mdm_lawmo=1
endif

ifeq ($(strip $(MTK_MDM_FUMO)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_mdm_fumo=1
endif

ifeq ($(strip $(MTK_MDM_SCOMO)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_mdm_scomo=1
endif

ifeq ($(strip $(MTK_MULTISIM_RINGTONE_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_multisim_ringtone=1
endif

ifeq ($(strip $(MTK_MT8193_HDCP_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_mt8193_hdcp_support=1
endif

ifeq ($(strip $(PURE_AP_USE_EXTERNAL_MODEM)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.pure_ap_use_external_modem=1
endif

ifeq ($(strip $(MTK_WFD_HDCP_TX_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_wfd_hdcp_tx_support=1
endif

ifeq ($(strip $(MTK_WFD_HDCP_RX_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_wfd_hdcp_rx_support=1
endif

ifeq ($(strip $(MTK_WORLD_PHONE_POLICY)), 1)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_world_phone_policy=1
else
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_world_phone_policy=0
endif

ifeq ($(strip $(MTK_ECCCI_C2K)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_md_world_mode_support=1
endif

ifeq ($(strip $(MTK_AUDIO_CHANGE_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_audio_change_support=1
endif

ifeq ($(strip $(MTK_SIM_HOT_SWAP_COMMON_SLOT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_sim_hot_swap_common_slot=1
endif

ifneq ($(strip $(MTK_SIM_CARD_ONOFF)), 1)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_sim_card_onoff=$(strip $(MTK_SIM_CARD_ONOFF))
endif

ifeq ($(strip $(EVDO_IR_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.evdo_ir_support=1
endif

ifeq ($(strip $(MTK_MULTI_PARTITION_MOUNT_ONLY_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_multi_patition=1
endif

ifeq ($(strip $(MTK_WIFI_CALLING_RIL_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_wifi_calling_ril_support=1
endif

ifeq ($(strip $(MTK_DRM_KEY_MNG_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_key_manager_support=1
endif

ifeq ($(strip $(MTK_MOBILE_MANAGEMENT)), yes)
  ifneq ($(strip $(BUILD_GMS)), yes)
    ifneq ($(strip $(MTK_GMO_ROM_OPTIMIZE)), yes)
      PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_mobile_management=1
    endif
  endif
endif

ifeq ($(strip $(MTK_RUNTIME_PERMISSION_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_runtime_permission=1
endif

# enable zsd+hdr
ifeq ($(strip $(MTK_CAM_ZSDHDR_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_zsdhdr_support=1
endif

ifeq ($(strip $(MTK_CAM_DUAL_ZOOM_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_cam_dualzoom_support=1
endif

ifeq ($(strip $(MTK_CAM_STEREO_DENOISE_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_cam_dualdenoise_support=1
endif

ifeq ($(strip $(MTK_CLEARMOTION_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_clearmotion_support=1
endif

ifeq ($(strip $(MTK_DISPLAY_120HZ_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_display_120hz_support=1
endif

ifeq ($(strip $(MTK_SLOW_MOTION_VIDEO_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_slow_motion_support=1
endif

ifeq ($(strip $(MTK_CAM_NATIVE_PIP_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_cam_native_pip_support=1
endif

ifeq ($(strip $(MTK_CAM_LOMO_SUPPORT)), yes)
  PRODUCT_PACKAGES += libcam.jni.lomohaljni
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_cam_lomo_support=1
endif

ifeq ($(strip $(MTK_CAM_IMAGE_REFOCUS_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_cam_img_refocus_support=1
endif

ifeq ($(strip $(MTK_CAM_STEREO_CAMERA_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_cam_stereo_camera_support=1
endif

ifeq ($(strip $(MTK_LTE_DC_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_lte_dc_support=1
endif

ifeq ($(strip $(MTK_ENABLE_MD5)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_enable_md5=1
endif

ifeq ($(strip $(MTK_FEMTO_CELL_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_femto_cell_support=1
endif

ifeq ($(strip $(MTK_SAFEMEDIA_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_safemedia_support=1
endif

ifeq ($(strip $(MTK_UMTS_TDD128_MODE)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_umts_tdd128_mode=1
endif

ifeq ($(strip $(MTK_SINGLE_IMEI)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_single_imei=1
endif

ifeq ($(strip $(MTK_SINGLE_3DSHOT_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_cam_single_3Dshot_support=1
endif

ifeq ($(strip $(MTK_CAM_MAV_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_cam_mav_support=1
endif

ifeq ($(strip $(MTK_CAM_FACEBEAUTY_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_cam_cfb=1
endif

ifeq ($(strip $(MTK_CAM_VIDEO_FACEBEAUTY_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_cam_vfb=1
endif

ifeq ($(strip $(MTK_RILD_READ_IMSI)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_rild_read_imsi=1
endif

ifeq ($(strip $(SIM_REFRESH_RESET_BY_MODEM)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.sim_refresh_reset_by_modem=1
endif

ifeq ($(strip $(MTK_EXTERNAL_SIM_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_external_sim_support=1
endif

ifeq ($(strip $(MTK_DISABLE_PERSIST_VSIM)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_persist_vsim_disabled=1
endif

ifneq ($(strip $(MTK_EXTERNAL_SIM_ONLY_SLOTS)),)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_external_sim_only_slots=$(strip $(MTK_EXTERNAL_SIM_ONLY_SLOTS))
else
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_external_sim_only_slots=0
endif

ifeq ($(strip $(MTK_EXTERNAL_SIM_RSIM_ENHANCEMENT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_non_dsda_rsim_support=1
endif

#ifeq ($(strip $(MTK_SUBTITLE_SUPPORT)), yes)
#  PRODUCT_PACKAGES += libvobsub_jni
#  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_subtitle_support=1
#endif

ifeq ($(strip $(MTK_DFO_RESOLUTION_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_dfo_resolution_support=1
endif

ifeq ($(strip $(MTK_SMARTBOOK_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_smartbook_support=1
endif

#ifeq ($(strip $(MTK_DX_HDCP_SUPPORT)), yes)
#  PRODUCT_PACKAGES += ffffffff000000000000000000000003.tlbin libDxHdcp DxHDCP.cfg
#  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_dx_hdcp_support=1
#endif

ifeq ($(strip $(MTK_LIVE_PHOTO_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_live_photo_support=1
endif

ifeq ($(strip $(MTK_MOTION_TRACK_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_motion_track_support=1
endif

ifeq ($(strip $(MTK_PASSPOINT_R2_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_passpoint_r2_support=1
endif

ifeq ($(strip $(MTK_WIFIWPSP2P_NFC_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_wifiwpsp2p_nfc_support=1
endif

ifeq ($(strip $(MTK_TC1_FEATURE)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_tc1_feature=1
endif

ifneq ($(strip $(SIM_ME_LOCK_MODE)),)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.sim_me_lock_mode=$(strip $(SIM_ME_LOCK_MODE))
else
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.sim_me_lock_mode=0
endif

ifneq ($(strip $(MTK_AP_INFO_COLLECT)),)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.ap_info_monitor=$(strip $(MTK_AP_INFO_COLLECT))
else
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.ap_info_monitor=0
endif

ifeq ($(strip $(MTK_EXTERNAL_MODEM_SLOT)), 1)
endif
ifeq ($(strip $(MTK_EXTERNAL_MODEM_SLOT)), 2)
endif

# default IME
ifeq (OP01,$(word 1,$(subst _, ,$(OPTR_SPEC_SEG_DEF))))
    PRODUCT_PROPERTY_OVERRIDES += ro.mtk_default_ime =com.iflytek.inputmethod.FlyIME
endif

# Data usage overview
ifeq ($(strip $(MTK_DATAUSAGE_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_datausage_support=1
endif

## VzW Device Type
#ifeq ($(strip $(MTK_VZW_DEVICE_TYPE)), 0)
#  PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.vendor.vzw_device_type=0
#endif
#ifeq ($(strip $(MTK_VZW_DEVICE_TYPE)), 1)
#  PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.vendor.vzw_device_type=1
#endif
#ifeq ($(strip $(MTK_VZW_DEVICE_TYPE)), 2)
#  PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.vendor.vzw_device_type=2
#endif
#ifeq ($(strip $(MTK_VZW_DEVICE_TYPE)), 3)
#  PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.vendor.vzw_device_type=3
#endif
#ifeq ($(strip $(MTK_VZW_DEVICE_TYPE)), 4)
#  PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.vendor.vzw_device_type=4
#endif

# wifi offload service common library
ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
    #PRODUCT_PACKAGES += wfo-common
    ifeq ($(strip $(MTK_WFC_SUPPORT)), yes)
        # PRODUCT_PACKAGES += WfoService
        #Define 93 MD and fusion ril
        ifneq ($(strip $(MTK_RIL_MODE)), c6m_1rild)
            PRODUCT_PACKAGES += vendor.mediatek.hardware.wfo@1.0-service
            #PRODUCT_PACKAGES += mediatek-wfo-legacy
            #PRODUCT_PACKAGES += com.mediatek.wfo.legacy.xml
        endif
    endif
endif

#Define MD has the capability to setup IMS PDN
ifeq ($(strip $(MTK_RIL_MODE)), c6m_1rild)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.md_auto_setup_ims=1
endif

# IMS and VoLTE feature
ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
    ifneq ($(wildcard vendor/mediatek/proprietary/frameworks/opt/net/ims/Android.bp),)
        #PRODUCT_PACKAGES += mediatek-ims-common
        #PRODUCT_BOOT_JARS += mediatek-ims-common
    endif
endif
ifeq ($(strip $(MTK_IMS_SUPPORT)), yes)
    ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
        #PRODUCT_PACKAGES += ImsService
        #PRODUCT_PACKAGES += mediatek-ims-oem-plugin
        #ifeq ($(strip $(MTK_TELEPHONY_ADD_ON_POLICY)), 0)
            #PRODUCT_PACKAGES += Gba
            #PRODUCT_PACKAGES += mediatek-ims-extension-plugin
            #PRODUCT_PACKAGES += mediatek-ims-legacy
        #endif
        ifneq ($(strip $(MTK_RIL_MODE)), c6m_1rild)
            PRODUCT_PACKAGES += vendor.mediatek.hardware.imsa@1.0-service
        endif
    endif
  # Put IMS permission for the device
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.ims_support=1
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_dynamic_ims_switch=1
  ifneq ($(filter $(strip $(MTK_MULTIPLE_IMS_SUPPORT)),2 3 4),)
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mims_support=$(strip $(MTK_MULTIPLE_IMS_SUPPORT))
  else
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mims_support=1
  endif
endif

#WFC feature
ifeq ($(strip $(MTK_WFC_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_wfc_support=1
  PRODUCT_PACKAGES += ipsec_mon
endif

ifeq ($(strip $(MTK_VOLTE_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.volte_support=1
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk.volte.enable=1
endif

build_vilte_package :=
ifeq ($(strip $(MTK_VILTE_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.vilte_support=1
  build_vilte_package := yes
else
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.vilte_support=0
endif

ifeq ($(strip $(MTK_VIWIFI_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.viwifi_support=1
  build_vilte_package := yes
else
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.viwifi_support=0
endif

ifdef build_vilte_package
  #PRODUCT_PACKAGES += libmtk_vt_wrapper
  #PRODUCT_PACKAGES += libmtk_vt_service
  PRODUCT_PACKAGES += vendor.mediatek.hardware.videotelephony@1.0-impl
  #PRODUCT_PACKAGES += vtservice
  PRODUCT_PACKAGES += vtservice_hidl
  DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_videotelephony.xml
endif

ifeq ($(strip $(MTK_DIGITS_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_digits_support=1
endif

# DTAG DUAL APN
ifeq ($(strip $(MTK_DTAG_DUAL_APN_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_dtag_dual_apn_support=1
endif

# Telstra PDP retry
ifeq ($(strip $(MTK_TELSTRA_PDP_RETRY_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_fallback_retry_support=1
endif

## RTT support
#ifeq ($(strip $(MTK_RTT_SUPPORT)),yes)
#  PRODUCT_SYSTEM_DEFAULT_PROPERTIES +=  persist.vendor.mtk_rtt_support=1
#endif

## sbc security
#ifeq ($(strip $(MTK_SECURITY_SW_SUPPORT)), yes)
#  PRODUCT_PACKAGES += libsec
#  PRODUCT_PACKAGES += sbchk
#  PRODUCT_PACKAGES += S_ANDRO_SFL.ini
#  PRODUCT_PACKAGES += S_SECRO_SFL.ini
#  PRODUCT_PACKAGES += sec_chk.sh
#  PRODUCT_PACKAGES += AC_REGION
#endif

ifneq ($(wildcard $(LOCAL_PATH)/audio_effects_config/audio_effects.xml),)
  PRODUCT_COPY_FILES += $(LOCAL_PATH)/audio_effects_config/audio_effects.xml:vendor/etc/audio_effects.xml
else
  PRODUCT_COPY_FILES += frameworks/av/media/libeffects/data/audio_effects.xml:vendor/etc/audio_effects.xml
endif

#PRODUCT_PACKAGES += NwMonitor

## ST NFC
ifeq ($(strip $(NFC_CHIP_SUPPORT)), yes)
  # Set SIM terminal capability TAG 82 to UICC-CLF
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_uicc_clf=1

  ifneq ($(wildcard $(MTK_TARGET_PROJECT_FOLDER)/script_DB10mtk*),)
    NFC_RF_CONFIG_PATH := $(MTK_TARGET_PROJECT_FOLDER)
  else
    NFC_RF_CONFIG_PATH := device/mediatek/$(MTK_PLATFORM_DIR)
  endif
  include vendor/mediatek/proprietary/external/stnfctools-vendor/NfcDeviceConfigVendor.mk
  ifneq ($(strip $(ST_NFC_CHIP_VERSION)), ST21NFCD)
    ESE_MANIFEST:=_ese
  else
    ESE_MANIFEST:=
  endif
endif

ifeq ($(strip $(MTK_OMAPI_SUPPORT)), yes)
    # Manifest of SIM1/SIM2 merged into manifest_xx.xml to support dynamic except for TC1
    ifeq ($(strip $(MSSI_MTK_TC1_COMMON_SERVICE)), yes)
        ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), ss)
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_secure_element_ss$(ESE_MANIFEST).xml
        endif
        ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsds)
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_secure_element_dsds$(ESE_MANIFEST).xml
        endif
        ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), dsda)
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_secure_element_dsds$(ESE_MANIFEST).xml
        endif
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), tsts)
        ifeq ($(strip $(MTK_EXTERNAL_SIM_RSIM_ENHANCEMENT)), yes)
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_secure_element_dsds$(ESE_MANIFEST).xml
        else
            DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_secure_element_tsts$(ESE_MANIFEST).xml
        endif
    endif
    ifeq ($(strip $(MTK_MULTI_SIM_SUPPORT)), qsqs)
        DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_secure_element_qsqs$(ESE_MANIFEST).xml
    endif

    PRODUCT_PACKAGES += android.hardware.secure_element@1.0-service-mediatek
endif

# IRTX HAL CORE
ifeq (yes,$(strip $(MTK_IRTX_SUPPORT)))
    DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_ir.xml
    PRODUCT_PACKAGES += android.hardware.ir@1.0-service
    PRODUCT_PACKAGES += android.hardware.ir@1.0-impl
else
ifeq (yes,$(strip $(MTK_IRTX_PWM_SUPPORT)))
    DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_ir.xml
    PRODUCT_PACKAGES += android.hardware.ir@1.0-service
    PRODUCT_PACKAGES += android.hardware.ir@1.0-impl
endif
endif

#ifeq ($(strip $(MTK_CROSSMOUNT_SUPPORT)),yes)
#  PRODUCT_PACKAGES += com.mediatek.crossmount.discovery
#  PRODUCT_PACKAGES += com.mediatek.crossmount.discovery.xml
#  PRODUCT_PACKAGES += CrossMount
#  PRODUCT_PACKAGES += com.mediatek.crossmount.adapter
#  PRODUCT_PACKAGES += com.mediatek.crossmount.adapter.xml
#  PRODUCT_PACKAGES += CrossMountSettings
#  PRODUCT_PACKAGES += CrossMountSourceCamera
#  PRODUCT_PACKAGES += CrossMountStereoSound
#  PRODUCT_PACKAGES += libcrossmount
#  PRODUCT_PACKAGES += libcrossmount_jni
#  PRODUCT_PACKAGES += sensors.virtual
#  PRODUCT_PACKAGES += SWMountViewer
#endif

#$(call inherit-product-if-exists, frameworks/base/data/videos/FrameworkResource.mk)
#ifeq ($(strip $(MTK_LIVE_PHOTO_SUPPORT)), yes)
#  PRODUCT_PACKAGES += com.mediatek.effect
#  PRODUCT_PACKAGES += com.mediatek.effect.xml
#endif

#ifeq ($(strip $(MTK_MULTICORE_OBSERVER_APP)), yes)
#  PRODUCT_PACKAGES += MultiCoreObserver
#endif

## for Search, ApplicationsProvider provides apps search
#PRODUCT_PACKAGES += ApplicationsProvider

#ifneq ($(strip $(MTK_PLATFORM)),)
#  PRODUCT_PACKAGES += libnativecheck-jni
#endif


# for mediatek-res
#PRODUCT_PACKAGES += mediatek-res

# for TER service
#PRODUCT_PACKAGES += terservice
#PRODUCT_PACKAGES_ENG += tertestclient
ifeq ($(strip $(MTK_TER_SERVICE)),yes)
  PRODUCT_PROPERTY_OVERRIDES += vendor.ter.service.enable=1
endif

## for IoctlFuzzer (MediaTek internal-use)
#PRODUCT_PACKAGES_ENG += ioctl_fuzzer

PRODUCT_PROPERTY_OVERRIDES += ro.vendor.wfd.dummy.enable=1
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.wfd.iframesize.level=0

ifeq ($(strip $(EVDO_IR_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += \
    vendor.ril.evdo.irsupport=1
endif

ifeq ($(strip $(EVDO_DT_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += \
    ril.evdo.dtsupport=1
endif

# for libudf
ifeq ($(strip $(MTK_USER_SPACE_DEBUG_FW)),yes)
#PRODUCT_PACKAGES += libudf
PRODUCT_PACKAGES += libudf.vendor
PRODUCT_PACKAGES_ENG += mtm_test
endif

PRODUCT_COPY_FILES += $(MTK_TARGET_PROJECT_FOLDER)/ProjectConfig.mk:$(TARGET_COPY_OUT_VENDOR)/data/misc/ProjectConfig.mk:mtk

ifeq ($(strip $(MTK_BICR_SUPPORT)), yes)
PRODUCT_COPY_FILES += $(LOCAL_PATH)/iAmCdRom.iso:$(TARGET_COPY_OUT_VENDOR)/etc/iAmCdRom.iso:mtk
endif

ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
  PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,device/mediatek/vendor/common/telephony/etc/smsdbvisitor.xml:$(TARGET_COPY_OUT_VENDOR)/etc/smsdbvisitor.xml:mtk)
  PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,device/mediatek/vendor/common/telephony/etc/special_pws_channel.xml:$(TARGET_COPY_OUT_VENDOR)/etc/special_pws_channel.xml:mtk)
  PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,device/mediatek/vendor/common/telephony/etc/virtual-spn-conf-by-efgid1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/virtual-spn-conf-by-efgid1.xml:mtk)
  PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,device/mediatek/vendor/common/telephony/etc/virtual-spn-conf-by-efpnn.xml:$(TARGET_COPY_OUT_VENDOR)/etc/virtual-spn-conf-by-efpnn.xml:mtk)
  PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,device/mediatek/vendor/common/telephony/etc/virtual-spn-conf-by-efspn.xml:$(TARGET_COPY_OUT_VENDOR)/etc/virtual-spn-conf-by-efspn.xml:mtk)
  PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,device/mediatek/vendor/common/telephony/etc/virtual-spn-conf-by-imsi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/virtual-spn-conf-by-imsi.xml:mtk)
  PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,device/mediatek/vendor/common/telephony/etc/spn-conf-op09.xml:$(TARGET_COPY_OUT_VENDOR)/etc/spn-conf-op09.xml:mtk)
endif

ifeq ($(strip $(MTK_AUDIO_ALAC_SUPPORT)), yes)
  PRODUCT_PACKAGES += libMtkOmxAlacDec
endif

# Keymaster HIDL

KEYMASTER_VERSION ?= 4.0

ifeq ($(strip $(KEYMASTER_VERSION)), 4.0)
    DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_km4.xml
ifeq ($(strip $(MTK_TEE_SUPPORT)), yes)
# list of all TEEs
ifeq ($(strip $(TRUSTONIC_TEE_SUPPORT)), yes)
    PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.trustonic
else ifeq ($(strip $(MICROTRUST_TEE_SUPPORT)), yes)
    PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.beanpod
else ifeq ($(strip $(MICROTRUST_TEE_LITE_SUPPORT)), yes)
    PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.beanpod.lite
else ifeq ($(strip $(TRUSTKERNEL_TEE_SUPPORT)), yes)
    PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.trustkernel
else ifeq ($(strip $(MTK_GOOGLE_TRUSTY_SUPPORT)), yes)
    PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.trusty
else
    PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service
endif #end of list of TEEs
else #MTK_TEE_SUPPORT
    #non-tee project
    PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service
endif #MTK_TEE_SUPPORT
else ifeq ($(strip $(KEYMASTER_VERSION)), 3.0)
    DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_km3.xml
    PRODUCT_PACKAGES += android.hardware.keymaster@3.0-impl
ifeq ($(strip $(MTK_TEE_SUPPORT)), yes)
# list of all TEEs
ifeq ($(strip $(TRUSTONIC_TEE_SUPPORT)), yes)
    PRODUCT_PACKAGES += android.hardware.keymaster@3.0-service.trustonic
else
    PRODUCT_PACKAGES += android.hardware.keymaster@3.0-service
endif #end of list of TEEs
else #MTK_TEE_SUPPORT
    #non-tee project
    PRODUCT_PACKAGES += android.hardware.keymaster@3.0-service
endif #MTK_TEE_SUPPORT
else #KEYMASTER_VERSION
    $(error invalid keymaster version = $(KEYMASTER_VERSION))
endif #KEYMASTER_VERSION

# Gatekeeper HIDL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service

# SoftGatekeeper HAL
PRODUCT_PACKAGES += \
    libSoftGatekeeper

ifeq ($(strip $(MTK_TEE_SUPPORT)), yes)
  DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_tee.xml

  # Keymaster Attestation HIDL
  PRODUCT_PACKAGES += \
      vendor.mediatek.hardware.keymaster_attestation@1.1-impl \
      vendor.mediatek.hardware.keymaster_attestation@1.1-service

  ifeq ($(strip $(TARGET_BUILD_VARIANT)),eng)
    PRODUCT_PACKAGES += tlctee_sanity
    PRODUCT_PACKAGES += tlcsec
  endif

   ifeq ($(strip $(MTK_CAM_SECURITY_SUPPORT)), yes)
       # ISP CA
       PRODUCT_PACKAGES += libispcameraca
       PRODUCT_PACKAGES += libimgsensorca
   endif

endif

ifeq ($(strip $(MTK_TEE_GP_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_tee_gp_support=1
endif

ifeq ($(strip $(TRUSTONIC_TEE_SUPPORT)), yes)
  DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_trustonic.xml
  PRODUCT_PACKAGES += libMcClient
  PRODUCT_PACKAGES += libTEECommon
  PRODUCT_PACKAGES += mcDriverDaemon
  PRODUCT_PACKAGES += libMcTeeKeymaster
  PRODUCT_PACKAGES += libMcGatekeeper
  PRODUCT_PACKAGES += kmsetkey.trustonic
  PRODUCT_PACKAGES += vendor.trustonic.tee@1.0-service
  PRODUCT_PACKAGES += vendor.trustonic.teeregistry@1.0-service
  # ISP CA
  PRODUCT_PACKAGES += libispcameraca
  PRODUCT_PACKAGES += libimgsensorca

  PRODUCT_PROPERTY_OVERRIDES += ro.hardware.kmsetkey=trustonic
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_trustonic_tee_support=1

  ifeq ($(strip $(MTK_SEC_VIDEO_PATH_SUPPORT)), yes)
    ifeq ($(strip $(MTK_TEE_GP_SUPPORT)),yes)
      PRODUCT_PACKAGES += AVCSecureVdecCA
      PRODUCT_PACKAGES += AVCSecureVencCA
      PRODUCT_PACKAGES += HEVCSecureVdecCA
    else
      PRODUCT_PACKAGES += libMtkH264SecVdecTLCLib
      PRODUCT_PACKAGES += libMtkH264SecVencTLCLib
      PRODUCT_PACKAGES += libMtkH265SecVdecTLCLib
    endif
    PRODUCT_PACKAGES += libMtkVP9SecVdecTLCLib
    PRODUCT_PACKAGES += libtlcWidevineModularDrm
    PRODUCT_PACKAGES += libtplay
  endif
  ifeq ($(strip $(MTK_TEE_TRUSTED_UI_SUPPORT)), yes)
    PRODUCT_PACKAGES += libTui
    PRODUCT_PACKAGES += TuiService
    PRODUCT_PACKAGES += libTlcPinpad
  endif
endif

PRODUCT_COPY_FILES += \
      $(LOCAL_PATH)/public.libraries.vendor.txt:$(TARGET_COPY_OUT_VENDOR)/etc/public.libraries.txt:mtk

ifeq ($(strip $(MTK_GOOGLE_TRUSTY_SUPPORT)), yes)
  PRODUCT_PACKAGES += gatekeeper.trusty
  PRODUCT_PACKAGES += storageproxyd
  PRODUCT_PACKAGES += libtrusty
  PRODUCT_PACKAGES += kmsetkey.trusty
  PRODUCT_PROPERTY_OVERRIDES += ro.hardware.gatekeeper=trusty
  PRODUCT_PROPERTY_OVERRIDES += ro.hardware.keystore=trusty
  PRODUCT_PROPERTY_OVERRIDES += ro.hardware.kmsetkey=trusty
endif

ifeq ($(strip $(MICROTRUST_TEE_LITE_SUPPORT)), yes)
  PRODUCT_PACKAGES += gatekeeper.itrusty
  PRODUCT_PACKAGES += keystore.itrusty
  PRODUCT_PACKAGES += istorageproxyd
  PRODUCT_PACKAGES += libitrusty
  PRODUCT_PACKAGES += kmsetkey.itrusty
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_microtrust_tee_support=1
  PRODUCT_PROPERTY_OVERRIDES += ro.hardware.gatekeeper=itrusty
  PRODUCT_PROPERTY_OVERRIDES += ro.hardware.keystore=itrusty
  PRODUCT_PROPERTY_OVERRIDES += ro.hardware.kmsetkey=itrusty
endif #MICROTRUST_TEE_LITE_SUPPORT

ifeq ($(strip $(MICROTRUST_TEE_SUPPORT)), yes)
  PRODUCT_PACKAGES += teei_daemon
  PRODUCT_PACKAGES += libmtee
  PRODUCT_PACKAGES += libTEECommon
  PRODUCT_PACKAGES += kmsetkey.default
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_microtrust_tee_support=1
  PRODUCT_PACKAGES += vendor.microtrust.hardware.capi@2.0-service
  DEVICE_MANIFEST_FILE += vendor/mediatek/proprietary/trustzone/microtrust/source/common/manifest.microtrust.xml
  ifeq ($(strip $(MTK_SEC_VIDEO_PATH_SUPPORT)), yes)
    ifeq ($(strip $(MTK_TEE_GP_SUPPORT)),yes)
      PRODUCT_PACKAGES += AVCSecureVdecCA
    endif
  endif
endif #MICROTRUST_TEE_SUPPORT

ifeq ($(strip $(MTK_SEC_VIDEO_PATH_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_sec_video_path_support=1
  ifneq ($(filter $(MTK_IN_HOUSE_TEE_SUPPORT) $(MTK_GOOGLE_TRUSTY_SUPPORT),yes),)
    PRODUCT_PACKAGES += lib_uree_mtk_video_secure_al
  endif
endif

# DRM key installation
ifeq ($(strip $(MTK_DRM_KEY_MNG_SUPPORT)), yes)
  # Since HIDL is not necessary for tablet projects and only tablet keyinstall
  # supports MTK in-house tee, use MTK_IN_HOUSE_TEE_SUPPORT to separate tablet
  # and phone projects.
  ifneq ($(strip $(MTK_IN_HOUSE_TEE_SUPPORT)), yes)
    PRODUCT_PACKAGES += liburee_meta_drmkeyinstall
    # HIDL
    PRODUCT_PACKAGES += vendor.mediatek.hardware.keyinstall@1.0-service
    PRODUCT_PACKAGES += vendor.mediatek.hardware.keyinstall@1.0-impl
    DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_keyinstall.xml
  else
    # Keymanage HIDL for tablet
    PRODUCT_PACKAGES += vendor.mediatek.hardware.keymanage@1.0-impl
    PRODUCT_PACKAGES += vendor.mediatek.hardware.keymanage@1.0-service
  endif
endif

# MTK GENIEZONE SUPPORT
ifeq ($(strip $(MTK_ENABLE_GENIEZONE)), yes)
  PRODUCT_PACKAGES += libgz_uree
#  PRODUCT_PACKAGES += storageproxyd
  PRODUCT_PACKAGES += libgz_gp_client
  PRODUCT_PACKAGES_DEBUG += uree_test
ifneq ($(filter yes,$(TRUSTONIC_TEE_SUPPORT) $(MICROTRUST_TEE_SUPPORT)),)
ifeq ($(strip $(MTK_TEE_GP_SUPPORT)), yes)
  PRODUCT_PACKAGES_DEBUG += fod_ca
  PRODUCT_PACKAGES_DEBUG += pmem_share_ns
  PRODUCT_PACKAGES_DEBUG += pmem_share_s
  PRODUCT_PACKAGES_DEBUG += pmem_ion_fast
  PRODUCT_PACKAGES_DEBUG += pmem_ion
  PRODUCT_PACKAGES_DEBUG += pmem_perf
endif
endif
endif

#################################################
################### Widevine DRM ####################
#Hidl impl and service, enable lazy hal on A-GO project to save memory
PRODUCT_PACKAGES += android.hardware.drm@1.0-impl
ifeq ($(strip $(MTK_GMO_RAM_OPTIMIZE)),yes)
  PRODUCT_PACKAGES += android.hardware.drm@1.0-service-lazy
  PRODUCT_PACKAGES += android.hardware.drm@1.2-service-lazy.clearkey
  ifeq ($(strip $(MTK_WVDRM_SUPPORT)),yes)
    PRODUCT_PACKAGES += android.hardware.drm@1.2-service-lazy.widevine
  endif
else
  PRODUCT_PACKAGES += android.hardware.drm@1.0-service
  PRODUCT_PACKAGES += android.hardware.drm@1.2-service.clearkey
  ifeq ($(strip $(MTK_WVDRM_SUPPORT)),yes)
    PRODUCT_PACKAGES += android.hardware.drm@1.2-service.widevine
  endif
endif

# Widevine relate libraries
ifeq ($(strip $(MTK_WVDRM_SUPPORT)),yes)
  #Mock modular drm plugin for cts
  PRODUCT_PACKAGES += libmockdrmcryptoplugin
  #both L1 and L3 library
  PRODUCT_PACKAGES += libwvhidl
  PRODUCT_PACKAGES += libwvdrmengine
  #PRODUCT_PACKAGES += move_widevine_data.sh
  ifeq ($(strip $(MTK_WVDRM_L1_SUPPORT)),yes)
    PRODUCT_PACKAGES += lib_uree_mtk_modular_drm
    PRODUCT_PACKAGES += liboemcrypto
    PRODUCT_PACKAGES += libtlcWidevineModularDrm
  endif
endif
#################################################

ifeq ($(strip $(MTK_COMBO_SUPPORT)), yes)
  $(call inherit-product-if-exists, $(LOCAL_PATH)/connectivity/product_package/product_package.mk)
endif

SPMFW_ROOT_DIR := vendor/mediatek/proprietary/hardware/spmfw
ifneq (yes,$(strip $(SPM_FW_USE_PARTITION)))
  $(call inherit-product-if-exists,$(SPMFW_ROOT_DIR)/build/product_package.mk)
else
  PRODUCT_PACKAGES += spmfw.img
endif

MCUPMFW_ROOT_DIR := vendor/mediatek/proprietary/hardware/mcupmfw
ifeq (yes,$(strip $(MCUPM_FW_USE_PARTITION)))
  PRODUCT_PACKAGES += mcupmfw.img
endif

ifeq ($(strip $(MTK_SENSOR_HUB_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_sensorhub_support=1
  PRODUCT_PACKAGES += libhwsensorhub \
                      libsensorhub \
                      libsensorhub_jni \
                      sensorhubservice \
                      libsensorhubservice
endif

ifeq ($(strip $(MTK_TC7_FEATURE)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_tc7_feature=1
endif

#Add for CCCI Lib
PRODUCT_PACKAGES += libccci_util

#Add for C2Kutils
#PRODUCT_PACKAGES += libc2kutils_sys

ifeq ($(strip $(MTK_WMA_PLAYBACK_SUPPORT)), yes)
  PRODUCT_PACKAGES += libMtkOmxWmaDec
endif

ifeq ($(strip $(MTK_WMA_PLAYBACK_SUPPORT))_$(strip $(MTK_SWIP_WMAPRO)), yes_yes)
  PRODUCT_PACKAGES += libMtkOmxWmaProDec
endif

#$(call inherit-product-if-exists, vendor/mediatek/proprietary/external/strongswan/copy_files.mk)

# AudioParamParser
PRODUCT_PACKAGES += libaudio_param_parser-vnd
PRODUCT_PACKAGES_DEBUG += audio_param_test-vnd

XML_CUS_FOLDER_ON_DEVICE := /data/vendor/audiohal/audio_param/
AUDIO_PARAM_OPTIONS_LIST += CUST_XML_DIR=$(XML_CUS_FOLDER_ON_DEVICE)
MTK_AUDIO_PARAM_DIR_LIST := $(strip $(MTK_AUDIO_PARAM_DIR_LIST))
ifneq ($(MTK_AUDIO_TUNING_TOOL_VERSION),)
  ifneq ($(strip $(MTK_AUDIO_TUNING_TOOL_VERSION)),V1)
    PRODUCT_PACKAGES += libspeechparser_vendor
    AUDIO_PARAM_OPTIONS_LIST += 5_POLE_HS_SUPPORT=$(MTK_HEADSET_ACTIVE_NOISE_CANCELLATION)
    MTK_AUDIO_PARAM_DIR_LIST += $(LOCAL_PATH)/audio_param
    #MTK_AUDIO_PARAM_FILE_LIST += SOME_ZIP_FILE
    ifeq ($(strip $(MTK_USB_PHONECALL)),AP)
      AUDIO_PARAM_OPTIONS_LIST += VIR_MTK_USB_PHONECALL=yes
    endif

    # speaker path customization for gain table
    ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),int_spk_amp)
      AUDIO_PARAM_OPTIONS_LIST += SPK_PATH_INT=yes
    else ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),2_in_1_spk)
      AUDIO_PARAM_OPTIONS_LIST += SPK_PATH_INT=yes
    else ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),3_in_1_spk)
      AUDIO_PARAM_OPTIONS_LIST += SPK_PATH_INT=yes
    else ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),int_lo_buf)
      AUDIO_PARAM_OPTIONS_LIST += SPK_PATH_LO=yes
    else ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),int_hp_buf)
      AUDIO_PARAM_OPTIONS_LIST += SPK_PATH_HP=yes
    else
      AUDIO_PARAM_OPTIONS_LIST += SPK_PATH_NO_ANA=yes
    endif

    # receiver path customization for gain table
    ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),2_in_1_spk)
      AUDIO_PARAM_OPTIONS_LIST += RCV_PATH_2_IN_1_SPK=yes
    else ifeq ($(strip $(MTK_AUDIO_SPEAKER_PATH)),3_in_1_spk)
      AUDIO_PARAM_OPTIONS_LIST += RCV_PATH_3_IN_1_SPK=yes
    else ifeq ($(findstring smartpa,$(MTK_AUDIO_SPEAKER_PATH)),smartpa)
      ifeq ($(MTK_2IN1_SPK_SUPPORT),yes)
        AUDIO_PARAM_OPTIONS_LIST += RCV_PATH_NO_ANA=yes
     else
        AUDIO_PARAM_OPTIONS_LIST += RCV_PATH_INT=yes
      endif
    else
      AUDIO_PARAM_OPTIONS_LIST += RCV_PATH_INT=yes
    endif

    # Speech Parameter Tuning
    # SPH_PARAM_VERSION: 0 support single network(MD ability related)
    # SPH_PARAM_VERSION: 1.0 support multiple networks(MD ability related)
    # SPH_PARAM_VERSION: 2.0 support IIR and fix WBFIR(Gen93)
    # SPH_PARAM_VERSION: 3.0 support SWIP Parser(above Gen95)
    AUDIO_PARAM_OPTIONS_LIST += SPH_PARAM_VERSION=3.0
    AUDIO_PARAM_OPTIONS_LIST += SPH_PARAM_TTY=yes
    AUDIO_PARAM_OPTIONS_LIST += FIX_WB_ENH=yes
    AUDIO_PARAM_OPTIONS_LIST += MTK_IIR_ENH_SUPPORT=yes
    AUDIO_PARAM_OPTIONS_LIST += MTK_IIR_MIC_SUPPORT=no
    AUDIO_PARAM_OPTIONS_LIST += MTK_FIR_IIR_ENH_SUPPORT=no
    # Speech Loopback Tunning
    ifeq ($(MTK_TC1_FEATURE),yes)
      AUDIO_PARAM_OPTIONS_LIST += MTK_AUDIO_SPH_LPBK_PARAM=yes
    else ifeq ($(MTK_TC10_FEATURE),yes)
      AUDIO_PARAM_OPTIONS_LIST += MTK_AUDIO_SPH_LPBK_PARAM=yes
    else ifeq ($(MTK_AUDIO_SPH_LPBK_PARAM),yes)
      AUDIO_PARAM_OPTIONS_LIST += MTK_AUDIO_SPH_LPBK_PARAM=yes
    endif
    # Super Volume Parameter
    AUDIO_PARAM_OPTIONS_LIST += SPH_PARAM_SV=no

    # Custom scene support
    ifeq ($(strip $(MTK_GMO_RAM_OPTIMIZE)),yes)
      AUDIO_PARAM_OPTIONS_LIST += VIR_SCENE_CUSTOMIZATION_SUPPORT=no
    else
      AUDIO_PARAM_OPTIONS_LIST += VIR_SCENE_CUSTOMIZATION_SUPPORT=yes
    endif
  endif
endif
ifeq ($(strip $(MTK_SPEECH_ENCRYPTION_SUPPORT)), yes)
  PRODUCT_PACKAGES += libaudiocustencrypt
endif


# aurisys framework
ifeq ($(MTK_AURISYS_FRAMEWORK_SUPPORT),yes)
  # configurations
  PRODUCT_COPY_FILES += vendor/mediatek/proprietary/external/aurisys/aurisys_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/aurisys_config.xml:mtk
  ifeq ($(MTK_AUDIODSP_SUPPORT),yes)
    PRODUCT_COPY_FILES += \
      $(call add-to-product-copy-files-if-exists, $(MTK_TARGET_PROJECT_FOLDER)/aurisys_config_hifi3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/aurisys_config_hifi3.xml:mtk) \
      $(call add-to-product-copy-files-if-exists, device/mediatek/$(MTK_PLATFORM_DIR)/aurisys_config_hifi3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/aurisys_config_hifi3.xml:mtk) \
      vendor/mediatek/proprietary/external/aurisys/aurisys_config_hifi3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/aurisys_config_hifi3.xml:mtk
  endif

  # aurisys demo library
  PRODUCT_PACKAGES   += libaurisysdemo

  # CM4 phone call
  ifeq ($(MTK_AURISYS_PHONE_CALL_SUPPORT),yes)
    PRODUCT_COPY_FILES += \
        $(call add-to-product-copy-files-if-exists, vendor/mediatek/proprietary/external/aurisys_3rdparty/libfvaudio/FV-SAM-MTKXX.dat:$(TARGET_COPY_OUT_VENDOR)/etc/aurisys_param/FV-SAM-MTKXX.dat:mtk)
    PRODUCT_PACKAGES   += libfvaudio
  endif

  # HiFi3 phone call + VoIP + Record
  ifeq ($(MTK_AUDIODSP_SUPPORT),yes)
    $(foreach bin,$(wildcard vendor/mediatek/proprietary/external/aurisys_3rdparty/libnxp/libnxpspeech/nxp_param/*.bin), \
        $(eval PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists, $(bin):$(TARGET_COPY_OUT_VENDOR)/etc/nxp/$(notdir $(bin)):mtk)) \
    )
    PRODUCT_PACKAGES   += libnxpspeech

    $(foreach bin,$(wildcard vendor/mediatek/proprietary/external/aurisys_3rdparty/libnxp/libnxprecord/nxp_im/*.bin), \
        $(eval PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists, $(bin):$(TARGET_COPY_OUT_VENDOR)/etc/nxp/$(notdir $(bin)):mtk)) \
    )
    PRODUCT_PACKAGES   += libnxprecord
    PRODUCT_COPY_FILES += \
        $(call add-to-product-copy-files-if-exists, vendor/mediatek/proprietary/external/aurisys_3rdparty/libfvaudio/FV-SAM-MTKXX.dat:$(TARGET_COPY_OUT_VENDOR)/etc/aurisys_param/FV-SAM-MTKXX.dat:mtk)
    PRODUCT_PACKAGES   += libfvaudio
  endif

  # mediatek IIR
  PRODUCT_PACKAGES   += lib_iir

  # mediatek BESSOUND
  PRODUCT_PACKAGES   += libaudioloudc

  # mediatek record/VoIP
  PRODUCT_COPY_FILES += $(LOCAL_PATH)/audio_param/Speech_AudioParam.xml:$(TARGET_COPY_OUT_VENDOR)/etc/aurisys_param/Speech_AudioParam.xml:mtk
  PRODUCT_PACKAGES   += lib_speech_enh

  # BliSRC & Bit Converter
  PRODUCT_PACKAGES += libaudiocomponentenginec
endif

# sample rate converter and bit converter
PRODUCT_PACKAGES += libaudiofmtconv

# Audio speech enhancement library
PRODUCT_PACKAGES += libspeech_enh_lib

# Audio speech custom parameter
PRODUCT_PACKAGES += libaudiocustparam_vendor


ifeq ($(findstring smartpa, $(MTK_AUDIO_SPEAKER_PATH)), smartpa)
    PRODUCT_PACKAGES += libaudio_param_parser-vnd
    MTK_AUDIO_PARAM_DIR_LIST += $(LOCAL_PATH)/audio_param_smartpa
endif

# Audio BTCVSD Lib
PRODUCT_PACKAGES += libcvsd_mtk
PRODUCT_PACKAGES += libmsbc_mtk


#ifeq ($(strip $(MTK_NTFS_OPENSOURCE_SUPPORT)), yes)
#  PRODUCT_PACKAGES += ntfs-3g
#  PRODUCT_PACKAGES += ntfsfix
#endif

## Add for HetComm feature
#ifeq ($(strip $(MTK_HETCOMM_SUPPORT)), yes)
#  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_hetcomm_support=1
#  PRODUCT_PACKAGES += HetComm
#endif

#ifeq ($(strip $(MTK_DEINTERLACE_SUPPORT)), yes)
#  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_deinterlace_support=1
#endif

ifeq ($(strip $(MTK_MD_DIRECT_TETHERING_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.mtk_md_direct_tethering=1
    PRODUCT_PROPERTY_OVERRIDES += ro.tethering.bridge.interface=mdbr0
    PRODUCT_PROPERTY_OVERRIDES += sys.mtk_md_direct_tether_enable=true
    PRODUCT_PACKAGES += brctl
endif

ifeq ($(strip $(MTK_SWITCH_ANTENNA_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_switch_antenna=1
endif

ifeq ($(strip $(MTK_TDD_DATA_ONLY_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_tdd_data_only_support=1
endif

ifneq ($(strip $(MTK_MD_SBP_CUSTOM_VALUE)),)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_md_sbp_custom_value=$(strip $(MTK_MD_SBP_CUSTOM_VALUE))
endif

#PRODUCT_PACKAGES += CarrierConfig

# Add for SensorHub
ifeq ($(strip $(MTK_GMO_ROM_OPTIMIZE)), yes)
    ifeq ($(strip $(TARGET_BUILD_VARIANT)),eng)
        PRODUCT_PACKAGES += SensorHub
    endif
else
    PRODUCT_PACKAGES += SensorHub
endif

ifeq ($(strip $(MTK_EMCAMERA_APP)), yes)
    ifeq ($(strip $(MTK_GMO_ROM_OPTIMIZE)), yes)
        ifeq ($(strip $(TARGET_BUILD_VARIANT)),eng)
            PRODUCT_PACKAGES += EmCamera
        endif
    else
        PRODUCT_PACKAGES += EmCamera
    endif
endif

# Add for Dynamic-SBP
ifeq ($(strip $(MTK_DYNAMIC_SBP_SUPPORT)), yes)
    ifneq ($(strip $(MTK_DYNAMIC_SBP_LEVEL)), )
          PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.mtk_dsbp_support= $(MTK_DYNAMIC_SBP_LEVEL)
    else
          PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.mtk_dsbp_support=1
    endif
endif

# Add for MTK_CT_VOLTE_SUPPORT
ifeq ($(strip $(MTK_CT_VOLTE_SUPPORT)), yes)
    ifeq ($(strip $(MTK_RIL_MODE)), c6m_1rild)
        ifeq ($(strip $(RAT_CONFIG_C2K_SUPPORT)),yes)
            PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_ct_volte_support=2
        else
            PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_ct_volte_support=1
        endif
    else
        PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_ct_volte_support=1
    endif
endif

# Add for Modem protocol2 capability setting
ifneq ($(strip $(MTK_PROTOCOL2_RAT_CONFIG)),)
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.mtk_ps2_rat=$(strip $(MTK_PROTOCOL2_RAT_CONFIG))
endif

# Add for Modem protocol3 capability setting
ifneq ($(strip $(MTK_PROTOCOL3_RAT_CONFIG)),)
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.mtk_ps3_rat=$(strip $(MTK_PROTOCOL3_RAT_CONFIG))
endif


ifeq ($(strip $(MTK_VIBSPK_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_vibspk_support=1
endif

PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RILMUXD=I

# Telephony RIL log configurations
ifeq ($(strip $(MTK_TELEPHONY_CONN_LOG_CTRL_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.log.tel_log_ctrl=1
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.AT=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RILC-MTK=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RILC=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMainThread=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxRoot=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxRilAdapter=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxController=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RILC-RP=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxTransUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMclDisThread=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxCloneMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxHandlerMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxIdToStr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxDisThread=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMclStatusMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-Fusion=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcEccNumberController=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcEccNumberUrcHandler=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpPhoneNumberController=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RilOpProxy=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RILC-OP=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RilOemClient=I
ifneq ($(strip $(TARGET_BUILD_VARIANT)),eng)
  # user/userdebug load
  # V/D/(I/W/E)
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DCT-C-0=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DCT-I-0=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DCT-C-1=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DCT-I-1=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DC-C-1=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DC-C-2=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-DATA=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.C2K_RIL-DATA=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.GsmCdmaPhone=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RILMD2-SS=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.CapaSwitch=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DSSelector=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DSSelectorOm=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DSSelectorOP01=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DSSelectorOP02=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DSSelectorOP09=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DSSelectorOP18=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DSSelectorUtil=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.SimSwitchOP01=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.SimSwitchOP02=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.SimSwitchOP18=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DcFcMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RetryManager=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.IccProvider=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.IccPhoneBookIM=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.AdnRecordCache=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.AdnRecordLoader=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.AdnRecord=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-PHB=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkIccProvider=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkIccPHBIM=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkAdnRecord=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkRecordLoader=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpPhbController=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcPhbReq=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcPhbUrc=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcPhb=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-SMS=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DupSmsFilterExt=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ConSmsFwkExt=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DataOnlySmsFwk=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.VT=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsVTProvider=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.IccCardProxy=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.IsimFileHandler=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.IsimRecords=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.SIMRecords=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.SpnOverride=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.UiccCard=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.UiccController=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-SIM=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.CountryDetector=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.NetworkStats=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.NetworkPolicy=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DataDispatcher=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsService=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.IMS_RILA=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.IMSRILRequest=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsManager=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsApp=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsBaseCommands=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkImsManager=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkImsService=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RP_IMS=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcIms=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcImsConference=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcImsDialog=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcImsCtlUrcHdl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcImsCtlReqHdl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsCall=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsPhone=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsPhoneCall=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsPhoneBase=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsCallSession=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsCallProfile=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsEcbm=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ImsEcbmProxy=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.OperatorUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.WfoApp=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.GsmCdmaConn=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.GsmCdmaPhone=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.Phone=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-CC=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpCallControl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpAudioControl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.GsmCallTkrHlpr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkPhoneNotifr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkFactory=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkGsmCdmaConn=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RadioManager=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL_Mux=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-OEM=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL_UIM_SOCKET=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RILD=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-RP=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMessage=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxDebugInfo=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxTimer=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxObject=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.SlotQueueEntry=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxAction=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RFX=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpRadioMessage=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpModemMessage=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PhoneFactory=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ProxyController=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.SpnOverride=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.SmsPlusCode=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.AutoRegSmsFwk=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.AirplaneHandler=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxDefDestUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxSM=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxSocketSM=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxDT=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpCdmaOemCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpRadioCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpMDCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpCdmaRadioCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpFOUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ExternalSimMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.VsimAdaptor=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MGsmSMSDisp=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MSimSmsIStatus=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MSmsStorageMtr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MSmsUsageMtr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.Mtk_RIL_ImsSms=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkConSmsFwk=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkCsimFH=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkDupSmsFilter=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkIccSmsIntMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkIsimFH=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkRuimFH=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkSIMFH=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkSIMRecords=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkSmsCbHeader=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkSmsManager=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkSmsMessage=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkSpnOverride=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkIccCardProxy=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkUiccCard=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkUiccCardApp=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkUiccCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkUsimFH=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxTransUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpRilClientCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RilMalClient=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpSimController=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkSubCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcEmbmsReq=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcEmbmsUrc=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcEmbmsUtil=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcEmbmsAt=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkEmbmsAdaptor=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RP_DAC=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RP_DC=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RTC_DAC=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMclDisThread=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxCloneMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxHandlerMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxIdToStr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxDisThread=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMclStatusMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.NetAgentService=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.NetAgent_IO=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.NetLnkEventHdlr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcDcCommon=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcDcDefault=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcDC=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RilClient=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcCommSimReq=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcCdmaSimRequest=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcGsmSimRequest=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcCommSimUrc=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcGsmSimUrc=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcCommSimCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcCommSimOpReq=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-Fusion=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcRadioCont=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkRetryManager=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcDcPdnManager=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcDcReqHandler=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcDcUtility=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxIdToMsgId=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxOpUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMclMessenger=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxRilAdapter=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxFragEnc=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxStatusMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MTKSST=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxRilUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcNwHdlr=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcNwReqHdlr=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcNwRTReqHdlr=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcRatSwHdlr=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcRatSwCtrl=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcNwCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcRadioReq=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcCapa=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcCapa=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpMalController=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.WORLDMODE=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcWp=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcWp=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcOpRadioReq=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxContFactory=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxChannelMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcCdmaSimUrc=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkPhoneNumberUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcOemHandler=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcModeCont=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkPhoneSwitcher=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-Parcel=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-Socket=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-SocListen=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-Netlink=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MwiRIL=I
ifeq ($(strip $(TARGET_BUILD_VARIANT)),user)
  # Only user load
  # V/D/(I/W/E)
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.CarrierExpressServiceImpl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.CarrierExpressServiceImplExt=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PhoneConfigurationSettings=I
endif
else
  # eng load
  # V/(D/I/W/E)
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DCT-C-0=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DCT-I-0=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DCT-C-1=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DCT-I-1=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DC-C-1=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DC-C-2=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-DATA=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.C2K_RIL-DATA=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RP_DAC=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RP_DC=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RTC_DAC=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpRadioMessage=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpModemMessage=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpCdmaRadioCtrl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcEmbmsReq=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcEmbmsUrc=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcEmbmsUtil=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcEmbmsAt=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkEmbmsAdaptor=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.ExternalSimMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.VsimAdaptor=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.NetAgentService=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.NetAgent_IO=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.NetLnkEventHdlr=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcDC=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcDcCommon=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MTKSST=V
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxRilUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxOpUtils=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMclMessenger=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxRilAdapter=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxStatusMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxCloneMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxFragEnc=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RilMalClient=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RpMalController=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcRadioReq=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcRadioCont=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcOpRadioReq=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RP_DC=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMessage=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxContFactory=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxChannelMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RmcCdmaSimUrc=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxMclDisThread=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxCloneMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RfxHandlerMgr=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RtcModeCont=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MtkPhoneSwitcher=V
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-Parcel=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-Socket=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-SocListen=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.RIL-Netlink=D
endif
# endif for TARGET_BUILD_VARIANT
else
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DCT=D
endif
# endif for MTK_TELEPHONY_CONN_LOG_CTRL_SUPPORT


# Add for opt_c2k_support
ifneq ($(strip $(MTK_PROTOCOL1_RAT_CONFIG)),)
ifneq ($(findstring C,$(strip $(MTK_PROTOCOL1_RAT_CONFIG))),)
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.C2K_AT=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.C2K_RILC=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.C2K_ATConfig=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.LIBC2K_RIL=I
endif
endif

# Add for Multi Ps Attach
ifeq ($(strip $(MTK_MULTI_PS_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_data_config=1
endif

# Audio policy config
ifeq ($(strip $(USE_XML_AUDIO_POLICY_CONF)), 1)
AUDIO_POLICY_PROJECT_CONFIGS := \
  $(strip \
    $(notdir $(wildcard $(MTK_TARGET_PROJECT_FOLDER)/audio_policy_config/*.xml)\
    ) \
  )
AUDIO_POLICY_BASE_PROJECT_CONFIGS := \
  $(strip \
    $(filter-out $(AUDIO_POLICY_PROJECT_CONFIGS), \
      $(notdir $(wildcard $(MTK_PROJECT_FOLDER)/audio_policy_config/*.xml)) \
    ) \
  )
AUDIO_POLICY_PLATFORM_CONFIGS := \
  $(strip \
    $(filter-out $(AUDIO_POLICY_PROJECT_CONFIGS) $(AUDIO_POLICY_BASE_PROJECT_CONFIGS), \
      $(notdir $(wildcard device/mediatek/$(MTK_PLATFORM_DIR)/audio_policy_config/*.xml)) \
    ) \
  )
AUDIO_POLICY_COMMON_CONFIGS := \
  $(strip \
    $(filter-out $(AUDIO_POLICY_PROJECT_CONFIGS) $(AUDIO_POLICY_BASE_PROJECT_CONFIGS) $(AUDIO_POLICY_PLATFORM_CONFIGS), \
      $(notdir $(wildcard $(LOCAL_PATH)/audio_policy_config/*.xml)) \
    ) \
  )

$(foreach x,$(AUDIO_POLICY_PROJECT_CONFIGS), \
  $(eval PRODUCT_COPY_FILES += $(MTK_TARGET_PROJECT_FOLDER)/audio_policy_config/$(x):$(TARGET_COPY_OUT_VENDOR)/etc/$(x)) \
)

$(foreach x,$(AUDIO_POLICY_BASE_PROJECT_CONFIGS), \
  $(eval PRODUCT_COPY_FILES += $(MTK_PROJECT_FOLDER)/audio_policy_config/$(x):$(TARGET_COPY_OUT_VENDOR)/etc/$(x)) \
)

$(foreach x,$(AUDIO_POLICY_PLATFORM_CONFIGS), \
  $(eval PRODUCT_COPY_FILES += device/mediatek/$(MTK_PLATFORM_DIR)/audio_policy_config/$(x):$(TARGET_COPY_OUT_VENDOR)/etc/$(x)) \
)

$(foreach x,$(AUDIO_POLICY_COMMON_CONFIGS), \
  $(eval PRODUCT_COPY_FILES += $(LOCAL_PATH)/audio_policy_config/$(x):$(TARGET_COPY_OUT_VENDOR)/etc/$(x)) \
)
endif



#Add for video codec customization
PRODUCT_PROPERTY_OVERRIDES += vendor.mtk.vdec.waitkeyframeforplay=9
PRODUCT_PACKAGES_ENG  += osal_ut
PRODUCT_PACKAGES_ENG  += omx_ut

ifeq ($(strip $(MTK_EMBMS_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_embms_support=1
endif

# Add for USB MIDI
PRODUCT_COPY_FILES += \
frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

# Add for verified boot
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

# Add for IpSec tunnel
ifneq (yes,$(strip $(MTK_IPSEC_TUNNELS_NO_SUPPORT)))
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml
endif

# workaround for dex_preopt
$(call add-product-dex-preopt-module-config,Settings,disable)
$(call add-product-dex-preopt-module-config,DataProtection,disable)
$(call add-product-dex-preopt-module-config,PermissionControl,disable)
$(call add-product-dex-preopt-module-config,PrivacyProtectionLock,disable)
ifndef ENABLE_DEX_PREOPT_VERIFIER
PRODUCT_DEX_PREOPT_BOOT_FLAGS += --no-abort-on-soft-verifier-error
endif

# Add for DuraSpeed
ifeq (yes,$(strip $(MTK_DURASPEED_SUPPORT)))
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.duraspeed.support=1
    PRODUCT_PROPERTY_OVERRIDES += ro.lmk.downgrade_pressure=60
    ifeq (yes,$(strip $(MTK_DURASPEED_DEFAULT_ON)))
        PRODUCT_PROPERTY_OVERRIDES += persist.vendor.duraspeed.app.on=1
    endif
    ifeq (yes,$(strip $(MTK_LOW_MEMORY_HINT_SUPPORT)))
        PRODUCT_PROPERTY_OVERRIDES += persist.vendor.low.memory.hint=1
    endif
endif

# Add for DuraSpeedML
ifeq (yes,$(strip $(MTK_DURASPEED_ML_SUPPORT)))
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.duraspeed.ml.support=1
endif

# Add for Resolution Switch feature
ifeq ($(strip $(MTK_RESOLUTION_SWITCH_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_res_switch=1
endif

# Add for heavy loading
ifeq (yes,$(strip $(MTK_HEAVY_LOADING_SUPPORT)))
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.heavy.loading.support=1
    PRODUCT_PROPERTY_OVERRIDES += ro.lmk.downgrade_pressure=70
endif

## Add for graphics debug
#PRODUCT_PACKAGES += libgui_debug
#
## Add for guiext with BQ monitor
#PRODUCT_PACKAGES += libgui_ext
#
## Add for sf debug
#PRODUCT_PACKAGES += libsf_debug
#
## Add for vsync hint
#PRODUCT_PACKAGES += libvsync_hint
#
## Add for vsync enhance
#PRODUCT_PACKAGES += libvsync_enhance
#
## Add for display dejitter
#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#PRODUCT_PACKAGES += libdisp_dejitter
#endif

## Add for Global PQ feature
#ifeq ($(strip $(MTK_GLOBAL_PQ_SUPPORT)), yes)
#  PRODUCT_PACKAGES += libsurfaceflingerpq
#endif

# Add for surfaceflinger default value
PRODUCT_PROPERTY_OVERRIDES += debug.sf.disable_backpressure=1

# Add for Display HDR feature
ifeq ($(strip $(MTK_HDR_VIDEO_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_hdr_video_support=1
endif

ifeq ($(strip $(MTK_MLC_NAND_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_mlc_nand_support=1
endif
ifeq ($(strip $(MTK_TLC_NAND_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_tlc_nand_support=1
endif

# for sensor multi-hal
ifeq ($(USE_SENSOR_MULTI_HAL), true)
  #PRODUCT_COPY_FILES += $(MTK_PROJECT_FOLDER)/hals.conf:system/etc/sensors/hals.conf:mtk
  PRODUCT_PROPERTY_OVERRIDES += ro.hardware.sensors=$(MTK_BASE_PROJECT)
  PRODUCT_PACKAGES += sensors.$(MTK_BASE_PROJECT)
endif

# sensor related xml files for CTS
ifeq ($(strip $(CUSTOM_KERNEL_ACCELEROMETER)),yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml
endif

ifeq ($(strip $(CUSTOM_KERNEL_MAGNETOMETER)),yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml
endif

ifeq ($(strip $(CUSTOM_KERNEL_ALSPS)),yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml
else
  ifeq ($(strip $(CUSTOM_KERNEL_PS)),yes)
    PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml
  endif
  ifeq ($(strip $(CUSTOM_KERNEL_ALS)),yes)
    PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml
  endif
endif

ifeq ($(strip $(CUSTOM_KERNEL_GYROSCOPE)),yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml
endif

ifeq ($(strip $(CUSTOM_KERNEL_BAROMETER)),yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml
endif

ifeq ($(strip $(CUSTOM_KERNEL_HUMIDITY)),yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.relative_humidity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.relative_humidity.xml
endif

ifeq ($(strip $(CUSTOM_KERNEL_STEP_COUNTER)),yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml
endif

ifeq ($(strip $(CUSTOM_KERNEL_STEP_DETECTOR)),yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml
endif

# for hifi sensors feature
ifeq ($(strip $(CUSTOM_HIFI_SENSORS)), yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.hifi_sensors.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.hifi_sensors.xml
endif

# for VR high performane feature
ifeq ($(MTK_VR_HIGH_PERFORMANCE_SUPPORT),yes)
  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.vr.high_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vr.high_performance.xml
  PRODUCT_PACKAGES += vr.$(MTK_PLATFORM_DIR)
endif

# Euicc feature
#  PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.telephony.euicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.euicc.xml

## Add EmergencyInfo apk to TK load
#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#  PRODUCT_PACKAGES += EmergencyInfo
#  ifneq ($(strip $(MTK_OVERRIDES_APKS)), no)
#    PRODUCT_PACKAGES += MtkEmergencyInfo
#  endif
#endif

# Add for SKT customization
ifeq ($(strip $(MTK_KOR_CUSTOMIZATION_SKT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.mtk_kor_customization_skt=1
  PRODUCT_PROPERTY_OVERRIDES += persist.ril.sim.regmode=0
endif

# Log control for SMS
ifneq ($(strip $(TARGET_BUILD_VARIANT)),eng)
  # user/userdebug load
  # V/D/(I/W/E)
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.CdmaMoSms=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.CdmaMtSms=I
else
  # eng load
  # V/(D/I/W/E)
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.CdmaMoSms=D
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.CdmaMtSms=D
endif

# Log control for PowerHal
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.libPowerHal=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.powerd=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.mtkpower@1.0-impl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.legacy_power@2.1-impl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.power@1.3-impl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PowerWrap=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.mtkperf_client=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.UxUtility=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PowerHalAddressUitls=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PowerHalMgrImpl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PowerHalMgrServiceImpl=I
  PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PowerHalWifiMonitor=I

# Add for LWA feature support
ifeq ($(strip $(MTK_LWA_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_lwa_support=1
endif

# Add for LWI feature support
ifeq ($(strip $(MTK_LWI_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_lwi_support=1
endif

## Add for LWA/LWI feature support
#ifneq (,$(filter yes,$(strip $(MTK_LWA_SUPPORT)) $(strip $(MTK_LWI_SUPPORT))))
#    PRODUCT_PACKAGES += liblwxnative
#endif

# Add for FTL feature support
ifeq ($(strip $(MTK_NAND_MTK_FTL_SUPPORT)), yes)
   PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_nand_ftl_support=1
endif

# Add for MNTL feature support
ifeq ($(strip $(MNTL_SUPPORT)), yes)
   PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mntl_support=1
endif

# whether logd reads kmsg
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.logd.kernel=false

# eng/userdebug load config fdsan level = fatal
ifneq ($(strip $(TARGET_BUILD_VARIANT)),user)
  PRODUCT_DEFAULT_PROPERTY_OVERRIDES += debug.fdsan=fatal
endif

# MTK internal load or customer eng/userdebug load will buildin log daemon.
# Customer user load default not have MTK log daemon.
# If customer user load want buildin the log daemon, You need set
# MTK_LOG_CUSTOMER_SUPPORT to yes, it will buildin log daemon as internal load.
# Each log daemon is decided by its feature option.
# Case: MTK internal load
ifneq ($(wildcard vendor/mediatek/internal/mtklog_enable),)
  DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_log.xml
  #PRODUCT_PACKAGES += log-handler
  PRODUCT_PACKAGES += loghidlvendorservice
  ifeq ($(strip $(MTK_LOG_SUPPORT_GPS)),yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_log_hide_gps=0
  else
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_log_hide_gps=1
  endif
# Add for ModemMonitor(MDM) framework
  ifeq ($(strip $(MTK_MODEM_MONITOR_SUPPORT)),yes)
    DEVICE_MANIFEST_FILE += device/mediatek/vendor/common/project_manifest/manifest_mdmonitor.xml
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_modem_monitor_support=1
    PRODUCT_PACKAGES += \
      md_monitor \
      md_monitor_ctrl
    #ifneq ($(strip $(MTK_GMO_RAM_OPTIMIZE)), yes)
    #    PRODUCT_PACKAGES += MDMLSample \
    #                        MDMConfig \
    #                        com.mediatek.mdml
    #endif
  endif
  ifeq ($(strip $(MTK_AEE_SUPPORT)),yes)
    HAVE_AEE_FEATURE = yes
  else
    HAVE_AEE_FEATURE = no
  endif
# Case: Customer eng/userdebug load
else ifneq ($(strip $(TARGET_BUILD_VARIANT)),user)
  DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_log.xml
  #PRODUCT_PACKAGES += log-handler
  PRODUCT_PACKAGES += loghidlvendorservice
  ifeq ($(strip $(MTK_LOG_SUPPORT_GPS)),yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_log_hide_gps=0
  else
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_log_hide_gps=1
  endif
# Add for ModemMonitor(MDM) framework
  ifeq ($(strip $(MTK_MODEM_MONITOR_SUPPORT)),yes)
    DEVICE_MANIFEST_FILE += device/mediatek/vendor/common/project_manifest/manifest_mdmonitor.xml
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_modem_monitor_support=1
    PRODUCT_PACKAGES += \
      md_monitor \
      md_monitor_ctrl
    #ifneq ($(strip $(MTK_GMO_RAM_OPTIMIZE)), yes)
    #    PRODUCT_PACKAGES += MDMLSample \
    #                        MDMConfig \
    #                        com.mediatek.mdml
    #endif
  endif
  ifeq ($(strip $(MTK_AEE_SUPPORT)),yes)
    HAVE_AEE_FEATURE = yes
  else
    HAVE_AEE_FEATURE = no
  endif
# Case: Customer user load and MTK_LOG_CUSTOMER_SUPPORT = yes
else ifeq ($(strip $(MTK_LOG_CUSTOMER_SUPPORT)),yes)
  DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_log.xml
  #PRODUCT_PACKAGES += log-handler
  PRODUCT_PACKAGES += loghidlvendorservice

  ifeq ($(strip $(MTK_LOG_SUPPORT_GPS)),yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_log_hide_gps=0
  else
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_log_hide_gps=1
  endif
# Add for ModemMonitor(MDM) framework
  ifeq ($(strip $(MTK_MODEM_MONITOR_SUPPORT)),yes)
    DEVICE_MANIFEST_FILE += device/mediatek/vendor/common/project_manifest/manifest_mdmonitor.xml
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_modem_monitor_support=1
    PRODUCT_PACKAGES += \
      md_monitor \
      md_monitor_ctrl
    #ifneq ($(strip $(MTK_GMO_RAM_OPTIMIZE)), yes)
    #    PRODUCT_PACKAGES += MDMLSample \
    #                        MDMConfig \
    #                        com.mediatek.mdml
    #endif
  endif
  ifeq ($(strip $(MTK_AEE_SUPPORT)),yes)
    HAVE_AEE_FEATURE = yes
  else
    HAVE_AEE_FEATURE = no
  endif
# Other Case: Customer user load and MTK_LOG_CUSTOMER_SUPPORT = no
else
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_log_hide_gps=1
  HAVE_AEE_FEATURE = no
endif

# AEE Config
ifeq ($(HAVE_AEE_FEATURE),yes)
  ifneq ($(wildcard vendor/mediatek/proprietary/external/aee_config_internal/init.aee.mtk.vendor.rc),)
$(call inherit-product-if-exists, vendor/mediatek/proprietary/external/aee_config_internal/aee_vendor.mk)
  else
$(call inherit-product-if-exists, vendor/mediatek/proprietary/external/aee/config_external/aee_vendor.mk)
  endif
#PRODUCT_COPY_FILES += vendor/mediatek/proprietary/external/aee/binary/aee-config:system/etc/aee-config:mtk
PRODUCT_COPY_FILES += vendor/mediatek/proprietary/external/aee/binary/aee-config:$(TARGET_COPY_OUT_VENDOR)/etc/aee-config:mtk

PRODUCT_PROPERTY_OVERRIDES += ro.vendor.have_aeev_feature=1
# MRDUMP
PRODUCT_PACKAGES += \
    mrdump_tool

ifeq ($(MTK_PRODUCT_LINE), smart_phone)
PRODUCT_PACKAGES += \
    dconfig \
    dtc_vendor
PRODUCT_HOST_PACKAGES += \
    dconfig
endif

#vendor bins
PRODUCT_PACKAGES += aeev
PRODUCT_PACKAGES += aee_aedv
PRODUCT_PACKAGES += aee_aedv64
PRODUCT_PACKAGES += aee_dumpstatev
PRODUCT_PACKAGES += aee_archivev
PRODUCT_PACKAGES += rttv
PRODUCT_PACKAGES += libaedv
#PRODUCT_PACKAGES += aee
#PRODUCT_PACKAGES += aee_aed
#PRODUCT_PACKAGES += aee_aed64
#PRODUCT_PACKAGES += aee_core_forwarder
#PRODUCT_PACKAGES += aee_dumpstate
#PRODUCT_PACKAGES += aee_archive
#PRODUCT_PACKAGES += rtt
#PRODUCT_PACKAGES += libaed
PRODUCT_PACKAGES += \
    vendor.mediatek.hardware.log@1.0-service
else # HAVE_AEE_FEATURE=no
PRODUCT_COPY_FILES += vendor/mediatek/proprietary/external/aee/aee.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.aee.rc:mtk
endif # HAVE_AEE_FEATURE
#PRODUCT_PACKAGES += libdirect-coredump
PRODUCT_PACKAGES += libdirect-coredump.vendor
#PRODUCT_PACKAGES += libmediatek_exceptionlog


#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#    PRODUCT_PACKAGES += MtkEmail
#endif

ifeq ($(strip $(MTK_EXCHANGE_SUPPORT)),yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_exchange_support=1
endif

# Modem log daemon built in according to feature option flow.
ifneq ($(wildcard vendor/mediatek/internal/mtklog_enable),)
  ifeq ($(strip $(MTK_MDLOGGER_SUPPORT)),yes)
    ifneq ($(strip $(MTK_SINGLE_BIN_MODEM_SUPPORT)),yes)
      DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_modemdbfilter.xml
      PRODUCT_PACKAGES += modemdbfilter_service
    endif
    ifneq ($(strip $(MTK_MD1_SUPPORT)),)
      ifneq ($(strip $(MTK_MD1_SUPPORT)),0)
        PRODUCT_PROPERTY_OVERRIDES += ro.vendor.md_log_memdump_wait=15
      endif
    endif
  endif
else ifneq ($(strip $(TARGET_BUILD_VARIANT)),user)
  ifeq ($(strip $(MTK_MDLOGGER_SUPPORT)),yes)
    ifneq ($(strip $(MTK_SINGLE_BIN_MODEM_SUPPORT)),yes)
      DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_modemdbfilter.xml
      PRODUCT_PACKAGES += modemdbfilter_service
    endif
    ifneq ($(strip $(MTK_MD1_SUPPORT)),)
      ifneq ($(strip $(MTK_MD1_SUPPORT)),0)
        PRODUCT_PROPERTY_OVERRIDES += ro.vendor.md_log_memdump_wait=15
      endif
    endif
  endif
else ifeq ($(strip $(MTK_LOG_CUSTOMER_SUPPORT)),yes)
  ifeq ($(strip $(MTK_MDLOGGER_SUPPORT)),yes)
    ifneq ($(strip $(MTK_SINGLE_BIN_MODEM_SUPPORT)),yes)
      DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_modemdbfilter.xml
      PRODUCT_PACKAGES += modemdbfilter_service
    endif
    ifneq ($(strip $(MTK_MD1_SUPPORT)),)
      ifneq ($(strip $(MTK_MD1_SUPPORT)),0)
        PRODUCT_PROPERTY_OVERRIDES += ro.vendor.md_log_memdump_wait=15
      endif
    endif
  endif
endif

## Add for RRO
#DEVICE_PACKAGE_OVERLAYS += \
#                           $(LOCAL_PATH)/overlay/swphone \
#                           $(LOCAL_PATH)/overlay/accdet \
#                           $(LOCAL_PATH)/overlay/tether \
#                           $(LOCAL_PATH)/overlay/multiuser \
#                           $(LOCAL_PATH)/overlay/power \
#                           $(LOCAL_PATH)/overlay/pno \
#                           $(LOCAL_PATH)/overlay/wifitethering \
#                           $(LOCAL_PATH)/overlay/wallpaper \
#                           $(LOCAL_PATH)/overlay/sensor \
#                           $(LOCAL_PATH)/overlay/cta \
#                           $(LOCAL_PATH)/overlay/pq \
#                           $(LOCAL_PATH)/overlay/wifiscan

#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#  DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/wifitethering_channel
#endif

#PRODUCT_ENFORCE_RRO_TARGETS += framework-res

# Add vendor minijail policy for mediacodec service for Android O
PRODUCT_COPY_FILES += $(LOCAL_PATH)/seccomp_policy/mediacodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy:mtk

# Add vendor minijail policy for mediaextractor service for Android O
PRODUCT_COPY_FILES += $(LOCAL_PATH)/seccomp_policy/mediaextractor.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaextractor.policy:mtk

# Add vendor minijail policy for mediaswcodec service for Android Q
PRODUCT_COPY_FILES += $(LOCAL_PATH)/seccomp_policy/mediaswcodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaswcodec.policy:mtk

## Add for mediatek-telecom-common.jar
#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#  ifneq ($(wildcard vendor/mediatek/proprietary/frameworks/opt/telecomm/Android.bp),)
#    PRODUCT_PACKAGES += mediatek-telecom-common
#    PRODUCT_BOOT_JARS += mediatek-telecom-common
#  endif
#endif

## Add for MtkCarrierConfig
#ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
#  ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/CarrierConfig/Android.bp),)
#    PRODUCT_PACKAGES += MtkCarrierConfig
#  endif
#endif

## Add WallpaperPicker or MtkWallpaperPicker based on available source code
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/WallpaperPicker/Android.mk),)
#    PRODUCT_PACKAGES += MtkWallpaperPicker
#else
#    PRODUCT_PACKAGES += WallpaperPicker
#endif

ifneq ($(MTK_BUILD_IGNORE_IMS_REPO),yes)
MTK_IMS_DEPENDENCY_ENABLED := 1
ifdef CUSTOM_MODEM
  ifeq ($(strip $(TARGET_BUILD_VARIANT)),eng)
    MTK_MODEM_MODULE_MAKEFILES := $(foreach item,$(CUSTOM_MODEM),$(firstword $(wildcard vendor/mediatek/proprietary/modem/$(patsubst %_prod,%,$(item))/Android.mk vendor/mediatek/proprietary/modem/$(item)/Android.mk)))
  else
    MTK_MODEM_MODULE_MAKEFILES := $(foreach item,$(CUSTOM_MODEM),$(firstword $(wildcard vendor/mediatek/proprietary/modem/$(patsubst %_prod,%,$(item))_prod/Android.mk vendor/mediatek/proprietary/modem/$(item)/Android.mk)))
  endif
  MTK_MODEM_APPS_MAKEFILES :=
  $(foreach f,$(MTK_MODEM_MODULE_MAKEFILES),\
    $(if $(strip $(MTK_MODEM_APPS_MAKEFILES)),,\
      $(eval MTK_MODEM_APPS_MAKEFILES := $(wildcard $(patsubst %/Android.mk,%/makefile/product_*.mk,$(f))))\
    )\
  )
  $(foreach f,$(MTK_MODEM_APPS_MAKEFILES),\
    $(eval $(call inherit-product-if-exists,$(f)))\
  )
endif
endif
ifdef CUSTOM_MODEM
  PRODUCT_PACKAGES += mcf_ota
endif

ifeq ($(strip $(MTK_SINGLE_BIN_MODEM_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_single_bin_modem_support=1
endif

#PRODUCT_PACKAGES += libandroid_net

# A/B System updates
ifeq ($(strip $(MTK_AB_OTA_UPDATER)), yes)
#PRODUCT_PACKAGES += \
#update_engine \
#update_engine_sideload \
#update_verifier

PRODUCT_HOST_PACKAGES += \
delta_generator \
shflags \
brillo_update_payload \
bsdiff \
simg2img

#PRODUCT_PACKAGES_DEBUG += \
#update_engine_client \
#bootctl

# bootctrl HAL and HIDL
PRODUCT_PACKAGES += \
        bootctrl.$(MTK_PLATFORM_DIR) \
        bootctrl.$(MTK_PLATFORM_DIR).recovery \
        android.hardware.boot@1.0-impl \
        android.hardware.boot@1.0-impl.recovery \
        android.hardware.boot@1.0-service

## A/B OTA dexopt package
#PRODUCT_PACKAGES += otapreopt_script

## Tell the system to enable copying odexes from other partition.
#PRODUCT_PACKAGES += \
#        cppreopts.sh

PRODUCT_PROPERTY_OVERRIDES += \
    ro.cp_system_other_odex=1

DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_boot.xml
endif

#ifneq ($(strip $(SYSTEM_AS_ROOT)), no)
#BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
#endif

-include vendor/mediatek/build/core/releaseBRM_vnd.mk

## Add for telephony resource overlay
#DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/telephony
#
#
##Add for OP03 resource overlay
#ifeq (OP03,$(word 1,$(subst _, ,$(OPTR_SPEC_SEG_DEF))))
#    DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/operator/OP03/CMAS/
#endif
#
##Add for OP07 resource overlay
#ifeq (OP07,$(word 1,$(subst _, ,$(OPTR_SPEC_SEG_DEF))))
#    DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/operator/OP07/CMAS/
#endif
#
##Add for OP08 resource overlay
#ifeq (OP08,$(word 1,$(subst _, ,$(OPTR_SPEC_SEG_DEF))))
#    DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/operator/OP08/CMAS/
#endif
#
##Add for OP12 resource overlay
#ifeq (OP12,$(word 1,$(subst _, ,$(OPTR_SPEC_SEG_DEF))))
#    DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/operator/OP12/CMAS/
#endif
#
##Add for OP20 resource overlay
#ifeq (OP20,$(word 1,$(subst _, ,$(OPTR_SPEC_SEG_DEF))))
#    DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay/operator/OP20/CMAS/
#endif
#
##TelephonyProvider AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/providers/Telephony/TelephonyProvider/Android.bp),)
#  PRODUCT_PACKAGES += MtkTelephonyProvider
#endif
#
## ContactsProvider AOSP code will be replaced by MTK
#ifneq ($(strip $(MTK_OVERRIDES_APKS)), no)
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/providers/ContactsProvider/Android.mk),)
#PRODUCT_PACKAGES += MtkContactsProvider
#endif
#endif

#netdagent
PRODUCT_PACKAGES += netdagent
PRODUCT_PACKAGES += netdc
DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_netdagent.xml

## Contacts AOSP code will be replaced by MTK
#ifneq ($(strip $(MTK_OVERRIDES_APKS)), no)
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/Contacts/Android.mk),)
#  PRODUCT_PACKAGES += \
#    MtkContacts \
#    MtkSimProcessor
#endif
#endif

##netutils-wrapper
#PRODUCT_PACKAGES += netutils-wrapper-1.0

## Dialer AOSP code will be replaced by MTK
#ifndef MTK_TB_WIFI_3G_MODE
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/Dialer/Android.mk),)
#  PRODUCT_PACKAGES += MtkDialer
#endif
#endif
#
## CalendarProvider AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/providers/CalendarProvider/Android.mk),)
#  PRODUCT_PACKAGES += MtkCalendarProvider
#endif
#
## Calendar AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/Calendar/Android.mk),)
#  PRODUCT_PACKAGES += MtkCalendar
#endif
#
## AOSP DeskClock code will be replaced with MtkDeskClock when vendor code is available
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/DeskClock/Android.mk),)
#  PRODUCT_PACKAGES += MtkDeskClock
#endif
#
## SystemUI AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/SystemUI/Android.bp),)
#  PRODUCT_PACKAGES += MtkSystemUI
#endif

# FrameworkResOverlay
PRODUCT_PACKAGES += FrameworkResOverlay

# SettingProviderOverlay
ifeq ($(strip $(MTK_GMO_RAM_OPTIMIZE)), yes)
    PRODUCT_PACKAGES += SettingProviderOverlay
endif

ifneq ($(strip $(MTK_BASIC_PACKAGE)), yes)
  # privapp-permissions whitelisting
  PRODUCT_PROPERTY_OVERRIDES += ro.control_privapp_permissions=enforce
  # Configuration files for mediatek apps
  #PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,vendor/mediatek/proprietary/frameworks/base/data/etc/privapp-permissions-mediatek.xml:system/etc/permissions/privapp-permissions-mediatek.xml)
endif

## MMSService AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/services/Mms/Android.bp),)
#  PRODUCT_PACKAGES += MtkMmsService
#endif
#
## TelephonyProvider AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/providers/TelephonyProvider/Android.bp),)
#  PRODUCT_PACKAGES += MtkTelephonyProvider
#endif

## Use Mtk Gallery to override AOSP Gallery
#    PRODUCT_PACKAGES += Gallery2
#    PRODUCT_PACKAGES += MtkGallery2
#    PRODUCT_PACKAGES += Gallery2Root
#    PRODUCT_PACKAGES += Gallery2Drm
#    PRODUCT_PACKAGES += Gallery2Gif
#    PRODUCT_PACKAGES += Gallery2Pq
#    PRODUCT_PACKAGES += Gallery2PqTool
#    PRODUCT_PACKAGES += Gallery2Raw
#    PRODUCT_PACKAGES += libjni_stereoinfoaccessor
#    PRODUCT_PACKAGES += libstereoinfoaccessor
#
#ifeq ($(strip $(MTK_CAM_IMAGE_REFOCUS_SUPPORT)),yes)
#    PRODUCT_PACKAGES += Gallery2StereoEntry
#    PRODUCT_PACKAGES += Gallery2StereoCopyPaste
#    PRODUCT_PACKAGES += Gallery2StereoBackground
#    PRODUCT_PACKAGES += Gallery2StereoFancyColor
#    PRODUCT_PACKAGES += Gallery2StereoRefocus
#    PRODUCT_PACKAGES += Gallery2PhotoPicker
#    PRODUCT_PACKAGES += Gallery2StereoFreeview3D
#    PRODUCT_PACKAGES += libjni_stereoapplication
#    PRODUCT_PACKAGES += libjni_depthgenerator
#    PRODUCT_PACKAGES += libjni_fancycolor
#    PRODUCT_PACKAGES += libjni_freeview
#    PRODUCT_PACKAGES += libjni_imagerefocus
#    PRODUCT_PACKAGES += libjni_imagesegment
#endif
#
## Support stereo thumbnail feature
#ifeq ($(strip $(MTK_CAM_STEREO_CAMERA_SUPPORT)),yes)
#    PRODUCT_PACKAGES += Gallery2StereoThumbnail
#endif
#
## DownloadProvider AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/providers/DownloadProvider/Android.mk),)
#  PRODUCT_PACKAGES += MtkDownloadProvider
#endif
#
## DownloadProviderUi AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/providers/DownloadProvider/ui/Android.mk),)
#  PRODUCT_PACKAGES += MtkDownloadProviderUi
#endif
#
## DownloadProviderTests AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/providers/DownloadProvider/tests/Android.mk),)
#  PRODUCT_PACKAGES += MtkDownloadProviderTests
#endif
#
## DocumentsUI AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/DocumentsUI/Android.mk),)
#  PRODUCT_PACKAGES += MtkDocumentsUI
#endif
#
## DocumentsUIAppPerfTests AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/DocumentsUI/app-perf-tests/Android.mk),)
#  PRODUCT_PACKAGES += MtkDocumentsUIAppPerfTests
#endif
#
## DocumentsUIPerfTests AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/DocumentsUI/perf-tests/Android.mk),)
#  PRODUCT_PACKAGES += MtkDocumentsUIPerfTests
#endif
#
## DocumentsUITests AOSP code will be replaced by MTK
#ifneq ($(wildcard vendor/mediatek/proprietary/packages/apps/DocumentsUI/tests/Android.mk),)
#  PRODUCT_PACKAGES += MtkDocumentsUITests
#endif
#
##MtkSettings override AOSP Settings
#ifneq ($(strip $(MTK_OVERRIDES_APKS)), no)
#  PRODUCT_PACKAGES += MtkSettings
#endif
#
##MtkSettingsProvider override AOSP SettingsProvider
#ifneq ($(strip $(MTK_OVERRIDES_APKS)), no)
#  PRODUCT_PACKAGES += MtkSettingsProvider
#endif
#
##MtkBluetooth override AOSP Bluetooth
#ifneq ($(strip $(MTK_OVERRIDES_APKS)), no)
#  PRODUCT_PACKAGES += MtkBluetooth
#endif

# vibrator HAL
PRODUCT_PACKAGES += \
        android.hardware.vibrator@1.0-impl
ifneq ($(strip $(MTK_HIDL_PROCESS_CONSOLIDATION_ENABLED)), yes)
ifneq ($(strip $(MTK_GMO_RAM_OPTIMIZE)), yes)
    PRODUCT_PACKAGES += android.hardware.vibrator@1.0-service
else
    PRODUCT_PACKAGES += android.hardware.vibrator@1.0-service-lazy
endif
endif

# light HAL
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-impl-mediatek

ifneq ($(strip $(MTK_GMO_RAM_OPTIMIZE)), yes)
    PRODUCT_PACKAGES += android.hardware.light@2.0-service-mediatek
else
    PRODUCT_PACKAGES += android.hardware.light@2.0-service-mediatek-lazy
endif

ifeq ($(strip $(CUSTOM_KERNEL_BIOMETRIC_SENSOR)),yes)
  PRODUCT_PACKAGES += biosensord_nvram
  PRODUCT_PACKAGES += libbiosensor
endif

## MtkSystemServices for decouple AOSP systemserver
#PRODUCT_PACKAGES += mediatek-services

## Framework add on for net modules
#ifneq ($(wildcard vendor/mediatek/proprietary/frameworks/opt/net/services/Android.mk),)
#    PRODUCT_PACKAGES += mediatek-framework-net
#endif

## move proprietary mount point to vendor
#PRODUCT_PACKAGES += gen_mount_point_for_ab

#PRODUCT_PACKAGES += MusicBspPlus


# Presence
ifeq ($(strip $(MTK_UCE_SUPPORT)), yes)
   PRODUCT_PACKAGES += \
     Presence \
     volte_uce_ua \
     vendor.mediatek.hardware.presence@1.0.so
#  PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.vendor.mtk_uce_support=1
   DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_presence.xml
endif

# Rcs UA
ifeq ($(strip $(MTK_RCS_UA_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_rcs_ua_support=1
  PRODUCT_PACKAGES += \
    volte_rcs_ua \
    vendor.mediatek.hardware.rcs@1.0.so \
    rcs_volte_stack \
    librcs_volte_core  \
    librcs_interface
  DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_rcs.xml
endif

#Client API feature
ifeq ($(strip $(MTK_VZW_CLIENT_API)),yes)
  PRODUCT_PACKAGES += volte_clientapi_ua
  PRODUCT_PACKAGES += vendor.mediatek.hardware.clientapi@1.0.so
  DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_clientapi.xml
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.clientapi_support=1
endif

## adb_r
#ifeq ($(strip $(MTK_BUILD_ROOT)), yes)
#  PRODUCT_PACKAGES += adbd_r
#endif

ifeq ($(strip $(MTK_HIDL_PROCESS_CONSOLIDATION_ENABLED)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_hidl_consolidation=1
endif

# Camera app
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_camera_app_version=$(strip $(MTK_CAMERA_APP_VERSION))

# For Smart Data Switch Support
ifeq ($(strip $(MTK_TEMPORARY_DATA_SUPPORT)), yes)
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.smart.data.switch=1
endif

# For IWLAN operation mode
ifneq ($(strip $(MTK_RIL_MODE)), c6m_1rild)
    PRODUCT_PROPERTY_OVERRIDES += ro.telephony.iwlan_operation_mode=legacy
else
    PRODUCT_PROPERTY_OVERRIDES += ro.telephony.iwlan_operation_mode=default
    #PRODUCT_PROPERTY_OVERRIDES += ro.telephony.iwlan_operation_mode=legacy
endif

PRODUCT_PACKAGES += check-mtk-hidl

# MPE
ifeq ($(strip $(MTK_MPE_SUPPORT)),yes)
PRODUCT_COPY_FILES += vendor/mediatek/proprietary/hardware/connectivity/gps/mtk_mnld/etc/mpe.conf:$(TARGET_COPY_OUT_VENDOR)/etc/mpe.conf:mtk
endif

## For Full Screen Switch
#ifeq ($(strip $(MTK_FULLSCREEN_SWITCH_SUPPORT)), yes)
#    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.fullscreen_switch=1
#    PRODUCT_PACKAGES += FullscreenSwitchService
#    PRODUCT_PACKAGES += FullscreenMode
#    PRODUCT_PACKAGES += FullscreenSwitchProvider
#endif

# Add Identity
TARGET_BOOTLOADER_BOARD_NAME := $(MTK_BASE_PROJECT)

# CONNSYS Log Feature Support
ifeq ($(strip $(MTK_CONNSYS_DEDICATED_LOG_PATH)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.connsys.dedicated.log=1
endif

# Only build ATCI when it's eng/userdebug load, internal user load, or EM ATCI forcely enabled
# Except for atcid which is needed by ATM
PRODUCT_PACKAGES += atcid
PRODUCT_PACKAGES += vendor.mediatek.hardware.atci@1.0.so
ifneq ($(TARGET_BUILD_VARIANT),user)
    PRODUCT_PACKAGES += atci_service
    #PRODUCT_PACKAGES += atci_service_sys
    PRODUCT_PACKAGES += libatciserv_jni
    #PRODUCT_PACKAGES += AtciService
else
    ifneq ($(wildcard vendor/mediatek/internal/em_enable),)
        PRODUCT_PACKAGES += atci_service
        #PRODUCT_PACKAGES += atci_service_sys
        PRODUCT_PACKAGES += libatciserv_jni
        #PRODUCT_PACKAGES += AtciService
    else
        ifeq ($(strip $(MTK_CUSTOM_USERLOAD_ENGINEERMODE)), yes)
            PRODUCT_PACKAGES += atci_service
            #PRODUCT_PACKAGES += atci_service_sys
            PRODUCT_PACKAGES += libatciserv_jni
            #PRODUCT_PACKAGES += AtciService
        endif
    endif
endif

#MTK_AVB_IMG_RELEASE_AUTH = yes

## setup dm-verity configs.
#MAIN_VBMETA_IN_BOOT := no
#PRODUCT_SHIPPING_API_LEVEL := $(strip $(word 1,$(PRODUCT_SHIPPING_API_LEVEL)))
#ifeq (-4.9,$(findstring -4.9,$(LINUX_KERNEL_VERSION)))
#    BOARD_AVB_ENABLE := true
#
#    # Migrate vboot1.0 to avb2.0 for Android P Treble system-as-root feature
#    # Only need to set MAIN_VBMETA_IN_BOOT as true for O OTA to P project which is kernel-4.9/kernel-4.14 and does not enable avb2.0 in O
#    ifneq ($(call math_lt,$(PRODUCT_SHIPPING_API_LEVEL),28),)
#        # If O enable AVB20, set MAIN_VBMETA_IN_BOOT_OVERRIDE to no
#        ifneq ($(MAIN_VBMETA_IN_BOOT_OVERRIDE),)
#            MAIN_VBMETA_IN_BOOT := $(MAIN_VBMETA_IN_BOOT_OVERRIDE)
#        else
#            MAIN_VBMETA_IN_BOOT := yes
#        endif
#    endif
#else ifeq (-4.14,$(findstring -4.14,$(LINUX_KERNEL_VERSION)))
#    BOARD_AVB_ENABLE := true
#
#    # Migrate vboot1.0 to avb2.0 for Android P Treble system-as-root feature
#    # Only need to set MAIN_VBMETA_IN_BOOT as true for O OTA to P project which is kernel-4.9/kernel-4.14 and does not enable avb2.0 in O
#    ifneq ($(call math_lt,$(PRODUCT_SHIPPING_API_LEVEL),28),)
#        # If O enable AVB20, set MAIN_VBMETA_IN_BOOT_OVERRIDE to no
#        ifneq ($(MAIN_VBMETA_IN_BOOT_OVERRIDE),)
#            MAIN_VBMETA_IN_BOOT := $(MAIN_VBMETA_IN_BOOT_OVERRIDE)
#        else
#            MAIN_VBMETA_IN_BOOT := yes
#        endif
#    endif
#endif
#    PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/platform/bootdevice/by-name/system

     PRODUCT_VENDOR_VERITY_PARTITION := /dev/block/platform/bootdevice/by-name/vendor

#settings for main vbmeta
BOARD_AVB_ENABLE ?= true

ifneq ($(strip $(BOARD_AVB_ENABLE)), true)
    # if avb2.0 is not enabled
    $(call inherit-product, build/target/product/verity.mk)
endif
#else
#    # if avb2.0 is enabled
#    # BOARD_BOOTIMAGE_PARTITION_SIZE and BOARD_RECOVERYIMAGE_PARTITION_SIZE
#    # are essential to avb2.0 and must be set correctly.
#
#    #settings for main vbmeta
#    BOARD_AVB_ALGORITHM := SHA256_RSA2048
#    BOARD_AVB_KEY_PATH := $(LOCAL_PATH)/oem_prvk.pem
#
#ifeq ($(strip $(MAIN_VBMETA_IN_BOOT)),no)
#    #settings for recovery, which is configured as chain partition
#    BOARD_AVB_RECOVERY_KEY_PATH := $(LOCAL_PATH)/recovery_prvk.pem
#    BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
#    BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 0
#    # Always assign "1" to BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION
#    # if MTK_OTP_FRAMEWORK_V2 is turned on in LK. In other words,
#    # rollback_index_location "1" can only be assigned to
#    # recovery partition.
#    BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
#endif
#
#    #settings for system, which is configured as chain partition
#    BOARD_AVB_SYSTEM_KEY_PATH := $(LOCAL_PATH)/system_prvk.pem
#    BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
#    BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
#    BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
#endif

# MTK Single Image
PRODUCT_MTK_RSC_ROOT_PATH ?= etc/rsc
ifeq ($(wildcard vendor/mediatek/internal/build vendor/mediatek/libs_internal),vendor/mediatek/internal/build vendor/mediatek/libs_internal)
CURRENT_RSC_NAMES := $(PRODUCT_MTK_RSC_NAMES)
else
CURRENT_RSC_NAMES := $(PRODUCT_CUSTOMER_RSC_NAMES)
endif
$(foreach mk,$(CURRENT_RSC_NAMES),\
  $(eval mtk_rsc_name := $(mk))\
  $(eval include device/mediatek/build/tasks/tools/config_mtk_rsc.mk))

ifeq (yes,$(MTK_TINYSYS_SCP_SUPPORT))
PRODUCT_PACKAGES += tinysys-scp
endif

ifeq (yes,$(MTK_AUDIODSP_SUPPORT))
PRODUCT_PACKAGES += tinysys-adsp
endif

ifeq (yes,$(MTK_TINYSYS_SSPM_SUPPORT))
PRODUCT_PACKAGES += tinysys-sspm
endif

# NeuroPilot NN SDK
ifeq ($(strip $(MTK_NN_SDK_SUPPORT)), yes)
#PRODUCT_PACKAGES += libneuropilot
PRODUCT_PACKAGES += libtflite_mtk
#PRODUCT_PACKAGES += libtflite_mtk.vendor
PRODUCT_PACKAGES += libtflite_mtk_static
PRODUCT_PACKAGES += libneuropilot_jni
PRODUCT_PACKAGES += libneuroeara
endif

# NeuroPilot Hal Util
#PRODUCT_PACKAGES += libneuropilot_hal_utils
PRODUCT_PACKAGES += libneuropilot_hal_utils.vendor

ifeq ($(strip $(MTK_IMSI_SWITCH_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_imsi_switch_support=1
endif

##Boot performance
PRODUCT_COPY_FILES += $(LOCAL_PATH)/bootperf.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/bootperf.rc

# App Resolution Tuner
ifeq ($(strip $(MTK_APP_RESOLUTION_TUNER_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.app_resolution_tuner=1
endif

ifeq ($(strip $(MTK_ION_CACHE_OPTIMIZATION)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.mtk_ion_cache_optimization=1
endif

# kernel doesn't have HEH filename encryption
PRODUCT_PROPERTY_OVERRIDES += \
    ro.crypto.volume.filenames_mode=aes-256-cts

# Imgsensor
PRODUCT_PACKAGES_DEBUG += sentest
PRODUCT_PACKAGES_DEBUG += eeprom_test

## camera meta
PRODUCT_PACKAGES_ENG += camtest_metadataconverter
PRODUCT_PACKAGES_ENG += camtest_metadata

#for gralloc test
PRODUCT_PACKAGES_ENG += test_grallocutils

## netlog compress so
#PRODUCT_PACKAGES += libcompress_copy

## For Telepony Assist
#PRODUCT_PACKAGES += MtkTelephonyAssist

#PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.base_build=noah

##Gaming with smooth lte mobile data
ifeq ($(strip $(MTK_GWSD_SUPPORT)), yes)
    PRODUCT_PACKAGES += libgwsd-ril
endif


## CdsInfo
#PRODUCT_PACKAGES_DEBUG += CDS_INFO

PRODUCT_HOST_PACKAGES += \
    ksyms-query \
    mkmntl

# Ambient Light Adaptive Luma
ifeq ($(strip $(MTK_AAL_SUPPORT)), yes)
    PRODUCT_PACKAGES += libaalservice
    PRODUCT_PACKAGES += libaal_cust
    PRODUCT_PACKAGES += libaal_mtk
endif

# PQ HIDL
ifeq (,$(filter $(strip $(MTK_PQ_SUPPORT)), no PQ_OFF))
    DEVICE_MANIFEST_FILE += device/mediatek/vendor/common/project_manifest/manifest_pq.xml
endif
PRODUCT_PACKAGES += \
  vendor.mediatek.hardware.pq@2.2-service \
  vendor.mediatek.hardware.pq@2.3-impl

# MMS HIDL
DEVICE_MANIFEST_FILE += device/mediatek/vendor/common/project_manifest/manifest_mmservice.xml
PRODUCT_PACKAGES += \
  vendor.mediatek.hardware.mms@1.5-service \
  vendor.mediatek.hardware.mms@1.5-impl

# nvram hidl. enable lazy hal on A-GO project to save memory
PRODUCT_PACKAGES += vendor.mediatek.hardware.nvram@1.1-impl

ifeq ($(strip $(MTK_GMO_RAM_OPTIMIZE)), yes)
  PRODUCT_PACKAGES += vendor.mediatek.hardware.nvram@1.1-service-lazy
else
  PRODUCT_PACKAGES += vendor.mediatek.hardware.nvram@1.1-service
endif

# MSI bringup missing package
PRODUCT_PACKAGES += \
    vendor.mediatek.hardware.gpu@1.0-impl \
    vendor.mediatek.hardware.gpu@1.0-service

# Another copy of AOSP root certs for vendor modules like AGPS or XCAP for IMS
ifeq ($(strip $(MTK_AGPS_APP)), yes)
    PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,system/ca-certificates/files,$(TARGET_COPY_OUT_VENDOR)/etc/security/cacerts)
else ifeq ($(strip $(MTK_UT_XCAP_SUPPORT)), yes)
    PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,system/ca-certificates/files,$(TARGET_COPY_OUT_VENDOR)/etc/security/cacerts)
endif

# mtk bt enable SAP profile
ifeq ($(strip $(MTK_BT_SAP_ENABLE)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk.bt_sap_enable=true
endif

# mtk sim switch policy
ifneq ($(strip $(MTK_DISABLE_CAPABILITY_SWITCH)),yes)
    PRODUCT_PROPERTY_OVERRIDES += persist.vendor.mtk_sim_switch_policy=2
endif

ifeq ($(MTK_DYNAMIC_PARTITION_SUPPORT), yes)
PRODUCT_PACKAGES += \
      fastbootd \
      android.hardware.fastboot@1.0-impl-mtk
endif

# Always On Display
ifeq ($(strip $(MTK_AOD_SUPPORT)), yes)
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.mtk_aod_support=1
endif

####################################################################################################
##
## MTK Diagnostic Monitoring Framework
##
## 1. Diagnostic Monitoring Collector (DMC)
##    - MTK_DMC_SUPPORT: Core implementation of DMC in vendor partition.
##    - MSSI_MTK_DMC_SUPPORT: The APM service in system partition, to collect KPI from Android FWK
##
## 2. DMC Application: Modem Analysis Public Interface (MAPI)
##    - MTK_MAPI_SUPPORT: Provide vendor executables for PC diagnostic tool.
##
## 3. DMC Application: Modem Diagnostic Monitoring Interface (MDMI)
##    - MTK_MDMI_SUPPORT: Defines diagnostic translator for MDMI in vendor partition.
##    - MSSI_MDMI_SUPPORT: MDMI libraries defined in GSMA TS.31 in system partition.
##
####################################################################################################
# DMC Framework
# Static JAVA library for ApmService interface,
# which may be linked with common module, built it w/o FO check.

ifeq ($(strip $(MTK_DMC_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_dmc_support=1
    PRODUCT_PACKAGES += dmc_core
    # Packet Monitor
    PRODUCT_PACKAGES += pkm_service
    PRODUCT_PACKAGES += libpkm
    # Shared library which used by dlopen(), so build it explictly
    PRODUCT_PACKAGES += libapmonitor_vendor
    PRODUCT_PACKAGES += libpkm
    # HIDL manifest
    DEVICE_MANIFEST_FILE += device/mediatek/common/project_manifest/manifest_dmc.xml
    DEVICE_MANIFEST_FILE += device/mediatek/common/project_manifest/manifest_apmonitor.xml
endif

# DMC Application: MDMI
ifeq ($(strip $(MTK_MDMI_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_mdmi_support=1
    PRODUCT_PACKAGES += libtranslator_mdmi_v2.8.2
endif

# DMC Application: MAPI
ifeq ($(strip $(MTK_MAPI_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_mapi_support=1
    PRODUCT_PACKAGES += libtranslator_mapi_v3.0
endif

# Diagnostic Monitoring Log Setting
# Set debug level to [I] in default, enable it in EM APP manually
ifeq ($(strip $(MTK_DMC_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DMC-Core=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DMC-TranslatorLoader=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DMC-TranslatorUtils=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DMC-ReqQManager=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DMC-DmcService=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DMC-ApmService=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DMC-SessionManager=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.DMC-EventsSubscriber=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.LCM-Subscriber=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.APM-Subscriber=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDM-Subscriber=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.APM-SessionJ=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.APM-SessionN=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.APM-ServiceJ=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.APM-KpiMonitor=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PKM-MDM=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PKM-Lib=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PKM-Monitor=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PKM-SA=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.PKM-Service=I
endif
ifeq ($(strip $(MTK_MAPI_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MAPI-TranslatorManager=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MAPI-MdiRedirectorCtrl=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MAPI-MdiRedirector=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MAPI-NetworkSocketConnection=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MAPI-SocketConnection=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MAPI-SocketListener=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MAPI-CommandProcessor=I
endif
ifeq ($(strip $(MTK_MDMI_SUPPORT)), yes)
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-TranslatorManager=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-MdmiRedirectorCtrl=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-MdmiRedirector=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-Permission=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-CoreSession=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-NetworkSocketConnection=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-SocketConnection=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-SocketListener=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-CommandProcessor=I
    PRODUCT_PROPERTY_OVERRIDES += persist.log.tag.MDMI-Provider=I
endif

####################################################################################################
## MTK Diagnostic Monitoring Framework End
####################################################################################################

# CTA SUPPORT
# enable this option for cta lab test only.
ifeq ($(strip $(MTK_CTA_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_cta_support=1
endif

#for ts_ufozip in libuvvf
ifeq ($(BUILD_MTK_LDVT), yes)
    PRODUCT_PACKAGES_ENG += ts_ufozip
endif

ifeq ($(strip $(MTK_DYNAMIC_PARTITION_SUPPORT)), yes)
    # Install gsi keys into ramdisk, to boot a GSI with verified boot
    $(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)
endif
PRODUCT_SHIPPING_API_LEVEL := $(firstword $(PRODUCT_SHIPPING_API_LEVEL))

# For performance tuning
ifeq ($(strip $(MTK_PERF_PLUS)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_perf_plus=1
endif

# lazy hal
ifeq ($(strip $(MTK_CAM_LAZY_HAL)), yes)
    PRODUCT_PROPERTY_OVERRIDES += ro.camera.enableLazyHal=true
    PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-service-lazy
endif

####################################################################################################
# From Android Q, GMS devices must preload Google signed Mainline module release
ifeq ($(BUILD_GMS), yes)
    ifneq ($(call math_gt_or_eq,$(PRODUCT_SHIPPING_API_LEVEL),29),)
        # FBE device can support updatable APEX
        # FBE is mandatory for Q new launching device
        # A-Go doesn't support updatable APEX
        ifneq ($(strip $(MTK_GMO_RAM_OPTIMIZE)), yes)
            # Enable updating of APEXes
            $(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)
        else
            PRODUCT_PROPERTY_OVERRIDES += ro.apex.updatable=false
            TARGET_FLATTEN_APEX := true
        endif
    else
        # FDE device cannot support updatable APEX
        # P OTA to Q project may be FDE
        PRODUCT_PROPERTY_OVERRIDES += ro.apex.updatable=false
        TARGET_FLATTEN_APEX := true
    endif
endif

ifneq ($(strip $(MTK_LCM_PHYSICAL_ROTATION)),)
  ifeq ($(strip $(MTK_LCM_PHYSICAL_ROTATION)), 90)
    PRODUCT_PROPERTY_OVERRIDES += ro.surface_flinger.primary_display_orientation=1
  else ifeq ($(strip $(MTK_LCM_PHYSICAL_ROTATION)), 180)
    PRODUCT_PROPERTY_OVERRIDES += ro.surface_flinger.primary_display_orientation=2
  else ifeq ($(strip $(MTK_LCM_PHYSICAL_ROTATION)), 270)
    PRODUCT_PROPERTY_OVERRIDES += ro.surface_flinger.primary_display_orientation=3
  else
    PRODUCT_PROPERTY_OVERRIDES += ro.surface_flinger.primary_display_orientation=0
  endif
endif

#Network Optimization
ifeq ($(strip $(MTK_NWK_OPT_SUPPORT)), yes)
  ifneq ($(wildcard vendor/mediatek/proprietary/hardware/lib_nwk_opt),)
    PRODUCT_PACKAGES += vendor.mediatek.hardware.nwk_opt@1.0-service
    DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_nwk_opt.xml
    PRODUCT_PACKAGES += libnwk_opt_halwrap_vendor
  endif
endif

ifeq ($(strip $(MTK_ENABLE_GENIEZONE)),yes)
PRODUCT_PACKAGES += gz.img
PRODUCT_PACKAGES += gz.bin
endif

#apdb
PRODUCT_PACKAGES += apdb

# Disable USAP pool
PRODUCT_PRODUCT_PROPERTIES += persist.device_config.runtime_native.usap_pool_enabled=false

# identity
PRODUCT_PRODUCT_PROPERTIES += \
    Build.BRAND=MTK

# Enable CFI for security-sensitive components
$(call inherit-product, $(SRC_TARGET_DIR)/product/cfi-common.mk)
$(call inherit-product-if-exists, vendor/google/products/cfi-vendor.mk)

# For VOW 2E2K feature file
# added dependency in relation to libvoicerecognition_jni
ifneq ($(wildcard vendor/mediatek/proprietary/external/voiceunlock2),)
    ifeq ($(strip $(MTK_VOW_2E2K_SUPPORT)),yes)
        PRODUCT_COPY_FILES += $(LOCAL_PATH)/com.mediatek.hardware.vow.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.mediatek.hardware.vow.xml:mtk
    endif
endif

# Add for Capability Test
PRODUCT_PACKAGES += CapabilityTest
PRODUCT_PACKAGES += capability_test
