
#ifndef _MT_DPE_H
#define _MT_DPE_H

#include <linux/ioctl.h>

#ifdef CONFIG_COMPAT
/* 64 bit */
#include <linux/fs.h>
#include <linux/compat.h>
#endif

/* enforce kernel log enable */
#define KERNEL_LOG  /* enable debug log flag if defined */

#define _SUPPORT_MAX_DPE_FRAME_REQUEST_ 32
#define _SUPPORT_MAX_DPE_REQUEST_RING_SIZE_ 32


#define SIG_ERESTARTSYS 512 /* ERESTARTSYS */
/*******************************************************************************
*
********************************************************************************/
#define DPE_DEV_MAJOR_NUMBER	251
#define DPE_MAGIC			   'd'

#define DPE_REG_RANGE		   (0x1000)
#define DPE_BASE_HW				0x15028000


#define DPE_DVE_INT_ST				((unsigned int)1<<1)
#define DPE_WMFE_INT_ST				((unsigned int)1<<2)

#define WMFE_CTRL_SIZE 5

typedef struct{
	unsigned int module;
	unsigned int Addr;		/* register's addr */
	unsigned int Val;		/* register's value */
} DPE_REG_STRUCT;

typedef struct{
	DPE_REG_STRUCT *pData;	/* pointer to DPE_REG_STRUCT */
	unsigned int Count;    /* count */
} DPE_REG_IO_STRUCT;

/* interrupt clear type */
typedef enum {
	DPE_IRQ_CLEAR_NONE,		/*non-clear wait, clear after wait */
	DPE_IRQ_CLEAR_WAIT,		/*clear wait, clear before and after wait */
	DPE_IRQ_WAIT_CLEAR,		/*wait the signal and clear it, avoid the hw executime is too s hort.  */
	DPE_IRQ_CLEAR_STATUS,	/*clear specific status only */
	DPE_IRQ_CLEAR_ALL		/*clear all status */
} DPE_IRQ_CLEAR_ENUM;


/* module's interrupt , each module should have its own isr. */
/* note: */
/* mapping to isr table,ISR_TABLE when using no device tree */

typedef enum{
		DPE_IRQ_TYPE_INT_DPE_ST,	/*DPE*/
		DPE_IRQ_TYPE_AMOUNT
} DPE_IRQ_TYPE_ENUM;

typedef struct{
	DPE_IRQ_CLEAR_ENUM  Clear;
	DPE_IRQ_TYPE_ENUM   Type;
	unsigned int		Status;		/* IRQ Status */
	unsigned int		Timeout;
	int				 UserKey;		/* user key for doing interrupt operation */
	int				 ProcessID;		/* user ProcessID (will filled in kernel) */
	unsigned int		bDumpReg;	/* check dump register or not*/
} DPE_WAIT_IRQ_STRUCT;

typedef struct{
	DPE_IRQ_TYPE_ENUM	 Type;
	int					UserKey;		/* user key for doing interrupt operation */
	unsigned int		   Status;			/* Input */
} DPE_CLEAR_IRQ_STRUCT;


typedef struct{
	unsigned int	DPE_DVE_CTRL;
	unsigned int	DPE_DVE_ORG_L_HORZ_BBOX;
	unsigned int	DPE_DVE_ORG_L_VERT_BBOX;
	unsigned int	DPE_DVE_ORG_R_HORZ_BBOX;
	unsigned int	DPE_DVE_ORG_R_VERT_BBOX;
	unsigned int	DPE_DVE_ORG_SIZE;
	unsigned int	DPE_DVE_ORG_SR_0;
	unsigned int	DPE_DVE_ORG_SR_1;
	unsigned int	DPE_DVE_ORG_SV;
	unsigned int	DPE_DVE_CAND_NUM;
	unsigned int	DPE_DVE_CAND_SEL_0;
	unsigned int	DPE_DVE_CAND_SEL_1;
	unsigned int	DPE_DVE_CAND_SEL_2;
	unsigned int	DPE_DVE_CAND_TYPE_0;
	unsigned int	DPE_DVE_CAND_TYPE_1;
	unsigned int	DPE_DVE_RAND_LUT;
	unsigned int	DPE_DVE_GMV;
	int				DPE_DVE_DV_INI;
	unsigned int	DPE_DVE_BLK_VAR_CTRL;
	unsigned int	DPE_DVE_SMTH_LUMA_CTRL;
	unsigned int	DPE_DVE_SMTH_DV_CTRL;
	unsigned int	DPE_DVE_ORD_CTRL;
	unsigned int	DPE_DVE_TYPE_CTRL_0;
	unsigned int	DPE_DVE_TYPE_CTRL_1;
	unsigned int	DPE_DVE_IMGI_L_BASE_ADDR;
	unsigned int	DPE_DVE_IMGI_L_STRIDE;
	unsigned int	DPE_DVE_IMGI_R_BASE_ADDR;
	unsigned int	DPE_DVE_IMGI_R_STRIDE;
	unsigned int	DPE_DVE_DVI_L_BASE_ADDR;
	unsigned int	DPE_DVE_DVI_L_STRIDE;
	unsigned int	DPE_DVE_DVI_R_BASE_ADDR;
	unsigned int	DPE_DVE_DVI_R_STRIDE;
	unsigned int	DPE_DVE_MASKI_L_BASE_ADDR;
	unsigned int	DPE_DVE_MASKI_L_STRIDE;
	unsigned int	DPE_DVE_MASKI_R_BASE_ADDR;
	unsigned int	DPE_DVE_MASKI_R_STRIDE;
	unsigned int	DPE_DVE_DVO_L_BASE_ADDR;
	unsigned int	DPE_DVE_DVO_L_STRIDE;
	unsigned int	DPE_DVE_DVO_R_BASE_ADDR;
	unsigned int	DPE_DVE_DVO_R_STRIDE;
	unsigned int	DPE_DVE_CONFO_L_BASE_ADDR;
	unsigned int	DPE_DVE_CONFO_L_STRIDE;
	unsigned int	DPE_DVE_CONFO_R_BASE_ADDR;
	unsigned int	DPE_DVE_CONFO_R_STRIDE;
	unsigned int	DPE_DVE_RESPO_L_BASE_ADDR;
	unsigned int	DPE_DVE_RESPO_L_STRIDE;
	unsigned int	DPE_DVE_RESPO_R_BASE_ADDR;
	unsigned int	DPE_DVE_RESPO_R_STRIDE;
	unsigned int	DPE_DVE_STA_0;	/* ReadOnly, DVE Statistic Result 0 */
} DPE_DVEConfig;


typedef struct{
	unsigned int	WMFE_CTRL;
	unsigned int	WMFE_SIZE;
	unsigned int	WMFE_IMGI_BASE_ADDR;
	unsigned int	WMFE_IMGI_STRIDE;
	unsigned int	WMFE_DPI_BASE_ADDR;
	unsigned int	WMFE_DPI_STRIDE;
	unsigned int	WMFE_TBLI_BASE_ADDR;
	unsigned int	WMFE_TBLI_STRIDE;
	unsigned int	WMFE_MASKI_BASE_ADDR;
	unsigned int	WMFE_MASKI_STRIDE;
	unsigned int	WMFE_DPO_BASE_ADDR;
	unsigned int	WMFE_DPO_STRIDE;
} DPE_WMFECtrl;


typedef struct{
	unsigned int	WmfeCtrlSize;
	DPE_WMFECtrl	WmfeCtrl[WMFE_CTRL_SIZE];
} DPE_WMFEConfig;


/*******************************************************************************
*
********************************************************************************/
typedef enum{
	DPE_CMD_RESET,				/* Reset */
	DPE_CMD_DUMP_REG,			/* Dump DPE Register */
	DPE_CMD_DUMP_ISR_LOG,		/* Dump DPE ISR log */
	DPE_CMD_READ_REG,			/* Read register from driver */
	DPE_CMD_WRITE_REG,			/* Write register to driver */
	DPE_CMD_WAIT_IRQ,			/* Wait IRQ */
	DPE_CMD_CLEAR_IRQ,			/* Clear IRQ */
	DPE_CMD_DVE_ENQUE_REQ,		/* DVE Enque Request */
	DPE_CMD_DVE_DEQUE_REQ,		/* DVE Deque Request */
	DPE_CMD_WMFE_ENQUE_REQ,		/* WMFE Enque Request */
	DPE_CMD_WMFE_DEQUE_REQ,		/* WMFE Deque Request */
	DPE_CMD_TOTAL,
} DPE_CMD_ENUM;

typedef struct{
	unsigned int  m_ReqNum;
	DPE_DVEConfig *m_pDpeConfig;
} DPE_DVERequest;


typedef struct{
	unsigned int  m_ReqNum;
	DPE_WMFEConfig *m_pWmfeConfig;
} DPE_WMFERequest;


#ifdef CONFIG_COMPAT
typedef struct{
	compat_uptr_t pData;
	unsigned int Count;  /* count */
} compat_DPE_REG_IO_STRUCT;


typedef struct{
	unsigned int  m_ReqNum;
	compat_uptr_t m_pDpeConfig;
} compat_DPE_DVERequest;

typedef struct{
	unsigned int  m_ReqNum;
	compat_uptr_t m_pWmfeConfig;
} compat_DPE_WMFERequest;

#endif

#define DPE_RESET			_IO(DPE_MAGIC, DPE_CMD_RESET)
#define DPE_DUMP_REG		_IO(DPE_MAGIC, DPE_CMD_DUMP_REG)
#define DPE_DUMP_ISR_LOG	_IO(DPE_MAGIC, DPE_CMD_DUMP_ISR_LOG)


#define DPE_READ_REGISTER	_IOWR(DPE_MAGIC, DPE_CMD_READ_REG, DPE_REG_IO_STRUCT)
#define DPE_WRITE_REGISTER	_IOWR(DPE_MAGIC, DPE_CMD_WRITE_REG, DPE_REG_IO_STRUCT)
#define DPE_WAIT_IRQ		_IOW(DPE_MAGIC, DPE_CMD_WAIT_IRQ, DPE_WAIT_IRQ_STRUCT)
#define DPE_CLEAR_IRQ		_IOW(DPE_MAGIC, DPE_CMD_CLEAR_IRQ, DPE_CLEAR_IRQ_STRUCT)

#define DPE_DVE_ENQUE_REQ	_IOWR(DPE_MAGIC, DPE_CMD_DVE_ENQUE_REQ, DPE_DVERequest)
#define DPE_DVE_DEQUE_REQ	_IOWR(DPE_MAGIC, DPE_CMD_DVE_DEQUE_REQ, DPE_DVERequest)
#define DPE_WMFE_ENQUE_REQ	_IOWR(DPE_MAGIC, DPE_CMD_WMFE_ENQUE_REQ, DPE_WMFERequest)
#define DPE_WMFE_DEQUE_REQ	_IOWR(DPE_MAGIC, DPE_CMD_WMFE_DEQUE_REQ, DPE_WMFERequest)


#ifdef CONFIG_COMPAT
#define COMPAT_DPE_WRITE_REGISTER	_IOWR(DPE_MAGIC, DPE_CMD_WRITE_REG, compat_DPE_REG_IO_STRUCT)
#define COMPAT_DPE_READ_REGISTER	_IOWR(DPE_MAGIC, DPE_CMD_READ_REG, compat_DPE_REG_IO_STRUCT)

#define COMPAT_DPE_DVE_ENQUE_REQ	_IOWR(DPE_MAGIC, DPE_CMD_DVE_ENQUE_REQ, compat_DPE_DVERequest)
#define COMPAT_DPE_DVE_DEQUE_REQ	_IOWR(DPE_MAGIC, DPE_CMD_DVE_DEQUE_REQ, compat_DPE_DVERequest)

#define COMPAT_DPE_WMFE_ENQUE_REQ	_IOWR(DPE_MAGIC, DPE_CMD_WMFE_ENQUE_REQ, compat_DPE_WMFERequest)
#define COMPAT_DPE_WMFE_DEQUE_REQ	_IOWR(DPE_MAGIC, DPE_CMD_WMFE_DEQUE_REQ, compat_DPE_WMFERequest)

#endif

#endif

