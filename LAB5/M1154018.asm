.data
hint: .asciiz "Enter the values of a and b:"
result: .asciiz "The GCD of a and b is "
input_array: .space 1024			#讀取輸入的字串陣列，大小為 1024。
array: .word 0             
       .space 8					#整數陣列，大小為 8。

.text
main:
	li $v0, 4        			#設定系統呼叫為 4 (印出字串)
	la $a0, hint				#印出提示
	syscall          			#執行系統呼叫
	
	# 輸入字串
    	li $v0, 8        			#設定系統呼叫為 8 (輸入字串)
    	la $a0, input_array   			#設定輸入字串的緩衝區位址
    	li $a1, 1024       			#設定緩衝區的大小為 1024
    	syscall
    	
    	move $t0, $a0				#把 a0 暫存器的內容（輸入的字串）移動到 t0
        la $a0, array				#把 a0 指向整數陣列 1 的起始位址
        
        move $t1, $a0				#把 a0 暫存器的內容（整數陣列 1 起始位址）移動到 t1
        li $a0, 0				#把 a0 暫存器的內容設為 0，之後要存數值（字串轉整數）。
        li $t2, 0				#把 t2 暫存器的內容設為 0 存整數陣列當前的長度
        
        addi  $sp, $sp, -12			#利用堆疊保護相關的數值以防被更動，一個整數 4 bytes 共需要 3 個總共 12 bytes，借用這些空間所有要先把 sp 暫存器 - 12。
        sw  $t1, 0($sp)				#存入整數陣列 1 的起始位址
        sw  $t0, 4($sp)				#存入輸入的字串
        sw  $ra, 8($sp)				#存入返回的位址
        
        jal tokenize				#跳到 tokenize 迴圈處理輸入的字串
        
        lw  $ra, 8($sp)				#堆疊是先進後出所以取出的順序要跟存入相反
        lw  $t0, 4($sp)
        lw  $t1, 0($sp)
        addi  $sp, $sp, 12			#用完了要恢復
        
        j start					#跳到開始找最大公因數的部分
    	
tokenize:
    	lb $a2, ($t0)				#從 input_array 讀取一個字元
    	beqz $a2, end			    	#如果讀到字串結尾，跳到 end，MIPS中 0 = '\0'。
    	beq $a2, 0x20, next			#如果讀到空白字元，跳到 next。
    	beq $a2, 0x0a, ret			#如果讀到 Enter，跳到 ret。
    	mul $a0, $a0, 10			#遇到多位數時每一個位數相差 10 倍
    	addi $a2, $a2, -48		      	#將字元轉換成數字
    	addu $a0, $a0, $a2			#把目前的計算結果和 a0 暫存器的內容相加
    	addi $t0, $t0, 1			#字串位址加一，指向下一個字元。
    	b tokenize				#繼續執行這個迴圈，“b”是 ARM CPU 的指令，類似 x86 CPU 的 “j”。
    	
end:
    	li $a0, 0				#清空 a0 暫存器，在 next 如果空白的下一個是 Enter 就不會執行到清空 a0 所以這裡再清一次。
    	jr  $ra            			#返回
    	
next:
    	sw $a0, ($t1)				#存入整數陣列
    	addi $t1, $t1, 4			#整數陣列索引移到下一個
    	addi $t0, $t0, 1			#移到下一個字元
    	lb $a0, ($t0)				#讀取下一個字元
    	seq $t7, $a0, 0x0a			#如果下一個字元是 Enter 就回傳 1
    	bne $t7, $zero, end			#如果回傳的不是 0（也就是回傳 1）就代表結束了要到 end 避免整數陣列長度被加 1 造成輸出錯誤
    	li $a0, 0				#清空 a0 暫存器，因為當讀取到空白代表一個數已經結束了。
    	addi $t2, $t2, 1			#整數陣列長度加一
    	beq $t2, 2, end				#如果整數陣列的長度已經是 2 代表已經有 2 個整數了，後面如果再有就略過，跳到 end。
    	j tokenize
    			
ret:   
	sw  $a0,($t1)				#存入整數陣列
	jr  $ra 		         	#返回

start:
	lw $t3, ($t1)				#取出整數陣列兩個數值至 t3、t4 暫存器
	addi $t1, $t1, 4
	lw $t4, ($t1)
	beqz $t3, first_value			#如果第一個數值是 0 跳到 first_value
	beqz $t4, second_value			#如果第二個數值是 0 跳到 second_value
	j gcd					#跳至 gcd 進行輾轉相除法
	
gcd:
	bge $t3, $t4, geather_than		#看哪個數比較大就跳至對應處理的部分
	bge $t4, $t3, less_than

geather_than:
	rem $t3, $t3, $t4			#t3 = t3 % t4
	beqz $t3, first_value			#如果 t3 取餘數後為 0 就跳至 first_value
	j gcd					#回到 gcd 繼續進行輾轉相除法

less_than:
	rem $t4, $t4, $t3
	beqz $t4, second_value
	j gcd

first_value:
	li $v0, 4
	la $a0, result				#印出結果
	syscall
	
	li $v0, 1
	la $a0, ($t4)				#如果 t3 已經是 0 了代表最大公因數是 t4 內的值
	syscall
	
	j done
	
second_value:
	li $v0, 4
	la $a0, result
	syscall
	
	li $v0, 1
	la $a0, ($t3)
	syscall
	
	j done

done:
	li $v0, 10				#結束
	syscall
