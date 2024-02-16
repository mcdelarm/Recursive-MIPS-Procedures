.include "macros.asm"

.data
newline: .asciiz "\n"
pattern:    .space 17		# array of 16 (1 byte) characters (i.e., string) plus null terminator

.text

# You should not need to modify this
main:
	print_str ("Enter the number of bits (1 <= N <= 16): ")
	read_int		# $v0 := N
	sb	$0, pattern($v0)# null-terminate pattern, i.e. pattern[N] = '\0'
	# pass $a0, $a1 args to bingen
	move	$a0, $v0	# $a0 := $v0 := N
	move	$a1, $v0	# $a1 := $v0 := n
    	jal	bingen
    	j	exit


# void bingen(unsigned int N, unsigned int n)
#	$a0 := N
#	$a1 := n
# $fp -> $ra
#        $fp
# $sp -> $a1

bingen:
	addi $sp, $sp, -8      #Save space on stack
	sw $ra, 4($sp)          #Save $ra
	sw $fp, 0($sp)           #Save $fp
	addi $fp, $sp, 4        #Set $fp
	addi $sp, $sp, -4       #Allocate more space on stack to store $a1
	sw $a1, 0($sp)          #Store $a1 in stack
	
	#Base Case
	lw $t1, 0($sp)           #$t1 = $a1 = n
	bgt $t1, $zero, if_block #go to if_block if n > 0

	#Print pattern when n <= 0
	print_str_label(pattern)      #print pattern
	addi $sp, $sp, -4             #allocate space on stack to save $a0
	sw $a0, 0($sp)                #Store $a0 on stack
	la $a0, newline               #load adress of new line string
	syscall_val (4)               #print newline
	lw $a0, 0($sp)                #Restore $a0
	addi $sp, $sp, 4              #Deallocate space on stack
	j bingen_end                  #skip if_block

if_block:	
	#Recursion 1
	lw $t1, 0($sp)           #$t1 = $a1
	sub $t2, $a0, $t1        #t2 = N - n
	li $t3, '0'              #Load ASCII value of '0'
	sb $t3, pattern($t2)   #pattern[N-n] = 0
	subi $a1, $t1, 1         #n = n - 1
	jal bingen
	lw $a1, 0($sp)           #Restore $a1 in case of clobber from recursion
	#Recursion 2
	lw $t1, 0($sp)           #$t1 = $a1
	sub $t2, $a0, $t1        #t2 = N - n
	li $t3, '1'              #Load ASCII value of '1' 
	sb $t3, pattern($t2)     #pattern[N-n] = 1
	subi $a1, $t1, 1         #n = n - 1
	jal bingen
	lw $a1, 0($sp)           #Restore $a1 in case of clobber from recursion
		
bingen_end:
	addi $sp, $fp, 4        #Restore $sp
	lw $ra, 0($fp)          #Restore $ra
	lw $fp, -4($fp)         #Restore $fp
	jr $ra                  #Return
exit:
	syscall_val (10)
