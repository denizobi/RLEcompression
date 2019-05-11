#Homework 8- Compression algorithm Melecia Young

.include	"HW8_macros.asm"

		.data
p:		.word	0	#pointer
#filename:	.space	1024	#this is going to be the file name we are gettng... created in macros instead
size:		.space	1024	
buffer:		.space	1024
#file:		.asciiz	"hello.txt"	#practice opening the file before the macro 
		.align	2


	.text
	
mainLoop:

################## ALLOCATE HEAP MEMORY ##############
#allocate 1024 bytes of dynamic memory
	allocate_heap($s7)	#need to use this as the buffer for the file 
	sw	$v0, p		#save pointer
	move	$s3, $v0	#moved the location of the pointer into $s3 so it doesn't get altered 

################## ASK USER FOR FILENAME ##############
	print_str("\nPlease enter the filename to compress or <enter> to exit: ")	#call macro to get string from user
	get_str()	#get string from the user
	
	###### if the user presses enter.... exit
	beq	$t1, 10 exit	#10 is the ascii character for a new line... if user hits enter, then exit
###############	REMOVE NEWLINE CHAR ##################
	rmv_end()	#remove the newline character and replace with end of line character 
	
	#printed the filename twice to make sure the new line character was successfully removed 
	#li	$v0, 4
	#syscall
	
	#li	$v0, 4
	#syscall
############### OPEN FILE FORE READING ##############
	open_file($s6)			#going to open the file and store the file descriptor in $s6		
	blt	$s6, $zero, error	#compare file descriptor to 0 to make sure it is not negative
	##### read file #####
	read_file(size, buffer)		#read the file into a buffer
	###### close file ######
	close_file(size)		#close the file 
	
############# OUTPUT ORIGINAL DATA ###############
	print_str("\nOriginal data: \n")	#print out the label
	output_data(size)			#print out the data in the original file
	
############ CALL COMPRESSION FUNCTION #############
	print_str("\nCompressed data: \n")	#print out the label 
	compression(size)			#call the macro to compress the file

############ CALL UNCOMPRESSION FUNCTION ##############
uncompression:					
	print_str("\nUncompressed data: \n")	#print the label 
	uncompress()				#uncompress the file
	
########### PRINT NUMBER OF BYTES FROM EACH FILE #############
printSize:
	print_str("\nOriginal file size: ")	#print the label
	print_int($s6)				#print the size of the original file... saved in $s6
	print_str("\nCompressed file size: ")	#print the label
	print_int($s7)				#print the size of the original file... saved in $s7
	j	deallocation

######### HAVE TO DEALLOCATE HEAP MEMORY #################	
deallocation:
	deallocate($s3)				#deallocate the heap memory 
	
loopBack:
	j	mainLoop			#go back to the top to enter a new file 
error:
	print_str("\nError opening file. Progam terminating.")	#if the file doesn't open then print the error

	
#exit the program 
exit:
	li	$v0, 10
	syscall
	
