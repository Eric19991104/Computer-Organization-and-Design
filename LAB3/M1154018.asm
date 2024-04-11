.data
number1: .asciiz "\nM1154018"
number2: .asciiz "\nM1154019"
hint1: .asciiz "Input the first sequence:"
hint2: .asciiz "Input the second sequence:"
input_array: .space 1024			#讀取輸入的字串陣列，大小為 1024。
array_1: .word 0             
      	 .space 1024				#整數陣列 1，大小為 1024。
array_2: .word 0             
      	 .space 1024				#整數陣列 2，大小為 1024。

.text
main:
	li $v0, 4        			#設定系統呼叫為 4 (印出字串)
	la $a0, hint1				#印出提示
	syscall          			#執行系統呼叫
	
	# 輸入字串
    	li $v0, 8        			#設定系統呼叫為 8 (輸入字串)
    	la $a0, input_array   			#設定輸入字串的緩衝區位址
    	li $a1, 1024       			#設定緩衝區的大小為 1024
    	syscall
    	
    	move $t0, $a0				#把 a0 暫存器的內容（輸入的字串）移動到 t0
        la $a0, array_1				#把 a0 指向整數陣列 1 的起始位址
        
        move $t1, $a0				#把 a0 暫存器的內容（整數陣列 1 起始位址）移動到 t1
        li $a0, 0				#把 a0 暫存器的內容設為 0，之後要存數值（字串轉整數）。
        li $t2, 0				#把 t2 暫存器的內容設為 0 存整數陣列 1 的最終長度
        
        addi  $sp, $sp, -12			#利用堆疊保護相關的數值以防被更動，一個整數 4 bytes 共需要 3 個總共 12 bytes，借用這些空間所有要先把 sp 暫存器 - 12。
        sw  $t1, 0($sp)				#存入整數陣列 1 的起始位址
        sw  $t0, 4($sp)				#存入輸入的字串
        sw  $ra, 8($sp)				#存入返回的位址
        
        jal tokenize1				#跳到 tokenize1 迴圈處理第一個輸入的字串
        
        lw  $ra, 8($sp)				#堆疊是先進後出所以取出的順序要跟存入相反
        lw  $t0, 4($sp)
        lw  $t1, 0($sp)
        addi  $sp, $sp, 12			#用完了要恢復
        
        li $v0, 4				#之後第二個字串一樣的處理方式，只是使用的暫存器不太一樣。
	la $a0, hint2
	syscall

    	# 輸入字串
    	li $v0, 8
    	la $a0, input_array
    	li $a1, 1024
    	syscall
    	
    	move $t3, $a0
        la $a0, array_2
        
        move $t4, $a0
        li $a0, 0
        li $t5, 0
        
        addi  $sp, $sp, -12
        sw  $t4, 0($sp)
        sw  $t3, 4($sp)
        sw  $ra, 8($sp)
        
        jal tokenize2
        
        lw  $ra, 8($sp)
        lw  $t3, 4($sp)
        lw  $t4, 0($sp)
        addi  $sp, $sp, 12
        
        li $t6, -1				#用 t6 暫存器來計算第幾個元素不一樣，初始值設為 -1，因為陣列的索引從 0 開始。
        
        j compare				#跳到比較 2 個整數陣列長度的部分決定最終要怎麼處理
    	
tokenize1:
    	lb $a2, ($t0)				#從 input_array 讀取一個字元
    	beqz $a2, end1			    	#如果讀到字串結尾，跳到 end1，MIPS中 0 = '\0'。
    	beq $a2, 0x20, next1			#如果讀到空白字元，跳到 next1。
    	beq $a2, 0x0a, ret1			#如果讀到 Enter，跳到 ret1。
    	mul $a0, $a0, 10			#遇到多位數時每一個位數相差 10 倍
    	addi $a2, $a2, -48		      	#將字元轉換成數字
    	addu $a0, $a0, $a2			#把目前的計算結果和 a0 暫存器的內容相加
    	addi $t0, $t0, 1			#字串位址加一，指向下一個字元。
    	b tokenize1				#繼續執行這個迴圈，“b”是 ARM CPU 的指令，類似 x86 CPU 的 “j”。
    	
end1:
    	li $a0, 0				#清空 a0 暫存器，在 next1 如果空白的下一個是 Enter 就不會執行到清空 a0 所以這裡再清一次。
    	jr  $ra            			#返回
    	
next1:
    	sw $a0, ($t1)				#存入整數陣列
    	addi $t1, $t1, 4			#整數陣列索引移到下一個
    	addi $t0, $t0, 1			#移到下一個字元
    	lb $a0, ($t0)				#讀取下一個字元
    	seq $t7, $a0, 0x0a			#如果下一個字元是 Enter 就回傳 1
    	bne $t7, $zero, end1			#如果回傳的不是 0（也就是回傳 1）就代表結束了要到 end1 避免整數陣列長度被加 1 造成輸出錯誤
    	li $a0, 0				#清空 a0 暫存器，因為當讀取到空白代表一個數已經結束了。
    	addi $t2, $t2, 1			#整數陣列長度加一
    	j tokenize1
    			
ret1:   
	sw  $a0,($t1)				#存入整數陣列
	jr  $ra 		         	#返回
	
tokenize2:					#之後第二個字串一樣的處理方式，只是使用的暫存器不太一樣。
    	lb $a2, ($t3)
    	beqz $a2, end2
    	beq $a2, 0x20, next2
    	beq $a2, 0x0a, ret2
    	mul $a0, $a0, 10
    	addi $a2, $a2, -48
    	addu $a0, $a0, $a2
    	addi $t3, $t3, 1
    	b tokenize2

end2:
    	li $a0, 0
	jr  $ra
    	
next2:
    	sw $a0, ($t4)
    	addi $t4, $t4, 4
    	addi $t3, $t3, 1
    	lb $a0, ($t3)
    	seq $t7, $a0, 0x0a
    	bne $t7, $zero,end2
    	li $a0, 0
    	addi $t5, $t5, 1
    	j tokenize2
    			
ret2:   
	sw  $a0,($t4)
	jr  $ra 
       
compare:
	seq $a0, $t2, $t5 			#比較兩個整數陣列的長度是不是一樣
	bne $a0, 0, equal			#一樣就跳到 equal 迴圈
	sgt $a1, $t2, $t5			#如果整數陣列 1 的長度小於整數陣列 2 的長度
	beqz $a1, less_than			#就跳到 less_than 迴圈
	j geather_than				#都不是就執行 geather_than 迴圈
    		
equal:
	addi $t6, $t6, 1			#先把索引加 1
	beqz $t2, done				#如果兩個整數陣列都已經沒了就跳到 done
	beqz $t5, done
	lw $a1, ($t1)				#分別取出兩個整數陣列當前的值
	lw $a2, ($t4)
	seq $a3, $a1, $a2			#如果兩個不一樣
	beqz $a3, done				#跳到 done
	addi  $t2, $t2, -1			#把整數陣列的長度減 1
        addi  $t1, $t1 ,4			#位址移到下一個，因為一個整數佔 4 bytes 所以加 4。
        addi  $t5, $t5, -1
        addi  $t4, $t4, 4
	j equal

geather_than:
	addi $t6, $t6, 1			#後面兩個概念類似，差在如果是要判斷是不是已經沒了要用比較長的那一個而已。
	beqz $t2, done
	lw $a1, ($t1)
	lw $a2, ($t4)
	seq $a3, $a1, $a2
	beqz $a3, done
	addi  $t2, $t2, -1
        addi  $t1, $t1 ,4
        addi  $t5, $t5, -1
        addi  $t4, $t4, 4
	j geather_than

less_than:
	addi $t6, $t6, 1
	beqz $t5, done
	lw $a1, ($t1)
	lw $a2, ($t4)
	seq $a3, $a1, $a2
	beqz $a3, done
	addi  $t2, $t2, -1
        addi  $t1, $t1 ,4
        addi  $t5, $t5, -1
        addi  $t4, $t4, 4
	j less_than

done:
	li $v0, 1				#印出不一樣的索引
	la $a0, ($t6)
	syscall
	
	li $v0, 4
	la $a0, number1				#印出組員 1
	syscall
	
	li $v0, 4
	la $a0, number2				#印出組員 2
	syscall
	
	li $v0, 10				#結束
	syscall
