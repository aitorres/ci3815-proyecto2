######################### INSTRUCCIONES #########################
# 1) Abrir Tools > Keyboard and Display MMIO Simulator
# 2) En Tool Control, hacer click en Connect to MIPS
# 3) Abrir Tools > Bitmap Display
# 4) Ajustar los valores:
#	4.1) Unit Width in Pixels: 16
#	4.2) Unit Height in Pixels: 16
#	4.3) Display Width in Pixels: 512
#	4.4) Display Height in Pixels: 512
#	4.5) Base address for display: 0x10040000 (heap)
# 5) Aumentar el tamaño del Bitmap Display para verlo completo
# 6) En Tool Control, hacer click en Connect to MIPS
# 7) Ensamblar
# 8) Correr :-)
##################################################################

.data
Display: .word 0
Tamano: .word 1024
Inicio: .word 0
Letra: .word 0
Barra: .word 0
UltimaFila: .word 3968
Vx: .word 0
Vy: .word 0
Azul1: .word 0x000077
Azul2: .word 0x0000a7
Azul3: .word 0x0000f4
Amarillo: .word 0xFFFF30
Verde1: .word 0x005000
Verde2: .word 0x008000
Verde3: .word 0x00b000
Verde4: .word 0x00fa00
Gris: .word 0x111111
Negro: .word 0x000000
endmessage: .asciiz " for Quality!"
leftmessage: .asciiz "Te moviste a la izquierda"
rightmessage: .asciiz "Te moviste a la derecha"
pausemessage: .asciiz "Juego en pausa"  

.text
setup:	# Reservamos el Bitmap Display en el Heap
	li $a0, 1024
	li $v0, 9
	syscall
	
	# Guardamos en la etiqueta DIsplay la dirección que obtuvimos del Heap
	sw $v0, Display
	
	# Cargamos en $s0 la dirección del Bitmap Display
	lw $s0, Display
	
	# Cargamos en $t1 el tamaño en bloques del Display
	lw $t1, Tamano
	
	# Copiamos en $t2 la dirección del Display para pintar
	move $t2, $s0
	
	# Copiamos en los registros $t3 a $t6 los colores para pintar
	# el tablero de juego
	lw $t3, Verde1
	lw $t4, Verde2
	lw $t5, Verde3
	
	# Cargamos los ladrillos. Son 128 ladrillos que hay que colorear
	# Para poder rellenar 4 hileras
CargarLadrillos:
	# Coloreamos de dos tonos los primeros dos ladrillos
	sw $t3,  0($t2)
	sw $t4,  4($t2)
	addiu $t2, $t2, 8 # Dos desplazamos dos bytes en el Display
	
	# Nos restan 126 hileras, por lo que iteramos de 6 en 6
	li $t9, 126
	
	cargarLoop:
	beqz $t9, LadrillosCargados # Si ya coloreamos los 126 ladrillos restantes, saltar
	sw $t5,  0($t2)
	sw $t3,  4($t2)
	sw $t4,  8($t2)
	sw $t5, 12($t2)
	sw $t3, 16($t2)
	sw $t4, 20($t2)
	
	addiu $t2, $t2, 24
	addiu $t9, $t9, -6
	b cargarLoop
			
LadrillosCargados:
	
	# Pintamos el fondo, por motivos estéticos
	# Hay que pintar 800 bloques
	lw $t3, Gris
	li $t9, 800
	
	pintarFondoloop:
	beqz $t9, FondoPintado
	sw $t3,  0($t2)
	sw $t3,  4($t2)
	sw $t3,  8($t2)
	sw $t3, 12($t2)
	
	addiu $t2, $t2, 16
	addiu $t9, $t9, -4
	b pintarFondoloop

FondoPintado:
	addiu $t2, $t2, 128
	
	# Pintamos la pelota
	lw $t3, Amarillo
	sw $t3, 60($t2)
	
	addiu $t2, $t2, 128
	
	# Pintamos la barra
	lw $t3, Azul1
	lw $t4, Azul2
	lw $t5, Azul3
	
	sw $t3, 52($t2)
	sw $t4, 56($t2)
	sw $t5, 60($t2)
	sw $t4, 64($t2)
	sw $t3, 68($t2)
	
	# Guardamos la posición en bits de la barra (dada por su extremo izquierdo)
	li $t9, 52
	sw $t9, Barra
	
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
	
	# Para imprimir mensajes al presionar teclas (debugging)
	li $v0, 4
	
	# Iterar hasta que se ingrese Q o q
main:	
	lw $s7, Letra
	beq $s7, 81, fin
	beq $s7, 113, fin

	beq $s7, 65, letraA
	beq $s7, 97, letraA
	
	beq $s7, 68, letraD
	beq $s7, 100, letraD
	
	beq $s7, 32, pausarJuego
	b main
	
letraA:
	la $a0, leftmessage
	syscall
	
	jal moverIzquierda

	sw $0, Letra
	b main

letraD:
	la $a0, rightmessage
	syscall
	
	jal moverDerecha
	
	sw $0, Letra
	b main

pausarJuego:
	la $a0, pausemessage
	syscall
	
	sw $0, Letra
	b main
	
	
moverIzquierda:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, Barra
	beqz $t0, retornarIzq
	
	addiu $t0, $t0, -4
	sw $t0, Barra
	jal redibujarBarra
	
	retornarIzq:
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra


redibujarBarra:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, Display
	lw $t1, UltimaFila
	lw $t2, Barra
	
	add $t0, $t0, $t1
	add $t0, $t0, $t2
	
	# Pintamos la barra
	lw $t3, Azul1
	lw $t4, Azul2
	lw $t5, Azul3
	lw $t6, Negro
	
	sw $t6, -4($t0)
	sw $t3, 0($t0)
	sw $t4, 4($t0)
	sw $t5, 8($t0)
	sw $t4, 12($t0)
	sw $t3, 16($t0)
	sw $t6, 20($t0)
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra

moverDerecha:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, Barra
	beq, $t0, 108, retornarDer
	
	addiu $t0, $t0, 4
	sw $t0, Barra
	jal redibujarBarra
	
	retornarDer:
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra

fin:	la $a0, endmessage
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall

.include "ManejadorDeExcepciones.asm"
