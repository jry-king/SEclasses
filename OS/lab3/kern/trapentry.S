/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
// 9 and 15 are reserved
TRAPHANDLER_NOEC(ENTRY_DIVIDE, T_DIVIDE)	// divide error
TRAPHANDLER_NOEC(ENTRY_DEBUG, T_DEBUG)		// debug exception
TRAPHANDLER_NOEC(ENTRY_NMI, T_NMI)		// non-maskable interrupt
TRAPHANDLER_NOEC(ENTRY_BRKPT, T_BRKPT)		// breakpoint
TRAPHANDLER_NOEC(ENTRY_OFLOW, T_OFLOW)		// overflow
TRAPHANDLER_NOEC(ENTRY_BOUND, T_BOUND)		// bounds check
TRAPHANDLER_NOEC(ENTRY_ILLOP, T_ILLOP)		// illegal opcode
TRAPHANDLER_NOEC(ENTRY_DEVICE, T_DEVICE)	// device not available
TRAPHANDLER(ENTRY_DBLFLT, T_DBLFLT)		// double fault
TRAPHANDLER(ENTRY_TSS, T_TSS)			// invalid task switch segment
TRAPHANDLER(ENTRY_SEGNP, T_SEGNP)		// segment not present
TRAPHANDLER(ENTRY_STACK, T_STACK)		// stack exception
TRAPHANDLER(ENTRY_GPFLT, T_GPFLT)		// general protection fault
TRAPHANDLER(ENTRY_PGFLT, T_PGFLT)		// page fault
TRAPHANDLER_NOEC(ENTRY_FPERR, T_FPERR)		// floating point error
TRAPHANDLER(ENTRY_ALIGN, T_ALIGN)		// alignment check
TRAPHANDLER_NOEC(ENTRY_MCHK, T_MCHK)		// machine check
TRAPHANDLER_NOEC(ENTRY_SIMDERR, T_SIMDERR)	// SIMD floating point error
TRAPHANDLER_NOEC(ENTRY_SYSCALL, T_SYSCALL)	// system call

/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps;
.type _alltraps,@function;
.align 2;
_alltraps:
	pushl %ds
	pushl %es
	pushal
	movl $GD_KD, %eax
	movw %ax, %ds
	movw %ax, %es
	pushl %esp
	call trap

.global sysenter_handler
.type sysenter_handler, @function					
.align 2
sysenter_handler:
	pushl %esi
	pushl %edi 
	pushl %ebx
	pushl %ecx 
	pushl %edx
	pushl %eax
	call syscall
	movl %esi, %edx
	movl %ebp, %ecx
	sysexit
