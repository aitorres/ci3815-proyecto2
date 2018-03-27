# Creado por: Ruth Iveth Campos Artavia <tutirica@gmail.com> Mario Valenciano Rojas
# Ultima edici�n: 28/09/2016
#
# Gracias a: https://github.com/Ricardo96r/Space-Invaders-MIPS-Assembly/blob/master/Space%20Invaders.asm
#
# Para jugarlo primero: 0- Abrir MARS
#			1- Tools -> Bitmap Display
#			2- unit width in pixel:8 / unit height in pixel: 8
#			3- Display Width in Pixels: 512 / Display Height in Pixels: 256
#			4- Base address for display: $gp
#			5- Tools -> Keyboard and Display
#			7- Connect to MIPS
#			8- Assemble y RUN
#
# Intrucciones:		- Se mueve hacia la  izquierda con "a" minuscula!
#			- Se mueve hacia la derecha con "d" minuscula!
#			- Se tiene que jugar con letras minusculas (bloq may�s desactivado)
#			- Los pixeles azules son el nivel actual (1, 2 o 3)
#			- Los Pixeles rosados son las vidas restantes(3,2,1)
.data
##################################################################################################################
#                                        Definici�n parametros juego                                             #
##################################################################################################################	
ancho: 				.byte 64 	# Cantidad de pixeles que entran en fila.  512 width  / 8 ancho  = 64
velocidad:			.byte 120		# tiempo en que se ejecuta el loop del juego. Milisegundos.
vidas:				.byte 3		#cantidad de vidas del jugador
niveles:			.byte 2		# Contador de niveles. El ultimo nivel es el 2
mode:				.word 0 	# 1 para jugar nivel 1
plus:				.word 1 	#cambiar direccion de la bola 
minus:				.word -1	#cambiar la direccion de la bola
##################################################################################################################
#                                        Definici�n parametros jugador                                           #
##################################################################################################################	
jugador: 			.space 256	# 4 bloques de 16x16 pixeles
jugador_x: 			.byte 31	# Posicion incial del jugador
jugador_size: 			.byte 24	# Cantidad de pixeles en word 4 x 8 =32
color_jugador: 			.word 0x0032cd32#color del jugador
color_jugador_nivel_1: 		.word 0x0032cd32#color de jugador en el segundo nivel		 
color_jugador_nivel_2: 		.word 0x0012fff7#color de jugador en el segundo nivel
##################################################################################################################
#                                        Definici�n parametros para bloques                                       #
##################################################################################################################
bloque:				.space 160	# 55 bloques. MATRIZ 10X4
bloques_vivos:			.space 56	# 0 = muerto, 1 = vivo. vector lleno de unos
bloque_size: 			.byte 3		# Tama�o en x de cada bloque
bloque_contador: 		.byte 0 	# al llegar a 55 pasa al segundo nivel
bloque_vivos_contador: 		.byte 0 	# al llegar a 55 pasa al segundo nivel
bloque_x: 			.byte 5		# separacion de bloques en x
bloque_y: 			.byte 3 	# separacion de bloques en y
c_inicialx:			.byte 6		#valor inicial en x pos0
c_inicialy:			.byte 4		#valor inicial en y pos0
color_bloque: 			.word 0x00ff8000#color del bloque registro
color_bloque_nivel_1: 		.word 0x00ff8000#color bloque para nivel 1
color_bloque_nivel_2: 		.word 0x0000AAFF#color de bloque para nivel 2
##################################################################################################################
#                                        Definici�n de colores adicionales                                       #
##################################################################################################################	
color_g_o:			.word 0x0000A0DD #color del game over
ballColor:			.word 0x00AA0000 #color bola
backgroundColor:		.word 0x00000000 #color fondo
blueColor:			.word 0x0012fff7 #color azul
color_vidas: 			.word 0x00FF00FF #color vidas
color_niveles:			.word 0x006666FF #color niveles
color_power_up:			.word 0x006556FF #color_power_up



.text
##################################################################################################################
#                                        Definici�n de nuevo juego                                               #
# $a0  coordenada en x												 #
# $a1 coordenada en y												 #
# $a2 the color													 #
# $a3 cordenada final x o y											 #
##################################################################################################################	
NewGame:
	li $a0, 250	#
	li $v0, 32	# pause for 250 milisec
	syscall	
	jal ClearBoard

Dibujar_pantalla_inicio:				
	####################################
	#   ESCRIBE  ARKANOID              #
	####################################
	li $a0, 10
	li $a1, 3
	lw $a2, ballColor
	li $a3, 8
	jal DrawVerticalLine 
	li $a0, 13
	jal DrawVerticalLine
	li $a0, 15
	jal DrawVerticalLine	
	li $a0, 17
	li $a1, 6
	li $a3, 7
	jal DrawVerticalLine
	li $a0, 18
	li $a1, 3
	li $a3, 6
	jal DrawVerticalLine
	li $a0, 20
	li $a3, 8
	jal DrawVerticalLine
	li $a0, 21
	li $a1, 5
	lw $a2, ballColor
	li $a3, 6
	jal DrawVerticalLine
	li $a0, 25
	li $a1, 3
	lw $a2, ballColor
	li $a3, 8
	jal DrawVerticalLine
	li $a0, 28
	jal DrawVerticalLine
	li $a0, 30
	jal DrawVerticalLine
	li $a0, 31
	li $a3, 4
	jal DrawVerticalLine
	li $a0, 32
	li $a1, 5
	li $a3, 6
	jal DrawVerticalLine
	li $a0, 33
	li $a1, 7
	li $a3, 8
	jal DrawVerticalLine
	li $a0, 34
	li $a1, 3
	jal DrawVerticalLine
	li $a0, 36
	jal DrawVerticalLine
	li $a0, 39
	li $a1, 3
	lw $a2, ballColor
	li $a3, 8
	jal DrawVerticalLine
	li $a0, 43
	jal DrawVerticalLine	
	li $a0, 47
	jal DrawVerticalLine	
	li $a0, 50
	li $a1, 4
	li $a3, 7
	jal DrawVerticalLine	
	li $a0, 10
	li $a1, 3
	li $a3, 13
	jal DrawHorizontalLine	
	li $a0, 10
	li $a1, 6
	li $a3, 13
	jal DrawHorizontalLine
	li $a0, 15
	li $a1, 3
	li $a3, 18
	jal DrawHorizontalLine	
	li $a1, 6
	jal DrawHorizontalLine	
	li $a0, 25
	li $a1, 3
	li $a3, 28
	jal DrawHorizontalLine	
	li $a0, 25
	li $a1, 6
	li $a3, 28
	jal DrawHorizontalLine	
	li $a0, 36
	li $a1, 3
	li $a3, 39
	jal DrawHorizontalLine	
	li $a1, 8
	jal DrawHorizontalLine	
	li $a0, 41
	li $a1, 3
	li $a3, 45
	jal DrawHorizontalLine	
	li $a0, 41
	li $a1, 8
	li $a3, 45
	jal DrawHorizontalLine	
	li $a0, 47
	li $a1, 3
	li $a3, 49
	jal DrawHorizontalLine	
	li $a1, 8
	jal DrawHorizontalLine		
	li $a0, 18
	li $a1, 8
	jal DrawPoint	
	li $a0, 22
	li $a1, 4
	jal DrawPoint
	li $a1, 7
	jal DrawPoint
	li $a0, 23
	li $a1, 3
	jal DrawPoint
	li $a1, 8
	jal DrawPoint		
	####################################
	#   ESCRIBE  JUGAR = 1             #
	####################################
	li $a0, 15
	li $a1, 26
	lw $a2, ballColor
	li $a3, 29
	jal DrawVerticalLine
	li $a0, 23
	li $a1, 26
	lw $a2, ballColor
	li $a3, 29
	jal DrawVerticalLine
	li $a0, 28
	li $a1, 26
	lw $a2, ballColor
	li $a3, 29
	jal DrawVerticalLine	
	li $a0, 31
	li $a1, 26
	lw $a2, ballColor
	li $a3, 29
	jal DrawVerticalLine	
	li $a0, 33
	li $a1, 26
	lw $a2, ballColor
	li $a3, 29
	jal DrawVerticalLine	
	li $a0, 44
	li $a1, 26
	lw $a2, ballColor
	li $a3, 29
	jal DrawVerticalLine	
	li $a0, 18
	li $a1, 26
	lw $a2, ballColor
	li $a3, 28
	jal DrawVerticalLine
	li $a0, 21
	li $a1, 26
	lw $a2, ballColor
	li $a3, 28
	jal DrawVerticalLine
	li $a0, 36
	li $a1, 26
	lw $a2, ballColor
	li $a3, 27
	jal DrawVerticalLine
	li $a0, 13
	li $a1, 26
	li $a3, 16
	jal DrawHorizontalLine
	li $a0, 23
	li $a1, 26
	li $a3, 26
	jal DrawHorizontalLine
	li $a0, 28
	li $a1, 26
	li $a3, 31
	jal DrawHorizontalLine		
	li $a0, 33
	li $a1, 26
	li $a3, 36
	jal DrawHorizontalLine
	li $a0, 13
	li $a1, 29
	li $a3, 15
	jal DrawHorizontalLine
	li $a0, 19
	li $a3, 20
	jal DrawHorizontalLine
	li $a0, 23
	li $a3, 26
	jal DrawHorizontalLine
	li $a0, 38
	li $a3, 40
	jal DrawHorizontalLine
	li $a0, 42
	li $a3, 45
	jal DrawHorizontalLine
	li $a0, 25
	li $a1, 28
	li $a3, 26
	jal DrawHorizontalLine
	li $a0, 29
	li $a3, 30
	jal DrawHorizontalLine
	li $a0, 34
	li $a3, 35
	jal DrawHorizontalLine
	li $a0, 38
	li $a1, 27
	li $a3, 40
	jal DrawHorizontalLine	
	li $a0, 36
	li $a1, 29
	jal DrawPoint
	li $a0, 43
	li $a1, 27
	jal DrawPoint
##################################################################################################################
#                                        Seleccion de Jugar		                                         #
# $t1 tecla del teclado                              		                                         #
##################################################################################################################
SelectMode:
	lw $t1, 0xFFFF0004						# chequea cual tecla est� presionada
	beq $t1, 0x00000031, SetPlayerMode 				# si la tecla es 1 brinca al modo de jugar
	li $a0, 250							# tiempo en milisegundos que espera 250
	li $v0, 32							# pausa por el tiempo en $a0
	syscall								# llama la funcion de esperarse	
	j SelectMode   							# vuelve nuevamente a esperar la tecla	
SetPlayerMode:
	sw $zero, 0xFFFF0000						# borra el bot�n presionado
##################################################################################################################
#                                       Nueva Ronda							         #
# Inicializa los registros para el nuevo juego				 					 #
# Establece y llama a las funciones para mostrar el  jugador y los bloques					 #
# Setea los valores para usar en la bola									 #
##################################################################################################################
NewRound:
	jal ClearBoard							#Llama a la pantalla en negro
	jal actualizar_borde						#actualizacion de bordes vidas y nivel
	jal player							#Establece los registros del jugador para guardarlos en un arreglo
	jal mostrar_jugador						#Mostrar la figura del jugador en pantalla
	jal mostrar_bloques						#Mostrar bloques en pantalla
set:	li $s6, 2							#Setea el valor inicial de la bola x=28
	lw $s2, color_jugador						#carga color del jugador en $s2
	li $s7, 28							#Setea el valor de la y de la bola y=28
	li $s0, 1 							#Direccion en x (1 +x, -1 -x)
	li $s1, -1     							#Direccion en y (1 +y, -1 -y)
	jal DrawPointB							#Pinta la bola en pantalla segun $s6(x) y Ss7(y)
	j main								#salta al main para mover la bola
##################################################################################################################
#                                      Direccion de memoria						         #
# Genera los pixeles y la direccion en la memoria para pantalla							 #
##################################################################################################################
DireccionEnMemoria:
	lbu $v0 ancho							#carga el ancho de la pantalla
	mulu $a1 $a1 $v0						#multiplica el ancho para obtener los campos
	addu $v0 $a0 $a1						#suma la coordenada de x al pixel obtenido
	sll $v0 $v0 2							#multiplica por 4 pixeles de pantalla
	addu $v0 $v0 $gp						#cambia el puntero a lo calculado
	jr $ra								#se devuelve a donde fue llamada
##################################################################################################################
#                                	    Borde								 #
#  Agrega el borde a la pantalla										 #
#  No Retorna						 				     		         #
#logica de generacionde bordes:											 #
#se cargan los valores iniciales de x, y									 #
#movemos $t3(x) al x equivalente a Dir.Memoria									 #
#movemos $t4(y) al x equivalente a Dir.Memoria									 #
#se llama la direccion de memoria para obtener pixeles								 #
#guarda en v0 el valor del fondo										 #
#suma uno a x o y segun el borde										 #
#vuelve a comenzar el borde de arriba hasta llegar al ancho							 #
##################################################################################################################

borde:	addi $sp $sp -4							#crea espacio en el stack
	sw $ra 0($sp)							#guardamos $ra
	lw $t1 backgroundColor						#pone color del borde
	lb $t2 ancho							#agrega el ancho total
borde_a:li $t3 0 							# X inicial X=0							
	li $t4 0 							# Y inicial Y=0
borde_arriba:
	move $a0 $t3						
	move $a1 $t4						
	jal DireccionEnMemoria					
	sw $t1 ($v0)						
	addi $t3 $t3 1							#suma uno a x
	bne $t3 $t2 borde_arriba					
borde_i:li $t3 0							# X inicial X=0	
	li $t4 0							# Y inicial Y=0
borde_izquierda:
	move $a0 $t3						
	move $a1 $t4						
	jal DireccionEnMemoria					
	sw $t1 ($v0)						
	addi $t4 $t4 1						
	bne $t4 $t2 borde_izquierda				
borde_d:li $t3 63							# carga x=63
	li $t4 0							# carga y=0
borde_derecha:								
	move $a0 $t3						
	move $a1 $t4						
	jal DireccionEnMemoria					
	sw $t1 ($v0)						
	addi $t4 $t4 1							#suma uno a y
	bne $t4 $t2 borde_derecha				
borde_b:li $t3 0							#carga valor x=0
	li $t4 29							#carga valor y=29
borde_abajo:
	move $a0 $t3							
	move $a1 $t4							
	jal DireccionEnMemoria						
	sw $t1 ($v0)
	addi $t3 $t3 1							#suma uno a x
	bne $t3 $t2 borde_abajo
borde_return:
	lw $ra 0($sp)
	addi $sp $sp 4
	jr $ra
##################################################################################################################
#                                     Vidas								         #
# Agrega los pixeles de las vidas 										 #
##################################################################################################################
mostrar_vidas:
	addi $sp $sp -4							#abre campo en el stack
	sw $ra 0($sp)							#guarda $ra en el stack
	lb $t0 vidas							#carga las vidas
	lw $t1 color_vidas						#carga color de vidas
	li $a0 63							#carga pixel x de ubicacion de vidas
	li $a1 2							#carga primer pixel en y para vidas
	jal DireccionEnMemoria						#llama direccion de memoria
	sw $t1 ($v0)							#guarda el color en $vo pantalla
	beq $t0 1 mostrar_vidas_return					#si las vidas son iguales a uno termina de imprimir
	li $a0 63							#genera segundo pixel de vidas
	li $a1 4							#genera y del segundo pizel de vidas
	jal DireccionEnMemoria						#Llama la direccion de memoria correspondiente
	sw $t1 ($v0)							#agrega el color de las vidas
	beq $t0 2 mostrar_vidas_return					#Si las vidas son dos, no pinta el ultimo punto
	li $a0 63							#se define el x para pintar
	li $a1 6							#se define el y de la ultima vida
	jal DireccionEnMemoria						#se llama la direccion de memoria
	sw $t1 ($v0)							#se pinta la direccion en la pantalla
mostrar_vidas_return:
	lw $ra 0($sp)							#saca la variable del stack
	addi $sp $sp 4							#cierra el campo utilizado
	jr $ra								#carga la direccion del jal+1 hecho
##################################################################################################################
#                                     Niveles								         #
# Agregs los pixeles de los niveles  al lado izquierdo de la pantalla						 #
##################################################################################################################
mostrar_nivel:
	addi $sp $sp -4							#abre el estacio en el stack
	sw $ra 0($sp)							#guarda la variable de addres del jal llamado
	lb $t0 niveles							#carga los niveles
	lw $t1 color_niveles						#carga el color
	li $a0 0							#pone el x de los niveles
	li $a1 2							#se define el y de los niveles
	jal DireccionEnMemoria						#se llama la memoria
	sw $t1 ($v0)							#se realiza el pintado de pixel
	ble $t0 1 mostrar_nivel_return					#si las vidas es 1 sale
	li $a0 0							#genera el x del nivel donde sera pintado
	li $a1 4							#genera el y del nivel 2
	jal DireccionEnMemoria						#llama la direccion de memoria
	sw $t1 ($v0)							#pinta la direccion obtenida
mostrar_nivel_return:							#retorna al jal+1 hecho
	lw $ra 0($sp)							#saca la variable del stack
	addi $sp $sp 4							#cierra el campo utilizado
	jr $ra								#carga la direccion del jal+1 hecho
##################################################################################################################
#                			      Actualizar el borde				         	 #
# crea el borde y actualiza las vidas y el nivel cada vez qie se pierde una vida.				 #
##################################################################################################################
actualizar_borde:
	addi $sp $sp -4							#abre campo en el stack
	sw $ra 0($sp)							#guarda la variable de return address
	jal borde							#llama la funcion para hacer los bordes
	jal mostrar_vidas						#llama motrar vida
	jal mostrar_nivel						#llama mostrar nivel
	lw $ra 0($sp)							#saca el dato almacenado
	addi $sp $sp 4							#cierra el campo en el stack
	jr $ra								#realiza el brinco al address donde se hizo jal+1
##################################################################################################################
#                			     Main mover bola					         	 #
# loop para realizar movimiento de la bola y obtener movimiento de la paleta					 #
##################################################################################################################
main:	jal moveBall							#loop que mueve la bolla
	lw $t9 0xFFFF0000						# ffff0000 = control que recibe letra del teclado
	blez $t9 main							# si no es 0 vuelve a mover la bola
Main_Obtener_Tecla:
	jal Obtener_tecla						# Obtener el valor de la tecla presionada
	move $t9 $v0							# mueve tecla obtenida a $t9
Main_mover_izquierda:
	bne $t9 0x02000000 Main_mover_derecha # A			# si no es a revisa si es d
	jal limpiar_jugador						# limpia el jugador pone lo anterior en negro
	jal mover_jugador_i						#mueve el jugador a la izquierda
	jal mostrar_jugador						#pinta al jugador
	j main								#vuelve al main
Main_mover_derecha:
	bne $t9 0x01000000 Main_mover_izquierda # D			#si no es d es izquierda
	jal limpiar_jugador						#limpia el jugador
	jal mover_jugador_d						#mueve a la derecha
	jal mostrar_jugador						#pinta al jugador
	j main								#vuelve al main
##################################################################################################################
#                			     Mover bola						         	 #
# movimiento de la bola, revisa si hay posibles colisiones						 	 #
##################################################################################################################
moveBall:
	addi $sp, $sp, -8						#crea campo en stack
	sw $ra, 0($sp)							#guarda la direccion de return address
	jal eliminar_bloque						#llama a la funcion para que revise si hay colision con los bloques
	lw $s2, backgroundColor						#carga el color del fondo
	jal DrawPointB							#dibuja la bola	en negro
	jal colisionpal							#busca si hay colision con la paleta
	jal collision							#entra a revisar si hay colision con bordes
	jal contadorbloquesdestruidos					#permite poner en pantalla los bloques destruidos
	jal powerup							#llama al power up peque�o
	jal powerup2							#llama al powerup grande
	add $s6, $s6, $s0 						#xsig = x+xDir
	add $s7, $s7, $s1 						#ysig = y+yDir
	lw $s2, color_jugador						#pone el color del jugador 
	jal DrawPointB							#pinta en la nueva direccion del jugador
	sw $s6, 4($sp)							#guarda $s6 en stack
	lb $a0, velocidad						#*controla la rapidez con la que se muebe la bola
	li $v0, 32							# pausa por la velocidad que se le asigne
	syscall								#llama las funciones del sistema (sleep)
	lw $s6, 4($sp)							#carga el valor de x nuevo
	lw $ra, 0($sp)							#carga el valor de return address
	addi $sp, $sp, 8						#cierra los campos en el stack
	jr $ra								#retorna a jal+1 instr
collision:
	addi $sp, $sp, -4
	sw $ra, 0($sp)							#guarda el valor de la direccion en el registro
	li $t0, 1							#establece un valor al registro
	li $t1,  60							#establece un valor al registro
	li $t2,  29							#establece un valor al registro
	beq $s7, $t0, collisionUp					#compara si $t1 es igual a $s6 para saltar a la funci�n collisionUp
Down:
	beq $s7, $t2, collisionDown					#compara si $t1 es igual a $s6 para saltar a la funci�n collisionDown
Left:
	beq $s6, $t0, collisionLeft					#compara si $t1 es igual a $s6 para saltar a la funci�n collisionLeft
Right:
	beq $s6, $t1, collisionRight					#compara si $t1 es igual a $s6 para saltar a la funci�n collisionRight		
	lw $ra, 0($sp)							# carga el valor de la direccion  en el registro
	addi $sp, $sp, 4						# sumo 4 al registro
	jr $ra								#carga el �ltimo valor del jump and link que haya hecho
collisionUp:
	lw $s1, plus							# carga el valor de la direccion  en el registro
	j Down								#salta a la funcion
collisionDown:
	lb $t4, vidas							# carga el valor de la direccion  en el registro
	addi $t4 $t4 -1							#pierde una vida
	sb $t4 vidas							#guarda el valor de la direccion en el registro
	beqz $t4 Reset							#compara si $t4 es igual a cero para saltar a la funci�n Reset	
	jal actualizar_borde						#salta a la funcion
	jal set								#salta a la funcion
	#lw $s1, minus
	lw $ra, 0($sp)							# carga el valor de la direccion  en el registro
	addi $sp, $sp, 4						# sumo 4 al registro
	jr $ra								#carga el �ltimo valor del jump and link que haya hecho
collisionLeft:
	lw $s0, plus							# carga el valor de la direccion  en el registro
	j Right								#salta a la funcion
collisionRight:
	lw $s0, minus							# carga el valor de la direccion  en el registro
	lw $ra, 0($sp)							# carga el valor de la direccion  en el registro
	addi $sp, $sp, 4						# sumo 4 al registro
	jr $ra								#carga el �ltimo valor del jump and link que haya hecho
mostrar_bloques:
	addi $sp $sp 4			# sumo 4 al registro
	sw $ra, 0($sp)			#guarda el valor de la direccion en el registro
	lw $a2 blueColor		# carga el valor de la direccion  en el registro
	lb $a0,c_inicialx		 #x carga el valor de la direccion  en el registro
	lb $a1,c_inicialy 		#y  carga el valor de la direccion  en el registro
mostrar_bloques_loop:
	lb $t4 bloque_size		# carga el valor de la direccion  en el registro
	add $a3 $a0 $t4
	jal DrawHorizontalLine		#salta a la funcion
	lb $t4 bloque_y			# carga el valor de la direccion  en el registro
	add $a1,$a1,$t4 		#y
	slti $t5, $a1, 18 		#limite abajo bloques
	bne $t5, $zero,mostrar_bloques_loop #compara si $t5 es diferente a cero para saltar a la funci�n mostrar bloques loop		
	lb $a1,c_inicialy 		#y	# carga el valor de la direccion  en el registro
	lb $t4 bloque_x			# carga el valor de la direccion  en el registro
	add $a0, $a0, $t4		#x
	slti $t5, $a0, 58
	bne $t5, $zero, mostrar_bloques_loop 		#compara si $t5 es diferente a cero para saltar a la funci�n mostrar bloques loop	
	li $t4 0			#establece un 0 al registro
	li $t5 0			#establece un 0 al registro
bl_v_loop: 				# bloque vivos, unector lleno de unos
	sb $t5 bloques_vivos($t4)	#guarda el valor de la direccion en el registro
	addi $t4 $t4 1			# sumo 1 al registro
	addi $t5 $t5 1			# sumo 1 al registro
	
	bne $t4 56 bl_v_loop		#compara si $t4 es diferente a 56 para saltar a la funci�n bl_v_loop	
bl_c_done:
	
	lw $ra, 0($sp)			# carga el valor de la direccion  en el registro
	addi $sp, $sp, 4		# sumo 4 al registro
	jr $ra				#carga el �ltimo valor del jump and link que haya hecho
eliminar_bloque: 
	addi $sp $sp -4			#le resta a $sp 4 para abrir los datos en la pila
	sw $ra 0($sp)			#guarda el valor de la direccion en el registro
	
	add $t5 $s7 $s1 		#y de la bola
	bgt $t5 16 Exit1
	li $t7 1 			#inicializo donde est� la bola en y =1
	beq $t5 4 Loopcollisionx	#compara si $t5 es igual a 4 para saltar a la funci�n
	addi $t7 $t7 1 			#inicializo donde est� la bola en y=2
	beq $t5 7 Loopcollisionx	#compara si $t5 es igual a 7 para saltar a la funci�n
	addi $t7 $t7 1			 #inicializo donde est� la bola en y=3
	beq $t5 10 Loopcollisionx	#compara si $t5 es igual a 10 para saltar a la funci�n
	addi $t7 $t7 1			 #inicializo donde est� la bola en y=4
	beq $t5 13 Loopcollisionx	#compara si $t5 es igual a 13 para saltar a la funci�n
	addi $t7 $t7 1 			#inicializo donde est� la bola en y=5
	beq $t5 16 Loopcollisionx	#compara si $t5 es igual a 16 para saltar a la funci�n
	j Exit1				#salto a la funci�n
Loopcollisionx:
	add $t3 $s6 $s0 		#x de la bola sig
	blt $t3 5 Exit1			#no_collisiona  
	bgt $t3 60 Exit1		# no_collision		
	li $t6 5			#establece un valor al registro
	divu $t3 $t3 $t6		#obtener el valor x numero bloque
	addi $t7 $t7 -5 		#y -5
	mul $t4 $t3 $t6 		#5*x
	add $t4 $t4 $t7 		#5x-5+y
	lb $t2 bloques_vivos($t4)	 # carga el valor de la direccion  en $t2
		
	addi $sp $sp -4			#le resta a $sp 4 para abrir los datos en la pila
	sw $a0 0($sp)			#guarda el valor de la direccion en el registro
	addi $a0 $t2 0			#establece $t2 igual a a0
	li $v0, 1			#establece un valor al registro
	syscall
	lw $a0 0($sp)
	addi $sp $sp 4			# sumo 4 al registro
	bne $t2 0 Loopcollision		#siguiente_nivel, compara si $t2 es diferente a $0 para saltar a la funci�n Loopcollision		
Exit1:	
	lw $ra 0($sp)
	addi $sp $sp 4			# sumo 4 al registro
	jr $ra				#carga el �ltimo valor del jump and link que haya hecho

Loopcollision:	
					  #obtener la ubicacion en matriz 
	li $t7 0			#establece un 0 al registro
	sb $t7 bloques_vivos($t4)	#guarda el valor de la direccion en el registro
	mul $t3 $t3 $t6 		#multiplica el registro por t6 y lo almacena
	add $t6 $t3 $t6			#suma t3 a t6 
	move $a0 $t3			#se mueve de un registro a otro
	move $a1 $t5			#se mueve de un registro a otro
	move $a3 $t6				#se mueve de un registro a otro
	lw $a2 backgroundColor			#carga el valor del registro
	jal DrawHorizontalLine			#salta a la funcion
	lb $t3 bloque_vivos_contador		#carga el valor del registro
	addi $t3 $t3 1				#suma 1 al registro
	sb $t3 bloque_vivos_contador		#guarda la direccion en el registro
	mul $s1,$s1,-1 				#invertir la direccion en y
#	lb $t2 velocidad
#	li $t3 40
#	blt $t2 $t3 Exit1													# carga el valor de la direccion  en el registro
#	addi $t2 $t2 -1
#	sb $t2 velocidad
	j Exit1				#salta a la funcion
	
colisionpal:
	li $t0 0			#establece un 0 al registro
	addi $sp $sp -4			#le resta a $sp 4 para abrir los datos en la pila
	sw $ra 0($sp)			#guarda el de la direccion en el registro
	add $t6 $s6 $s0			#sumo la ultima direccion de la paleta en x
	add $t7 $s7 $s1			#sumo la ultima direccion de la paleta en y
	bne $t7 28 ex			#compara si $t7 es diferente de $28 para saltar a la ex
	lb $t3 jugador_x			#x inicial de la bola	#carga el valor del registro
	lb $t5 jugador_size		#carga el valor del registro
	div $t5 $t5 5			#divido $t5 entre 4
	add $t5 $t3 $t5			#suma t3 a t5 
	blt $t6 $t3 ex 			#compara el x inicial
	bgt $t6 $t5 ex 			#compara el x final
	mul $s1 $s1 -1			#cambio la direcci�m
ex:	lw $ra 0($sp)			#carga el valor del registro
	addi $sp $sp 4			# sumo 4 al registro
	jr $ra				#carga el �ltimo valor del jump and link que haya hecho
	
# Crea la forma del jugador y lo guarda en un vector
player:	addi $sp, $sp, -4
	sw $ra 0($sp)			#guarda el de la direccion en el registro
	lb $a0 jugador_x		#carga el valor del registro 
	li $t1 28			#carga el valor del registro 
	lw $t2 color_jugador		#establece el color
pl_c:	move $a1 $t1			#mueve t1 a a1
	jal DireccionEnMemoria		#salta a la funcion
	li $t3 0			#establece un 0 al registro
	sw $v0 jugador($t3)		#guarda el valor $vo a la direccion
	addi $t3 $t3 4			# sumo 4 al registro
	sw $v0 jugador($t3) # pixel derecho 	guarda el valor $vo a la direccion
	addi $v0 $v0 4			# sumo 4 al registro
	addi $t3 $t3 4			# sumo 4 al registro
	sw $v0 jugador($t3)		#guarda el valor $vo a la direccion
	addi $v0 $v0 4			# sumo 4 al registro
	addi $t3 $t3 4			# sumo 4 al registro
	sw $v0 jugador($t3)		#guarda el valor $vo a la direccion
	addi $v0 $v0 4			# sumo 4 al registro
	addi $t3 $t3 4			# sumo 4 al registro
	sw $v0 jugador($t3)		#guarda el valor $vo a la direccion
	addi $v0 $v0 4			# sumo 4 al registro
	addi $t3 $t3 4			# sumo 4 al registro
	sw $v0 jugador($t3)		#guarda el valor $vo a la direccion
	addi $v0 $v0 4			# sumo 4 al registro
	addi $t3 $t3 4			# sumo 4 al registro	
	sw $v0 jugador($t3)		#guarda el valor $vo a la direccion
	addi $v0 $v0 4			# sumo 4 al registro
	addi $t3 $t3 4			# sumo 4 al registro
	sw $v0 jugador($t3)		#guarda el valor $vo a la direccion
	lw $ra, 0($sp)
	addi $sp, $sp, 4		#le suma a $sp 4 para borrar los datos en la pila
	jr $ra				#carga el �ltimo valor del jump and link que haya hecho

##################################################
# Mostrar el vector jugador en pantalla	
# No retorna nada
mostrar_jugador:
	li $t0 0				#establece un 0 al registro
	lb $t1 jugador_size			#carga el valor de jugador size en el registro
	lw $t2 color_jugador			#carga el color
mostrar_jugador_loop:
	lw $t3 jugador($t0)			#carga el valor de jugador m�s la base en el registro
	sw $t2 ($t3) 				# guarda el valor de $t2 en la direcci�n
	addi $t0 $t0 4				# sumo 4 al registro 
	bne $t0 $t1 mostrar_jugador_loop	#compara si $t1 es diferente de $t0 para saltar a la funci�n mostrar_jugador_loop
	jr $ra					#carga el �ltimo valor del jump and link que haya hecho
##############################################
# Limpia el jugador en la patalla
# No retorna nada
limpiar_jugador:
	li $t0 0				#establece un 0 al registro
	lb $t1 jugador_size			#carga el valor de jugador size en el registro
	lw $t2 backgroundColor			#carga el color
limpiar_jugador_loop:
	lw $t3 jugador($t0)			#carga el valor de jugador m�s la base en el registro
	sw $t2 ($t3)				# guarda el valor de $t2 en la direcci�n
	addi $t0 $t0 4				# sumo 4 al registro 
	bne $t0 $t1 limpiar_jugador_loop	#compara si $t1 es diferente de $t0 para saltar a la funci�n mover_jugador_loop
	jr $ra					#carga el �ltimo valor del jump and link que haya hecho
##################################################
# Mover Jugador izquierda
# No retorna nada
mover_jugador_i:
	li $t0 0				#establece un 0 al registro
	lb $t1 jugador_size			#carga el valor de jugador size en el registro
mover_jugador_loop_i:
	lw $t2 jugador($t0)			#carga el valor de jugador m�s la base en el registro
	lb $t3 jugador_x			#carga el valor de jugador x en el registro
	beq $t3 1 mover_jugador_i_sin_accion	# compara si el valor $t3 es igual a 1 y salta a mover_jugador__i_sin_accion
	subi $t2 $t2 16				# resto 16 al registro $t2
	sw $t2 jugador($t0)			# guarda el valor de $t2 en la direcci�n
	addi $t0 $t0 4				# sumo 4 al registro $t0
	bne $t0 $t1 mover_jugador_loop_i	#compara si $t1 es diferente de $t0 para saltar a la funci�n mover_jugador_loop_i
	subi $t3 $t3 4				#resta 4 a $t3
	sb $t3 jugador_x			# guarda el valor de $t3 en jugador_x
mover_jugador_i_sin_accion:
	jr $ra					#carga el �ltimo valor del jump and link que haya hecho
	
##################################################
# Mover Jugador derecha
# No retorna nada
mover_jugador_d:
	li $t0 0			#establece un 0 al registro
	lb $t1 jugador_size		#carga el valor de jugador size en el registro
mover_jugador_loop_d:
	lw $t2 jugador($t0)			#carga el valor de jugador m�s la base en el registro
	lb $t3 jugador_x			#carga el valor de jugador x en el registro
	lb $t4 jugador_size			#carga el valor de jugador size en el registro
	div $t4 $t4 -4				#vidido $t4 entre -4
	addi $t4 $t4 60				# sumo 16 al registro $t2
	bgt $t3 $t4 mover_jugador_d_sin_accion # compara si el valor $t3 es igual o mayor a $t4 y salta a mover_jugador_d_sin_accion
	addi $t2 $t2 16					# sumo 16 al registro $t2
	sw $t2 jugador($t0)				# guarda el valor de $t2 en la direcci�n
	addi $t0 $t0 4				# sumo 4 al registro $t0
	bne $t0 $t1 mover_jugador_loop_d    	#compara si $t1 es diferente de $t0 para saltar a la funci�n mover_jugador_loop_d
	addi $t3 $t3 4				# sumo 4 al registro $t3
	sb $t3 jugador_x			# guarda el valor de $t3 en jugador_x
mover_jugador_d_sin_accion:
	jr $ra				#carga el �ltimo valor del jump and link que haya hecho
contadorbloquesdestruidos:
	addi $sp $sp -4			#le resta a $sp 4 para abrir los datos en la pila
	sw $ra 0($sp)
	li $a0, 0			#carga el limite inicial en x para dibujar
	li $a1, 30			# carga el limite en y para dibujar
	lw $a2, blueColor		# carga el color que queremos tener en el contadpr
	lb $t1 bloque_vivos_contador 	# carga el valor de bloque_vivos_contador en $t1
	beq $t3 55 siguiente_nivel		#compara si $t3 es igual a $55 para saltar a la funci�n siguiente_nivel	
contblo:
	beq $t1 $a0 salir		#compara si $t1 es igual a $a0 para saltar a la funci�n salir
	jal DrawPoint			#realiza el salto a la funci�n Drawpoint
	addi $a0 $a0 1			#suma 1 a $a0
	addi $a2 $a2 100		#suma 100 a $a2
	sb $a0 bloque_contador		# guarda el valor de $a0 en bloque_contador
	bne $t1 $a0 contblo		#compara si $t1 es diferente de $a0 para saltar a la funci�n contblo
salir:
	lw $ra 0($sp)
	addi $sp $sp 4			#le suma a $sp 4 para borrar los datos en la pila
	jr $ra				#carga el �ltimo valor del jump and link que haya hecho
	
powerup:
	addi $sp $sp -4			#le resta a $sp 4 para abrir los datos en la pila
	sw $ra 0($sp)
	
	addi $t0 $zero 2		#crea un 2 en $t0 para luego compararlo
	lb $t1 bloque_vivos_contador 	# carga el valor de bloque_vivos_contador en $t1
	bne $t1 $t0 salir		#compara si $t1 es diferente de $t0 para saltar a la funci�n salir
	jal limpiar_jugador
	li $t0 16
	sb $t0 jugador_size
	jal mostrar_jugador		# guarda el valor de $t1 en jugador_size
	j salir				#salta a la funci�n salir
	
powerup2:
	addi $sp $sp -4			#le resta a $sp 4 para abrir los datos en la pila
	sw $ra 0($sp)		
	lb $t1 bloque_vivos_contador 
	beq $t1 55 siguiente_nivel
	addi $t0 $zero 20		#crea un 10 en $t0
	lb $t1 bloque_vivos_contador 	# carga el valor de bloque_vivos_contador en $t1
	bne $t1 $t0 salir		#compara si $t1 es diferente de $t0 para saltar a la funci�n salir
	li $t1 32
	sb $t1 jugador_size
	jal player
	jal mostrar_jugador		# guarda el valor de $t1 en jugador_size	
	j salir				#salta a la funci�n salir


# $a0 contains x position
# $a1 contains y position
# $a2 contains color
DrawPointB: 			#dibuja un punto (1 bit)
	sll $t0, $s7,  6  	# multiplica las coordenada en y (length of the field)
	addu $v0, $s6, $t0	# suma a t0 m�s la $s6 y lo almacena en $vo
	sll $v0, $v0, 2		#divide entre 4, corrimiento de 2 a la izquierda
	addu $v0, $v0, $gp	# suma a v0 m�s el puntero y lo almacena en el primero mencionada
	sw $s2, ($v0)		# dibuja el color de la localizaci�n
	jr $ra			# #carga el �ltimo valor del jump and link que haya hecho
		# $a0 contains x position
		# $a1 contains y position
		# $a2 contains color
DrawPoint: #dibuja un punto (1 bit)
	sll $t0, $a1,  6  # multiply y-coordinate by 64 (length of the field)
	addu $v0, $a0, $t0		# suma a t0 m�s la pocision inicial y lo almacena en $vo
	sll $v0, $v0, 2			#divide entre 4, corrimiento de 2 a la izquierda
	addu $v0, $v0, $gp		# suma a v0 m�s el puntero y lo almacena en el primero mencionada
	sw $a2, ($v0)			# draw the color to the location
	jr $ra				#carga el �ltimo valor del jump and link que haya hecho

DrawHorizontalLine:
	addi $sp, $sp, -4			#le resta a $sp 4 para abrir los datos en la pila
	sw $ra, 0($sp)
	sub $t9, $a3, $a0			# resta la posicion en x final y la guarda en el registro $t9
	move $t1, $a0				# mueve a0 a $t1
		
HorizontalLoop:
	add $a0, $t1, $t9			#le suma a la pocision inicial en y un registro
	jal DrawPoint				#dibuja un punto
	addi $t9, $t9, -1			#le resta a $t9 un 1
	bge $t9, 0, HorizontalLoop		# compara si el valor $t9 es igual o mayor a 0 y salta a HorizontalLoop
	lw $ra, 0($sp)				# put return back
   	addi $sp, $sp, 4			#le suma a $sp 4 para borrar los datos en la pila
	jr $ra					#carga el �ltimo valor del jump and link que haya hecho
DrawVerticalLine:
	addi $sp, $sp, -4			#le resta a $sp 4 para abrir los datos en la pila
   	sw $ra, 0($sp)
	sub $t9, $a3, $a1			# resta la posicion en y y la giarda en el registro $t9
	move $t1, $a1				# mueve a1 a $t1
VerticalLoop:
	add $a1, $t1, $t9			#le suma a la pocision en y un registro
	jal DrawPoint				#dibuja un punto
	addi $t9, $t9, -1			#le resta a $t9 un 1
	bge $t9, 0, VerticalLoop		# compara si el valor $t9 es igual o mayor a 0 y salta a VerticalLoop
	lw $ra, 0($sp)				# put return back
	addi $sp, $sp, 4			#le suma a $sp 4 para borrar los datos en la pila

	jr $ra					#carga el �ltimo valor del jump and link que haya hecho
					# crea la pantalla color negra
ClearBoard:
	lw $t0, backgroundColor			## carga el valor de backgroundColor en $t0
	li $t1, 8192 				# n�mero de pixeles en la pantalla
StartCLoop:
	subi $t1, $t1, 4			#le suma a $t1 4
	addu $t2, $t1, $gp			# suma $t1 m�s el puntero y lo almacena en $t2
	sw $t0, ($t2)				# guarda el valor de $t0 en $t2
	beqz $t1, EndCLoop			# compara si el valor $t1 es igual a 0 y salta a EndCLoop
	j StartCLoop				# salta a la funci�n StartCLoop	
EndCLoop:
	jr $ra					# carga el �ltimo valor del jump and link que haya hecho

Obtener_tecla:
	lw $t9 0xFFFF0004		# Carga el valor presionado (ASCII)
Obtener_tecla_derecha:
	bne $t9 100 Obtener_tecla_izquierda	# compara si el valor $t9 es igual a 100 y salta a obtener tecla izquierda
	li $v0 0x01000000			# establece en $vo que se mueva a la derecha
	j Obtener_tecla_return			# salta a la funci�n Obtener_tecla_return
Obtener_tecla_izquierda:
	bne $t9 97 Obtener_tecla_derecha	# compara si el valor $t9 es igual a 97 y salta a obtener tecla derecha
	li $v0 0x02000000			# establece en $vo que se mueva a la izquierda
	j Obtener_tecla_return			# salta a la funci�n Obtener_tecla_return	
Obtener_tecla_return:
	jr $ra					# carga el �ltimo valor del jump and link que haya hecho
				## vuelve a las condiciones iniciales, reinicia el juego
Reset:	
	li $t3, 0			# establece el valor 0 en el registro $t3
	sb $t3 bloque_vivos_contador	# guarda el valor de $t3 en bloque_vivos_contador
	
	li $t4,  3              # establece el valor 3 en el registro $t4
	sb $t4 vidas		# guarda el valor de $t4 en vidas
	sw $zero, 0xFFFF0000	# crea las letras del teclado o s�mbolo
	sw $zero, 0xFFFF0004 	# establece la letra del teclado
	jal ClearBoard		# limpia la pantalla, la pone en negro
	j Game_Over		# finaliza el juego
siguiente_nivel:
	li $t3, 0			# establece el valor 0 en el registro $t3
	sb $t3 bloque_vivos_contador	# guarda el valor de $t3 en bloque_vivos_contador
	lb $t0 niveles			# carga el valor de los niveles en $t0
	addi $t0 $t0 1			# suma 1 al valor de los niveles
	sb $t0 niveles			# guarda el valor de $t0 en los niveles
	beq $t0 2 siguiente_nivel_2	# compara si el valor $t0 de los niveles es igual a 2 y salta al siguiente nivel
	li $t0 0
	sb $t0 niveles
	li $t4,  3			# asigna el valor 3 a $t4
	sb $t4 vidas			# guarda el valor de $t4 en vidas
	sw $zero, 0xFFFF0000		 #crea las letras del teclado o s�mbolo
	sw $zero, 0xFFFF0004	 	# establece la letra del teclado
	jal ClearBoard			# limpia la pantalla, la pone en negro
	j NewGame
siguiente_nivel_2:

	lw $t0 color_bloque_nivel_2     # carga el valor de color_bloque_nivel_2 en $t0
	sw $t0 color_bloque		#guarda el valor de $t0 en color_bloque
	lw $t0 color_jugador_nivel_2    # carga el valor de color_jugador_nivel_2 en $t0
	sw $t0 color_jugador		#guarda el valor de $t0 en color_jugador
	j NewGame			# salta a la funci�n NewGame

Game_Over:		#############################################
		# Dibujar palabra GAME:                      #
		#############################################
		li $a0, 50			#Tono		
		li $a1, 500			#Duraci�n en ms
		li $a2, 30			#Instrumento (guitarra)
		li $a3, 127			#Volumen (m�ximo)
		li $v0, 31			#servicio 31, En MARS sirve para emitir sonidos
		syscall				#emite el sonido
		
		# $a0 la coordinada inicial en x 
		# $a1 la coordinada en y
		# $a2 el color
		# $a3 la coordinada final en x

		#dibuja la letra G:
		li $a0, 15
		li $a1, 0
		lw $a2, color_g_o
		li $a3, 20
		jal DrawHorizontalLine
		li $a1, 1
		jal DrawHorizontalLine
		li $a1, 8
		jal DrawHorizontalLine
		li $a1, 9
		jal DrawHorizontalLine
		li $a1, 2
		li $a3, 7
		jal DrawVerticalLine
		li $a0, 16
		jal DrawVerticalLine
		li $a0, 19
		li $a1, 5
		jal DrawVerticalLine
		li $a0, 20
		jal DrawVerticalLine
		li $a0, 18
		jal DrawPoint
		#dibuja la letra A:
		li $a0, 22
		li $a1, 1
		li $a3, 9
		jal DrawVerticalLine
		li $a0, 23
		li $a1, 0
		jal DrawVerticalLine
		li $a0, 26
		jal DrawVerticalLine
		li $a0, 27
		li $a1, 1
		jal DrawVerticalLine
		li $a0, 24
		li $a1, 0
		li $a3, 25
		jal DrawHorizontalLine
		li $a1, 1
		jal DrawHorizontalLine
		li $a1, 4
		jal DrawHorizontalLine
		li $a1, 5
		jal DrawHorizontalLine
		#dibuja la letra M:
		li $a0, 29
		li $a1, 0
		li $a3, 9
		jal DrawVerticalLine
		li $a0, 30
		jal DrawVerticalLine
		li $a0, 37
		jal DrawVerticalLine
		li $a0, 38
		jal DrawVerticalLine
		li $a0, 31
		li $a3, 2
		jal DrawVerticalLine
		li $a0, 36
		jal DrawVerticalLine
		li $a0, 32
		li $a1, 1
		li $a3, 3
		jal DrawVerticalLine
		li $a0, 35
		jal DrawVerticalLine
		li $a0, 33
		li $a1, 2
		li $a3, 9
		jal DrawVerticalLine
		li $a0, 34
		jal DrawVerticalLine
		#dibuja la letra E:
		li $a0, 40
		li $a1, 0
		li $a3, 45
		jal DrawHorizontalLine
		li $a1, 1
		jal DrawHorizontalLine
		li $a1, 8
		jal DrawHorizontalLine
		li $a1, 9
		jal DrawHorizontalLine
		li $a1, 4
		li $a3, 44
		jal DrawHorizontalLine
		li $a1, 5
		jal DrawHorizontalLine
		li $a1, 2
		li $a3, 41
		jal DrawHorizontalLine
		li $a1, 3
		jal DrawHorizontalLine
		li $a1, 7
		jal DrawHorizontalLine
		li $a1, 6
		jal DrawHorizontalLine
		
		#############################################
		#Dibujar palabra OVER:                      #
		#############################################		
		# dibuja la letra O:						
		li $a0, 17
		li $a1, 13
		li $a3, 20
		jal DrawVerticalLine
		li $a0, 22
		jal DrawVerticalLine
		li $a0, 18
		li $a1, 12
		li $a3, 21
		jal DrawVerticalLine
		li $a0, 21
		jal DrawVerticalLine
		li $a0, 19
		li $a3, 13
		jal DrawVerticalLine
		li $a0, 20
		jal DrawVerticalLine
		li $a0, 19
		li $a1, 20
		li $a3, 21
		jal DrawVerticalLine
		li $a0, 20
		jal DrawVerticalLine
		#dibuja la letra V:
		li $a0, 24
		li $a1, 12
		li $a3, 19
		jal DrawVerticalLine
		li $a0, 29
		jal DrawVerticalLine
		li $a0, 25
		li $a3, 20
		jal DrawVerticalLine
		li $a0, 28
		jal DrawVerticalLine
		li $a0, 26
		li $a1, 20
		li $a3, 21
		jal DrawVerticalLine
		li $a0, 27
		jal DrawVerticalLine
		# dibuja la E:
		li $a0, 31
		li $a1, 12
		li $a3, 36
		jal DrawHorizontalLine
		li $a1, 13
		jal DrawHorizontalLine
		li $a1, 20
		jal DrawHorizontalLine
		li $a1, 21
		jal DrawHorizontalLine
		li $a1, 16
		li $a3, 35
		jal DrawHorizontalLine
		li $a1, 17
		jal DrawHorizontalLine
		li $a1, 14
		li $a3, 32
		jal DrawHorizontalLine
		li $a1, 15
		jal DrawHorizontalLine
		li $a1, 18
		jal DrawHorizontalLine
		li $a1, 19
		jal DrawHorizontalLine
		# dibuja la R:
		li $a0, 38
		li $a1, 12
		li $a3, 21
		jal DrawVerticalLine		
		li $a0, 39
		jal DrawVerticalLine
		li $a0, 42
		jal DrawVerticalLine
		li $a0, 43
		li $a1, 17
		jal DrawVerticalLine
		li $a1, 13
		li $a3, 15
		jal DrawVerticalLine
		li $a0, 40
		li $a1, 12
		li $a3, 13
		jal DrawVerticalLine	
		li $a0, 41
		jal DrawVerticalLine	
		li $a0, 40
		li $a1, 16
		li $a3, 17
		jal DrawVerticalLine
		li $a0, 41
		jal DrawVerticalLine
		
		#SLEEP para que el mensaje dure un tiempo en pantalla
		li $a0, 500	#Tiempo en ms
		li $v0, 32 	#valor syscall para "sleep"
		syscall
		
		j NewGame	
