######################### INSTRUCCIONES #########################
# 1) Abrir Tools > Keyboard and Display MMIO Simulator
# 2) En Tool Control, hacer click en Connect to MIPS
# 3) Abrir Tools > Bitmap Display
# 4) Ajustar los valores:
#	OPCIÓN 1 (grande)
#	4.1.1) Unit Width in Pixels: 16
#	4.1.2) Unit Height in Pixels: 16
#	4.1.3) Display Width in Pixels: 512
#	4.1.4) Display Height in Pixels: 512

#	OPCIÓN 2
#	4.2.1) Unit Width in Pixels: 8
#	4.2.2) Unit Height in Pixels: 8
#	4.2.3) Display Width in Pixels: 256
#	4.2.4) Display Height in Pixels: 256

#	4.3) Base address for display: 0x10010000 (static data)
# 5) Aumentar el tamaño del Bitmap Display para verlo completo
# 6) En Tool Control, hacer click en Connect to MIPS
# 7) Ensamblar
# 8) Correr :-)
##################################################################

.data
Display: .space 4096
Tamano: .word 4096
Inicio: .word 0
Letra: .word 0
Timer: .word 0
Barra: .word 0
Ladrillos: .word 128
T: .word 2
UltimaFila: .word 3968
Vx: .word 0
Vy: .word 0
Px: .word 0
Py: .word 0
Azul: .word 0x000077, 0x0000a7, 0x0000f4
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
pressanykey: .asciiz "Press the ANY key to start"

.text
setup:	
	# Preparamos una semilla aleatoria a partir del tiempo
	li $v0, 30 
	syscall
	
	# Configuramos el generador de números aleatorios 1 con semilla
	# correspondiente al entero del tiempo, que está en $a0
	move $a1, $a0
	li $a0, 1
	li $v0, 40
	syscall
	
	# Generamos un entero entre -1 y 1 para Vx
	li $a0, 1
	li $a1, 2
	li $v0, 42
	syscall
	
	subi $a0, $a0, 1
	sw $a0, Vx
	
	# Generamos un entero no nulo entre 1 y 2 para Vy (tiene que subir al principio)
	li $a0, 1
	li $a1, 1
	li $v0, 42
	syscall
	
	addi $a0, $a0, 1
	sw $a0, Vy	
	
	# Cargamos en $s0 la dirección del Bitmap Display
	la $s0, Display
	
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
	addiu $t2, $t2, 3328
	
	# Pintamos la pelota
	lw $t3, Amarillo
	sw $t3, 60($t2)
	
	li $t5, 15
	li $t4, 30
	
	# Guardamos la ubicación de la pelota
	sw $t5, Px
	sw $t4, Py
		
	addiu $t2, $t2, 128
	
	# Pintamos la barra
	lw $t3, Azul
	lw $t4, Azul+4
	lw $t5, Azul+8
	
	sw $t3, 52($t2)
	sw $t4, 56($t2)
	sw $t5, 60($t2)
	sw $t4, 64($t2)
	sw $t3, 68($t2)
	
	# Guardamos la posición en bits de la barra (dada por su extremo izquierdo)
	li $t9, 52
	sw $t9, Barra
	
	# Encendemos los bits 1, 8, 16 del registro Status
	# El 1 para activar Interrupciones
	# El 8 para pemitir interrupciones de nivel 1
	# El 16 para encender el Timer
	mfc0 $a0, $12
	ori $a0, 0x8101 
	mtc0 $a0, $12
	
	# Encendemos el bit 2 del Receiver Control para
	# generar interrupciones si se recibe un caracter
	li $t0, 2
	sw $t0, 0xFFFF0000
	
splashScreen:
	# Mostramos un mensaje en terminal para que presione en teclado cualquier letra
	la $a0, pressanykey # debería ser una pantalla distinta
	li $v0 4
	syscall
	
	splashLoop:
	lw $s7, Letra
	beqz $s7, splashLoop
	sw $s0, Letra
	
	iniciarJuego:
	# Para imprimir mensajes al presionar teclas (debugging)
	li $v0, 4 
	
	# Ponemos al timer a esperar (part-debugging)
	lw $a0, T
	jal esperar
	
main:	
	lw $s6, Timer
	beqz $s6, noMover
	
	jal moverPelota
		
	lw $a0, T
	jal esperar
	
	noMover:
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
	
	la $t0, Display
	lw $t1, UltimaFila
	lw $t2, Barra
	
	add $t0, $t0, $t1
	add $t0, $t0, $t2
	
	# Pintamos la barra
	lw $t3, Azul
	lw $t4, Azul+4
	lw $t5, Azul+8
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
	
moverPelota:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, Px
	lw $t1, Py
	
	lw $t2, Vx
	lw $t3, Vy
	
	fronteraX0:
	bgtz $t0, fronteraX128
	sub $t2, $0, $t2
	sw $t2, Vx
	b fronteraY0
	
	fronteraX128:
	blt $t0, 32, fronteraY0
	sub $t2, $0, $t2
	sw $t2, Vx
	b fronteraY0
	
	fronteraY0:
	bgtz $t1, fronteraYfin
	sub $t3, $0, $t3
	sw $t3, Vy
	b mover
	
	fronteraYfin:
	blt $t1, 32, mover
	sub $t3, $0, $t3
	sw $t3, Vy
	b mover
	
	mover:
	sub $s1, $t0, $t2
	sub $s2, $t1, $t3
	
	jal dibujarPuntoNegro
	
	sw $s1, Px
	sw $s2, Py
	
	jal dibujarPelota
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra

dibujarPuntoNegro:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, Px
	lw $t1, Py
	
	lw $t2, Negro
	mul $t1, $t1, 128
	mul $t0, $t0, 4
	
	la $t3, Display
	add $t3, $t3, $t1
	add $t3, $t3, $t0
	sw $t2, 0($t3)
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra
	
dibujarPelota:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, Px
	lw $t1, Py
	
	lw $t2, Amarillo
	
	mul $t1, $t1, 128
	mul $t0, $t0, 4
	
	la $t3, Display
	add $t3, $t3, $t1
	add $t3, $t3, $t0
	sw $t2, 0($t3)
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra

esperar:
	mfc0 $t0, $9
	add $t0, $t0, $a0
	mtc0 $t0, $11
	
	jr $ra

fin:	la $a0, endmessage
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall

.include "ManejadorDeExcepciones.asm"
