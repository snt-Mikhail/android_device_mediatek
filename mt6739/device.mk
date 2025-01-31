
# Do not copy rc files before this line !!
# RC files should goto /vendor since O-MR1
MTK_RC_TO_VENDOR = yes
ifeq ($(strip $(MTK_RC_TO_VENDOR)), yes)
  MTK_TARGET_VENDOR_RC = $(TARGET_COPY_OUT_VENDOR)/etc/init/hw
  PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.rc=/vendor/etc/init/hw/
  ifeq ($(strip $(MTK_EMMC_SUPPORT)),yes)
    PRODUCT_COPY_FILES += device/mediatek/mt6739/ueventd.mt6739.emmc.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc
  else ifeq ($(strip $(MTK_UFS_SUPPORT)),yes)
    PRODUCT_COPY_FILES += device/mediatek/mt6739/ueventd.mt6739.ufs.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc
  else ifeq ($(strip $(MNTL_SUPPORT)),yes)
    PRODUCT_COPY_FILES += device/mediatek/mt6739/ueventd.mt6739.nand.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc
  endif
else
  MTK_TARGET_VENDOR_RC = root
  PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.rc=/
  ifeq ($(strip $(MTK_EMMC_SUPPORT)),yes)
    PRODUCT_COPY_FILES += device/mediatek/mt6739/ueventd.mt6739.emmc.rc:root/ueventd.mt6739.rc
  else ifeq ($(strip $(MTK_UFS_SUPPORT)),yes)
    PRODUCT_COPY_FILES += device/mediatek/mt6739/ueventd.mt6739.ufs.rc:root/ueventd.mt6739.rc
  else ifeq ($(strip $(MNTL_SUPPORT)),yes)
    PRODUCT_COPY_FILES += device/mediatek/mt6739/ueventd.mt6739.nand.rc:root/ueventd.mt6739.rc
  endif
endif

# disable system as root by platform
# will move it to common/device.mk after all platform ready
BOARD_BUILD_SYSTEM_ROOT_IMAGE := false

PRODUCT_SUPPORT_DYNAMIC_PARTITION ?= true

# for trustkernel related configurations
ifeq ($(strip $(TRUSTKERNEL_TEE_SUPPORT)), yes)
$(call inherit-product, vendor/mediatek/proprietary/trustzone/trustkernel/source/bsp/platform/common/scripts/device_trustkernel.mk)
endif

PRODUCT_PROPERTY_OVERRIDES += ro.hardware.egl=mtk

# media_profiles.xml for media profile support
ifeq ($(MTK_CAM_STEREO_CAMERA_SUPPORT),yes)
    PRODUCT_COPY_FILES += device/mediatek/mt6739/media_profiles_ducam.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml:mtk
else
    PRODUCT_COPY_FILES += device/mediatek/mt6739/media_profiles.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml:mtk
endif

PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

ifneq ($(strip $(CUSTOM_KERNEL_STEP_COUNTER)),)
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml
endif

# IRTX
ifeq ($(strip $(MTK_IRTX_SUPPORT)),yes)
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.consumerir.xml
PRODUCT_PACKAGES += consumerir.mt6739
PRODUCT_PACKAGES += consumerir.mt6739m
else
# IRTX over PWM
ifeq ($(strip $(MTK_IRTX_PWM_SUPPORT)),yes)
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.consumerir.xml
PRODUCT_PACKAGES += consumerir.mt6739
PRODUCT_PACKAGES += consumerir.mt6739m
else
ifeq ($(strip $(MTK_IR_LEARNING_SUPPORT)),yes)
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.consumerir.xml
PRODUCT_PACKAGES += consumerir.mt6739
PRODUCT_PACKAGES += consumerir.mt6739m
endif
endif
endif


#GPU collection
PRODUCT_PACKAGES += libI420colorconvert
PRODUCT_PACKAGES += libvcodec_utility
PRODUCT_PACKAGES += libvcodec_oal
PRODUCT_PACKAGES += libh264enc_sa.ca7
PRODUCT_PACKAGES += libh264enc_sb.ca7
PRODUCT_PACKAGES += libhevce_sb.ca7.android
PRODUCT_PACKAGES += libHEVCdec_sa.ca7.android
PRODUCT_PACKAGES += libmp4enc_sa.ca7
PRODUCT_PACKAGES += libmp4enc_xa.ca7
PRODUCT_PACKAGES += libvc1dec_sa.ca7
PRODUCT_PACKAGES += libvp8dec_sa.ca7
PRODUCT_PACKAGES += libvp8enc_sa.ca7
PRODUCT_PACKAGES += libvp9dec_sa.ca7
PRODUCT_PACKAGES += libvideoeditorplayer
PRODUCT_PACKAGES += libvideoeditor_osal
PRODUCT_PACKAGES += libvideoeditor_3gpwriter
PRODUCT_PACKAGES += libvideoeditor_mcs
PRODUCT_PACKAGES += libvideoeditor_core
PRODUCT_PACKAGES += libvideoeditor_stagefrightshells
PRODUCT_PACKAGES += libvideoeditor_videofilters
PRODUCT_PACKAGES += libvideoeditor_jni
PRODUCT_PACKAGES += audio.primary.default
PRODUCT_PACKAGES += audio.primary.mt6739
PRODUCT_PACKAGES += sound_trigger.primary.mt6739
PRODUCT_PACKAGES += audio.primary.mt6739m
PRODUCT_PACKAGES += audio.primary.mt6753
PRODUCT_PACKAGES += audio_policy.stub
PRODUCT_PACKAGES += local_time.default
PRODUCT_PACKAGES += libaudiocustparam
#PRODUCT_PACKAGES += libaudiocomponentengine
PRODUCT_PACKAGES += libaudiocomponentengine_vendor
PRODUCT_PACKAGES += libh264dec_xa.ca9
PRODUCT_PACKAGES += libh264dec_xb.ca9
PRODUCT_PACKAGES += libh264dec_sa.ca7
PRODUCT_PACKAGES += libh264dec_sd.ca7
PRODUCT_PACKAGES += libh264dec_se.ca7
PRODUCT_PACKAGES += libh264dec_customize
PRODUCT_PACKAGES += libmp4dec_sa.ca9
PRODUCT_PACKAGES += libmp4dec_sb.ca9
PRODUCT_PACKAGES += libmp4dec_customize
PRODUCT_PACKAGES += libvp8dec_xa.ca9
PRODUCT_PACKAGES += libmp4enc_xa.ca9
PRODUCT_PACKAGES += libmp4enc_xb.ca9
PRODUCT_PACKAGES += libh264enc_sa.ca9
PRODUCT_PACKAGES += libh264enc_sb.ca9
PRODUCT_PACKAGES += libvcodec_oal
PRODUCT_PACKAGES += libvc1dec_sa.ca9
PRODUCT_PACKAGES += liblic_divx
PRODUCT_PACKAGES += liblic_s263
PRODUCT_PACKAGES += init.factory.rc
PRODUCT_PACKAGES += libaudio.primary.default
PRODUCT_PACKAGES += audio_policy.default
PRODUCT_PACKAGES += audio_policy.mt6739
PRODUCT_PACKAGES += libaudio.a2dp.default
PRODUCT_PACKAGES += libMtkVideoTranscoder
PRODUCT_PACKAGES += libMtkOmxCore
PRODUCT_PACKAGES += libMtkOmxOsalUtils
PRODUCT_PACKAGES += libMtkOmxVdecEx
PRODUCT_PACKAGES += libMtkOmxVenc
#PRODUCT_PACKAGES += libaudiodcrflt
PRODUCT_PACKAGES += libaudiosetting
#PRODUCT_PACKAGES += librtp_jni
PRODUCT_PACKAGES += mfv_ut
PRODUCT_PACKAGES += libstagefrighthw
PRODUCT_PACKAGES += libstagefright_memutil
PRODUCT_PACKAGES += factory.ini
PRODUCT_PACKAGES += libmtdutil
PRODUCT_PACKAGES += libminiui
PRODUCT_PACKAGES += factory
PRODUCT_PACKAGES += drvbd
PRODUCT_PACKAGES += libaudio.usb.default
PRODUCT_PACKAGES += audio.usb.default
PRODUCT_PACKAGES += audio.usb.mt6739
PRODUCT_PACKAGES += audio.usb.mt6739m
PRODUCT_PACKAGES += audio.usb.mt6753
PRODUCT_PACKAGES += AccountAndSyncSettings
#PRODUCT_PACKAGES += DeskClock
PRODUCT_PACKAGES += AlarmProvider
#PRODUCT_PACKAGES += Bluetooth
PRODUCT_PACKAGES += Calculator
#PRODUCT_PACKAGES += Calendar
#PRODUCT_PACKAGES += CertInstaller
ifeq ($(strip $(MTK_OMADRM_SUPPORT)), yes)
  #PRODUCT_PACKAGES += DrmProvider
endif
#PRODUCT_PACKAGES += Email
#PRODUCT_PACKAGES += FusedLocation
#PRODUCT_PACKAGES += TelephonyProvider
#PRODUCT_PACKAGES += LatinIME
#PRODUCT_PACKAGES += Music
#PRODUCT_PACKAGES += MusicFX
#PRODUCT_PACKAGES += Protips
#PRODUCT_PACKAGES += Settings
PRODUCT_PACKAGES += Sync
#PRODUCT_PACKAGES += SystemUI
#PRODUCT_PACKAGES += Updater
#PRODUCT_PACKAGES += CalendarProvider
PRODUCT_PACKAGES += ccci_mdinit
PRODUCT_PACKAGES += ccci_fsd
PRODUCT_PACKAGES += ccci_rpcd
#PRODUCT_PACKAGES += batterywarning
PRODUCT_PACKAGES += SyncProvider
PRODUCT_PACKAGES += disableapplist.txt
PRODUCT_PACKAGES += resmonwhitelist.txt
ifeq ($(strip $(MTK_GMO_RAM_OPTIMIZE)),yes)
else
    #PRODUCT_PACKAGES += MTKThermalManager
    #PRODUCT_PACKAGES += thermald
endif
PRODUCT_PACKAGES += libmtcloader
PRODUCT_PACKAGES += thermal_manager
PRODUCT_PACKAGES += thermal
PRODUCT_PACKAGES += thermal.mt6739
PRODUCT_PACKAGES += thermalloadalgod
PRODUCT_PACKAGES += libthermalalgo
PRODUCT_PACKAGES += CellConnService
ifneq ($(strip $(OPTR_SPEC_SEG_DEF)),NONE)
    PRODUCT_PACKAGES += MTKAndroidSuiteDaemon
endif
PRODUCT_PACKAGES += libthha
PRODUCT_PACKAGES += ami304d
PRODUCT_PACKAGES += akmd8963
PRODUCT_PACKAGES += akmd09911
PRODUCT_PACKAGES += akmd09912
PRODUCT_PACKAGES += akmd09918
PRODUCT_PACKAGES += akmd8975
PRODUCT_PACKAGES += istd8303
PRODUCT_PACKAGES += AcdApiDaemon
PRODUCT_PACKAGES += calib.dat
PRODUCT_PACKAGES += param.dat
PRODUCT_PACKAGES += sensors.dat
PRODUCT_PACKAGES += geomagneticd
PRODUCT_PACKAGES += orientationd
PRODUCT_PACKAGES += memsicd
PRODUCT_PACKAGES += msensord
PRODUCT_PACKAGES += lsm303md
PRODUCT_PACKAGES += memsicd3416x
PRODUCT_PACKAGES += s62xd smartsensor
PRODUCT_PACKAGES += bmm050d
PRODUCT_PACKAGES += mc6420d
PRODUCT_PACKAGES += magd
PRODUCT_PACKAGES += sensors.mt6739
PRODUCT_PACKAGES += sensors.mt6739m
PRODUCT_PACKAGES += sensors.mt6753
PRODUCT_PACKAGES += libhwm
PRODUCT_PACKAGES += lights.mt6739
PRODUCT_PACKAGES += lights.mt6739m
PRODUCT_PACKAGES += lights.mt6753
$(foreach custom_hal_msensorlib,$(CUSTOM_HAL_MSENSORLIB),$(eval PRODUCT_PACKAGES += lib$(custom_hal_msensorlib)))
PRODUCT_PACKAGES += meta_tst
PRODUCT_PACKAGES += multi_init
#PRODUCT_PACKAGES += GoogleOtaBinder
PRODUCT_PACKAGES += dhcp6c
PRODUCT_PACKAGES += dhcp6ctl
PRODUCT_PACKAGES += dhcp6c.conf
PRODUCT_PACKAGES += dhcp6cDNS.conf
PRODUCT_PACKAGES += dhcp6s
PRODUCT_PACKAGES += dhcp6s.conf
PRODUCT_PACKAGES += dhcp6c.script
PRODUCT_PACKAGES += dhcp6cctlkey
#PRODUCT_PACKAGES += libblisrc
PRODUCT_PACKAGES += libifaddrs
PRODUCT_PACKAGES += libmobilelog_jni
PRODUCT_PACKAGES += audio.r_submix.default
PRODUCT_PACKAGES += audio.r_submix.mt6739
PRODUCT_PACKAGES += audio.r_submix.mt6739m
PRODUCT_PACKAGES += libaudio.usb.default
#PRODUCT_PACKAGES += libnbaio
#PRODUCT_PACKAGES += libaudioflinger
PRODUCT_PACKAGES += libmeta_audio
PRODUCT_PACKAGES += liba3m
PRODUCT_PACKAGES += libja3m
PRODUCT_PACKAGES += libmmprofile
PRODUCT_PACKAGES += libmmprofile_jni
PRODUCT_PACKAGES += libtvoutjni
PRODUCT_PACKAGES += libtvoutpattern
PRODUCT_PACKAGES += libmtkhdmi_jni
PRODUCT_PACKAGES += libmtkcam_modulefactory_custom
PRODUCT_PACKAGES += libmtkcam_modulefactory_drv
PRODUCT_PACKAGES += libmtkcam_modulefactory_aaa
PRODUCT_PACKAGES += libmtkcam_modulefactory_feature
PRODUCT_PACKAGES += libmtkcam_modulefactory_utils
PRODUCT_PACKAGES += libcam_platform
PRODUCT_PACKAGES += camerahalserver
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-service-mediatek
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-impl-mediatek
PRODUCT_PACKAGES += libmtkcam_device1
PRODUCT_PACKAGES += libmtkcam_device3
PRODUCT_PACKAGES += camera.mt6739
PRODUCT_PACKAGES += camera.mt6753
PRODUCT_PACKAGES += camera.mt6739m
PRODUCT_PACKAGES_ENG += iopipeTest
PRODUCT_PACKAGES += xlog
#PRODUCT_PACKAGES += liblog
PRODUCT_PACKAGES += shutdown
PRODUCT_PACKAGES += muxreport
PRODUCT_PACKAGES += mtkrild
PRODUCT_PACKAGES += mtk-ril
PRODUCT_PACKAGES += librilmtk
PRODUCT_PACKAGES += libutilrilmtk
PRODUCT_PACKAGES += gsm0710muxd
PRODUCT_PACKAGES += mtkrildmd2
PRODUCT_PACKAGES += mtk-rilmd2
PRODUCT_PACKAGES += librilmtkmd2
PRODUCT_PACKAGES += gsm0710muxdmd2
PRODUCT_PACKAGES += md_minilog_util
#PRODUCT_PACKAGES += wbxml
PRODUCT_PACKAGES += wappush
PRODUCT_PACKAGES += thememap.xml
PRODUCT_PACKAGES += libBLPP.so
PRODUCT_PACKAGES += rc.fac
PRODUCT_PACKAGES += mtkGD
#PRODUCT_PACKAGES += libdrm
PRODUCT_PACKAGES += libdrm.vendor
PRODUCT_PACKAGES += libGLES_meow
PRODUCT_PACKAGES += libMEOW_trace
PRODUCT_PACKAGES += libclangIMG
PRODUCT_PACKAGES += libEGL_mtk
PRODUCT_PACKAGES += libGLESv1_CM_mtk
PRODUCT_PACKAGES += libGLESv2_mtk
PRODUCT_PACKAGES += libglslcompiler
PRODUCT_PACKAGES += libIMGegl
PRODUCT_PACKAGES += libLLVMIMG
PRODUCT_PACKAGES += libmemtrack_GL
PRODUCT_PACKAGES += liboclcompiler
PRODUCT_PACKAGES += libpvrANDROID_WSEGL
PRODUCT_PACKAGES += libPVROCL
PRODUCT_PACKAGES += libPVRScopeServices
PRODUCT_PACKAGES += libsrv_um
PRODUCT_PACKAGES += libmpvr
PRODUCT_PACKAGES += libufwriter
PRODUCT_PACKAGES += libusc
PRODUCT_PACKAGES += libtqvalidate
PRODUCT_PACKAGES += pvrsrvctl
PRODUCT_PACKAGES += rgx.fw
PRODUCT_PACKAGES += thermalindicator
PRODUCT_PACKAGES += libged
ifneq ($(MTK_BASIC_PACKAGE), yes)
  PRODUCT_PACKAGES += libgas
endif
PRODUCT_PACKAGES += libFraunhoferAAC
PRODUCT_PACKAGES += audiocmdservice_atci
PRODUCT_PACKAGES += libMtkOmxAudioEncBase
PRODUCT_PACKAGES += libMtkOmxAmrEnc
PRODUCT_PACKAGES += libMtkOmxAwbEnc
PRODUCT_PACKAGES += libMtkOmxAacEnc
PRODUCT_PACKAGES += libMtkOmxVorbisEnc
PRODUCT_PACKAGES += libMtkOmxAdpcmEnc
PRODUCT_PACKAGES += libMtkOmxMp3Dec
PRODUCT_PACKAGES += libMtkOmxGsmDec
PRODUCT_PACKAGES += libMtkOmxAacDec
PRODUCT_PACKAGES += libMtkOmxG711Dec
PRODUCT_PACKAGES += libMtkOmxVorbisDec
PRODUCT_PACKAGES += libMtkOmxAudioDecBase
PRODUCT_PACKAGES += libMtkOmxAdpcmDec
PRODUCT_PACKAGES += libMtkOmxRawDec
PRODUCT_PACKAGES += libMtkOmxAMRNBDec
PRODUCT_PACKAGES += libMtkOmxAMRWBDec
#PRODUCT_PACKAGES += libvoicerecognition_jni
#PRODUCT_PACKAGES += libvoicerecognition
PRODUCT_PACKAGES += libphonemotiondetector_jni
PRODUCT_PACKAGES += libphonemotiondetector
PRODUCT_PACKAGES += libmotionrecognition
PRODUCT_PACKAGES += audio.primary.default
PRODUCT_PACKAGES += audio_policy.stub
PRODUCT_PACKAGES += audio_policy.default
PRODUCT_PACKAGES += libaudio.primary.default
PRODUCT_PACKAGES += libaudio.a2dp.default
#PRODUCT_PACKAGES += audio.a2dp.default
#PRODUCT_PACKAGES += libaudio-resampler
PRODUCT_PACKAGES += local_time.default
PRODUCT_PACKAGES += libaudiocustparam
#PRODUCT_PACKAGES += libaudiodcrflt
PRODUCT_PACKAGES += libaudiosetting
#PRODUCT_PACKAGES += librtp_jni
PRODUCT_PACKAGES += libmatv_cust
#PRODUCT_PACKAGES += libmtkplayer
PRODUCT_PACKAGES += libatvctrlservice
PRODUCT_PACKAGES += matv
PRODUCT_PACKAGES += libMtkOmxApeDec
PRODUCT_PACKAGES += libMtkOmxFlacDec
PRODUCT_PACKAGES += ppp_dt
PRODUCT_PACKAGES += power.mt6739
PRODUCT_PACKAGES += android.hardware.power@1.3-impl-mediatek
PRODUCT_PACKAGES += vendor.mediatek.hardware.power@2.1-impl
PRODUCT_PACKAGES += vendor.mediatek.hardware.mtkpower@1.0-impl
PRODUCT_PACKAGES += vendor.mediatek.hardware.mtkpower@1.0-service
PRODUCT_PACKAGES += libdiagnose
PRODUCT_PACKAGES += MPED
PRODUCT_PACKAGES += libmpe.sensorlistener.so
PRODUCT_PACKAGES += libmpe.driver.so
PRODUCT_PACKAGES += libfusion.so
PRODUCT_PACKAGES += libDR.so
#PRODUCT_PACKAGES += libsonivox
PRODUCT_PACKAGES += iAmCdRom.iso
PRODUCT_PACKAGES += libmemorydumper
PRODUCT_PACKAGES += memorydumper
PRODUCT_PACKAGES += libvt_custom
PRODUCT_PACKAGES += libamrvt
PRODUCT_PACKAGES += libvtmal
PRODUCT_PACKAGES += libipsec_ims
#PRODUCT_PACKAGES += racoon
PRODUCT_PACKAGES += libipsec
#PRODUCT_PACKAGES += libpcap
#PRODUCT_PACKAGES += mtpd
PRODUCT_PACKAGES += netcfg
#PRODUCT_PACKAGES += pppd
PRODUCT_PACKAGES += pppd_via
PRODUCT_PACKAGES += pppd_dt
PRODUCT_PACKAGES += dhcpcd
PRODUCT_PACKAGES += dhcpcd.conf
PRODUCT_PACKAGES += dhcpcd-run-hooks
PRODUCT_PACKAGES += 20-dns.conf
PRODUCT_PACKAGES += 95-configured
PRODUCT_PACKAGES += radvd
PRODUCT_PACKAGES += radvd.conf
#PRODUCT_PACKAGES += dnsmasq
#PRODUCT_PACKAGES += netd
#PRODUCT_PACKAGES += ndc
#PRODUCT_PACKAGES += libiprouteutil
#PRODUCT_PACKAGES += libnetlink
#PRODUCT_PACKAGES += tc
#PRODUCT_PACKAGES += libext2_profile
#PRODUCT_PACKAGES += e2fsck
#PRODUCT_PACKAGES += libext2_blkid
#PRODUCT_PACKAGES += libext2_e2p
#PRODUCT_PACKAGES += libext2_com_err
#PRODUCT_PACKAGES += libext2fs
#PRODUCT_PACKAGES += libext2_uuid
#PRODUCT_PACKAGES += mke2fs
#PRODUCT_PACKAGES += tune2fs
#PRODUCT_PACKAGES += badblocks
#PRODUCT_PACKAGES += resize2fs
PRODUCT_PACKAGES += resize.f2fs
PRODUCT_PACKAGES += libnvram
PRODUCT_PACKAGES += libnvram_daemon_callback
PRODUCT_PACKAGES += libfile_op
PRODUCT_PACKAGES += nvram_daemon
PRODUCT_PACKAGES += make_ext4fs
#PRODUCT_PACKAGES += sdcard
PRODUCT_PACKAGES += libext
PRODUCT_PACKAGES += libext4
PRODUCT_PACKAGES += libext6
PRODUCT_PACKAGES += libxtables
PRODUCT_PACKAGES += libip4tc
PRODUCT_PACKAGES += libip6tc
PRODUCT_PACKAGES += ipod
PRODUCT_PACKAGES += libipod
PRODUCT_PACKAGES += fuelgauged
PRODUCT_PACKAGES += fuelgauged_nvram
ifeq ($(MTK_GAUGE_VERSION), 30)
PRODUCT_PACKAGES += libfgauge_gm30
else
PRODUCT_PACKAGES += libfgauge
endif
PRODUCT_PACKAGES += android.hardware.health@2.0-service
PRODUCT_PACKAGES += android.hardware.health@2.0-service.override
#DEVICE_FRAMEWORK_MANIFEST_FILE += \
#    system/libhidl/vintfdata/manifest_healthd_exclude.xml
PRODUCT_PACKAGES += gatord
PRODUCT_PACKAGES += gator.ko
#PRODUCT_PACKAGES += boot_logo_updater
PRODUCT_PACKAGES += boot_logo
#PRODUCT_PACKAGES += bootanimation
#PRODUCT_PACKAGES += kpoc_charger
PRODUCT_PACKAGES += libtvoutjni
PRODUCT_PACKAGES += libtvoutpattern
PRODUCT_PACKAGES += libmtkhdmi_jni
PRODUCT_PACKAGES += libhissage.so
PRODUCT_PACKAGES += libhpe.so
PRODUCT_PACKAGES += sdiotool
PRODUCT_PACKAGES += superumount
PRODUCT_PACKAGES += libsched
PRODUCT_PACKAGES += fsck_msdos_mtk
PRODUCT_PACKAGES += cmmbsp
PRODUCT_PACKAGES += libcmmb_jni
PRODUCT_PACKAGES += robotium
PRODUCT_PACKAGES += libc_malloc_debug_mtk
PRODUCT_PACKAGES += dpfd
PRODUCT_PACKAGES += SchedulePowerOnOff
PRODUCT_PACKAGES += BatteryWarning
PRODUCT_PACKAGES += pq
PRODUCT_PACKAGES += libpq_cust_base
PRODUCT_PACKAGES += libpq_cust_base_mtk
PRODUCT_PACKAGES += libpq_cust
PRODUCT_PACKAGES += libpq_cust_mtk
PRODUCT_PACKAGES += librgbwlightsensor
#PRODUCT_PACKAGES += libPQjni
#PRODUCT_PACKAGES += libPQDCjni
#PRODUCT_PACKAGES += MiraVision
#PRODUCT_PACKAGES += libMiraVision_jni
PRODUCT_PACKAGES += hald
PRODUCT_PACKAGES += dmlog
PRODUCT_PACKAGES += mtk_msr.ko
PRODUCT_PACKAGES += send_bug
#PRODUCT_PACKAGES += met-cmd
PRODUCT_PACKAGES += libmet-tag
#PRODUCT_PACKAGES += met_log_d
PRODUCT_PACKAGES += met.ko
PRODUCT_PACKAGES += met_plf.ko
PRODUCT_PACKAGES += trace-cmd
PRODUCT_PACKAGES += libMtkOmxRawDec
PRODUCT_PACKAGES += libfbc
PRODUCT_PACKAGES += libpowerhal
#PRODUCT_PACKAGES += libpowerhalctl
PRODUCT_PACKAGES += libpowerhalctl_vendor
#PRODUCT_PACKAGES += libpowerhalwrap
PRODUCT_PACKAGES += libpowerhalwrap_vendor
#PRODUCT_PACKAGES += libmtkperf_client
PRODUCT_PACKAGES += libmtkperf_client_vendor
#PRODUCT_PACKAGES += libperfctl
PRODUCT_PACKAGES += libperfctl_vendor
PRODUCT_PACKAGES += power_native_test_v_1_0
PRODUCT_PACKAGES += power_legacy_test_v_1_0
PRODUCT_PACKAGES += power_app_cfg.xml
PRODUCT_PACKAGES += powerscntbl.xml
PRODUCT_PACKAGES += powerboosttbl.cfg
PRODUCT_PACKAGES += powercontable.xml
PRODUCT_PACKAGES += fstb.cfg
PRODUCT_PACKAGES += sn
#PRODUCT_PACKAGES += lcdc_screen_cap
PRODUCT_PACKAGES += libJniAtvService
PRODUCT_PACKAGES += GoogleKoreanIME
PRODUCT_PACKAGES += memtrack.mt6739
PRODUCT_PACKAGES += memtrack.mt6739m
PRODUCT_PACKAGES += memtrack.mt6753
PRODUCT_PACKAGES += android.hardware.memtrack@1.0-impl

#ifeq ($(ENABLE_TREBLE), true)
ifneq ($(strip $(MTK_HIDL_PROCESS_CONSOLIDATION_ENABLED)), yes)
    PRODUCT_PACKAGES += android.hardware.memtrack@1.0-service
endif
#endif

PRODUCT_PACKAGES += mbimd

ifndef MTK_TB_WIFI_3G_MODE
	PRODUCT_PACKAGES += Mms
else
	ifeq ($(strip $(MTK_TB_WIFI_3G_MODE)), 3GDATA_SMS)
		PRODUCT_PACKAGES += Mms
	endif
endif

PRODUCT_PROPERTY_OVERRIDES += ro.vendor.enable.geo.fencing=1

PRODUCT_PACKAGES += libjni_koreanime.so
PRODUCT_PACKAGES += wpa_supplicant
PRODUCT_PACKAGES += wpa_cli
PRODUCT_PACKAGES += wpa_supplicant.conf
PRODUCT_PACKAGES += wpa_supplicant_overlay.conf
PRODUCT_PACKAGES += p2p_supplicant_overlay.conf
PRODUCT_PACKAGES += hostapd
PRODUCT_PACKAGES += hostapd_cli
PRODUCT_PACKAGES += lib_driver_cmd_mt66xx.a
ifndef MTK_TB_WIFI_3G_MODE
#PRODUCT_PACKAGES += Dialer
endif
#PRODUCT_PACKAGES += CallLogBackup
PRODUCT_PACKAGES += libacdk

# camtool
PRODUCT_PACKAGES += libcam.hal3a.cctsvr
#PRODUCT_PACKAGES += camtool
PRODUCT_PACKAGES += jpegtool
#PRODUCT_PACKAGES += libmtkcam_cct

PRODUCT_PACKAGES += hwcomposer.mt6739
PRODUCT_PACKAGES += hwcomposer.mt6739m
PRODUCT_PACKAGES += md_ctrl

PRODUCT_PACKAGES += \
                android.hardware.graphics.composer@2.1-impl \
                android.hardware.graphics.composer@2.1-service

ifeq ($(strip $(MTK_CCCI_PERMISSION_CHECK_SUPPORT)),yes)
PRODUCT_PACKAGES += permission_check
PRODUCT_PROPERTY_OVERRIDES += persist.md.perm.checked=to_upgrade
endif

PRODUCT_PROPERTY_OVERRIDES += ro.vendor.camera.isp-version.major=3

#PRODUCT_PACKAGES += libGLES_android

ifneq ($(MTK_BASIC_PACKAGE), yes)
PRODUCT_PACKAGES += guiext-server
endif

PRODUCT_PACKAGES += fstab.mt6739
PRODUCT_PACKAGES += fstab.mt6739.ramdisk

#ifeq ($(strip $(MTK_VT3G324M_SUPPORT)),yes)
PRODUCT_PACKAGES += libmtk_vt_client
PRODUCT_PACKAGES += libmtk_vt_em
PRODUCT_PACKAGES += libmtk_vt_utils
#PRODUCT_PACKAGES += libmtk_vt_service
PRODUCT_PACKAGES += libmtk_vt_swip
#PRODUCT_PACKAGES += vtservice
#endif

ifeq ($(strip $(BUILD_MTK_LDVT)),yes)
  #PRODUCT_PACKAGES += ts_uvvf
endif

ifeq ($(strip $(MTK_TC7_FEATURE)), yes)
  PRODUCT_COPY_FILES += device/mediatek/mt6755/frdump_init.rc:$(MTK_TARGET_VENDOR_RC)/frdump_init.rc
  PRODUCT_PACKAGES += frdump
endif

ifeq ($(strip $(MTK_APP_GUIDE)),yes)
  PRODUCT_PACKAGES += ApplicationGuide
endif

ifneq ($(strip $(foreach value,$(DFO_NVRAM_SET),$(filter yes,$($(value))))),)
  PRODUCT_PACKAGES += featured
  PRODUCT_PACKAGES += libdfo
  PRODUCT_PACKAGES += libdfo_jni
endif

ifeq ($(strip $(MTK_CDS_EM_SUPPORT)), yes)
  #PRODUCT_PACKAGES += CDS_INFO
endif

ifeq ($(strip $(MTK_EMMC_SUPPORT)),yes)
else ifeq ($(strip $(MTK_UFS_SUPPORT)),yes)
else ifeq ($(strip $(MNTL_SUPPORT)),yes)
else
  ifeq ($(strip $(MTK_NAND_UBIFS_SUPPORT)), yes)
  else
  endif
endif

ifeq ($(strip $(MTK_ENABLE_MD1)),yes)
  ifneq ($(wildcard $(MTK_ROOT_CUSTOM_OUT))/modem/modem_1_2g_n.img),)
    PRODUCT_PACKAGES += modem_1_2g_n.img
    ifeq ($(MTK_MDLOGGER_SUPPORT),yes)
      PRODUCT_PACKAGES += catcher_filter_1_2g_n.bin
    endif
  endif
  ifneq ($(wildcard $(MTK_ROOT_CUSTOM_OUT))/modem/modem_1_wg_n.img),)
    PRODUCT_PACKAGES += modem_1_wg_n.img
    ifeq ($(MTK_MDLOGGER_SUPPORT),yes)
      PRODUCT_PACKAGES += catcher_filter_1_wg_n.bin
    endif
  endif
  ifneq ($(wildcard $(MTK_ROOT_CUSTOM_OUT))/modem/modem_1_tg_n.img),)
    PRODUCT_PACKAGES += modem_1_tg_n.img
    ifeq ($(MTK_MDLOGGER_SUPPORT),yes)
      PRODUCT_PACKAGES += catcher_filter_1_tg_n.bin
    endif
  endif
endif

ifeq ($(strip $(MTK_ENABLE_MD2)),yes)
  ifneq ($(wildcard $(MTK_ROOT_CUSTOM_OUT))/modem/modem_2_2g_n.img),)
    PRODUCT_PACKAGES += modem_2_2g_n.img
    ifeq ($(MTK_MDLOGGER_SUPPORT),yes)
      PRODUCT_PACKAGES += catcher_filter_2_2g_n.bin
    endif
  endif
  ifneq ($(wildcard $(MTK_ROOT_CUSTOM_OUT))/modem/modem_2_wg_n.img),)
    PRODUCT_PACKAGES += modem_2_wg_n.img
    ifeq ($(MTK_MDLOGGER_SUPPORT),yes)
      PRODUCT_PACKAGES += catcher_filter_2_wg_n.bin
    endif
  endif
  ifneq ($(wildcard $(MTK_ROOT_CUSTOM_OUT))/modem/modem_2_tg_n.img),)
    PRODUCT_PACKAGES += modem_2_tg_n.img
    ifeq ($(MTK_MDLOGGER_SUPPORT),yes)
      PRODUCT_PACKAGES += catcher_filter_2_tg_n.bin
    endif
  endif
endif

ifeq ($(strip $(MTK_EMULATOR_SUPPORT)),yes)
  PRODUCT_PACKAGES += SDKGallery
else
  #PRODUCT_PACKAGES += Gallery2
  #PRODUCT_PACKAGES += Gallery2Root
  #PRODUCT_PACKAGES += Gallery2Drm
  #PRODUCT_PACKAGES += Gallery2Gif
  #PRODUCT_PACKAGES += Gallery2Pq
  #PRODUCT_PACKAGES += Gallery2PqTool
  #PRODUCT_PACKAGES += Gallery2Raw
  #PRODUCT_PACKAGES += Gallery2SlowMotion
  #PRODUCT_PACKAGES += Gallery2StereoEntry
  #PRODUCT_PACKAGES += Gallery2StereoCopyPaste
  #PRODUCT_PACKAGES += Gallery2StereoBackground
  #PRODUCT_PACKAGES += Gallery2StereoFancyColor
  #PRODUCT_PACKAGES += Gallery2StereoRefocus
  #PRODUCT_PACKAGES += Gallery2PhotoPicker
endif

ifneq ($(strip $(MTK_EMULATOR_SUPPORT)),yes)
  #PRODUCT_PACKAGES += Provision
endif

ifeq ($(strip $(HAVE_CMMB_FEATURE)), yes)
  PRODUCT_PACKAGES += CMMBPlayer
endif

ifeq ($(strip $(MTK_DATA_TRANSFER_APP)), yes)
  PRODUCT_PACKAGES += DataTransfer
endif

ifeq ($(strip $(MTK_MDM_APP)),yes)
  PRODUCT_PACKAGES += MediatekDM
endif

ifeq ($(strip $(MTK_VT3G324M_SUPPORT)),yes)
  PRODUCT_PACKAGES += libmtk_vt_client
  PRODUCT_PACKAGES += libmtk_vt_em
  PRODUCT_PACKAGES += libmtk_vt_utils
  PRODUCT_PACKAGES += libmtk_vt_service
  PRODUCT_PACKAGES += libmtk_vt_swip
  PRODUCT_PACKAGES += vtservice
endif

ifeq ($(strip $(MTK_OOBE_APP)),yes)
  PRODUCT_PACKAGES += OOBE
endif

ifdef MTK_WEATHER_PROVIDER_APP
  ifneq ($(strip $(MTK_WEATHER_PROVIDER_APP)), no)
    PRODUCT_PACKAGES += MtkWeatherProvider
  endif
endif

ifeq ($(strip $(MTK_ENABLE_VIDEO_EDITOR)),yes)
  PRODUCT_PACKAGES += VideoEditor
endif

ifeq ($(strip $(MTK_CALENDAR_IMPORTER_APP)), yes)
  ifneq ($(strip $(BUILD_GMS)), yes)
    #PRODUCT_PACKAGES += CalendarImporter
  endif
endif

ifeq ($(strip $(MTK_LOG2SERVER_APP)), yes)
  PRODUCT_PACKAGES += Log2Server
  PRODUCT_PACKAGES += Excftpcommonlib
  PRODUCT_PACKAGES += Excactivationlib
  PRODUCT_PACKAGES += Excadditionnallib
  PRODUCT_PACKAGES += Excmaillib
endif

ifeq ($(strip $(MTK_CAMERA_APP)), yes)
  PRODUCT_PACKAGES += CameraOpen
else
  #PRODUCT_PACKAGES += Camera
  PRODUCT_PACKAGES += Panorama
  PRODUCT_PACKAGES += NativePip
  PRODUCT_PACKAGES += SlowMotion
  PRODUCT_PACKAGES += CameraRoot
endif

ifeq ($(strip $(MTK_VIDEO_FAVORITES_WIDGET_APP)), yes)
  ifneq ($(strip $(MTK_TABLET_PLATFORM)), yes)
    PRODUCT_PACKAGES += VideoFavorites
    PRODUCT_PACKAGES += libjtranscode
  endif
endif

ifeq ($(strip $(MTK_VIDEOWIDGET_APP)),yes)
  PRODUCT_PACKAGES += MtkVideoWidget
endif

ifeq ($(strip $(MTK_RCSE_SUPPORT)), yes)
  #PRODUCT_PACKAGES += Rcse
  PRODUCT_PACKAGES += Provisioning
endif

ifeq ($(strip $(MTK_GPS_SUPPORT)), yes)
  ifeq ($(strip $(MTK_GPS_CHIP)), MTK_GPS_MT6620)
    PRODUCT_PROPERTY_OVERRIDES += gps.solution.combo.chip=1
  endif
  ifeq ($(strip $(MTK_GPS_CHIP)), MTK_GPS_MT6628)
    PRODUCT_PROPERTY_OVERRIDES += gps.solution.combo.chip=1
  endif
  ifeq ($(strip $(MTK_GPS_CHIP)), MTK_GPS_MT3332)
    PRODUCT_PROPERTY_OVERRIDES += gps.solution.combo.chip=0
  endif
endif

ifeq ($(strip $(MTK_NAND_UBIFS_SUPPORT)),yes)
  PRODUCT_PACKAGES += mkfs_ubifs
  PRODUCT_PACKAGES += ubinize
  PRODUCT_PACKAGES += mtdinfo
  PRODUCT_PACKAGES += ubiupdatevol
  PRODUCT_PACKAGES += ubirmvol
  PRODUCT_PACKAGES += ubimkvol
  PRODUCT_PACKAGES += ubidetach
  PRODUCT_PACKAGES += ubiattach
  PRODUCT_PACKAGES += ubinfo
  PRODUCT_PACKAGES += ubiformat
endif

ifeq ($(strip $(MTK_LIVEWALLPAPER_APP)), yes)
  PRODUCT_PACKAGES += LiveWallpapers
  #PRODUCT_PACKAGES += LiveWallpapersPicker
  PRODUCT_PACKAGES += MagicSmokeWallpapers
  PRODUCT_PACKAGES += VisualizationWallpapers
  PRODUCT_PACKAGES += Galaxy4
  PRODUCT_PACKAGES += HoloSpiralWallpaper
  PRODUCT_PACKAGES += NoiseField
  PRODUCT_PACKAGES += PhaseBeam
endif

ifeq ($(strip $(MTK_SNS_SUPPORT)), yes)
  PRODUCT_PACKAGES += SNSCommon
  PRODUCT_PACKAGES += SnsContentProvider
  PRODUCT_PACKAGES += SnsWidget
  PRODUCT_PACKAGES += SnsWidget24
  PRODUCT_PACKAGES += SocialStream
  ifeq ($(strip $(MTK_SNS_KAIXIN_APP)), yes)
    PRODUCT_PACKAGES += KaiXinAccountService
  endif
  ifeq ($(strip $(MTK_SNS_RENREN_APP)), yes)
    PRODUCT_PACKAGES += RenRenAccountService
  endif
  ifeq ($(strip $(MTK_SNS_FACEBOOK_APP)), yes)
    PRODUCT_PACKAGES += FacebookAccountService
  endif
  ifeq ($(strip $(MTK_SNS_FLICKR_APP)), yes)
    PRODUCT_PACKAGES += FlickrAccountService
  endif
  ifeq ($(strip $(MTK_SNS_TWITTER_APP)), yes)
    PRODUCT_PACKAGES += TwitterAccountService
  endif
  ifeq ($(strip $(MTK_SNS_SINAWEIBO_APP)), yes)
    PRODUCT_PACKAGES += WeiboAccountService
  endif
endif

ifeq ($(strip $(MTK_DATADIALOG_APP)), yes)
  PRODUCT_PACKAGES += DataDialog
endif

ifeq ($(strip $(MTK_DATA_TRANSFER_APP)), yes)
  PRODUCT_PACKAGES += DataTransfer
endif

ifeq ($(strip $(MTK_FM_SUPPORT)), yes)
  #PRODUCT_PACKAGES += FMRadio
endif

ifeq ($(strip $(MTK_CAM_LOMO_SUPPORT)), yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.vendor.mtk_cam_lomo_support=1
  #PRODUCT_PACKAGES += libjni_lomoeffect
endif

ifeq (MT6620_FM,$(strip $(MTK_FM_CHIP)))
  PRODUCT_PROPERTY_OVERRIDES += fmradio.driver.chip=1
endif

ifeq (MT6626_FM,$(strip $(MTK_FM_CHIP)))
  PRODUCT_PROPERTY_OVERRIDES += fmradio.driver.chip=2
endif

ifeq (MT6628_FM,$(strip $(MTK_FM_CHIP)))
  PRODUCT_PROPERTY_OVERRIDES += fmradio.driver.chip=3
endif


RAT_CONFIG = $(strip $(MTK_PROTOCOL1_RAT_CONFIG))
ifneq (, $(RAT_CONFIG))
  ifneq (,$(findstring C,$(RAT_CONFIG)))
    #C2K is supported
    RAT_CONFIG_C2K_SUPPORT=yes
  endif
endif

#for continuous shot
PRODUCT_PROPERTY_OVERRIDES += vendor.mtkcamapp.cshot.platform=-1

ifeq ($(strip $(MTK_DT_SUPPORT)),yes)
  ifneq ($(strip $(RAT_CONFIG_C2K_SUPPORT)),yes)
    ifeq ($(strip $(MTK_MDLOGGER_SUPPORT)),yes)
      PRODUCT_PACKAGES += ExtModemLog
      PRODUCT_PACKAGES += libextmdlogger_ctrl_jni
      PRODUCT_PACKAGES += libextmdlogger_ctrl
      PRODUCT_PACKAGES += extmdlogger
    endif
  endif
endif

ifneq ($(strip $(MTK_LCM_PHYSICAL_ROTATION)),)
endif

ifeq ($(strip $(MTK_FM_TX_SUPPORT)), yes)
  PRODUCT_PACKAGES += FMTransmitter
endif

ifeq ($(strip $(MTK_SOUNDRECORDER_APP)),yes)
  #PRODUCT_PACKAGES += SoundRecorder
endif

ifeq ($(strip $(MTK_LOCKSCREEN_TYPE)),2)
  PRODUCT_PACKAGES += MtkWallPaper
endif

ifneq ($(strip $(MTK_LOCKSCREEN_TYPE)),)
  PRODUCT_PROPERTY_OVERRIDES += curlockscreen=$(MTK_LOCKSCREEN_TYPE)
endif

  PRODUCT_PACKAGES += Browser
  #PRODUCT_PACKAGES += DownloadProvider

ifeq ($(strip $(MTK_WIFI_P2P_SUPPORT)),yes)
  PRODUCT_PACKAGES += WifiContactSync
  PRODUCT_PACKAGES += WifiP2PWizardy
  PRODUCT_PACKAGES += FileSharingServer
  PRODUCT_PACKAGES += FileSharingClient
  PRODUCT_PACKAGES += UPnPAV
  PRODUCT_PACKAGES += WifiWsdsrv
  PRODUCT_PACKAGES += bonjourExplorer
endif

ifeq ($(strip $(CUSTOM_KERNEL_TOUCHPANEL)),generic)
  PRODUCT_PACKAGES += Calibrator
endif

ifeq ($(strip $(MTK_FILEMANAGER_APP)), yes)
  #PRODUCT_PACKAGES += FileManager
endif

ifneq ($(findstring OP03, $(strip $(OPTR_SPEC_SEG_DEF))),)
  PRODUCT_PACKAGES += SimCardAuthenticationService
endif

ifeq ($(strip $(MTK_APKINSTALLER_APP)), yes)
  PRODUCT_PACKAGES += APKInstaller
endif

ifeq ($(strip $(MTK_SMSREG_APP)), yes)
  PRODUCT_PACKAGES += SmsReg
endif

ifeq ($(MTK_BACKUPANDRESTORE_APP),yes)
  PRODUCT_PACKAGES += BackupAndRestore
endif

ifeq ($(strip $(MTK_BWC_SUPPORT)), yes)
  PRODUCT_PACKAGES += libbwc
endif

ifeq ($(strip $(MTK_GPU_SUPPORT)), yes)
  ifeq ($(MTK_PLATFORM),$(filter $(MTK_PLATFORM),MT6739))
    PRODUCT_PACKAGES += gralloc.mt6739
    PRODUCT_PACKAGES += gralloc.mt6739m
    PRODUCT_PACKAGES += gralloc.mt6753
    PRODUCT_PACKAGES += libOpenCL
    PRODUCT_PACKAGES += libGLES_mali
    PRODUCT_PACKAGES += libgpu_aux
    PRODUCT_PACKAGES += libgpud
    PRODUCT_PACKAGES += libRSDriver_mtk
    PRODUCT_PACKAGES += rs2spir
    PRODUCT_PACKAGES += spir2cl
    ifeq ($(strip $(MTK_K64_SUPPORT)), yes)
        PRODUCT_PACKAGES += vulkan.mt6739
        PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml
        PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml
        PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml
    endif
    PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml
    PRODUCT_PACKAGES += android.hardware.graphics.allocator@2.0-impl
    PRODUCT_PACKAGES += android.hardware.graphics.mapper@2.0-impl-2.1
    ifneq ($(strip $(MTK_HIDL_PROCESS_CONSOLIDATION_ENABLED)), yes)
        PRODUCT_PACKAGES += android.hardware.graphics.allocator@2.0-service
    endif
    PRODUCT_PROPERTY_OVERRIDES += ro.opengles.version=196610
  endif
endif


ifeq ($(strip $(MTK_DT_SUPPORT)),yes)
  PRODUCT_PACKAGES += ip-up
  PRODUCT_PACKAGES += ip-down
  PRODUCT_PACKAGES += ppp_options
  PRODUCT_PACKAGES += chap-secrets
  PRODUCT_PACKAGES += init.gprs-pppd
endif

# OEM Unlock reporting
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.oem_unlock_supported=1


ifeq (yes,$(strip $(MTK_FD_SUPPORT)))
  # Only support the format: n.m (n:1 or 1+ digits, m:Only 1 digit) or n (n:integer)
  # Time Unit:0.1 sec
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.fd.counter=150
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.fd.off.counter=50
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.fd.r8.counter=150
  PRODUCT_PROPERTY_OVERRIDES += persist.vendor.radio.fd.off.r8.counter=50
endif


#################################################
#Widevine DRM part
ifeq ($(strip $(MTK_WVDRM_SUPPORT)),yes)
  #both L1 and L3 library
  PRODUCT_PROPERTY_OVERRIDES += drm.service.enabled=true
  PRODUCT_PACKAGES += com.google.widevine.software.drm.xml
  PRODUCT_PACKAGES += com.google.widevine.software.drm
  #PRODUCT_PACKAGES += libdrmmtkutil
  PRODUCT_PACKAGES += libdrmwvmplugin
  PRODUCT_PACKAGES += libwvm
  PRODUCT_PACKAGES += libdrmdecrypt
  ifeq ($(strip $(MTK_WVDRM_L1_SUPPORT)),yes)
    PRODUCT_PACKAGES += libWVStreamControlAPI_L1
    PRODUCT_PACKAGES += libwvdrm_L1
    PRODUCT_PACKAGES += lib_uree_mtk_crypto
  else
    PRODUCT_PACKAGES += libWVStreamControlAPI_L3
    PRODUCT_PACKAGES += libwvdrm_L3
  endif
else
  PRODUCT_PROPERTY_OVERRIDES += drm.service.enabled=false
endif

###Modular drm
ifeq ($(strip $(MTK_WVDRM_SUPPORT)),yes)
  #Mock modular drm plugin for cts
  PRODUCT_PACKAGES += libmockdrmcryptoplugin
  #both L1 and L3 library
  PRODUCT_PACKAGES += libwvdrmengine
  ifeq ($(strip $(MTK_WVDRM_L1_SUPPORT)),yes)
    PRODUCT_PACKAGES += lib_uree_mtk_modular_drm
    PRODUCT_PACKAGES += liboemcrypto
  endif
endif

################################################

#################################################
#OMA DRM part
ifeq ($(strip $(MTK_OMADRM_SUPPORT)), yes)
  #PRODUCT_PACKAGES += libdrmmtkutil
  #Media framework reads this property
  PRODUCT_PROPERTY_OVERRIDES += drm.service.enabled=true
  #PRODUCT_PACKAGES += libdcfdecoderjni
  #PRODUCT_PACKAGES += libdrmmtkplugin
  PRODUCT_PACKAGES += drm_chmod
endif
ifeq ($(strip $(MTK_CTA_SET)), yes)
  #PRODUCT_PACKAGES += libdrmmtkutil
  #Media framework reads this property
  PRODUCT_PROPERTY_OVERRIDES += drm.service.enabled=true
  #PRODUCT_PACKAGES += libdcfdecoderjni
  ifneq ($(strip $(BUILD_GMS)), yes)
    #PRODUCT_PACKAGES += libdrmctaplugin
    #PRODUCT_PACKAGES += DataProtection
  else
    ifneq ($(strip $(MTK_GMO_ROM_OPTIMIZE)), yes)
      #PRODUCT_PACKAGES += libdrmctaplugin
      #PRODUCT_PACKAGES += DataProtection
    endif
  endif
endif

################################################

############find all modules under custom folder
#define find-all-my-module
all_sensor_modules := $(addsuffix _tuning,$(notdir $(foreach f,$(CUSTOM_HAL_IMGSENSOR),$(wildcard vendor/mediatek/proprietary/custom/mt6739/hal/imgsensor/$(f)))))

PRODUCT_PACKAGES += $(all_sensor_modules)
###############################################

ifeq ($(strip $(HAVE_SRSAUDIOEFFECT_FEATURE)),yes)
  PRODUCT_PACKAGES += DTSTruMedia
  PRODUCT_PACKAGES += libsrsprocessing
endif

ifeq ($(strip $(MTK_DOLBY_DAP_SUPPORT)), yes)
  PRODUCT_PACKAGES += libdseffect \
                      Ds \
                      DsUI \
                      dolby_ds
endif

ifeq ($(strip $(MTK_AUDIO_DDPLUS_SUPPORT)), yes)
    PRODUCT_PACKAGES += libstagefright_soft_ddpdec
endif

ifeq ($(strip $(MTK_WEATHER_WIDGET_APP)), yes)
  PRODUCT_PACKAGES += MtkWeatherWidget
endif

ifeq ($(strip $(MTK_ECCCI_C2K)),yes)
endif

ifeq ($(strip $(MTK_WFD_SINK_SUPPORT)), yes)
  PRODUCT_PACKAGES += MtkFloatMenu
endif

PRODUCT_PACKAGES += libsec
PRODUCT_PACKAGES += sbchk

PRODUCT_BRAND := alps
PRODUCT_MANUFACTURER := alps

# for USB Accessory Library/permission
# Mark for early porting in JB
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml
#PRODUCT_PACKAGES += com.android.future.usb.accessory

# System property for MediaTek ANR pre-dump.
PRODUCT_PROPERTY_OVERRIDES += dalvik.vm.mtk-stack-trace-file=/data/anr/mtk_traces.txt

ifeq ($(strip $(MTK_RILD_READ_IMSI)),yes)
endif

ifeq ($(strip $(MTK_FACTORY_RESET_PROTECTION_SUPPORT)),yes)
ifeq ($(strip $(MTK_EMMC_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/platform/bootdevice/by-name/frp
else ifeq ($(strip $(MTK_UFS_SUPPORT)),yes)
  PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/platform/bootdevice/by-name/frp
endif
endif


PRODUCT_COPY_FILES += device/mediatek/mt6739/init.mt6739.rc:$(MTK_TARGET_VENDOR_RC)/init.mt6739.rc
PRODUCT_COPY_FILES += device/mediatek/mt6739/factory_init.rc:$(MTK_TARGET_VENDOR_RC)/factory_init.rc
PRODUCT_COPY_FILES += device/mediatek/mt6739/init.modem.rc:$(MTK_TARGET_VENDOR_RC)/init.modem.rc


ifeq ($(strip $(MTK_FAT_ON_NAND)),yes)
PRODUCT_COPY_FILES += device/mediatek/mt6739/init.fon.rc:$(MTK_TARGET_VENDOR_RC)/init.fon.rc
endif

PRODUCT_COPY_FILES += device/mediatek/mt6739/init.sensor_1_0.rc:$(MTK_TARGET_VENDOR_RC)/init.sensor_1_0.rc
PRODUCT_COPY_FILES += device/mediatek/mt6739/meta_init.modem.rc:$(MTK_TARGET_VENDOR_RC)/meta_init.modem.rc
PRODUCT_COPY_FILES += device/mediatek/mt6739/meta_init.rc:$(MTK_TARGET_VENDOR_RC)/meta_init.rc
PRODUCT_COPY_FILES += device/mediatek/mt6739/init.mt6739.usb.rc:$(MTK_TARGET_VENDOR_RC)/init.mt6739.usb.rc
PRODUCT_COPY_FILES += device/mediatek/mt6739/init.recovery.mt6739.rc:recovery/root/init.recovery.mt6739.rc
PRODUCT_COPY_FILES += device/mediatek/mt6739/egl.cfg:$(TARGET_COPY_OUT_VENDOR)/lib/egl/egl.cfg:mtk

ifeq ($(TARGET_BUILD_VARIANT),eng)
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/thermal.eng.conf:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/thermal.conf:mtk
else
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/thermal.conf:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/thermal.conf:mtk
endif
    #PRODUCT_COPY_FILES += $(LOCAL_PATH)/thermal.wfd.6739.conf:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/.thermal_policy_00:mtk
PRODUCT_COPY_FILES += $(LOCAL_PATH)/thermal.off.conf:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/thermal.off.conf:mtk
PRODUCT_COPY_FILES += $(LOCAL_PATH)/ht120.mtc:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/.ht120.mtc:mtk

PRODUCT_COPY_FILES += $(LOCAL_PATH)/partition_permission.sh:$(TARGET_COPY_OUT_VENDOR)/etc/partition_permission.sh:mtk

PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml:mtk
PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml

ifneq ($(MTK_BASIC_PACKAGE), yes)
    ifeq ($(strip $(MTK_AUDIO_CODEC_SUPPORT_TABLET)), yes)
        PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_mediatek_audio_tablet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_audio.xml:mtk
    else
        ifeq (yes,$(strip $(MTK_GMO_RAM_OPTIMIZE)))
            PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_mediatek_audio_phone_gmo.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_audio.xml:mtk
        else
            PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_mediatek_audio_phone.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_audio.xml:mtk
        endif
    endif
else
    PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_mediatek_audio_basic.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_audio.xml:mtk
endif


PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_google_video_gmo.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video_le.xml
ifeq (yes,$(strip $(MTK_GMO_RAM_OPTIMIZE)))
    PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_c2_gmo.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_c2.xml:mtk
else
    PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_c2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_c2.xml:mtk
endif

ifeq (yes 0x20000000,$(strip $(MTK_GMO_RAM_OPTIMIZE)) $(strip $(CUSTOM_CONFIG_MAX_DRAM_SIZE)))
  PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_mediatek_video_gmo.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_video.xml
  ifeq ($(strip $(MTK_AUDIO_CODEC_SUPPORT_TABLET)), yes)
        PRODUCT_COPY_FILES += device/mediatek/mt6739/mtk_omx_core_gmo_tablet.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/mtk_omx_core.cfg:mtk
  else
        PRODUCT_COPY_FILES += device/mediatek/mt6739/mtk_omx_core_gmo.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/mtk_omx_core.cfg:mtk
  endif
else
  PRODUCT_COPY_FILES += device/mediatek/mt6739/media_codecs_mediatek_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_video.xml:mtk
  ifeq ($(strip $(MTK_AUDIO_CODEC_SUPPORT_TABLET)), yes)
      PRODUCT_COPY_FILES += device/mediatek/mt6739/mtk_omx_core_tablet.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/mtk_omx_core.cfg:mtk
  else
      PRODUCT_COPY_FILES += device/mediatek/mt6739/mtk_omx_core.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/mtk_omx_core.cfg:mtk
  endif
endif

PRODUCT_COPY_FILES += frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml
# frameworks/av/services/mediacodec/android.hardware.media.omx@1.0-service.rc
PRODUCT_COPY_FILES += vendor/mediatek/proprietary/hardware/omx/mediacodec/android.hardware.media.omx@1.0-service.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/android.hardware.media.omx@1.0-service.rc

ifeq ($(MTK_CLEARMOTION_SUPPORT),yes)
PRODUCT_COPY_FILES += device/mediatek/mt6739/mtk_clear_motion.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/mtk_clear_motion.cfg:mtk
endif

#Audio config
PRODUCT_COPY_FILES += device/mediatek/mt6739/audio_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_device.xml:mtk

#Audio low latency
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml

#Audio config
PRODUCT_COPY_FILES += device/mediatek/mt6739/audio_device_param/DSM_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/DSM_config.xml:mtk
PRODUCT_COPY_FILES += device/mediatek/mt6739/audio_device_param/DSM.xml:$(TARGET_COPY_OUT_VENDOR)/etc/DSM.xml:mtk

# USB ADB
PRODUCT_PROPERTY_OVERRIDES += \
    persist.adb.nonblocking_ffs=0

ifneq ($(MTK_AUDIO_TUNING_TOOL_VERSION),)
  ifneq ($(strip $(MTK_AUDIO_TUNING_TOOL_VERSION)),V1)
    MTK_AUDIO_PARAM_DIR_LIST += device/mediatek/mt6739/audio_param
    # Speech Parameter Tuning
    # SPH_PARAM_VERSION: 0 support single network(MD ability related)
    # SPH_PARAM_VERSION: 1.0 support multiple networks(MD ability related)
    # SPH_PARAM_VERSION: 2.0 support IIR and fix WBFIR(Gen93)
    AUDIO_PARAM_OPTIONS_LIST += SPH_PARAM_VERSION=2.0
  endif
endif

#aurisys library parameters
ifeq ($(MTK_AURISYS_PHONE_CALL_SUPPORT),yes)
PRODUCT_PACKAGES += libfvaudio
#PRODUCT_PACKAGES += AudioSetParam
PRODUCT_COPY_FILES += $(LOCAL_PATH)/aurisys_param/phone_call/forte_media/FV-SAM-MTK2.dat:$(TARGET_COPY_OUT_VENDOR)/etc/FV-SAM-MTK2.dat:mtk
endif

ifeq ($(strip $(TRUSTONIC_TEE_SUPPORT)), yes)
  PRODUCT_PACKAGES += keystore.mt6739
  PRODUCT_PACKAGES += keystore.mt6739m
  PRODUCT_PACKAGES += keystore.mt6753
  PRODUCT_PACKAGES += libMcGatekeeper
  PRODUCT_PACKAGES += rda
endif

ifeq ($(strip $(MTK_TEE_TRUSTED_UI_SUPPORT)), yes)
  PRODUCT_PACKAGES += libTui
  PRODUCT_PACKAGES += TuiService
  PRODUCT_PACKAGES += SamplePinpad
  PRODUCT_PACKAGES += libTlcPinpad
endif

ifeq ($(strip $(MICROTRUST_TEE_SUPPORT)), yes)
PRODUCT_PACKAGES   += 	keystore.mt6739
PRODUCT_PACKAGES   += 	gatekeeper.mt6739
PRODUCT_PACKAGES   += 	kmsetkey.mt6739
endif

# userspace sysenv
PRODUCT_PACKAGES += libsysenv
PRODUCT_PACKAGES += sysenv_daemon

ifeq ($(strip $(MTK_AOD_SUPPORT)), yes)
    #PRODUCT_PACKAGES += AlwaysOnDisplay
endif

# camera hal3 zsl default backtrace timestamp
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.camera3.zsl.default=150

# for 3Gdongle
ifeq ($(strip $(MTK_EXTERNAL_DONGLE_SUPPORT)), yes)
    PRODUCT_PACKAGES += dongled \
                        chat \
                        rild_dongle \
                        libril_dongle \
                        Dongle \
                        TeledongleDemo \
                        tedongle-telephony

    $(call inherit-product-if-exists, vendor/mediatek/proprietary/hardware/dongle-ril/vendorSoFile64/vendorSoFile.mk)
    $(call inherit-product-if-exists, vendor/mediatek/proprietary/hardware/dongle-ril/dongled/dongled.mk)
    $(call inherit-product-if-exists, vendor/mediatek/proprietary/hardware/dongle-ril/vendor001-ril/vendor001-ril.mk)
    $(call inherit-product-if-exists, vendor/mediatek/proprietary/hardware/dongle-ril/vendor002-ril/vendor002-ril.mk)
    $(call inherit-product-if-exists, frameworks/opt/tedongle/tedonglePermission.mk)
endif

# for logd filter
ifeq ($(OPTR_SPEC_SEG_DEF),OP03_SPEC0200_SEGDEFAULT)
ifeq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PROPERTY_OVERRIDES += persist.log.tag=I
endif
endif


ifeq ($(strip $(MNTL_SUPPORT)), yes)
    PRODUCT_PACKAGES += mnb.img
    PRODUCT_PACKAGES += mntl_link
    PRODUCT_PACKAGES += mkmntl
endif
# add vintf utility
#PRODUCT_PACKAGES += \
#    vintf

# Bluetooth HAL
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl-mediatek \
    android.hardware.bluetooth@1.0-service-mediatek

#Fingerprint(Goodix) Begin
ifeq (yes, $(strip $(MTK_FINGERPRINT_SUPPORT)))
  ifeq ($(strip $(MTK_FINGERPRINT_SELECT)), $(filter $(MTK_FINGERPRINT_SELECT), GF316M GF318M GF3118M GF518M GF5118M GF516M GF816M GF3208 GF3206 GF3266 GF3288 GF5206 GF5216 GF5208))
    PRODUCT_PACKAGES += \
    libgf_ca \
    libgf_algo \
    libgf_hal \
    libgoodixfingerprintd_binder \
    goodixfingerprintd \
    fingerprint.mt6739 \
    fingerprintd

# only for fingerprint factory test
    PRODUCT_PACKAGES += \
    libgf_hal_factory \
    libgf_hal_ree \
    libgf_ca_ree \
    libgf_ta_ree

    PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml
  endif
endif
#Fingerprint(Goodix) End

# CCU
PRODUCT_PACKAGES += lib3a.ccu.pm
PRODUCT_PACKAGES += lib3a.ccu.dm
PRODUCT_PACKAGES += lib3am.ccu.pm
PRODUCT_PACKAGES += lib3am.ccu.dm
PRODUCT_PACKAGES += libccu_imx214_mipi_mono.pm
PRODUCT_PACKAGES += libccu_imx214_mipi_mono.dm
PRODUCT_PACKAGES += libccu_imx338_mipi_raw.pm
PRODUCT_PACKAGES += libccu_imx338_mipi_raw.dm
PRODUCT_PACKAGES += libccu_imx386_mipi_raw.pm
PRODUCT_PACKAGES += libccu_imx386_mipi_raw.dm
PRODUCT_PACKAGES += libccu_imx398_mipi_raw.pm
PRODUCT_PACKAGES += libccu_imx398_mipi_raw.dm
PRODUCT_PACKAGES += libccu_ov8858_mipi_raw.pm
PRODUCT_PACKAGES += libccu_ov8858_mipi_raw.dm
PRODUCT_PACKAGES += libccu_s5k4e6_mipi_raw.pm
PRODUCT_PACKAGES += libccu_s5k4e6_mipi_raw.dm

# for fpsgo fbt game
PRODUCT_PACKAGES += fpsgo-user.ko fpsgo-eng.ko
PRODUCT_PACKAGES += fpsgo.ko



# Audio HAL
PRODUCT_PACKAGES += \
    fs_config_files

# vendor hidl process merging together to save memory
ifeq ($(strip $(MTK_HIDL_PROCESS_CONSOLIDATION_ENABLED)), yes)
    PRODUCT_PACKAGES += merged_hal_service
endif

# vibrator HAL
PRODUCT_PACKAGES += \
        android.hardware.vibrator@1.0-impl
ifneq ($(strip $(MTK_HIDL_PROCESS_CONSOLIDATION_ENABLED)), yes)
        PRODUCT_PACKAGES += android.hardware.vibrator@1.0-service
endif

# light HAL
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-impl-mediatek
    PRODUCT_PACKAGES += android.hardware.light@2.0-service-mediatek

# sensor HAL HIDL
PRODUCT_PACKAGES += \
    android.hardware.sensors@2.0-service-mediatek

# thermal HIDL
PRODUCT_PACKAGES += \
    android.hardware.thermal@1.0-impl
ifneq ($(strip $(MTK_HIDL_PROCESS_CONSOLIDATION_ENABLED)), yes)
    PRODUCT_PACKAGES += android.hardware.thermal@1.0-service
endif

# Presence
ifeq ($(strip $(MTK_RCS_SUPPORT)), yes)
PRODUCT_PACKAGES += \
  volte_uce_ua \
  vendor.mediatek.hardware.presence@1.0.so \
  volte_rcs_ua \
  vendor.mediatek.hardware.rcs@1.0.so
endif

# APE service HIDL
PRODUCT_PACKAGES += \
        vendor.mediatek.hardware.mtkcodecservice@1.1-impl \
        vendor.mediatek.hardware.mtkcodecservice@1.1-service

# OemLock HAL
PRODUCT_PACKAGES += \
    android.hardware.oemlock@1.0-service \
    android.hardware.oemlock@1.0-impl
# mtk av enhance
#PRODUCT_PACKAGES += libmtkavenhancements
#PRODUCT_PACKAGES += libmtkmkvextractor
#PRODUCT_PACKAGES += libmtkmpeg2extractor

# Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.1-service-mediatek

# gpu HAL HIDL
PRODUCT_PACKAGES += \
    vendor.mediatek.hardware.gpu@1.0-impl \
    vendor.mediatek.hardware.gpu@1.0-service

# lmkd parameters
ifneq ($(strip $(MTK_GMO_RAM_OPTIMIZE)), yes)
PRODUCT_PROPERTY_OVERRIDES += \
     ro.lmk.use_minfree_levels=true \
     ro.lmk.kill_heaviest_task=true \
     ro.lmk.kill_timeout_ms=100
endif

#inherit common platform
$(call inherit-product, device/mediatek/vendor/common/device.mk)

#inherit prebuilt
$(call inherit-product-if-exists, vendor/mediatek/mt6739/device-vendor.mk)
