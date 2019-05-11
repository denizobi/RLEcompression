#Homework 8 Macros -- Melecia Young

#get string from user
.macro get_str() 
	.data
fileName:	.space	64
	.text
	li	$v0, 8	#read string
	la	$a0, fileName	
	la	$a1, 64
	syscall
	
	li	$v0, 4	#print string
	la	$a0, fileName
	syscall

	move	$t1, $a0
.end_macro

#print a string
.macro print_str(%str)
	.data
macro_str:	.asciiz	%str
	.text
	li	$v0, 4	#print string
	la	$a0, macro_str
	syscall
.end_macro

#remove the end of the file and replace it with a 0 
.macro	rmv_end()
	move	$s1, $a0
	li	$t2, '\n'	#load the register with the new line character to compare

loop:
	lb	$t3, 0($s1)	#if the current byte equals the new line character
	beq	$t3, 10, replace	#branch to replacement
	addi	$s1, $s1, 1		#iterate to the next character
	j loop

replace:
	sb	$zero, 0($s1)	#replace the 10 with a 0... replace the new line character with end of line characters
.end_macro


#print an int
.macro print_int(%x)
	li	$v0, 1	#print int
	add	$a0, $zero, %x
	syscall
.end_macro

#open file
.macro	open_file(%file_descriptor_dest)	
	li	$v0, 13	#open file syscall
	la	$a1, 0 
	la	$a2, 0
	syscall
	
	move	%file_descriptor_dest, $v0	#going to store the file descriptor 

.end_macro

#read file
.macro	read_file(%space, %buffer)	#by adding the second parameter we should be able to choose if we want a static or dynamic memory
	li	$v0, 14
	la	$a0, ($s6)	#file descriptor
	la	$a1, %space	#size allotment of the file
	la	$a2, %buffer	#choose static or dynamic memory storage
	syscall
	
	#going to store the size of the file so we can print it later 
	move	$s2, $v0	#store the amount of characters counted when the file was read
	move	$s6, $s2 
	
.end_macro

#close file
.macro	close_file(%space)
	li	$v0, 16
	la	$a0, ($s6)
	syscall
.end_macro

#allocate heap memory
.macro allocate_heap(%memory_location)	#its going to take in the register where the memory will be stored
	li	$v0, 9
	la	$a0, 1024
	syscall
	
	#syscall 9 stores the address of the memory we allocated to $v0
	#need to move the address somewhere
	move	%memory_location, $v0
.end_macro

#print out the data in the buffer 
.macro	output_data(%buffer)	#take in location of the file
	li	$v0, 4		#print
	la	$a0, %buffer
	syscall
.end_macro

#psuedocode for the compression algorithm
#for loop:
	#one conditional statment
	#need to increment i 
#while loop:
	#use j as i + 1
	#conditional statment length
	#store char at i
	#store char at j
	#compare the two
	#not equal...print... for
	#otherwise
		#add one to the count
		#increment i 
		#loop while
			
#compress the file 
.macro compression(%input_buffer)
	la	$a0, %input_buffer	#this is the original buffer that the file was read into
	la	$a1, ($s7)	#this is where we are going to put the new compressed file 
	la	$a2, ($s2)	#needs to be size of uncompressed file (stored in $s2)
	#lw	$t6, p
	
	move	$s1, $a0
	move	$s2, $a0
	move	$t7, $a0
	li	$t0, 0	#i
	li	$t1, 1	#counter
	addi	$t2, $t0, 1	#j = i+1
	li	$s7, 0	#char count
	li	$t6, 4
	
for:
	addi	$t2, $t0, 1
	add	$s1, $s1, $t2	#j

while:
	lb	$t3, ($s2)	#every byte we are comparing will come from $a0
	beq	$t3, 0, uncompression
	lb	$t4, ($s1)	#the comparsion byte will come from $s1
	beq	$t3, 0, uncompression
	beq	$t3, $t4, addCounter
	sb	$t3, ($s3)	#store the byte into heap memory 
	#addi	$t6, $t6, 4	#add one to the pointer
	li	$v0, 11		#if theyre different we print!
	la	$a0, ($t3)
	syscall
	addi	$s7, $s7, 1
	add	$s3, $s3, $t6
	sb	$t1, ($s3)
	#addi	$t6, $t6, 4
	add	$s3, $s3, $t6
	li	$v0, 1
	la	$a0, ($t1)
	syscall
	addi	$s7, $s7,1
	j	reset
	
addCounter:
	addi	$t1, $t1, 1
	addi	$t2, $t2, 1	#increment j until they are different
	addi	$s1, $s1, 1
	j	while

reset:
	move	$t0, $t2, 
	move	$s2, $t7
	add	$s2, $s2, $t0	#i
	li	$t1, 1
	move	$s1, $t7
	j	for
.end_macro	

#pusedocode
#need to load the first byte... letter
#print out the character 
#need to get the next byte... number and print it as many times as we need to before loading the next byte
#add one 
#loop

#macro to uncompress the file 
.macro uncompress()
#need to move the pointer back to the front
	li	$t2, 0	#i = 0
	li	$t4, 4	#offset 
	li	$t1, 4
	mul	$t1, $t1, $s7	#multiply the number of characters ($t5) by 4($t1)
	sub	$s3, $s3, $t1	#subtract to move the pointer back to the front 
	
loop:		
	#mul	$t2, $t2, 4
	#add	$s3, $s3, $t4		
	lb	$t6, ($s3)	#load the first byte
	move	$t5, $t6
	beq	$t5, 0, printSize
	print_char($t5)		#print out the current character 
	j	checkNum
	
checkNum:
	add	$s3, $s3, $t4	#get the next byte which is the number
	lb	$t6, ($s3)
	beq	$t6, 0, printSize
	bgt	$t6, 1, printer
	addi	$t2, $t2, 1
	add	$s3, $s3, $t4
	j	loop	
	
printer:
	print_char($t5)	#call the print char macro to print the character
	addi	$t6, $t6, -1
	beq	$t6, 1, addTo
	j	printer	
	
addTo:
	add	$s3, $s3, $t4
	j	loop
	
.end_macro 

#print an integer
.macro print_int(%register_of_int)
	li	$v0, 1	#print int
	la	$a0, (%register_of_int)
	syscall
.end_macro

#print a character
.macro print_char(%register_of_char)
	li	$v0, 11	#print char
	la	$a0, (%register_of_char)
	syscall
.end_macro

#deallocate the heap memory 
.macro	deallocate(%heap_memory)	#$s3 is the heap allocation location
	li	$t2, 0	#i = 0
	li	$t4, 4	#offset 
	li	$t1, 4
	mul	$t1, $t1, $s7	#multiply the number of characters ($t5) by 4($t1)
	sub	$s3, $s3, $t1	#subtract to move the pointer back to the front 
	
loop:
	lb	$t6, ($s3)
	beq	$t6, 0, loopBack	#if the byte is null... going to leave the macro 
	li	$t6, 0	#replace current byte with a 0
	sb	$t6, ($s3)	#store th 0 into the location
	j	add4
	
add4:
	addi	$s3, $s3, 4	#go to the next byte
	j	loop
	

.end_macro
