.include "macros.asm"

.text

# You should not need to modify this
main:
	print_str ("Enter BST size: ")
	read_int			# $v0 := size
	move	$s0, $v0		# $s0 := size
	print_str ("Value: ")
	read_int			# $v0 = val
	move	$t0, $v0
	new_node ($t0)			# $v0 = *bst = new_node(val)
	move	$a0, $v0		# $a0 = *bst, since insert uses $a0 as BST* root
	li	$t0, 1			# $t0 := i := 1

main_loop:
	bge	$t0, $s0, main_end	# if i >= size, branch to main_end
	print_str ("Value: ")
	read_int			# $v0 = val
	# pass args before calling insert
	# $a0 is already correct
	# $a0 hasn't changed because macros save and restore $a0
	move	$a1, $v0		# pass val to insert
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)		# save $t0 because insert may clobber
	jal	insert
	lw	$t0, 0($sp)		# restore $t0
	addi	$sp, $sp, 4
	addi	$t0, $t0, 1		# i++
	j	main_loop

main_end:
	print_str ("Inorder: ")
	jal	inorder
	syscall_val (10)		# exit program


# BST* insert(BST* root, int x)
#	$a0 := *root
#	$a1 := x
#	$v0 := BST*

# $fp -> $ra
#        $fp
# #sp -> $a0
insert:
	#Create Stack
	addi $sp, $sp, -8      #Create SF
	sw $ra, 4($sp)         #Save $ra
	sw $fp, 0($sp)         #Save $fp
	addi $fp, $sp, 4       #Set $fp
	addi $sp, $sp, -4      #Allocate more space on SF
	sw $a0, 0($sp)         #Store $a0 on SF
	
	#Check if root == null
	beq $a0, NULL, create_node #if root == null then new_node(x)
	
	#Compare x with root->data
	lw $t0, 0($a0)         #Load root->data into $t0
	bge $a1, $t0, greater_than #Branch is x >= root->data
	
	# x < root->data
	lw $a0, 4($a0)             #Load root->left into $a0
	jal insert                 #insert(root->left, x)
	lw $a0, 0($sp)             #Restore $a0
	sw $v0, 4($a0)             #Store returned value as root->left
	j insert_end
	
greater_than:
	#x >= root->data
	lw $a0, 8($a0)            #Load root->right into $a0
	jal insert                #insert(root->right, x)
	lw $a0, 0($sp)            #Restore $a0
	sw $v0, 8($a0)             #Store returned value as root->right
	j insert_end

create_node:
	new_node($a1)             #Creates new node and stores its pointer in $v0
	addi $sp, $fp, 4          #Restore $sp
	lw $ra, 0($fp)            #Restore $ra
	lw $fp, -4($fp)           #Restore $fp
	jr $ra                    #Return

insert_end:
	lw $a0, 0($sp)            #Restore root
	move $v0, $a0             #Return root as result
	addi $sp, $fp, 4          #Restore $sp
	lw $ra, 0($fp)            #Restore $ra
	lw $fp, -4($fp)           #Restore $fp
	jr $ra                    #Return
	
# void inorder(BST* root)
#	$a0 := *root

# $fp -> $ra
#        $fp
# $sp -> $a0

inorder:
	#Create SF
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	addi $fp, $sp, 4
	addi $sp, $sp, -4     #Allocate more space in the stack
	sw $a0, 0($sp)        #Store $a0 in stack
	
	#Check if root != NULL
	beq $a0, NULL, inorder_end       #Branch to end if root is null
	
	#Recursively call inorder(root->left)
	lw $a0, 4($a0)        #Set $a0 to root->left
	jal inorder           #inorder(root->left)
	
	#Print root->data
	lw $a0, 0($sp)        #Restore $a0
	lw $t0, 0($a0)        #$t0 = root->data
	addi $sp, $sp, -4             #allocate space on stack to save $a0
	sw $a0, 0($sp)                #Store $a0 on stack
	move $a0, $t0                 #load root->data to print
	syscall_val (1)               #print root->data
	li $a0, 32                    #load ASCII value of whitespace
	syscall_val(11)               #print whitespace
	lw $a0, 0($sp)                #Restore $a0
	addi $sp, $sp, 4              #Deallocate space on stack
	
	#Recursively call inorder(root->right)
	lw $a0, 8($a0)               #Set $a0 to root->right
	jal inorder                  #inorder(root->right)
	
inorder_end:
	addi $sp, $fp, 4
	lw $ra, 0($fp)
	lw $fp, -4($fp)
	jr $ra
	
exit:
	syscall_val (10)		# exit program
