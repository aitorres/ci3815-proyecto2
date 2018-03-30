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
Display: .space 4096 # Espacio reservado para el Display: 1024 bloques, a 4 bytes cada uno
Pausa: .word 0 # Booleano, 1 si el juego está pausado, 0 si no
Letra: .word 0 # Letra recibida y no procesada del teclado
Timer: .word 0 # Booleano, señal del timer
Barra: .word 0 # Posición del extremo izquierdo de la barra
Ladrillos: .word 128 # Cantidad de ladrillos, si llega a 0 se gana el juego
T: .word 10 # Velocidad medida en ciclos de reloj (inicial)
Incremento: .word 100 # Incremento a la velocidad del juego 
Vx: .word 0 # Desplazamiento en x de la bola
Vy: .word 0 # Desplazamiento en y de la bola
Px: .word 0 # Posición en x de la bola
Py: .word 0 # Posición en y de la bla
Amarillo: .word 0xFFFF30 # Color amarillo, para la bola
Azul: .word 0x000077, 0x0000a7, 0x0000f4 # Colores azules, para la barra
Verde: .word 0x005000, 0x008000, 0x00b000 # Colores verdes, para los ladrillos
Negro: .word 0x000000 # Color gris, de fondo
endmessage: .asciiz "¡HA FINALIZADO EL JUEGO"
leftmessage: .asciiz "Te moviste a la izquierda"
rightmessage: .asciiz "Te moviste a la derecha"
pausemessage: .asciiz "Juego en pausa"  
pressanykey: .asciiz "Press the ANY key to start"
incrementarmessage: .asciiz "¡Has incrementado la velocidad!"
decrementarmessage: .asciiz "Has decrementado la velocidad..."

.text
setup:	
	# Preparamos una semilla aleatoria a partir del tiempo
	li $v0, 30 
	syscall
	
	b ganar

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
	
	# Encendemos los bits 1, 8, 16 del registro Status
	# El 1 para activar Interrupciones
	# El 8 para pemitir interrupciones de nivel 1
	mfc0 $a0, $12
	ori $a0, 0x101 
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
	
	dibujarSplash:
	# Cargamos en $t3 a $t5 los colores azules
	lw $t3, Azul
	lw $t4, Azul+4
	lw $t5, Azul+8

	# Cargamos en $s0 la dirección del Bitmap Display
	la $s0, Display

	# Dejamos la primera línea en negro
	addiu $s0, $s0, 128

	#Pintamos BREAK
	sw $t3, 4($s0)
	sw $t3, 8($s0)
	sw $t3, 12($s0)
	sw $t3, 24($s0)
	sw $t3, 28($s0)
	sw $t3, 32($s0)
	sw $t3, 44($s0)
	sw $t3, 48($s0)
	sw $t3, 52($s0)
	sw $t3, 64($s0)
	sw $t3, 76($s0)
	sw $t3, 88($s0)
	addiu $s0, $s0, 128
	
	sw $t4, 4($s0)
	sw $t4, 16($s0)
	sw $t4, 24($s0)
	sw $t4, 36($s0)
	sw $t4, 44($s0)
	sw $t4, 60($s0)
	sw $t4, 68($s0)
	sw $t4, 76($s0)
	sw $t4, 84($s0)
	addiu $s0, $s0, 128

	sw $t3, 4($s0)
	sw $t3, 8($s0)
	sw $t3, 12($s0)
	sw $t3, 24($s0)
	sw $t3, 28($s0)
	sw $t3, 32($s0)
	sw $t3, 44($s0)
	sw $t3, 48($s0)
	sw $t3, 60($s0)
	sw $t3, 64($s0)
	sw $t3, 68($s0)
	sw $t3, 76($s0)
	sw $t3, 80($s0)
	addiu $s0, $s0, 128

	sw $t4, 4($s0)
	sw $t4, 16($s0)
	sw $t4, 24($s0)
	sw $t4, 32($s0)
	sw $t4, 44($s0)
	sw $t4, 60($s0)
	sw $t4, 68($s0)
	sw $t4, 76($s0)
	sw $t4, 84($s0)
	addiu $s0, $s0, 128

	sw $t3, 4($s0)
	sw $t3, 8($s0)
	sw $t3, 12($s0)
	sw $t3, 24($s0)
	sw $t3, 36($s0)
	sw $t3, 44($s0)
	sw $t3, 48($s0)
	sw $t3, 52($s0)
	sw $t3, 60($s0)
	sw $t3, 68($s0)
	sw $t3, 76($s0)
	sw $t3, 88($s0)
	addiu $s0, $s0, 128

	# Línea en blanco
	addiu $s0, $s0, 128

	# Escribimos OUT
	sw $t4, 80($s0)
	sw $t4, 92($s0)
	sw $t4, 104($s0)
	sw $t4, 112($s0)
	sw $t4, 116($s0)
	sw $t4, 120($s0)
	addiu $s0, $s0, 128

	sw $t3, 76($s0)
	sw $t3, 84($s0)
	sw $t3, 92($s0)
	sw $t3, 104($s0)
	sw $t3, 116($s0)
	addiu $s0, $s0, 128

	sw $t4, 76($s0)
	sw $t4, 84($s0)
	sw $t4, 92($s0)
	sw $t4, 104($s0)
	sw $t4, 116($s0)
	addiu $s0, $s0, 128

	sw $t3, 76($s0)
	sw $t3, 84($s0)
	sw $t3, 92($s0)
	sw $t3, 104($s0)
	sw $t3, 116($s0)
	addiu $s0, $s0, 128

	sw $t4, 80($s0)
	sw $t4, 96($s0)
	sw $t4, 100($s0)
	sw $t4, 116($s0)

	addiu $s0, $s0, 128
	
	addiu $t0, $0, 128 
	sll $t0, $t0, 3

	add $s0, $s0, $t0

	# Cargamos en $t3 a $t5 los colores verdes
	la $t2, Verde
	lw $t3, ($t2)
	lw $t4, 4($t2)
	lw $t5, 8($t2)

	# Escribimos Press
	sw $t3, 4($s0)
	sw $t3, 8($s0)
	sw $t3, 12($s0)
	sw $t3, 24($s0)
	sw $t3, 28($s0)
	sw $t3, 32($s0)
	sw $t3, 44($s0)
	sw $t3, 48($s0)
	sw $t3, 52($s0)
	sw $t3, 64($s0)
	sw $t3, 68($s0)
	sw $t3, 84($s0)
	sw $t3, 88($s0)
	addiu $s0, $s0, 128

	sw $t4, 4($s0)
	sw $t4, 16($s0)
	sw $t4, 24($s0)
	sw $t4, 36($s0)
	sw $t4, 44($s0)
	sw $t4, 60($s0)
	sw $t4, 80($s0)
	addiu $s0, $s0, 128

	sw $t3, 4($s0)
	sw $t3, 8($s0)
	sw $t3, 12($s0)
	sw $t3, 24($s0)
	sw $t3, 28($s0)
	sw $t3, 32($s0)
	sw $t3, 44($s0)
	sw $t3, 48($s0)
	sw $t3, 64($s0)
	sw $t3, 68($s0)
	sw $t3, 84($s0)
	sw $t3, 88($s0)
	addiu $s0, $s0, 128

	sw $t4, 4($s0)
	sw $t4, 24($s0)
	sw $t4, 32($s0)
	sw $t4, 44($s0)
	sw $t4, 72($s0)
	sw $t4, 92($s0)
	addiu $s0, $s0, 128

	sw $t3, 4($s0)
	sw $t3, 24($s0)
	sw $t3, 36($s0)
	sw $t3, 44($s0)
	sw $t3, 48($s0)
	sw $t3, 52($s0)
	sw $t3, 64($s0)
	sw $t3, 68($s0)
	sw $t3, 84($s0)
	sw $t3, 88($s0)
	addiu $s0, $s0, 128

	# Saltamos una línea
	addiu $s0, $s0, 128

	# Escribimos A KEY
	sw $t4, 44($s0)
	sw $t4, 68($s0)
	sw $t4, 80($s0)
	sw $t4, 88($s0)
	sw $t4, 92($s0)
	sw $t4, 96($s0)
	sw $t4, 104($s0)
	sw $t4, 112($s0)
	addiu $s0, $s0, 128

	sw $t3, 40($s0)
	sw $t3, 48($s0)
	sw $t3, 68($s0)
	sw $t3, 76($s0)
	sw $t3, 88($s0)
	sw $t3, 104($s0)
	sw $t3, 112($s0)
	addiu $s0, $s0, 128

	sw $t4, 40($s0)
	sw $t4, 44($s0)
	sw $t4, 48($s0)
	sw $t4, 68($s0)
	sw $t4, 72($s0)
	sw $t4, 88($s0)
	sw $t4, 92($s0)
	sw $t4, 104($s0)
	sw $t4, 112($s0)
	addiu $s0, $s0, 128

	sw $t3, 40($s0)
	sw $t3, 48($s0)
	sw $t3, 68($s0)
	sw $t3, 76($s0)
	sw $t3, 88($s0)
	sw $t3, 108($s0)
	addiu $s0, $s0, 128

	sw $t4,  40($s0)
	sw $t4,  48($s0)
	sw $t4,  68($s0)
	sw $t4,  80($s0)
	sw $t4,  88($s0)
	sw $t4,  92($s0)
	sw $t4,  96($s0)
	sw $t4, 108($s0)
	addiu $s0, $s0, 128
	
	# Reproducimos sonido
	li $v0, 33
	li $a0, 69
	li $a1, 250
	li $a2, 0
	li $a3, 100
	syscall
	
	li $v0, 33
	li $a0, 64
	li $a1, 360
	li $a2, 0
	li $a3, 100
	syscall
	
	li $v0, 33
	li $a0, 69
	li $a1, 200
	li $a2, 0
	li $a3, 100
	syscall
	
	li $v0, 33
	li $a0, 69
	li $a1, 200
	li $a2, 0
	li $a3, 100
	syscall
	
	li $v0, 33
	li $a0, 71
	li $a1, 200
	li $a2, 0
	li $a3, 100
	syscall
	
	li $v0, 33
	li $a0, 73
	li $a1, 200
	li $a2, 0
	li $a3, 100
	syscall
	
	li $v0, 33
	li $a0, 74
	li $a1, 200
	li $a2, 0
	li $a3, 100
	syscall
	
	li $v0, 33
	li $a0, 76
	li $a1, 350
	li $a2, 0
	li $a3, 100
	syscall

	# Loopeamos hasta que sea ingresada una tecla
	splashLoop:
	lw $s7, Letra
	beqz $s7, splashLoop
	sw $s0, Letra
	
dibujarTablero:
	# Coloreamos todo de negro
	lw $a0, Negro
	jal rellenarDeColor

	# Cargamos en $s0 la dirección del Bitmap Display
	la $s0, Display

	# Copiamos en los registros $t3 a $t6 los colores para pintar
	# el tablero de juego
	la $t2, Verde
	lw $t3, ($t2)
	lw $t4, 4($t2)
	lw $t5, 8($t2)
	
	# Cargamos los ladrillos. Son 128 ladrillos que hay que colorear
	# Para poder rellenar 4 hileras
CargarLadrillos:
	# Coloreamos de dos tonos los primeros dos ladrillos
	sw $t3,  0($s0)
	sw $t4,  4($s0)
	addiu $s0, $s0, 8 # Nos desplazamos dos bytes en el Display
	
	# Nos restan 126 hileras, por lo que iteramos de 6 en 6
	li $t9, 126
	
	cargarLoop:
	beqz $t9, LadrillosCargados # Si ya coloreamos los 126 ladrillos restantes, saltar
	sw $t5,  0($s0)
	sw $t3,  4($s0)
	sw $t4,  8($s0)
	sw $t5, 12($s0)
	sw $t3, 16($s0)
	sw $t4, 20($s0)
	
	addiu $s0, $s0, 24
	addiu $t9, $t9, -6
	b cargarLoop
			
LadrillosCargados:
	addiu $s0, $s0, 3328
	
	# Pintamos la pelota
	lw $t3, Amarillo
	sw $t3, 60($s0)
	
	li $t5, 15
	li $t4, 30
	
	# Guardamos la ubicación de la pelota
	sw $t5, Px
	sw $t4, Py
		
	addiu $s0, $s0, 128
	
	# Pintamos la barra
	lw $t3, Azul
	lw $t4, Azul+4
	lw $t5, Azul+8
	
	sw $t3, 52($s0)
	sw $t4, 56($s0)
	sw $t5, 60($s0)
	sw $t4, 64($s0)
	sw $t3, 68($s0)
	
	# Guardamos la posición en bits de la barra (dada por su extremo izquierdo)
	li $t9, 13
	sw $t9, Barra
	
iniciarJuego:	
	# Encendemos el bit 16 (timer)
	mfc0 $a0, $12
	ori $a0, 0x8000 
	mtc0 $a0, $12
	
	# Para imprimir mensajes al presionar teclas (debugging)
	li $v0, 4 
	
	# Ponemos al timer a esperar (part-debugging)
	jal esperar
	
main:	
	pausado:
	lw $s7, Letra # Cargamos la letra en $s7
	
	# Branch para el espacio
	beq $s7, 32, pausarJuego
	
	# Verificamos si el juego está pausado
	
	lb $s5, Pausa
	bnez $s5, pausado
	
	# Verificamos si el timer mandó una señal
	lw $s6, Timer
	beqz $s6, noMover # Si no hay señal, saltamos
		
	# Movemos la pelota de lugar 
	jal moverPelota
	
	# Desmarcamos el Timer pues ya utilizamos esta señal
	sw $0, Timer
	jal esperar # Ponemos el timer a esperar de nuevo
	
	noMover:
	lw $s7, Letra # Cargamos de nuevo la letra en $s7
	
	# Branch para la letra Q
	beq $s7, 81, fin
	beq $s7, 113, fin
	
	# Branch para la letra U
	beq $s7, 85, incrementar
	beq $s7, 117, incrementar
		
	# Branch para la letra L
	beq $s7, 76, decrementar
	beq $s7, 108, decrementar

	# Branch para la letra A
	beq $s7, 65, letraA
	beq $s7, 97, letraA
	
	# Branch para la letra D
	beq $s7, 68, letraD
	beq $s7, 100, letraD
	
	b main # Loop
	
letraA: # Imprimimos un mensaje
	la $a0, leftmessage
	syscall
	
	# Saltamos a rutina para mover barra a izquierda
	jal moverIzquierda

	b retornarAMenu

letraD: # Imprimios un mensaje
	la $a0, rightmessage
	syscall
	
	# Saltamos a rutina para mover barra a derecha
	jal moverDerecha
	
	b retornarAMenu

incrementar:
	# Imprimimos un mensaje
	la $a0, incrementarmessage
	syscall
	
	# Realizamos el incremento
	lw $t0, T # Cargamos T
	lw $t1, Incremento # Cargamos el incremento
	add $t0, $t0, $t1 # Sumamos ambos
	sw $t0, T # Lo almacenamos en T
	
	b retornarAMenu
	
decrementar:
	# Imprimimos un mensaje
	la $a0, decrementarmessage
	syscall
	
	# Realizamos el decremento
	lw $t0, T # Cargamos T
	lw $t1, Incremento # Cargamos el incremento
	sub $t0, $t0, $t1 # Restamos el incremento a T
	beqz $t0, retornarAMenu # ¡Ojo! No podemos permitir velocidades negativas
	sw $t0, T # Si no hicimos branch, lamacenamos en T
	
	b retornarAMenu

pausarJuego:
	# Imprimimos un mensaje
	la $a0, pausemessage
	syscall
	
	# Aplicamos un NOT al primer bit de Pausa
	lb $t0, Pausa
	not $t0, $t0
	sb $t0, Pausa
	
	b retornarAMenu
	
retornarAMenu:
	# Descartamos la letra y retornamos
	sw $0, Letra
	b main
	
moverIzquierda:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, Barra
	beqz $t0, retornarIzq
	
	addiu $t0, $t0, -1
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
	
	li $t1, 31 # Última fila del display
	sll $t1, $t1, 7
	
	lw $t2, Barra
	sll $t2, $t2, 2
	
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
	beq, $t0, 27, retornarDer
	
	addiu $t0, $t0, 1
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
	blt $t0, 31, fronteraY0
	sub $t2, $0, $t2
	sw $t2, Vx
	b fronteraY0
	
	fronteraY0:
	bgtz $t1, fronteraYfin
	sub $t3, $0, $t3
	sw $t3, Vy
	b mover
	
	fronteraYfin:
	blt $t1, 31, mover
	sub $t3, $0, $t3
	sw $t3, Vy
	b mover
	
	mover:
	sub $s1, $t0, $t2
	sub $s2, $t1, $t3
	
	lw $a0, Negro
	jal dibujarPelotaConColor
	
	sw $s1, Px
	sw $s2, Py
	
	lw $a0, Amarillo
	jal dibujarPelotaConColor
	
	#jal chequearAzul
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra
	
chequearAzul:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, Px
	lw $t1, Py
	addi $t1, $t1, 1
	
	sll $t0, $t0, 7
	sll $t1, $t1, 2
	la $t2, Display
	add $t2, $t2, $t0
	add $t2, $t2, $t1
	
	lw $t3, 0($t2)
	
	beqz $t3, chequearRet
	
	# debo dar distitnas velocidades, esto es debgging
	lw $t2, Vy
	sub $t2, $0, $t2
	sw $t2, Vy
	
	chequearRet:
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra

# Recibe en $a0 un color
dibujarPelotaConColor:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, Px
	lw $t1, Py
	
	sll $t1, $t1, 7 # Multiplicamos por 2^7, es decir, 128 
	sll $t0, $t0, 2 # Multiplicamos por 2^2, es decir, 4
	
	la $t3, Display
	add $t3, $t3, $t1
	add $t3, $t3, $t0
	sw $a0, 0($t3)
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra

# Recibe en $a0 la palabra de un color
rellenarDeColor:
	# Cargamos en $s0 la dirección del Bitmap Display
	la $t0, Display

	li $t9, 1024
	loopRellenar:
	beqz $t9, finRellenar
	sw $a0,  0($t0)
	sw $a0,  4($t0)
	sw $a0,  8($t0)
	sw $a0, 12($t0)
	sw $a0, 16($t0)
	sw $a0, 20($t0)
	sw $a0, 24($t0)
	sw $a0, 28($t0)
	addiu $t9, $t9, -8
	addiu $t0, $t0, 32
	b loopRellenar

	finRellenar:
	jr $ra

ganar:
	# Apagamos las interrupciones
	mfc0 $t0, $12
	andi $t0, $t0, 0
	mtc0 $t0, $12

	# Dibujamos la pantalla de ganador: rellenamos la pantalla de verde
	lw $a0, Verde
	jal rellenarDeColor

	# Cargamos los colores en $t1, $t2
	lw $t1, Amarillo
	
	# Escribimos YOU
	la $s0, Display

	li $t0, 1280
	add $s0, $s0, $t0

	sw $t1, 16($s0)
	sw $t1, 24($s0)
	sw $t1, 36($s0)
	sw $t1, 40($s0)
	sw $t1, 52($s0)
	sw $t1, 64($s0)
	addiu $s0, $s0, 128

	sw $t1, 16($s0)
	sw $t1, 24($s0)
	sw $t1, 32($s0)
	sw $t1, 44($s0)
	sw $t1, 52($s0)
	sw $t1, 64($s0)
	addiu $s0, $s0, 128

	sw $t1, 16($s0)
	sw $t1, 24($s0)
	sw $t1, 32($s0)
	sw $t1, 44($s0)
	sw $t1, 52($s0)
	sw $t1, 64($s0)
	addiu $s0, $s0, 128

	sw $t1, 20($s0)
	sw $t1, 32($s0)
	sw $t1, 44($s0)
	sw $t1, 52($s0)
	sw $t1, 64($s0)
	addiu $s0, $s0, 128

	sw $t1, 20($s0)
	sw $t1, 36($s0)
	sw $t1, 40($s0)
	sw $t1, 52($s0)
	sw $t1, 56($s0)
	sw $t1, 60($s0)
	sw $t1, 64($s0)
	addiu $s0, $s0, 128

	addiu $s0, $s0, 128

	# Escribimos "Won !"

	sw $t1, 40($s0)
	sw $t1, 56($s0)
	sw $t1, 68($s0)
	sw $t1, 72($s0)
	sw $t1, 84($s0)
	sw $t1, 100($s0)
	sw $t1, 108($s0)
	addiu $s0, $s0, 128

	sw $t1, 40($s0)
	sw $t1, 56($s0)
	sw $t1, 64($s0)
	sw $t1, 76($s0)
	sw $t1, 84($s0)
	sw $t1, 88($s0)
	sw $t1, 100($s0)
	sw $t1, 108($s0)
	addiu $s0, $s0, 128

	sw $t1, 40($s0)
	sw $t1, 48($s0)
	sw $t1, 56($s0)
	sw $t1, 64($s0)
	sw $t1, 76($s0)
	sw $t1, 84($s0)
	sw $t1, 92($s0)
	sw $t1, 100($s0)
	sw $t1, 108($s0)
	addiu $s0, $s0, 128

	sw $t1, 40($s0)
	sw $t1, 48($s0)
	sw $t1, 56($s0)
	sw $t1, 64($s0)
	sw $t1, 76($s0)
	sw $t1, 84($s0)
	sw $t1, 96($s0)
	sw $t1, 100($s0)
	addiu $s0, $s0, 128

	sw $t1, 44($s0)
	sw $t1, 52($s0)
	sw $t1, 68($s0)
	sw $t1, 72($s0)
	sw $t1, 84($s0)
	sw $t1, 100($s0)
	sw $t1, 108($s0)
	addiu $s0, $s0, 128

	b fin


esperar:
	lw $t0, T
	mtc0 $0, $9
	mtc0 $t0, $11
	
	jr $ra

fin:	la $a0, endmessage
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall

.include "ManejadorDeExcepciones.asm"
