.data
number1: .asciiz "\nM1154018"
number2: .asciiz "\nM1154019"
answer1: .asciiz "MARS simulator is Little Endiann"
answer2: .asciiz "MARS simulator is Big Endiann"

input: .word 0x12345678

.text
main:
	lbu $t0, input				#讀取 1 byte 的 input 資料至 t0 暫存器中
	beq $t0, 0x12, big_endian		#如果 t0 暫存器中是 0x12 就跳至 big_endian
	beq $t0, 0x78, little_endian		#如果 t0 暫存器中是 0x78 就跳至 little_endian

big_endian:
	li $v0, 4
	la $a0, answer2
	syscall
	j end
	
little_endian:
	li $v0, 4
	la $a0, answer1
	syscall
	j end

end:
	li $v0, 4
	la $a0, number1				#印出組員 1
	syscall
	
	li $v0, 4
	la $a0, number2				#印出組員 2
	syscall
	
	li $v0, 10				#結束
	syscall