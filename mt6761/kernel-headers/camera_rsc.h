
#ifndef _MT_RSC_H
#define _MT_RSC_H

#include <linux/ioctl.h>

#ifdef CONFIG_COMPAT
/* 64 bit */
#include <linux/fs.h>
#include <linux/compat.h>
#endif

/*
 *   enforce kernel log enable
 */
#define KERNEL_LOG		/* enable debug log flag if defined */

#define _SUPPORT_MAX_RSC_FRAME_REQUEST_ 32
#define _SUPPORT_MAX_RSC_REQUEST_RING_SIZE_ 32


#define SIG_ERESTARTSYS 512	/* ERESTARTSYS */
/*
 *
 */
#define RSC_DEV_MAJOR_NUMBER    251

#define RSC_MAGIC               'r'

#define RSC_REG_RANGE           (0x1000)

#define RSC_BASE_HW   0x15029000

/*This macro is for setting irq status represnted
* by a local variable,RSCInfo.IrqInfo.Status[RSC_IRQ_TYPE_INT_RSC_ST]
*/
#define RSC_INT_ST                 ((unsigned int)1<<0)


typedef struct {
	unsigned int module;
	unsigned int Addr;	/* register's addr */
	unsigned int Val;	/* register's value */
} RSC_REG_STRUCT;

typedef struct {
	RSC_REG_STRUCT *pData;	/* pointer to RSC_REG_STRUCT */
	unsigned int Count;	/* count */
} RSC_REG_IO_STRUCT;

/*
 *   interrupt clear type
 */
typedef enum {
	RSC_IRQ_CLEAR_NONE,	/* non-clear wait, clear after wait */
	RSC_IRQ_CLEAR_WAIT,	/* clear wait, clear before and after wait */
	RSC_IRQ_WAIT_CLEAR,	/* wait the signal and clear it, avoid the hw executime is too s hort. */
	RSC_IRQ_CLEAR_STATUS,	/* clear specific status only */
	RSC_IRQ_CLEAR_ALL	/* clear all status */
} RSC_IRQ_CLEAR_ENUM;


/*
 *   module's interrupt , each module should have its own isr.
 *   note:
 *	mapping to isr table,ISR_TABLE when using no device tree
 */
typedef enum {
	RSC_IRQ_TYPE_INT_RSC_ST,	/* RSC */
	RSC_IRQ_TYPE_AMOUNT
} RSC_IRQ_TYPE_ENUM;

typedef struct {
	RSC_IRQ_CLEAR_ENUM Clear;
	RSC_IRQ_TYPE_ENUM Type;
	unsigned int Status;	/*IRQ Status */
	unsigned int Timeout;
	int UserKey;		/* user key for doing interrupt operation */
	int ProcessID;		/* user ProcessID (will filled in kernel) */
	unsigned int bDumpReg;	/* check dump register or not */
} RSC_WAIT_IRQ_STRUCT;

typedef struct {
	RSC_IRQ_TYPE_ENUM Type;
	int UserKey;		/* user key for doing interrupt operation */
	unsigned int Status;	/* Input */
} RSC_CLEAR_IRQ_STRUCT;




typedef struct {
	unsigned int RSC_CTRL;
	unsigned int RSC_SIZE;
	unsigned int RSC_IMGI_C_BASE_ADDR;
	unsigned int RSC_IMGI_C_STRIDE;
	unsigned int RSC_IMGI_P_BASE_ADDR;
	unsigned int RSC_IMGI_P_STRIDE;
	unsigned int RSC_MVI_BASE_ADDR;
	unsigned int RSC_MVI_STRIDE;
	unsigned int RSC_APLI_C_BASE_ADDR;
	unsigned int RSC_APLI_P_BASE_ADDR;
	unsigned int RSC_MVO_BASE_ADDR;
	unsigned int RSC_MVO_STRIDE;
	unsigned int RSC_BVO_BASE_ADDR;
	unsigned int RSC_BVO_STRIDE;
#define RSC_TUNABLE
#ifdef RSC_TUNABLE
	unsigned int RSC_MV_OFFSET;
	unsigned int RSC_GMV_OFFSET;
	unsigned int RSC_CAND_NUM;
	unsigned int RSC_RAND_HORZ_LUT;
	unsigned int RSC_RAND_VERT_LUT;
	unsigned int RSC_SAD_CTRL;
	unsigned int RSC_SAD_EDGE_GAIN_CTRL;
	unsigned int RSC_SAD_CRNR_GAIN_CTRL;
	unsigned int RSC_STILL_STRIP_CTRL0;
	unsigned int RSC_STILL_STRIP_CTRL1;
	unsigned int RSC_RAND_PNLTY_CTRL;
	unsigned int RSC_RAND_PNLTY_GAIN_CTRL0;
	unsigned int RSC_RAND_PNLTY_GAIN_CTRL1;
#endif
} RSC_Config;

/*
 *
 */
typedef enum {
	RSC_CMD_RESET,		/* Reset */
	RSC_CMD_DUMP_REG,	/* Dump RSC Register */
	RSC_CMD_DUMP_ISR_LOG,	/* Dump RSC ISR log */
	RSC_CMD_READ_REG,	/* Read register from driver */
	RSC_CMD_WRITE_REG,	/* Write register to driver */
	RSC_CMD_WAIT_IRQ,	/* Wait IRQ */
	RSC_CMD_CLEAR_IRQ,	/* Clear IRQ */
	RSC_CMD_ENQUE_NUM,	/* RSC Enque Number */
	RSC_CMD_ENQUE,		/* RSC Enque */
	RSC_CMD_ENQUE_REQ,	/* RSC Enque Request */
	RSC_CMD_DEQUE_NUM,	/* RSC Deque Number */
	RSC_CMD_DEQUE,		/* RSC Deque */
	RSC_CMD_DEQUE_REQ,	/* RSC Deque Request */
	RSC_CMD_TOTAL,
} RSC_CMD_ENUM;
/*  */

typedef struct {
	unsigned int m_ReqNum;
	RSC_Config *m_pRscConfig;
} RSC_Request;






#ifdef CONFIG_COMPAT
typedef struct {
	compat_uptr_t pData;
	unsigned int Count;	/* count */
} compat_RSC_REG_IO_STRUCT;

typedef struct {
	unsigned int m_ReqNum;
	compat_uptr_t m_pRscConfig;
} compat_RSC_Request;


#endif




#define RSC_RESET           _IO(RSC_MAGIC, RSC_CMD_RESET)
#define RSC_DUMP_REG        _IO(RSC_MAGIC, RSC_CMD_DUMP_REG)
#define RSC_DUMP_ISR_LOG    _IO(RSC_MAGIC, RSC_CMD_DUMP_ISR_LOG)


#define RSC_READ_REGISTER   _IOWR(RSC_MAGIC, RSC_CMD_READ_REG,        RSC_REG_IO_STRUCT)
#define RSC_WRITE_REGISTER  _IOWR(RSC_MAGIC, RSC_CMD_WRITE_REG,       RSC_REG_IO_STRUCT)
#define RSC_WAIT_IRQ        _IOW(RSC_MAGIC, RSC_CMD_WAIT_IRQ,        RSC_WAIT_IRQ_STRUCT)
#define RSC_CLEAR_IRQ       _IOW(RSC_MAGIC, RSC_CMD_CLEAR_IRQ,       RSC_CLEAR_IRQ_STRUCT)

#define RSC_ENQNUE_NUM  _IOW(RSC_MAGIC, RSC_CMD_ENQUE_NUM,    int)
#define RSC_ENQUE      _IOWR(RSC_MAGIC, RSC_CMD_ENQUE,      RSC_Config)
#define RSC_ENQUE_REQ  _IOWR(RSC_MAGIC, RSC_CMD_ENQUE_REQ,  RSC_Request)

#define RSC_DEQUE_NUM  _IOR(RSC_MAGIC, RSC_CMD_DEQUE_NUM,    int)
#define RSC_DEQUE      _IOWR(RSC_MAGIC, RSC_CMD_DEQUE,      RSC_Config)
#define RSC_DEQUE_REQ  _IOWR(RSC_MAGIC, RSC_CMD_DEQUE_REQ,  RSC_Request)


#ifdef CONFIG_COMPAT
#define COMPAT_RSC_WRITE_REGISTER   _IOWR(RSC_MAGIC, RSC_CMD_WRITE_REG,     compat_RSC_REG_IO_STRUCT)
#define COMPAT_RSC_READ_REGISTER    _IOWR(RSC_MAGIC, RSC_CMD_READ_REG,      compat_RSC_REG_IO_STRUCT)

#define COMPAT_RSC_ENQUE_REQ   _IOWR(RSC_MAGIC, RSC_CMD_ENQUE_REQ,  compat_RSC_Request)
#define COMPAT_RSC_DEQUE_REQ   _IOWR(RSC_MAGIC, RSC_CMD_DEQUE_REQ,  compat_RSC_Request)

#endif

/*  */
#endif
