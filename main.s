  .align 2
  .data
  .eqv MAX_INPUT_LEN 80
input_command:  .space MAX_INPUT_LEN ## Space for string input
command_not_found_message:  .asciiz "Command not found."
input_too_long_message: .asciiz "Input too long."
  
  .text
  .globl main

#############################################################################
  ## Main function
main:
  li $v0, 8
  la $a0, input_command
  li $a1, MAX_INPUT_LEN
  syscall
  ## Now split string into words (separated by spaces)
  jal split_string
  ## Print whatever's in a0
  li $v0, 4
  syscall
  j end

#############################################################################
  ## End the program
end:
  li $v0, 10
  syscall

#############################################################################
  ## Includes
.include "command_parser.s"
