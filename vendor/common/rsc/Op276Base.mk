# For SIM Configuration: Single SIM
include device/mediatek/vendor/common/rsc/SsBase.mk

# Rat Configuration: 5M
include device/mediatek/vendor/common/rsc/RatMode4mFddBase.mk

MTK_RSC_VENDOR_PROPERTIES += \
        persist.vendor.radio.mtk_ps2_rat=W/G \

# Operator package properties: OP276
MTK_RSC_VENDOR_PROPERTIES += \
        ro.vendor.operator.optr=OP276 \
        ro.vendor.operator.spec=SPEC0200 \
        ro.vendor.operator.seg=SEGDEFAULT \
        persist.vendor.operator.optr=OP276 \
        persist.vendor.operator.spec=SPEC0200 \
        persist.vendor.operator.seg=SEGDEFAULT

MTK_RSC_XML_OPTR := OP276_SPEC0200_SEGDEFAULT

# For DSBP
MTK_RSC_VENDOR_PROPERTIES += \
        persist.vendor.radio.mtk_dsbp_support=1 \
        ro.vendor.mtk_md_sbp_custom_value=276

# For CXP
MTK_RSC_VENDOR_PROPERTIES += \
    ro.vendor.mtk_carrierexpress_pack=no

# For CXP-Switable NA Features, configured with PRODUCT_PROPERTY_OVERRIDES in device.mk
MTK_RSC_VENDOR_PROPERTIES += \
    persist.vendor.volte_support=1 \
    persist.vendor.mtk.volte.enable=1 \
    persist.vendor.mtk_wfc_support=1 \
    persist.vendor.mtk.wfc.enable=1 \
    persist.vendor.vilte_support=0 \
    persist.vendor.mtk.ims.video.enable=0 \
    persist.vendor.viwifi_support=0 \
    persist.vendor.mtk_rcs_ua_support=0

# For MCF(Modem configuration framework)
MTK_RSC_VENDOR_PROPERTIES += ro.vendor.mtk_mcf_support=0