  .text
  li $t0, 10

  .data
  .eqv MAX_INPUT_LEN 80
input_command:	.space MAX_INPUT_LEN # Space for string input
command_not_found_message:  .asciiz "Command not found."
input_too_long_message: .asciiz "Input too long."
  
  .text
  .globl main
main:
  .text
	li $v0, 8
  la $a0, input_command
  li $a1, MAX_INPUT_LEN
  syscall
  # Now split string into words (separated by spaces)
	jal split_string
  # Print whatever's in a1
  li $v0, 4
  syscall
  j end

####################################################################################################
  # Function to split a string and place the words in the stack,
	# separated with NULs. The final word will be terminated with 2
	# NULs. Upon return, $a0 will point to the start of the list, and $a1
	# will point to the start of a block of words which hold addresses to
	# the start of each word, with the words all terminated with a NUL.
split_string:
	move $t0, $a0
  move $a0, $sp
  addi $t0, $t0, -4
split_string_loop: # Loop through the chars
  #Increment char pointer
  addi $t0, $t0, 4
  lw $t1, 0($t0) # Get the current char
  # Check if we're at the end of the string, if we are then leave function
  beq $t1, 0, split_string_end
  # Check if this is whitespace
  beq $t1, 32, split_string_ins_nul # Space
  beq $t1, 9,  split_string_ins_nul # Tab
  # Not whitespace, not NUL, add char to stack
  sw $t1, 0($sp)
  addi $sp, $sp, -4
  j split_string_loop
# Pushes NUL onto stack then returns to split_string_loop, unless NUL
# is already on top of stack, then just jumps to split_string_loop.
split_string_ins_nul: 
  # Load last pushed word to check not nul
  lw $t2, -4($sp)
  beq $t2, $0, split_string_loop
  # Not null, push null to stack
  sw $0, 0($sp)
  addi $sp, $sp, -4
  j split_string_loop
split_string_end: # Function cleanup here 
  jr $ra
####################################################################################################
  
end:
  li $v0, 10
  syscall
