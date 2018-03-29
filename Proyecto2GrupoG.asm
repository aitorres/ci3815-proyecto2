.data
Letra: .word 0
endmessage: .asciiz " for Quality!"

.text

setup:	
	# Encendemos los bits 1 y 8 del registro Status
	# El 1 para activar Interrupciones
	# El 8 para pemitir interrupciones de nivel 1
	mfc0 $a0, $12
	ori $a0, 0x101 
	mtc0 $a0, $12
	
	# Encendemos el bit 2 del Receiver Control para
	# generar interrupciones si se recibe un caracter
	li $t0, 2
	sw $t0, 0xFFFF0000
	
	# Iterar hasta que se ingrese Q o q
main:	lw $s0, Letra
	beq $s0, 81, fin
	beq $s0, 113, fin
	b main
	
fin:	la $a0, endmessage
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall

.include "ManejadorDeExcepciones.asm"