# ===========================================================
# Identificacao do grupo: 01T  [T?? para Tagus ou A?? para Alameda]
#
# Membros [istID, primeiro + ultimo nome]
# 1. 113459 Gabriel Monte
# 2. 114921 Pedro Lourenço
# 3. 113780 Francisco Simões
#
# ===========================================================
# Requisitos do enunciado que *nao* estao corretamente implementados:
# (indicar um por linha, ou responder "nenhum")
# - nenhum
#
# ===========================================================
# Top-5 das otimizacoes que a vossa solucao incorpora:
# (maximo 140 caracteres por cada otimizacao)
#
# 1. Conversão otimizada de bytes para inteiros: Processamento
#     em loop dos bytes lidos, subtraindo 32 (para m0 e m1) e
#     armazenando diretamente como inteiros de 32 bits.
#
# 2. Reutilização de dotproduct em matmul: Chamada interna de
#     dotproduct para calcular produtos escalares,
#     reduzindo redundância e melhorando legibilidade.
#
# 3. Minimização de alocação dinâmica: Uso da pilha (sp) para 
#     preservar registradores temporários, evitando alocações
#     desnecessárias em memória.
#
# 4.
#
# 5.
#
# ===========================================================

.data

# ===========================================================
#Main data structures. These definitions cannot be changed.

h_m0: .word 128
w_m0: .word 784
m0: .zero 401408                #h_m0 * w_m0 * 4 bytes

h_m1: .word 10
w_m1: .word 128
m1: .zero 5120                  #h_m1 * w_m1 * 4 bytes

h_input: .word 784
w_input: .word 1
input: .zero 3136               #h_input * w_input * 4 bytes

h_h: .word 128
w_h: .word 1
h: .zero 512                    #h_h * w_h * 4 bytes

h_o: .word 10
w_o: .word 1
o: .zero 40                     #h_o * w_o * 4 bytes


# ===========================================================
# Here you can define any additional data structures that your program might need

matrizm0: .string "m0.bin"     # Name of the binary file of the matrix m0

m0inbin: .zero  100352         # Buffer to store the m0 file content

matrizm1: .string "m1.bin"     # Name of the binary file of the matrix m1

m1inbin: .zero 1280            # Buffer to store the m1 file content

image: .string "output0.bin"   # Name of the binary file of the input image 

inputinbin: .zero 784          # Buffer to store the input image file content


# ===========================================================
.text

main:
    
    # Set up arguments for *classify* function
    la a0, matrizm0         # Load the adress of the m0 file name
    la a1, matrizm1         # Load the adress of the m1 file name
    la a2, image            # Load the adress of the input image file name

    # Call *classify* function
    jal ra, classify        # Jump to classify and save return adress in ra

    j exit                  # Jump to exit
    

# ===========================================================
# FUNCTION: abs
#   Computes absolute value of the int stored at a0
# Arguments:
#   a0, a pointer to int
# Returns:
#   Nothing (modifies value in memory)
# ===========================================================
  
abs:
  lw t0, 0(a0)             # Load int value
  bge t0, zero, done_abs   # If value >= 0, skip negation
  sub t0, x0, t0           # t0 = -t0
  sw t0, 0(a0)             # Store back to memory

done_abs:
  jr ra                    # Return to the caller


# ============================================================
# FUNCTION: relu
#   Applies ReLU on each element of the array (in-place)
# Arguments:
#   a0 = pointer to int array
#   a1 = array length
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ============================================================
relu:
    blez a1, exit_with_error_36    # Error condition (a1 <= 0)
    li t0, 0                       # Index

Loop_relu:
    beq t0, a1, loop_end_relu      # Loop condition (t0 == a1)
    slli t1, t0, 2                 # t1 = t0 * 4
    add t2, a0, t1                 # t2 = a0 + t1
    lw t3, 0(t2)                   # Loads the value of the respective index
    bltz t3, change_to_zero_relu   # Swap condition (t3 < 0)
    j next_relu                    # Jumps to next

change_to_zero_relu:
    sw zero, 0(t2)                 # Switch the negative value to zero

next_relu:
    addi t0, t0, 1                 # Iterates to the next index (t0 = t0 + 1)
    j Loop_relu                    # Goes back to the loop

loop_end_relu:
  jr ra                            # normal return


# =================================================================
# FUNCTION: Given an int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the number of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
    
argmax:
    blez a1, exit_with_error_37       # Error condition (a1 <= 0)
    li t0, 0                          # Load current index
    li t5, 0                          # Load index with the largest value
    lw t3, 0(a0)                      # Stores the first value of the array a0
    add t4, x0, t3                    # Stores the max value of the array
    

Loop_argmax:
    beq t0, a1, loop_end_argmax       # Loop condition (t0 == a1) 
    slli t1, t0, 2                    # t1 = t0 * 4 
    add t2, a0, t1                    # t2 = a0 + t1
    lw t3, 0(t2)                      # Loads the value of the respective index 
    bgt t3, t4, MAx                   # Swap condition (t3 > t4)
    j next_argmax                     # Jumps to next

MAx:
    add t4, x0, t3                    # t4 = 0 + t3
    add t5, x0, t0                    # t5 = 0 + t0

next_argmax:
    addi t0, t0, 1                    # t0 = t0 + 1
    j Loop_argmax                     # Goes back to the loop
    
loop_end_argmax:
    add a0, x0, t5                    # Store in a0 the greater index (a0 = 0 + t5)
    jr ra                             # Return to the caller


# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) - Pointer to the start of arr0
#   a1 (int*) - Pointer to the start of arr1
#   a2 (int)  - Number of elements to use  
#   a3 (int)  - Increment for index of matrix 1 (Column of matrix 1 minus 1)
# Returns:
#   a0 (int)  - The dot product of arr0 and arr1
# Exceptions:
#   - If a2 < 1, exit with error code 38
# =======================================================

dotproduct: 
    ble a2, zero, exit_with_error_38   # Exit if the number of elements is less than 1
    addi sp, sp, -24                   # Create stack 
    sw s0, 0(sp)                       # Save s0 (temporary register of arr0)
    sw s1, 4(sp)                       # Save s1 (temporary register of arr1)
    sw s2, 8(sp)                       # Save s2 (product accumulator)
    sw s3, 12(sp)                      # Save s3 (sum accumulator)
    sw s4, 16(sp)                      # Save s4 (arr0 index)
    sw s5, 20(sp)                      # Save s5 (arr1 index)
    
    li s4, 0                           # Index of matrix 0
    li s5, 0                           # Index of matrix 1
    li s2, 0                           # Initialize multiplication acummulator
    li s3, 0                           # Initialize sum accumulator
                                
loop_dotproduct:
    #Matrix 1
    bge s4, a2, end_loop_dotproduct   # Ends loop if the index of the matrix 1 reaches the limit
    mv t1, s4                         # Copies index of matrix 0
    slli t1, t1, 2                    # Calculate byte offset
    add t1, a0, t1                    # Get arr0[s4]
    addi s4, s4, 1                    # Increment arr0 index
    lw s0, 0(t1)                      # Load the arr0 elemnt
    
    #Matrix 2
    mv t1, s5                         # Arr1 index
    mv t3, a3                         # Load arr1 increment        
    mul t3, t3, t1                    # Multiplies the increment with the index
    add t3, t3, t1                    # And adds to that the index (And we get the index we want)
    slli t3, t3, 2                    # Calculate byte offset
    add t3, a1, t3                    # Get arr1[s5]
    addi s5, s5, 1                    # Increment arr1 index
    lw s1, 0(t3)                      # Load arr1 element
    mul s2, s1, s0                    # arr0 * arr1
    add s3, s3, s2                    # Accumulate result
    j loop_dotproduct                 # Loop call
    
end_loop_dotproduct:
    mv a0, s3    	                  # Return the result in a0
    lw s0, 0(sp)                      # Restore the registers
    lw s1, 4(sp) 
    lw s2, 8(sp)
    lw s3, 12(sp) 
    lw s4, 16(sp)
    lw s5, 20(sp) 
    addi sp, sp ,24                   # Restore the stack
    jr ra                             # Return


# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
#
# Arguments:
#   a0 (int*)  - pointer to the start of m0     (Matrix A)
#   a1 (int*)  - pointer to the start of m1     (Matrix B)
#   a2 (int)   - number of rows in m0 (A)             [rows_A]
#   a3 (int)   - number of columns in m0 (A)          [cols_A]
#   a4 (int)   - number of rows in m1 (B)             [rows_B]
#   a5 (int)   - number of columns in m1 (B)          [cols_B]
#   a6 (int*)  - pointer to the start of d            (Matrix C = A x B)
#
# Returns:
#   None (void); result is stored in memory pointed to by a6 (d)
#
# Exceptions:
#  - If the height or width of any of the matrices is less than 1, 
#    this function terminates the program with error core 39
#  - If the number of columns in matrix A is not equal to the number 
#    of rows in matrix B, it terminates with error code 40
# =======================================================

matmul:
        blez a2, exit_with_error_39        # Validate the dimensions of matrices
        blez a3, exit_with_error_39
        blez a4, exit_with_error_39
        blez a5, exit_with_error_39
        bne a3, a4, exit_with_error_40
        
        addi sp, sp, -32                   # Create stack
        sw s0, 0(sp)                       # Counter for how many times we increment the adress for m0 
        sw s1, 4(sp)                       # Rows of matrix 0
        sw s2, 8(sp)                       # Adress of matrix 1
        sw s3, 12(sp)                      # Adress of matrix 0
        sw ra, 16(sp)                      # Save the ra
        sw s4, 20(sp)                      # Counter for how many times we increment the adress for m1 
        sw s5, 24(sp)                      # Value of the column of the matrix 0
        sw s6, 28(sp)                      # Value of the increment for the adress of matrix 0
        
        mv s1, a2                          # Saving the values according to what we've said above
        mv s2, a1   
        mv s3, a0 
        mv s5, a3
        mv s6, a3                          # The increment of the adress of matrix 0 is the columns of matrix 0
                                           # Times 4, and then we add the same value until the end of the multiplication
        li s0, 0                           # Counters starting at 0
        li s4, 0
        slli s6, s6, 2                 
                                           # Below these 5 lines we prepare the arguments for the dotproduct function
        mv a0, s3                          # Adress of matrix 0
        mv a1, s2                          # Adress of matrix 1
        mv a2, s5                          # Number of elements to use
        mv a3, a5                          # Increment necessary to read the columns of matrix 1
        addi a3, a3, -1                    # The increment is the column of matrix 1 minus 1
        
 
    matmul_loop:
        bge s0, s1, matmul_end             # Stops when s0 == rows of matrix 0
        beq a5, s4, matmul_reset           # Resets when s4 == columns of matrix 1
        addi sp, sp, -12                   # We save some registers that we will need further like ra(return to classify)    
        sw a0, 0(sp)
        sw t3, 4(sp)
        sw ra, 8(sp)
        jal ra, dotproduct
        sw a0, 0(a6)                       # Stores the result in C
        lw a0, 0(sp)
        lw t3, 4(sp)
        lw ra, 8(sp)
        addi a6, a6, 4                     # Advancing one index on the adress for C
        addi sp, sp, 12         
        addi a1, a1, 4                     # Advancing one index on the adress for m1
        addi s4, s4, 1                     # Increment the times we advance an index on m1
        j matmul_loop                      # Return to Loop
    
    
    matmul_reset:
        li s4, 0                           # Reset the counter of the times we advance an index on m1 
        mv a1, s2                          # Reset the adress of m1, so the multiplication starts again on the first column
        add a0, a0, s6                     # Apply the increment on the adress of m0 
        addi s0, s0, 1                     # Increment the times we increment the adress of m0
        j matmul_loop                      # Return to loop
    
    
    matmul_end:
        lw s0, 0(sp)                       # Restore the registers           
        lw s1, 4(sp)  
        lw s2, 8(sp)   
        lw s3, 12(sp)                
        lw ra, 16(sp)                      
        lw s4, 20(sp)                  
        lw s5, 24(sp)
        lw s5, 28(sp) 
        addi sp, sp, 32                    # Restore the stack
        jr ra  


######################################################################
# Function: read_file(char* filename, byte* buffer, int length)
# Input:
#   a0: pointer to null-terminated filename string
#   a1: destination buffer
#   a2: number of bytes to read
# Output:
#   a0: number of bytes read (return value from syscall)
# Exceptions:
#   - Error code 41 if error in the file descriptor
#   - Error code 42 If the length of the bytes to read is less than 1
######################################################################

read_file:
    
#open_file
    addi sp, sp, -4                 # Create stack
    sw a1, 0(sp)                    
    li a7, 1024                     # Syscall code for open
    li a1, 0                        # Set flags to zero
    ecall                           # Call open
    
    lw a1, 0(sp)                    # Restore the buffer pointer
    addi sp, sp, 4
    
    blt a0, x0, exit_with_error_41  # If the file descriptor <0 exit with error 41

#read_content
    li a7, 63                       # syscall code for read
    ecall                           # Call read
    
    bgt a0, a2, exit_with_error_42  # If the number of bytes read in a2 < 1 exit with error 42

#close_file
    li a7, 57                       # Syscall code for close
    ecall                           # Call close
    
    jr ra                           # Return to the caller





# =======================================================
# FUNCTION: Classify decimal digit from input image
#   d = classify(A, B, input)
#
# Arguments:
#   a0 (string*)  - pathname of file with the weight matrix m0
#   a1 (string*)  - pathname of file with the weight matrix m1
#   a2 (string*)  - pathname of file with the input image in Raw PGM format
#
# Returns:
#   a0 (int) - value of the classified decimal digit
#
# =======================================================

classify:
    la a0, matrizm0                # Load address of m0 filename
    la a1, matrizm1                # Load address of m1 filename
    la a2, image                   # Load address of the input image filename
    addi sp, sp, -16               # Create stack
    sw a0, 0(sp)                   # Save the arguments
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw ra, 12(sp)                  # Save the return address
    
    #--------------------------------Load m0--------------------------------------------
    li t2, 0                       # Reset the counter for the loop
    la a1, m0inbin                 # Buffer for the m0 file
    li a2, 100352                  # Number of bytes to read
    li t1, 100352                  # Loop limit
    jal ra, read_file              # Read m0 file into buffer
    la t6, m0                      # Destination for the processed m0
    jal ra, loop_sub32_classify    # Convert bytes to int and subtract 32
    #--------------------------------Load m1--------------------------------------------
    li t2, 0                       # Reset counter
    la a0, matrizm1                # m1 filename
    la a1, m1inbin                 # Buffer for m1 file
    li a2, 1280                    # Number of bytes to read
    li t1, 1280                    # Loop limit
    jal ra, read_file              # Read m1 file into buffer
    la t6, m1                      # Destination for the processed m1
    jal ra, loop_sub32_classify    # Convert bytes to int and subtract 32
    #--------------------------------Load input image-----------------------------------
    li t2, 0                       # Reset counter
    la a0, image                   # Image filename
    la a1, inputinbin              # Buffer for image file
    li a2, 784                     # Number of bytes to read
    li t1, 784                     # Loop limit
    jal ra, read_file              # Read image file into buffer
    addi a1, a1, 12                # Skip the header
    la t6, input                   # Destination for the processed input
    jal ra, test                   # Convert the bytes to int
    #--------------------------------h = matmul(m0, input)------------------------------
    la a0, m0                      # Pointer to the m0 matrix
    la a1, input                   # Pointer to the input vector
    lw a2, h_m0                    # Rows in m0
    lw a3, w_m0                    # Columns in m0
    lw a4, h_input                 # Rows in input
    lw a5, w_input                 # Columns in input
    la a6, h                       # Output buffer for h
    addi sp, sp, -4                # store ra
    sw ra, 0(sp)
    jal ra, matmul                 # h = matmul(m0, input)
    lw ra, 0(sp)                   # Restore the ra
    addi sp, sp, 4
    #--------------------------------relu(h)-----------------------------------------
    la a0, h                       # Pointer to the h matrix
    lw a1, h_h                     # Number of elements in h
    jal ra, relu                   # relu(h)
    #--------------------------------o = matmul(m1, h)-------------------------------
    la a0, m1                      # Pointer to the m1 matrix
    la a1, h                       # Pointer to h
    lw a2, h_m1                    # Rows in m1
    lw a3, w_m1                    # Columns in m1
    lw a4, h_h                     # Rows in h
    lw a5, w_h                     # Columns in h
    la a6, o                       # Output buffer for o
    addi sp, sp, -4                # Store ra
    sw ra, 0(sp)
    jal ra, matmul                 # o = matmul(m1, h)
    lw ra, 0(sp)                   # Restore the ra
    addi sp, sp, 4
    #--------------------------------argmax(o)---------------------------------------
    la a0, o                       # Pointer to o
    lw a1, h_o                     # Number of elements of 0
    jal ra, argmax                 # argmax(o)
    #--------------------------------Return and exit---------------------------------
    lw ra, 12(sp)                  # Restore return adress
    addi sp,sp, 16
    li a7, 1                       # Syscall code for print integer
    ecall                          # Print result
    jr ra                          # Return to caller
    
    
     
test:
    bge t2, t1, end_loop_classify    # If counter t2 == size t1, end loop
    lb t3, 0(a1)                     # Load current byte from input buffer (signed)
    sw t3, 0(t6)                     # Store value as int in the output buffer
    addi t6, t6, 4                   # Next int position in the output buffer
    addi a1, a1, 1                   # Move to the next byte in the input buffer
    addi t2, t2, 1                   # Increment counter
    j test                           # Loop call
        
    
loop_sub32_classify:
    bge t2, t1, end_loop_classify    # If counter t2 == size t1 end loop
    lb t3, 0(a1)                     # Load current byte from input buffer (signed)
    addi t3, t3, -32                 # subtract 32 from value
    sw t3, 0(t6)                     # Store value as int in the output buffer
    addi t6, t6, 4                   # Next int position in the output buffer
    addi a1, a1, 1                   # Move to the next byte in the input buffer
    addi t2, t2, 1                   # Increment counter
    j loop_sub32_classify            # Loop call

    
end_loop_classify:
    jr ra                    # Return to the caller


# =======================================================
# Exit procedures

exit_with_error_36:
    li a0, 36            # Exit with error 36  
    j exit_with_error
    
exit_with_error_37:
    li a0, 37            # Exit with error 37
    j exit_with_error 
    
exit_with_error_38:
    li a0, 38            # Exit with error 38
    j exit_with_error

exit_with_error_39:
    li a0, 39            # Exit with error 39
    j exit_with_error
    
exit_with_error_40:
    li a0, 40            # Exit with error 40
    j exit_with_error
    
exit_with_error_41:
    li a0, 41            # Exit with error 41
    li a7, 93
    ecall

exit_with_error_42:
    li a0, 42            # Exit with error 42
    j exit_with_error
    
    
# =======================================================

# Exits the program (with code 0)

exit:
    li a7, 10     # Exit syscall code
    ecall         # Terminate the program

# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here


exit_with_error:    
  li a7, 93            # Exit system call
  ecall                # Terminate program
