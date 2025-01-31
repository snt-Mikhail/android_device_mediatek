#ifndef __M4U_LIB_PORT_H__
#define __M4U_LIB_PORT_H__

//====================================
// about portid
//====================================
typedef int M4U_PORT_ID;
typedef int M4U_MODULE_ID_ENUM;
typedef int M4U_PORT_ID_ENUM;

enum
{
	M4U_PORT_DISP_OVL0,
	M4U_PORT_DISP_2L_OVL0_LARB0,
	M4U_PORT_DISP_RDMA0,
	M4U_PORT_DISP_WDMA0,
	M4U_PORT_MDP_RDMA0,
	M4U_PORT_MDP_WDMA0,
	M4U_PORT_MDP_WROT0,
	M4U_PORT_DISP_FAKE_LARB0,

	M4U_PORT_HW_VDEC_MC_EXT,
	M4U_PORT_HW_VDEC_PP_EXT,
	M4U_PORT_HW_VDEC_VLD_EXT,
	M4U_PORT_HW_VDEC_AVC_MV_EXT,
	M4U_PORT_HW_VDEC_PRED_RD_EXT,
	M4U_PORT_HW_VDEC_PRED_WR_EXT,
	M4U_PORT_HW_VDEC_PPWRAP_EXT,

	M4U_PORT_CAM_IMGO,
	M4U_PORT_CAM_RRZO,
	M4U_PORT_CAM_AAO,
	M4U_PORT_CAM_AFO,
	M4U_PORT_CAM_LSCI_0,
	M4U_PORT_CAM_LSC3I,
	M4U_PORT_CAM_RSSO,
	M4U_PORT_CAM_SV0,
	M4U_PORT_CAM_SV1,
	M4U_PORT_CAM_SV2,
	M4U_PORT_CAM_LCSO,
	M4U_PORT_CAM_UFEO,
	M4U_PORT_CAM_BPCI,
	M4U_PORT_CAM_PDO,
	M4U_PORT_CAM_RAWI,
	M4U_PORT_CAM_CCUI,
	M4U_PORT_CAM_CCUO,
	M4U_PORT_CAM_CCUG,

	M4U_PORT_VENC_RCPU,
	M4U_PORT_VENC_REC,
	M4U_PORT_VENC_BSDMA,
	M4U_PORT_VENC_SV_COMV,
	M4U_PORT_VENC_RD_COMV,
	M4U_PORT_JPGENC_RDMA,
	M4U_PORT_JPGENC_BSDMA,
	M4U_PORT_JPGDEC_WDMA,
	M4U_PORT_JPGDEC_BSDMA,
	M4U_PORT_VENC_CUR_LUMA,
	M4U_PORT_VENC_CUR_CHROMA,
	M4U_PORT_VENC_REF_LUMA,
	M4U_PORT_VENC_REF_CHROMA,

	M4U_PORT_DISP_OVL1,
	M4U_PORT_DISP_2L_OVL1,
	M4U_PORT_DISP_RDMA1,
	M4U_PORT_DISP_RDMA2,
	M4U_PORT_DISP_WDMA1,
	M4U_PORT_DISP_OD_R,
	M4U_PORT_DISP_OD_W,
	M4U_PORT_DISP_2L_OVL0_LARB4,
	M4U_PORT_MDP_RDMA1,
	M4U_PORT_MDP_WROT1,
	M4U_PORT_DISP_FAKE_LARB4,

	M4U_PORT_CAM_IMGI,
	M4U_PORT_CAM_IMG2O,
	M4U_PORT_CAM_IMG3O,
	M4U_PORT_CAM_VIPI,
	M4U_PORT_CAM_ICEI,
	M4U_PORT_CAM_RP,
	M4U_PORT_CAM_WR,
	M4U_PORT_CAM_RB,
	M4U_PORT_CAM_DPE_RDMA,
	M4U_PORT_CAM_DPE_WDMA,
	M4U_PORT_CAM_RSC_RDMA,
	M4U_PORT_CAM_RSC_WDMA,
	M4U_PORT_CAM_GEPFI,
	M4U_PORT_CAM_GEPFO,

	M4U_PORT_UNKNOWN

};

#define M4U_PORT_NR M4U_PORT_UNKNOWN
#define M4U_PORT_CAM_DISP M4U_PORT_CAM_IMGO
#define M4U_PORT_CAM_MDP  M4U_PORT_CAM_IMGO

#endif
