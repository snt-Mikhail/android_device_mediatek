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
#ifndef _MT_EAF_H
#define _MT_EAF_H
#include <linux/ioctl.h>
#define KERNEL_LOG
#define _SUPPORT_MAX_EAF_FRAME_REQUEST_ 2
#define _SUPPORT_MAX_EAF_REQUEST_RING_SIZE_ 2
#define SIG_ERESTARTSYS 512
#define EAF_DEV_MAJOR_NUMBER 251
#define EAF_MAGIC 'e'
#define EAF_REG_RANGE (0x1000)
#define EAF_BASE_HW 0x1502D000
#define EAF_INT_ST (1 << 0)
typedef struct {
  unsigned int module;
  unsigned int Addr;
  unsigned int Val;
} EAF_REG_STRUCT;
typedef struct {
  EAF_REG_STRUCT * pData;
  unsigned int Count;
} EAF_REG_IO_STRUCT;
typedef enum {
  EAF_IRQ_CLEAR_NONE,
  EAF_IRQ_CLEAR_WAIT,
  EAF_IRQ_WAIT_CLEAR,
  EAF_IRQ_CLEAR_STATUS,
  EAF_IRQ_CLEAR_ALL
} EAF_IRQ_CLEAR_ENUM;
typedef enum {
  EAF_IRQ_TYPE_INT_EAF_ST,
  EAF_IRQ_TYPE_AMOUNT
} EAF_IRQ_TYPE_ENUM;
typedef struct {
  EAF_IRQ_CLEAR_ENUM Clear;
  EAF_IRQ_TYPE_ENUM Type;
  unsigned int Status;
  unsigned int Timeout;
  int UserKey;
  int ProcessID;
  unsigned int bDumpReg;
} EAF_WAIT_IRQ_STRUCT;
typedef struct {
  EAF_IRQ_TYPE_ENUM Type;
  int UserKey;
  unsigned int Status;
} EAF_CLEAR_IRQ_STRUCT;
typedef struct {
  unsigned int EAF_MAIN_CFG0;
  unsigned int EAF_MAIN_CFG1;
  unsigned int EAF_MAIN_CFG2;
  unsigned int EAF_MAIN_CFG3;
  unsigned int EAF_HIST_CFG0;
  unsigned int EAF_HIST_CFG1;
  unsigned int EAF_SRZ_CFG0;
  unsigned int EAF_BOXF_CFG0;
  unsigned int EAF_DIV_CFG0;
  unsigned int EAF_LKHF_CFG0;
  unsigned int EAF_LKHF_CFG1;
  unsigned int EAFI_MASK0;
  unsigned int EAFI_MASK1;
  unsigned int EAFI_MASK2;
  unsigned int EAFI_MASK3;
  unsigned int EAFI_CUR_Y0;
  unsigned int EAFI_CUR_Y1;
  unsigned int EAFI_CUR_Y2;
  unsigned int EAFI_CUR_Y3;
  unsigned int EAFI_CUR_UV0;
  unsigned int EAFI_CUR_UV1;
  unsigned int EAFI_CUR_UV2;
  unsigned int EAFI_CUR_UV3;
  unsigned int EAFI_PRE_Y0;
  unsigned int EAFI_PRE_Y1;
  unsigned int EAFI_PRE_Y2;
  unsigned int EAFI_PRE_Y3;
  unsigned int EAFI_PRE_UV0;
  unsigned int EAFI_PRE_UV1;
  unsigned int EAFI_PRE_UV2;
  unsigned int EAFI_PRE_UV3;
  unsigned int EAFI_DEP0;
  unsigned int EAFI_DEP1;
  unsigned int EAFI_DEP2;
  unsigned int EAFI_DEP3;
  unsigned int EAFI_LKH_WMAP0;
  unsigned int EAFI_LKH_WMAP1;
  unsigned int EAFI_LKH_WMAP2;
  unsigned int EAFI_LKH_WMAP3;
  unsigned int EAFI_LKH_EMAP0;
  unsigned int EAFI_LKH_EMAP1;
  unsigned int EAFI_LKH_EMAP2;
  unsigned int EAFI_LKH_EMAP3;
  unsigned int EAFI_PROB0;
  unsigned int EAFI_PROB1;
  unsigned int EAFI_PROB2;
  unsigned int EAFI_PROB3;
  unsigned int EAFO_FOUT0;
  unsigned int EAFO_FOUT1;
  unsigned int EAFO_FOUT2;
  unsigned int EAFO_FOUT3;
  unsigned int EAFO_FOUT4;
  unsigned int EAFO_POUT0;
  unsigned int EAFO_POUT1;
  unsigned int EAFO_POUT2;
  unsigned int EAFO_POUT3;
  unsigned int EAFO_POUT4;
  unsigned int EAF_MASK_LB_CTL0;
  unsigned int EAF_MASK_LB_CTL1;
  unsigned int EAF_PRE_Y_LB_CTL0;
  unsigned int EAF_PRE_Y_LB_CTL1;
  unsigned int EAF_PRE_UV_LB_CTL0;
  unsigned int EAF_PRE_UV_LB_CTL1;
  unsigned int EAF_CUR_UV_LB_CTL0;
  unsigned int EAF_CUR_UV_LB_CTL1;
  unsigned int EAF_DMA_DCM_DIS;
  unsigned int EAF_MAIN_DCM_DIS;
  unsigned int EAF_DMA_DCM_ST;
  unsigned int EAF_MAIN_DCM_ST;
  unsigned int EAF_INT_CTL;
  unsigned int JBFR_CFG0;
  unsigned int JBFR_CFG1;
  unsigned int JBFR_CFG2;
  unsigned int JBFR_CFG3;
  unsigned int JBFR_CFG4;
  unsigned int JBFR_CFG5;
  unsigned int JBFR_SIZE;
  unsigned int JBFR_CFG6;
  unsigned int JBFR_CFG7;
  unsigned int JBFR_CFG8;
  unsigned int SRZ6_CONTROL;
  unsigned int SRZ6_IN_IMG;
  unsigned int SRZ6_OUT_IMG;
  unsigned int SRZ6_HORI_STEP;
  unsigned int SRZ6_VERT_STEP;
  unsigned int SRZ6_HORI_INT_OFST;
  unsigned int SRZ6_HORI_SUB_OFST;
  unsigned int SRZ6_VERT_INT_OFST;
  unsigned int SRZ6_VERT_SUB_OFST;
  unsigned int EAF_DMA_SOFT_RSTSTAT;
  unsigned int EAF_TDRI_BASE_ADDR;
  unsigned int EAF_TDRI_OFST_ADDR;
  unsigned int EAF_TDRI_XSIZE;
  unsigned int EAF_VERTICAL_FLIP_EN;
  unsigned int EAF_DMA_SOFT_RESET;
  unsigned int EAF_LAST_ULTRA_EN;
  unsigned int EAF_SPECIAL_FUN_EN;
  unsigned int EAFO_BASE_ADDR;
  unsigned int EAFO_OFST_ADDR;
  unsigned int EAFO_XSIZE;
  unsigned int EAFO_YSIZE;
  unsigned int EAFO_STRIDE;
  unsigned int EAFO_CON;
  unsigned int EAFO_CON2;
  unsigned int EAFO_CON3;
  unsigned int EAFO_CROP;
  unsigned int EAFI_BASE_ADDR;
  unsigned int EAFI_OFST_ADDR;
  unsigned int EAFI_XSIZE;
  unsigned int EAFI_YSIZE;
  unsigned int EAFI_STRIDE;
  unsigned int EAFI_CON;
  unsigned int EAFI_CON2;
  unsigned int EAFI_CON3;
  unsigned int EAF2I_BASE_ADDR;
  unsigned int EAF2I_OFST_ADDR;
  unsigned int EAF2I_XSIZE;
  unsigned int EAF2I_YSIZE;
  unsigned int EAF2I_STRIDE;
  unsigned int EAF2I_CON;
  unsigned int EAF2I_CON2;
  unsigned int EAF2I_CON3;
  unsigned int EAF3I_BASE_ADDR;
  unsigned int EAF3I_OFST_ADDR;
  unsigned int EAF3I_XSIZE;
  unsigned int EAF3I_YSIZE;
  unsigned int EAF3I_STRIDE;
  unsigned int EAF3I_CON;
  unsigned int EAF3I_CON2;
  unsigned int EAF3I_CON3;
  unsigned int EAF4I_BASE_ADDR;
  unsigned int EAF4I_OFST_ADDR;
  unsigned int EAF4I_XSIZE;
  unsigned int EAF4I_YSIZE;
  unsigned int EAF4I_STRIDE;
  unsigned int EAF4I_CON;
  unsigned int EAF4I_CON2;
  unsigned int EAF4I_CON3;
  unsigned int EAF5I_BASE_ADDR;
  unsigned int EAF5I_OFST_ADDR;
  unsigned int EAF5I_XSIZE;
  unsigned int EAF5I_YSIZE;
  unsigned int EAF5I_STRIDE;
  unsigned int EAF5I_CON;
  unsigned int EAF5I_CON2;
  unsigned int EAF5I_CON3;
  unsigned int EAF6I_BASE_ADDR;
  unsigned int EAF6I_OFST_ADDR;
  unsigned int EAF6I_XSIZE;
  unsigned int EAF6I_YSIZE;
  unsigned int EAF6I_STRIDE;
  unsigned int EAF6I_CON;
  unsigned int EAF6I_CON2;
  unsigned int EAF6I_CON3;
} EAF_Config;
typedef enum {
  EAF_CMD_RESET,
  EAF_CMD_DUMP_REG,
  EAF_CMD_DUMP_ISR_LOG,
  EAF_CMD_READ_REG,
  EAF_CMD_WRITE_REG,
  EAF_CMD_WAIT_IRQ,
  EAF_CMD_CLEAR_IRQ,
  EAF_CMD_ENQUE_NUM,
  EAF_CMD_ENQUE,
  EAF_CMD_ENQUE_REQ,
  EAF_CMD_DEQUE_NUM,
  EAF_CMD_DEQUE,
  EAF_CMD_DEQUE_REQ,
  EAF_CMD_TOTAL,
} EAF_CMD_ENUM;
typedef struct {
  unsigned int m_ReqNum;
  EAF_Config * m_pEafConfig;
} EAF_Request;
#define EAF_RESET _IO(EAF_MAGIC, EAF_CMD_RESET)
#define EAF_DUMP_REG _IO(EAF_MAGIC, EAF_CMD_DUMP_REG)
#define EAF_DUMP_ISR_LOG _IO(EAF_MAGIC, EAF_CMD_DUMP_ISR_LOG)
#define EAF_READ_REGISTER _IOWR(EAF_MAGIC, EAF_CMD_READ_REG, EAF_REG_IO_STRUCT)
#define EAF_WRITE_REGISTER _IOWR(EAF_MAGIC, EAF_CMD_WRITE_REG, EAF_REG_IO_STRUCT)
#define EAF_WAIT_IRQ _IOW(EAF_MAGIC, EAF_CMD_WAIT_IRQ, EAF_WAIT_IRQ_STRUCT)
#define EAF_CLEAR_IRQ _IOW(EAF_MAGIC, EAF_CMD_CLEAR_IRQ, EAF_CLEAR_IRQ_STRUCT)
#define EAF_ENQNUE_NUM _IOW(EAF_MAGIC, EAF_CMD_ENQUE_NUM, int)
#define EAF_ENQUE _IOWR(EAF_MAGIC, EAF_CMD_ENQUE, EAF_Config)
#define EAF_ENQUE_REQ _IOWR(EAF_MAGIC, EAF_CMD_ENQUE_REQ, EAF_Request)
#define EAF_DEQUE_NUM _IOR(EAF_MAGIC, EAF_CMD_DEQUE_NUM, int)
#define EAF_DEQUE _IOWR(EAF_MAGIC, EAF_CMD_DEQUE, EAF_Config)
#define EAF_DEQUE_REQ _IOWR(EAF_MAGIC, EAF_CMD_DEQUE_REQ, EAF_Request)
#endif
