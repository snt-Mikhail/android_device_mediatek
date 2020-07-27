### enable make target-files-package/dist
ifdef MTK_TARGET_PROJECT

ifeq ($(PLATFORM_VERSION),R)
# workaround for brotli checkvintf imgdiff used by releasetools
$(BUILT_TARGET_FILES_PACKAGE): | $(INTERNAL_OTATOOLS_FILES)
endif

$(BUILT_TARGET_FILES_PACKAGE): $(INSTALLED_LK_TARGET) $(INSTALLED_LOGO_TARGET)
$(BUILT_TARGET_FILES_PACKAGE): $(INSTALLED_PRELOADER_TARGET)
$(BUILT_TARGET_FILES_PACKAGE): $(TARGET_PRELOADER)
$(BUILT_TARGET_FILES_PACKAGE): $(TINYSYS_INSTALLED_TARGET)
$(BUILT_TARGET_FILES_PACKAGE): $(INSTALLED_TRUSTZONE_TARGET)
$(BUILT_TARGET_FILES_PACKAGE): $(TINYSYS_SSPM_INSTALLED_TARGET)
$(TINYSYS_SSPM_INSTALLED_TARGET):

ifneq (true,$(BOARD_AVB_ENABLE))
ifneq (yes,$(MTK_AVB20_SUPPORT))
droidcore bootimage: $(addsuffix -verified$(suffix $(MTK_BOOTIMAGE_TARGET)),$(basename $(MTK_BOOTIMAGE_TARGET)))
$(addsuffix -verified$(suffix $(MTK_BOOTIMAGE_TARGET)),$(basename $(MTK_BOOTIMAGE_TARGET))):
droidcore recoveryimage: $(addsuffix -verified$(suffix $(INSTALLED_RECOVERYIMAGE_TARGET)),$(basename $(INSTALLED_RECOVERYIMAGE_TARGET)))
$(addsuffix -verified$(suffix $(INSTALLED_RECOVERYIMAGE_TARGET)),$(basename $(INSTALLED_RECOVERYIMAGE_TARGET))):
endif
endif


intermediates := $(call intermediates-dir-for,PACKAGING,vendor_target_files)

$(BUILT_TARGET_FILES_PACKAGE): INSTALLED_ANDROID_INFO_TXT_TARGET := $(INSTALLED_ANDROID_INFO_TXT_TARGET) $(MTK_SPLIT_VENDOR_OTA_TXT_TARGET)
$(BUILT_TARGET_FILES_PACKAGE): $(MTK_SPLIT_VENDOR_OTA_TXT_TARGET)


endif#MTK_TARGET_PROJECT
