###########################################################
# Kite: Architecture Simulator for RISC-V Instruction Set #
# Developed by William J. Song                            #
# Intelligent Computing Systems Lab, Yonsei University    #
# Version: 1.10                                           #
###########################################################

# Kite program code
#   1. The first instruction starts at PC = 4. PC = 0 is reserved as invalid.
#   2. To terminate the program, let the next PC naturally go out of range.
#   3. All the instructions and labels are case-insensitive.
#   4. The program code supports only the following list of instructions
#      (sorted by alphabetical order in each type).
#      R-type: add, and, div, divu, mul, or, rem, remu, sll, sra, srl, sub, xor
#      I-type: addi, andi, jalr, ld, slli, srai, srli, ori, xori
#      S-type: sd
#      SB-type: beq, bge, blt, bne
#      U-type: lui
#      UJ-type: jal
#      No-type: nop

################## STACK CONTENTS ######################
#  0(x2) return address
#  8(x2) array address 
# 16(x2) array size
################# ASSIGNED REGISTER ####################
# x5: i                     Iterator
# x6: j                     Iterator
# x10: &array[0]            Array Pointer
# x11: n                    Array Size
#**************** FOR TEMPORARY USE *******************#
# x12 - x15: TEMPORARY            
# x28 - x31: TEMPORARY
########################################################
#  2019142185
#  Jaewon Lee
#
#  - In the comments, arr and array are the same
#  - The square brackets[] mean that sizeof(data) is multiplied
#    As all data are 8bytes, sizeof(data) = 8
#########################################################

# void quick_sort(int64_t* array, size_t size);
# quick sort driver function
quick_sort:
    addi x2, x2,  -24       #adjust stack pointer
    sd   x1,  0(x2)         #return address stack
    sd  x10,  8(x2)         #array address stack
    sd  x11, 16(x2)         #array size stack
    # Check if array size < 8
    addi x31, x0, 8
    bge x11,  x31, stepOne          #if size > 8 quick sort
    bge x0,  x0,  insertion_sort    #else insertion sort

# quick sort step one: find pivot
stepOne:
    #load data at index 0, s/2, s-1
    ld  x12,  0(x10)        #x12 = arr[0]
    addi x11, x11, -1       #s - 1
    slli x11, x11, 3        #[s - 1]
    add x10, x10, x11       #&arr[s - 1]
    ld x14, 0(x10)          #x14 = arr[s-1]
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size
    srli x11, x11, 1        #s/2
    slli x11, x11, 3        #[s/2]
    add x10, x10, x11       #&arr[s/2]
    ld x13, 0(x10)          #x13 = arr[s/2]
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size

# sort pivot candidates
check1:
    bge x13, x12, check2    #if x12 >= x13 swap
    addi x31, x12, 0        #swap x13, x12
    addi x12, x13, 0
    addi x13, x31, 0
check2:
    bge x14, x13, check3    #if x13 >= x14 swap
    addi x31, x14, 0        #swap x13, x14
    addi x14, x13, 0
    addi x13, x31, 0
check3:
    bge x13, x12, finpiv    #if x12 >= x13 swap
    addi x31, x12, 0        #swap x13, x12
    addi x12, x13, 0
    addi x13, x31, 0

# Through check 1 ~ 3 get the following result
# x12 = min, x13 = med, x14 = max
finpiv:
    sd  x12,  0(x10)        #arr[0] = x12
    addi x11, x11, -1       #s - 1
    slli x11, x11, 3        #[s - 1]
    add x10, x10, x11       #&arr[s - 1]
    sd x14, 0(x10)          #arr[s - 1] = x14
    addi x10, x10, -8       #&arr[s - 2]
    ld x15, 0(x10)          #x15 = arr[s - 2]
    sd x13, 0(x10)          #arr[s - 2] = med
    ld x11, 16(x2)          #restore size
    ld x10, 8(x2)           #restore arr
    srli x11, x11, 1        #s/2
    slli x11, x11, 3        #[s/2]
    add x10, x10, x11       #&arr[s/2]
    sd x15, 0(x10)          #arr[s/2] = previous arr[s - 2]
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size

#x5 = i, x6 = j, x13 = pivot
# quick sort step two: Scanning the array
stepTwo:
    addi x5, x0, 1          #i = 1
    addi x6, x11, -3        #j = size - 3
# The while(j > i) loop
stepTwoLoop:
    bge x5, x6, comPivot    #break if i >= j
# increment i if arr[i] < pivot
stepTwoI:
    slli x31, x5, 3         #x31 = [i]
    add x10, x10, x31       #x10 = &arr[i]
    ld x29, 0(x10)          #x29 = arr[i]
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size
    bge x29, x13, stepTwoJ  #arr[i] >= pivot
    addi x5, x5, 1          # ++i
    beq x0, x0, stepTwoI
# decrement j if arr[j] > pivot
stepTwoJ:
    slli x31, x6, 3         #x31 = [j]
    add x10, x10, x31       #x10 = &arr[j]
    ld x30, 0(x10)          #x30 = arr[j]
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size
    bge x13, x30, comPivot  #pivot >= arr[j]
    addi x6, x6, -1         # --j
    beq x0, x0, stepTwoJ
# check conditions and swap elements at i & j
comPivot:
    bge x5, x6, stepThree   #if i >= j
    #x29 = arr[i], x30 = arr[j]
    slli x31, x5, 3         #x31 = [i]
    add x10, x10, x31       #x10 = &arr[i]
    sd x30, 0(x10)          #arr[i] = x30 = arr[j]
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size
    slli x31, x6, 3         #x31 = [j]
    add x10, x10, x31       #x10 = &arr[j]
    sd x29, 0(x10)          #arr[j] = x29 = arr[i]
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size
    beq x0, x0, stepTwoLoop #back to while loop

#Divide & Conquer
stepThree:
    #swap arr[s - 2], arr[i]
    addi x11, x11, -2       #s - 2
    slli x11, x11, 3        #[s - 2]
    add x10, x10, x11       #&arr[s - 2]
    ld x31, 0(x10)          #x31 = arr[s - 2]
    sd x29, 0(x10)          #arr[s - 2] = x29 = arr[i]
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size
    slli x11, x5, 3         #x11 = [i]
    add x10, x10, x11       #&arr[i]
    sd x31, 0(x10)          #arr[i] = x31 = arr[s - 2]
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size    

    #right -> quick_sort(&arr[0] = x10, i = x5)
    addi x11, x5, 0         #size = i
    addi x2, x2, -8         #sp - 8
    sd x5, 0(x2)            #sp[0] = i
    jal x1, quick_sort      #left array quick sort
    ld x5, 0(x2)            #restore return address
    addi x2, x2, 8          #delete useless stack data
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size
    #left -> quick_sort(&arr[i + 1], size - i - 1)
    addi x31, x5, 1         #i + 1
    slli x31, x31, 3        #[i + 1]
    add x10, x10, x31       #&arr[i + 1]
    addi x11, x11, -1       #size - 1
    sub x11, x11, x5        #size - i - 1
    jal x1, quick_sort      #right array quick sort

    beq x0, x0, exit        #Exit to Caller


# void insertion_sort(int64_t* array, size_t size);
insertion_sort:
    addi x5, x0, 1          # i = 1
loop:                       # Start i loop
    bge x5, x11, exit       # check if i < size (true: continue, false: exit)
    add x12, x0, x5         # arr_address_1 = i
    slli x12, x12, 3        # arr_address_1 = i*8 (sizeof(int64_t))
    add x12, x12, x10       # arr_address_1 = &arr[i]
    ld x28, 0(x12)          # element = arr[i];
    addi x6, x5, 0          # j = i
iloop:                      # Start j loop
    add x13, x0, x6         # arr_address_2 = j
    slli x13, x13, 3        # arr_address_2 = j*8
    add x13, x13, x10       # arr_address_2 = &arr[j]
    beq x6, x0, iexit       # check if j == 0 (true: iexit, false: continue)
    ld x30, -8(x13)         # arr_tmp = arr[j - 1]
    bge x28, x30, iexit     # check if arr[j - 1] > element (true: continue, false: iexit)
    sd x30, 0(x13)          # arr[j] = arr[j - 1]
    addi x6, x6, -1         # j--
    beq x0, x0, iloop       # Back to iloop
iexit:                      # iexit (innerloop exit)
    sd x28, 0(x13)          # arr[j] = element
    addi x5, x5, 1          # i++
    beq x0, x0, loop        # Back to loop

exit:                       # exit (loop exit)
    ld x10, 8(x2)           #restore arr
    ld x11, 16(x2)          #restore size    
    ld   x1,  0(x2)         #restore return address
    addi x2, x2, 24         #restore stack pointer
    jalr x0, 0(x1)          #back to caller function
