.data 0x10000000
pumpt: .asciiz "Enter an index of senator (0 - 4)\n"
space: .space 13
pumpt2: .asciiz "The candidate you voted already got "
space2: .space 11
votes: .word 56003, 60978, 45591, 37081, 47009
#            wrong, right, right, wrong, right
.text
    # README:
    # Process: Check the number, if wrong, flipped the error bit; -->
    #          Decode the number --> decoded number + 1 --> Encode the number
    # Enter the number of 0-4
    # Result of Each function save in $s0
    # when checks the function Check, break 35 line
    # when checks the function Decode, break 39 line
    # when checks the function Eecode, break 56 line
main:
    

    # load the number from the memory
    ori $v0, $zero, 4               # print pumpt
    lui $a0, 0x1000
    or $zero, $zero, $zero          # nop
    syscall
    or $zero, $zero, $zero          # nop

    ori $v0, $zero, 5               # read the integer for user
    syscall
    ori $a0, $a0, 0x0060
    sll $v0, $v0, 2                 # v0 * 4
    add $s3, $a0, $v0               # address move to candinate I want
    lw $s0, ($s3)                   # load the votes from memory
    or $zero, $zero, $zero          # nop

    addi $sp, $sp, -4               # reserve the space
    sw $ra, ($sp)                   # save return address =
    or $zero, $zero, $zero          # nop

    jal Check                       # call the function check
    or $zero, $zero, $zero          # nop

    jal Decode                      #
    or $zero, $zero, $zero          # nop

    addi $s0, $s0, 1
    #print a pumpt
    ori $v0, $zero, 4               # print pumpt
    lui $a0, 0x1000
    addi $a0, $a0, 0x0030           # address moving
    or $zero, $zero, $zero          # nop
    syscall

    ori $v0, $zero, 1               # print already voted
    or $a0, $s0, $zero
    syscall

    jal Encode
    or $zero, $zero, $zero          # nop
   
    lw $ra, ($sp)                   # load back the return address
    or $zero, $zero, $zero          # nop
    addi $sp, $sp, 4                # return the space

    sw $s0, ($s3)                   # save the final decode to memory
    or $zero, $zero, $zero          # nop

    jr $ra                          # return
    or $zero, $zero, $zero          # nop


# FUNCTION: check 
Check:
    # $s0 is input and output
    # $s1 is how many bits of 1 in number
    # $t0 is temporary input
    # $t1 is how long to travel a number
    # $t2 is xor result
    # $t3 is a register for assigning every result
    
    or $t0, $s0, $zero              # initial $t0
    add $s1, $zero, $zero           # initial $s1
    addi $t1, $zero, 15             # initial $t1
    or $s2, $zero, $zero            # initial $t2

    loop_check:
    #condition of loop
    slt $t3, $t1, $zero             # check $t1 whether is less than 0
    bne $t3, $zero, done_checkBit1  # $t1 is less than 0, jump branch
    or $zero, $zero, $zero          # nop
    
    #body 
    andi $t3, $t0, 1                # resign $t3 is 1
    beq $t3, $zero, noAction        # if this bit is zero, go to branch
    or $zero, $zero, $zero          # nop
    addi $s1, $s1, 1                # +1 num of bit 1
    xor $t2, $t2, $t1               # $t2 = $t2 xor $t1
    noAction:                       
    srl $t0, $t0, 1                 # $t0 reduce 1 bit
    addi $t1, $t1, -1               # travel time - 1
    j loop_check                    # jump
    or $zero, $zero, $zero          # nop
    
    #end loop_check

    done_checkBit1:
    andi $t3, $s1, 1                # check $s1 is odd or even
    beq $t3, $zero, done            # $ s1 is even, then done

    # otherwise, flip the error bit back
    # save data in stack, and call function flipbit 

    addi $sp, $sp, -16
    sw $t0, ($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $ra, 12($sp)
    add $a0, $zero, $t2 
    jal flipBit
    or $zero, $zero, $zero
    lw $t0, ($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    done:
    jr $ra
    or $zero, $zero, $zero

    flipBit:
    addi $t0, $zero, 1          # inital $t0 to 1
    addi $t1, $zero, 15         # inital $t1 
    sub $t1, $t1, $a0           # find actual location that needs to flip (from right to left)
    sllv $t0, $t0, $t1          # left shift t0 to the actual bit
    and $t2, $t0, $s0           # $t2 is a register for assigning results         
    beq $t2, $zero, zero        # if $t2 is zero, go to branch
    or $zero, $zero, $zero      # nop
    sub $s0, $s0, $t0           # error bit is 1,change to be 0
    j done_flipBit              # jump
    or $zero, $zero, $zero      # nop
    zero:
    add $s0, $s0, $t0           # error bit is 0,change to be 1
    done_flipBit:
    jr $ra                      # return
    or $zero, $zero, $zero      # nop

# FUNCTION: Decode
Decode: 
    # $s0 is storing 11 bit number after decode
    # $t3 is a register by assigning results

    or $a0, $s0, $zero
    or $s0, $zero, $zero        # inital $s0
    ori $t0, $zero, 2           # inital $t0, this is a stop line
    ori $t1, $zero, 15          # inital $t1, conter
    or $t2, $zero, $zero        # inital $t2, postion of ptr

    loop_decode:
    #condition of loop_decode
    beq $t0, $t1, end_decode    # Last three bits don't need to deal
    or $zero, $zero, $zero      # nop

    #body
    ori $t3, $zero, 8           # postion bit 8
    beq $t3, $t1, skip          # if $t1 = 8, go to branch
    or $zero, $zero, $zero      # nop
    ori $t3, $zero, 4           # postion bit 8
    beq $t3, $t1, skip          # if $t1 = 8, go to branch
    or $zero, $zero, $zero      # nop
    
    andi $t3, $a0, 1            # get the right bit
    sllv $t3, $t3, $t2          # left shift $t3 by $t2 bits
    add $s0, $s0, $t3           # $s0 = $s0 + $t3
    addi $t2, $t2, 1            # postion move on

    skip:
    srl $a0, $a0, 1             # $a0 reduce 1 bit
    addi $t1, $t1, -1           # counter - 1

    j loop_decode
    or $zero, $zero, $zero      # nop

    end_decode:
    jr $ra                      # return
    or $zero, $zero, $zero      # nop

# Function: Encode
Encode:
    # $s0 is input and output
    # $t0 is temporary input
    # $t1 is counter
    # $t2 is xor result of 11 bit number
    # $t3 is a register by assigning results

    or $t0, $s0, $zero              # inital $t0 to be same as $s0
    addi $t1, $zero, 15             # inital counter to be 15
    or $t2, $zero, $zero            # inital $t2 to be 0
    ori $t4, $zero, 2               # inital $t4 to be 2, this is the end loop condition

    loop_xor11bits:
    beq $t1, $t4, encode_section    # go to branch
    or $zero, $zero, $zero          # nop

    ori $t3, $zero, 8               # postion bit 8
    beq $t1, $t3, skip_xor
    or $zero, $zero, $zero          # nop
    ori $t3, $zero, 4               # postion bit 4
    beq $t1, $t3, skip_xor
    or $zero, $zero, $zero          # nop

    andi $t3, $t0, 1                # check the most right bit
    beq $t3, $zero, noXor           # if the bit is 0, go to branch
    or $zero, $zero, $zero          # nop
    xor $t2, $t2, $t1               # $t2 = $t2 xor $t1
    noXor:
    srl $t0, $t0, 1                 # right shift $t0 by one bit 
    skip_xor:
    addi $t1, $t1, -1               # counter - 1
    j loop_xor11bits                # jump loop_xor11bits  
    or $zero, $zero, $zero          # nop

    encode_section:
    
    or $t0, $s0, $zero              # inital $t0 to be same as $s0
    or $s0, $zero, $zero            # inital $s0, and it is storing the final answer
    addi $t1, $zero, 15             # ptr of bit postion
    or $t4, $zero, $zero            # actual bit location
    or $t5, $zero, $zero            # xor of 15 bits
    
    finalLoop_encode:

    #condition 
    slt $t3, $t1, $zero             # counter is less than 0
    bne $t3, $zero, end_encode    # go to branch
    or $zero, $zero, $zero          # nop

    #body
    ori $t3, $zero, 8               # position of bit 8
    beq $t1, $t3, InsertKeys_encode
    or $zero, $zero, $zero          # nop
    ori $t3, $zero, 4               # position of bit 4
    beq $t1, $t3, InsertKeys_encode
    or $zero, $zero, $zero          # nop
    ori $t3, $zero, 2               # position of bit 4
    beq $t1, $t3, InsertKeys_encode
    or $zero, $zero, $zero          # nop
    ori $t3, $zero, 1               # position of bit 4
    beq $t1, $t3, InsertKeys_encode
    or $zero, $zero, $zero          # nop
    ori $t3, $zero, 0               # position of bit 0
    beq $t1, $t3, InsertTop_encode
    or $zero, $zero, $zero          # nop

    andi $t3, $t0, 1                # get the most right bit of 11 bit 
    xor $t5, $t5, $t3               # xor $t3 to $t5
    sllv $t3, $t3, $t4              # left shift $t3 by $t4 bit                
    srl $t0, $t0, 1                 # $t0 reduce one bit
    j final_encode                    
    or $zero, $zero, $zero          # nop

    InsertKeys_encode:
    and $t3, $t2, $t3               # t3 is location
    beq $t3, $zero, skip_isZero     # this bit is zero, go to branch
    or $zero, $zero, $zero          # nop
    ori $t3, $zero, 1               # set $t3 to be 1
    skip_isZero:
    xor $t5, $t5, $t3               # xor $t3 to $t5         
    sllv $t3, $t3, $t4              # left shift $t3 by $t4 bit 
    j final_encode
    or $zero, $zero, $zero          # nop

    InsertTop_encode:
    sllv $t3, $t5, $t4              # $t5 is postion of bit 0

    final_encode:
    add $s0, $s0, $t3               # add to the sum $t3
    addi $t1, $t1, -1               # counter - 1
    addi $t4, $t4, 1                # actual bit move on
    j finalLoop_encode
    or $zero, $zero, $zero          # nop

    end_encode:
    jr $ra                          # return
    or $zero, $zero, $zero          # nop

    





    
    

    
    
     






