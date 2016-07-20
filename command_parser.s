  .globl split_string
 #############################################################################
  ## Function to split a string and place the words in the stack,
  ## separated with NULs. The address of the string should be stored in $a0.
  ## The final word will be terminated with 2 NULs (then more to pad align).
  ## Upon return, $a0 will point to the start of the list, and $a1 will
	## point to the start of a block of words which hold addresses to the
	## start of each word, with the words all terminated with a NUL (4
	## bytes).
split_string:
  ## Check we haven't been DUPED and a0 actually contains just a NUL
  lb $t0, 0($a0)
  bne $0, $t0, split_string_arguments_ok
  ## Deal with string of length 0:
  ## Push 2 nulls, set a0
  move $a0, $sp
  sb $0, 0($sp)
  sb $0, -1($sp)
  addi $sp, $sp, -2
  ## Push another null, set a1 to just after 1st 2 nulls
  move $a1, $sp
  sb $0, 0($sp)
  addi $sp, $sp, -1
  j split_string_return
  
  ## a0 is fine, continue normally
split_string_arguments_ok:  
  move $t0, $a0
  move $a0, $sp
  addi $t0, $t0, -1
split_string_loop: ## Loop through the chars
  #Increment char pointer
  addi $t0, $t0, 1
  lb $t1, 0($t0) ## Get the current char
  ## Check if we're at the end of the string, if we are then move to
  ## the next step
  beq $t1, 0, split_string_write_addresses
  ## Check if this is whitespace
  beq $t1, 32, split_string_ins_nul ## Space
  beq $t1, 9,  split_string_ins_nul ## Tab
  ## Not whitespace, not NUL, add char to stack
  sb $t1, 0($sp)
  addi $sp, $sp, -1
  j split_string_loop

  ## Pushes NUL onto stack then returns to split_string_loop, unless NUL
  ## is already on top of stack, then just jumps to split_string_loop.
split_string_ins_nul: 
  ## Load last pushed char to check not nul
  lb $t2, 1($sp)
  beq $t2, $0, split_string_loop
  ## Not null, push null to stack
  sb $0, 0($sp)
  addi $sp, $sp, -1
  j split_string_loop

split_string_write_addresses: ## Push addresses of words onto the stack
  ## Push 2 NULs onto the stack
  sb $0, 0($sp)
  sb $0, -1($sp)
  addi $sp, $sp, -2
  ## Push all string addresses onto the stack
  move $t0, $a0 ## Set counter to start of word list
  move $a1, $sp ## Set a1 to the start of the word address list
  sw $t0, 0($sp) ## Push the first address onto the stack
  addi $sp, $sp, -4
split_string_write_addresses_loop:  
  addi $t0, $t0, -1 ## Inc counter
  ## Check if NUL
  lb $t1, 0($t0)
  beq $t1, $0, split_string_add_word_address
  ## Not null, so continue with loop
  j split_string_write_addresses_loop
split_string_add_word_address:  
  lw $t1, -4($t0) ## Load char after the nul (start of the next word)
  ## If it's another nul, then just return, we're done               
  beq $t1, $0, split_string_return 
  ## Not another nul, so push this address onto the stack
  addi $t1, $t0, 4
  sw $t1, 0($sp)
  addi $sp, $sp, -4
  j split_string_write_addresses_loop

split_string_return:  
  sw $0, 0($sp) ## Push a final NUL to finish this block of data
  addi $sp, $sp, -4
  jr $ra                        # Return


