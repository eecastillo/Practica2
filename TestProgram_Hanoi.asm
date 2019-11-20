#Alejandro Gudiño
#Ethandrake Castillo
.text 
main:
	addi $s0, $s0, 0x000000df #Cargar valor de memoria a registros A, origen
	addi $s1, $s1, 0x000000eb #Cargar valor de memoria a registro B, auxiliar
	addi $s2, $s2, 0x000000f7 #Cargar valor de memoria a registro C, final
	addi $s3, $s3, 3 #Guardar numero de discos
	
	#Meter los valores en la torre A	
	add $t0, $t0, $s0 #Cargar dirección A para manipular
for:	sw $s3, ($t0) #Poner el valor n en torre A
	addi $t0, $t0, 4 #Aumentar un byte de memoria a A
	addi $s3, $s3, -1 #Reducir n
	bne $s3, $zero, for #Regresar a for hasta que n = 0
	
	addi $s3, $s3, 3 #Guardar número de discos
	jal hanoi
	j exit
	
hanoi:  
        addi $sp, $sp, -20 #Espacio para guardar los 5 registros
	sw $ra, 0($sp) #Guardar RA para poder regresar
	sw $s0, 4($sp) #Guardar dirección de A
	sw $s1, 8($sp) #Guardar dirección de B
	sw $s2, 12($sp) #Guardar dirección de C
	sw $s3, 16($sp) #Guardar N
	
	#Revisar caso base
	beq $s3, 1, if #Revisar si n=1
	j else
if: 
	#Si n=1
	sw $s3, ($s2) #Mover disco de origen a destino
	sw $zero, ($s0) #Borrar dato de memoria
	j return
	
else:
	addi $s3, $s3, -1 #Decrementar en 1 el valor de n
	addi $s0, $s0, 4 #Incrementar un byte a la dirección de origen
	lw $s2, 8($sp) #El destino pasa a ser el auxiliar
	lw $s1, 12($sp)	#El auxiliar pasa a ser el destino
	jal hanoi
	addi, $s0, $s0, -4 #Decrementar un byte al origen
	lw $s2, 12($sp) #C vuelve a ser el destino
	lw $t0, ($s0)
	sw $t0, ($s2) #Mover el disco del origen al destino
	sw $zero, ($s0) #Borrar disco de torre A
	addi $s2, $s2, 4 #Aumentar en un byte el destino
	lw $s1, 4($sp) #El origen ahora es el auxiliar
	lw $s0, 8($sp) #El auxiliar ahora es el origen
	jal hanoi  
	
		
return:
	lw $ra, 0($sp) #Sacar valor de RA del stack
	lw $s0, 4($sp) #Sacar direccion de A del stack
	lw $s1, 8($sp) #Sacar direccion de B del stack
	lw $s2, 12($sp) #Sacar direccion de C del stack
	lw $s3, 16($sp) #Sacar valor de n de la pila
	addi $sp, $sp, 20 #Regresar el stacka su valor normal
	jr $ra	#Fin de la funcion
	
exit:
