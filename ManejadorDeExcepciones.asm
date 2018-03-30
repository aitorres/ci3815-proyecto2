.kdata
__m1_: .asciiz " Exception "
__m2_: .asciiz " occurred and ignored\n"
__e0_: .asciiz " [Interrupt] "
__e1_: .asciiz " [TLB]"
__e2_: .asciiz " [TLB]"
__e3_: .asciiz " [TLB]"
__e4_: .asciiz " [Address error in inst/data fetch] "
__e5_: .asciiz " [Address error in store] "
__e6_: .asciiz " [Bad instruction address] "
__e7_: .asciiz " [Bad data address] "
__e8_: .asciiz " [Error in syscall] "
__e9_: .asciiz " [Breakpoint] "
__e10_: .asciiz " [Reserved instruction] "
__e11_: .asciiz ""
__e12_: .asciiz " [Arithmetic overflow] "
__e13_: .asciiz " [Trap] "
__e14_: .asciiz ""
__e15_: .asciiz " [Floating point] "
__e16_: .asciiz ""
__e17_: .asciiz ""
__e18_: .asciiz " [Coproc 2]"
__e19_: .asciiz ""
__e20_: .asciiz ""
__e21_: .asciiz ""
__e22_: .asciiz " [MDMX]"
__e23_: .asciiz " [Watch]"
__e24_: .asciiz " [Machine check]"
__e25_: .asciiz ""
__e26_: .asciiz ""
__e27_: .asciiz ""
__e28_: .asciiz ""
__e29_: .asciiz ""
__e30_: .asciiz " [Cache]"
__e31_: .asciiz ""
__excp: .word __e0_, __e1_, __e2_, __e3_, __e4_, __e5_, __e6_, __e7_, __e8_, __e9_
.word __e10_, __e11_, __e12_, __e13_, __e14_, __e15_, __e16_, __e17_, __e18_,
.word __e19_, __e20_, __e21_, __e22_, __e23_, __e24_, __e25_, __e26_, __e27_,
.word __e28_, __e29_, __e30_, __e31_
s1: .word 0
s2: .word 0
timsave: .word 0
timermessage: .asciiz "TIMER!!!"

# This is the exception handler code that the processor runs when
# an exception occurs. It only prints some information about the
# exception, but can server as a model of how to write a handler.
#
# Because we are running in the kernel, we can use $k0/$k1 without
# saving their old values.
# This is the exception vector address for MIPS32:
.ktext 0x80000180

.set noat
	move $k1 $at # Save $at
	
.set at
	sw $v0 s1 # Not re-entrant and we can't trust $sp
	sw $a0 s2 # But we need to use these registers
	
	mfc0 $a0, $9
	sw $a0, timsave # Save the timer
	
		# Disable interrupts
	mfc0 $k0 $12
	andi $k0 0xfffffffe
	mtc0 $k0 $12
	
	mfc0 $k0 $13 # Cause register

# Print information about exception.

	li $v0 4 # syscall 4 (print_str)
	la $a0 __m1_
	syscall
	
	li $v0 1 # syscall 1 (print_int)
	srl $a0 $k0 2 # Extract ExcCode Field
	andi $a0 $a0 0x1f
	syscall
	
	li $v0 4 # syscall 4 (print_str)
	andi $a0 $k0 0x3c
	lw $a0 __excp($a0)
	nop
	syscall
	
	bne $k0 0x18 ok_pc # Bad PC exception requires special checks
	nop
	mfc0 $a0 $14 # EPC
	andi $a0 $a0 0x3 # Is EPC word-aligned?
	beq $a0 0 ok_pc
	nop
	li $v0 10 # Exit on really bad PC
	syscall
	
ok_pc:
	li $v0 4 # syscall 4 (print_str)
	la $a0 __m2_
	syscall
	
	srl $a0 $k0 2 # Extract ExcCode Field
	andi $a0 $a0 0x1f
	bne $a0 0 ret # 0 means exception was an interrupt
	nop
	
Interrupcion:
	# Verificamos si la interrupción es de teclado
	IntTeclado:
	lw $a0, 0xFFFF0000
	andi $a0, $a0, 0x1
	beqz $a0, IntTimer

	li $v0, 11
	lw $a0, 0xFFFF0004 
	syscall
	
	sw $a0, Letra
	b retInt
	
	IntTimer:
	li $v0, 1
	sw $v0, Timer
	
	li $v0, 4
	la $a0, timermessage
	syscall
	
	b retInt

# Manejador del timer


ret:
# Return from (non-interrupt) exception. Skip offending instruction
# at EPC to avoid infinite loop.
#
	mfc0 $k0 $14 # Bump EPC register
	addiu $k0 $k0 4 # Skip faulting instruction

# (Need to handle delayed branch case here)
	mtc0 $k0 $14

# Restore registers and reset procesor state
retInt:
	lw $a0, timsave
	mtc0 $a0, $9
	lw $v0 s1 # Restore other registers
	lw $a0 s2
.set noat
	move $at $k1 # Restore $at
.set at
	mtc0 $0 $13 # Clear Cause register
	mfc0 $k0 $12 # Set Status register
	ori $k0 0x1 # Interrupts enabled
	mtc0 $k0 $12

# Retornar de la excepción (al epc)
	eret
