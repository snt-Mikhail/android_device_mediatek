/****************************************************************************
 ****************************************************************************
 ***
 ***   This header was automatically generated from a Linux kernel header
 ***   of the same name, to make information necessary for userspace to
 ***   call into the kernel available to libc.  It contains only constants,
 ***   structures, and macros generated from the original header, and thus,
 ***   contains no copyrightable information.
 ***
 ***   To edit the content of this header, modify the corresponding
 ***   source file (e.g. under external/kernel-headers/original/) then
 ***   run bionic/libc/kernel/tools/update_all.py
 ***
 ***   Any manual change here will be lost the next time this script will
 ***   be run. You've been warned!
 ***
 ****************************************************************************
 ****************************************************************************/
#ifndef _MT_DPE_H
#define _MT_DPE_H
#include <linux/ioctl.h>
#define KERNEL_LOG
#define _SUPPORT_MAX_DPE_FRAME_REQUEST_ 6
#define _SUPPORT_MAX_DPE_REQUEST_RING_SIZE_ 4
#define SIG_ERESTARTSYS 512
#define DPE_DEV_MAJOR_NUMBER 251
#define DPE_MAGIC 'd'
#define DPE_REG_RANGE (0x1000)
#define DPE_BASE_HW 0x15028000
#define DPE_DVE_INT_ST ((unsigned int) 1 << 1)
#define DPE_WMFE_INT_ST ((unsigned int) 1 << 2)
#define WMFE_CTRL_SIZE 5
struct DPE_REG_STRUCT {
  unsigned int module;
  unsigned int Addr;
  unsigned int Val;
};
struct DPE_REG_IO_STRUCT {
  struct DPE_REG_STRUCT * pData;
  unsigned int Count;
};
enum DPE_IRQ_CLEAR_ENUM {
  DPE_IRQ_CLEAR_NONE,
  DPE_IRQ_CLEAR_WAIT,
  DPE_IRQ_WAIT_CLEAR,
  DPE_IRQ_CLEAR_STATUS,
  DPE_IRQ_CLEAR_ALL
};
enum DPE_IRQ_TYPE_ENUM {
  DPE_IRQ_TYPE_INT_DPE_ST,
  DPE_IRQ_TYPE_AMOUNT
};
struct DPE_WAIT_IRQ_STRUCT {
  enum DPE_IRQ_CLEAR_ENUM Clear;
  enum DPE_IRQ_TYPE_ENUM Type;
  unsigned int Status;
  unsigned int Timeout;
  int UserKey;
  int ProcessID;
  unsigned int bDumpReg;
};
struct DPE_CLEAR_IRQ_STRUCT {
  enum DPE_IRQ_TYPE_ENUM Type;
  int UserKey;
  unsigned int Status;
};
struct DPE_DVEConfig {
  unsigned int DPE_DVE_CTRL;
  unsigned int DPE_DVE_ORG_L_HORZ_BBOX;
  unsigned int DPE_DVE_ORG_L_VERT_BBOX;
  unsigned int DPE_DVE_ORG_R_HORZ_BBOX;
  unsigned int DPE_DVE_ORG_R_VERT_BBOX;
  unsigned int DPE_DVE_ORG_SIZE;
  unsigned int DPE_DVE_ORG_SR_0;
  unsigned int DPE_DVE_ORG_SR_1;
  unsigned int DPE_DVE_ORG_SV;
  unsigned int DPE_DVE_CAND_NUM;
  unsigned int DPE_DVE_CAND_SEL_0;
  unsigned int DPE_DVE_CAND_SEL_1;
  unsigned int DPE_DVE_CAND_SEL_2;
  unsigned int DPE_DVE_CAND_TYPE_0;
  unsigned int DPE_DVE_CAND_TYPE_1;
  unsigned int DPE_DVE_RAND_LUT;
  unsigned int DPE_DVE_GMV;
  int DPE_DVE_DV_INI;
  unsigned int DPE_DVE_BLK_VAR_CTRL;
  unsigned int DPE_DVE_SMTH_LUMA_CTRL;
  unsigned int DPE_DVE_SMTH_DV_CTRL;
  unsigned int DPE_DVE_ORD_CTRL;
  unsigned int DPE_DVE_TYPE_CTRL_0;
  unsigned int DPE_DVE_TYPE_CTRL_1;
  unsigned int DPE_DVE_IMGI_L_BASE_ADDR;
  unsigned int DPE_DVE_IMGI_L_STRIDE;
  unsigned int DPE_DVE_IMGI_R_BASE_ADDR;
  unsigned int DPE_DVE_IMGI_R_STRIDE;
  unsigned int DPE_DVE_DVI_L_BASE_ADDR;
  unsigned int DPE_DVE_DVI_L_STRIDE;
  unsigned int DPE_DVE_DVI_R_BASE_ADDR;
  unsigned int DPE_DVE_DVI_R_STRIDE;
  unsigned int DPE_DVE_MASKI_L_BASE_ADDR;
  unsigned int DPE_DVE_MASKI_L_STRIDE;
  unsigned int DPE_DVE_MASKI_R_BASE_ADDR;
  unsigned int DPE_DVE_MASKI_R_STRIDE;
  unsigned int DPE_DVE_DVO_L_BASE_ADDR;
  unsigned int DPE_DVE_DVO_L_STRIDE;
  unsigned int DPE_DVE_DVO_R_BASE_ADDR;
  unsigned int DPE_DVE_DVO_R_STRIDE;
  unsigned int DPE_DVE_CONFO_L_BASE_ADDR;
  unsigned int DPE_DVE_CONFO_L_STRIDE;
  unsigned int DPE_DVE_CONFO_R_BASE_ADDR;
  unsigned int DPE_DVE_CONFO_R_STRIDE;
  unsigned int DPE_DVE_RESPO_L_BASE_ADDR;
  unsigned int DPE_DVE_RESPO_L_STRIDE;
  unsigned int DPE_DVE_RESPO_R_BASE_ADDR;
  unsigned int DPE_DVE_RESPO_R_STRIDE;
  unsigned int DPE_DVE_STA_0;
};
struct DPE_WMFECtrl {
  unsigned int WMFE_CTRL;
  unsigned int WMFE_SIZE;
  unsigned int WMFE_IMGI_BASE_ADDR;
  unsigned int WMFE_IMGI_STRIDE;
  unsigned int WMFE_DPI_BASE_ADDR;
  unsigned int WMFE_DPI_STRIDE;
  unsigned int WMFE_TBLI_BASE_ADDR;
  unsigned int WMFE_TBLI_STRIDE;
  unsigned int WMFE_MASKI_BASE_ADDR;
  unsigned int WMFE_MASKI_STRIDE;
  unsigned int WMFE_DPO_BASE_ADDR;
  unsigned int WMFE_DPO_STRIDE;
};
struct DPE_WMFEConfig {
  unsigned int WmfeCtrlSize;
  struct DPE_WMFECtrl WmfeCtrl[WMFE_CTRL_SIZE];
};
enum DPE_CMD_ENUM {
  DPE_CMD_RESET,
  DPE_CMD_DUMP_REG,
  DPE_CMD_DUMP_ISR_LOG,
  DPE_CMD_READ_REG,
  DPE_CMD_WRITE_REG,
  DPE_CMD_WAIT_IRQ,
  DPE_CMD_CLEAR_IRQ,
  DPE_CMD_DVE_ENQUE_REQ,
  DPE_CMD_DVE_DEQUE_REQ,
  DPE_CMD_WMFE_ENQUE_REQ,
  DPE_CMD_WMFE_DEQUE_REQ,
  DPE_CMD_TOTAL,
};
struct DPE_DVERequest {
  unsigned int m_ReqNum;
  struct DPE_DVEConfig * m_pDpeConfig;
};
struct DPE_WMFERequest {
  unsigned int m_ReqNum;
  struct DPE_WMFEConfig * m_pWmfeConfig;
};
#define DPE_RESET _IO(DPE_MAGIC, DPE_CMD_RESET)
#define DPE_DUMP_REG _IO(DPE_MAGIC, DPE_CMD_DUMP_REG)
#define DPE_DUMP_ISR_LOG _IO(DPE_MAGIC, DPE_CMD_DUMP_ISR_LOG)
#define DPE_READ_REGISTER _IOWR(DPE_MAGIC, DPE_CMD_READ_REG, struct DPE_REG_IO_STRUCT)
#define DPE_WRITE_REGISTER _IOWR(DPE_MAGIC, DPE_CMD_WRITE_REG, struct DPE_REG_IO_STRUCT)
#define DPE_WAIT_IRQ _IOW(DPE_MAGIC, DPE_CMD_WAIT_IRQ, struct DPE_WAIT_IRQ_STRUCT)
#define DPE_CLEAR_IRQ _IOW(DPE_MAGIC, DPE_CMD_CLEAR_IRQ, struct DPE_CLEAR_IRQ_STRUCT)
#define DPE_DVE_ENQUE_REQ _IOWR(DPE_MAGIC, DPE_CMD_DVE_ENQUE_REQ, struct DPE_DVERequest)
#define DPE_DVE_DEQUE_REQ _IOWR(DPE_MAGIC, DPE_CMD_DVE_DEQUE_REQ, struct DPE_DVERequest)
#define DPE_WMFE_ENQUE_REQ _IOWR(DPE_MAGIC, DPE_CMD_WMFE_ENQUE_REQ, struct DPE_WMFERequest)
#define DPE_WMFE_DEQUE_REQ _IOWR(DPE_MAGIC, DPE_CMD_WMFE_DEQUE_REQ, struct DPE_WMFERequest)
#endif
