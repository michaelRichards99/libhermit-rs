.section .text
.extern do_bad_mode
.extern do_irq
.extern do_fiq
.extern do_sync
.extern do_error

.macro trap_entry
     stp x29, x30, [sp, #-16]!
     stp x27, x28, [sp, #-16]!
     stp x25, x26, [sp, #-16]!
     stp x23, x24, [sp, #-16]!
     stp x21, x22, [sp, #-16]!
     stp x19, x20, [sp, #-16]!
     stp x17, x18, [sp, #-16]!
     stp x15, x16, [sp, #-16]!
     stp x13, x14, [sp, #-16]!
     stp x11, x12, [sp, #-16]!
     stp x9, x10, [sp, #-16]!
     stp x7, x8, [sp, #-16]!
     stp x5, x6, [sp, #-16]!
     stp x3, x4, [sp, #-16]!
     stp x1, x2, [sp, #-16]!

     mrs x22, tpidr_el0
     stp x22, x0, [sp, #-16]!

     mrs x22, elr_el1
     mrs x23, spsr_el1
     stp x22, x23, [sp, #-16]!
.endm

.macro trap_exit
     ldp x22, x23, [sp], #16
     msr elr_el1, x22
     msr spsr_el1, x23

     ldp x22, x0, [sp], #16
     msr tpidr_el0, x22

     ldp x1, x2, [sp], #16
     ldp x3, x4, [sp], #16
     ldp x5, x6, [sp], #16
     ldp x7, x8, [sp], #16
     ldp x9, x10, [sp], #16
     ldp x11, x12, [sp], #16
     ldp x13, x14, [sp], #16
     ldp x15, x16, [sp], #16
     ldp x17, x18, [sp], #16
     ldp x19, x20, [sp], #16
     ldp x21, x22, [sp], #16
     ldp x23, x24, [sp], #16
     ldp x25, x26, [sp], #16
     ldp x27, x28, [sp], #16
     ldp x29, x30, [sp], #16
.endm

/*
 * Exception vector entry
 */
.macro ventry label
.align  7
b       \label
.endm

.macro invalid, reason
mov     x0, sp
mov     x1, #\reason
b       do_bad_mode
.endm

/*
 * SYNC exception handler.
 */
.align 6
el1_sync:
      trap_entry
      mov     x0, sp
      bl      do_sync
      trap_exit
      eret
.size el1_sync, .-el1_sync
.type el1_sync, @function

/*
 * IRQ handler.
 */
.align 6
el1_irq:
      trap_entry
      mov     x0, sp
      bl      do_irq
      trap_exit
      eret
.size el1_irq, .-el1_irq
.type el1_irq, @function

/*
 * FIQ handler.
 */
.align 6
el1_fiq:
      trap_entry
      mov     x0, sp
      bl      do_fiq
      trap_exit
      eret
.size el1_fiq, .-el1_fiq
.type el1_fiq, @function

.align 6
el1_error:
      trap_entry
      mov     x0, sp
      bl      do_error
      trap_exit
      eret
.size el1_error, .-el1_error
.type el1_error, @function

el0_sync_invalid:
   invalid 0
.type el0_sync_invalid, @function

el0_irq_invalid:
   invalid 1
.type el0_irq_invalid, @function

el0_fiq_invalid:
   invalid 2
.type el0_fiq_invalid, @function

el0_error_invalid:
   invalid 3
.type el0_error_invalid, @function

el1_sync_invalid:
   invalid 0
.type el1_sync_invalid, @function

el1_irq_invalid:
   invalid 1
.type el1_irq_invalid, @function

el1_fiq_invalid:
   invalid 2
.type el1_fiq_invalid, @function

el1_error_invalid:
   invalid 3
.type el1_error_invalid, @function

/* start of the data section */
.section .rodata
.align  11
.global vector_table
vector_table:
/* Current EL with SP0 */
ventry el1_sync_invalid	        // Synchronous EL1t
ventry el1_irq_invalid	        // IRQ EL1t
ventry el1_fiq_invalid	        // FIQ EL1t
ventry el1_error_invalid        // Error EL1t

/* Current EL with SPx */
ventry el1_sync                 // Synchronous EL1h
ventry el1_irq                  // IRQ EL1h
ventry el1_fiq                  // FIQ EL1h
ventry el1_error                // Error EL1h

/* Lower EL using AArch64 */
ventry el0_sync_invalid         // Synchronous 64-bit EL0
ventry el0_irq_invalid          // IRQ 64-bit EL0
ventry el0_fiq_invalid          // FIQ 64-bit EL0
ventry el0_error_invalid        // Error 64-bit EL0

/* Lower EL using AArch32 */
ventry el0_sync_invalid         // Synchronous 32-bit EL0
ventry el0_irq_invalid          // IRQ 32-bit EL0
ventry el0_fiq_invalid          // FIQ 32-bit EL0
ventry el0_error_invalid        // Error 32-bit EL0
.size vector_table, .-vector_table