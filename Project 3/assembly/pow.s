! This program executes pow as a test program using the LC 2200 calling convention
! Check your registers ($v0) and memory to see if it is consistent with this program

main:	  lea $sp, initsp                       ! initialize the stack pointer
        lw $sp, 0($sp)                        ! finish initialization

        lea $a0, BASE                         ! load base for pow
        lw $a0, 0($a0)
        lea $a1, EXP                          ! load power for pow
        lw $a1, 0($a1)
        lea $at, POW                          ! load address of pow
        jalr $ra, $at                         ! run pow
        lea $a0, ANS                          ! load base for pow
        sw $v0, 0($a0)

        halt

BASE:   .fill 2
EXP:    .fill 10
ANS:	  .fill 0                               ! should come out to 1024

POW:    addi $sp, $sp, -1                     ! allocate space for old frame pointer
        sw $fp, 0($sp)
        addi $fp, $sp, 0                      ! set new frame pinter
        add $t1, $zero, $zero                 ! $t1 = 0
        addi $t2, $zero, 1                    ! $t2 = 1
        slt $t1, $a1, $t2                     ! check if $a1 is 0 (if not, $t1 = 0)
        bne $t1, $zero, RET1                  ! if $t1 == 1, branch to RET1
        add $t1, $zero, $zero                 ! $t1 = 0
        addi $t2, $zero, 1                    ! $t2 = 1
        slt $t1, $a0, $t2                     ! if the base is 0, $t1 = 1
        bne $t1, $zero, RET0                  ! if $t1 == 1, branch to RET0
        addi $a1, $a1, -1                     ! decrement the power
        lea $at, POW                          ! load the address of POW
        addi $sp, $sp, -2                     ! push 2 slots onto the stack
        sw $ra, -1($fp)                       ! save RA to stack
        sw $a0, -2($fp)                       ! save arg 0 to stack
        jalr $ra, $at                         ! recursively call POW
        add $a1, $v0, $zero                   ! store return value in arg 1
        lw $a0, -2($fp)                       ! load the base into arg 0
        lea $at, MULT                         ! load the address of MULT
        jalr $ra, $at                         ! multiply arg 0 (base) and arg 1 (running product)
        lw $ra, -1($fp)                       ! load RA from the stack
        addi $sp, $sp, 2
        addi $t1, $zero, 1                    ! $t1 = 1
        bne $zero, $t1, FIN                   ! unconditional branch to FIN
RET1:   addi $v0, $zero, 1                    ! return a value of 1
        addi $t1, $zero, 1                    ! $t1 = 1
        bne $zero, $t1, FIN                   ! unconditional branch to FIN
RET0:   add $v0, $zero, $zero                 ! return a value of 0
FIN:	  lw $fp, 0($fp)                        ! restore old frame pointer
        addi $sp, $sp, 1                      ! pop off the stack
        jalr $zero, $ra

MULT:   add $v0, $zero, $zero                 ! zero out return value
        addi $t0, $zero, 1
AGAIN:  add $v0, $v0, $a0                     ! multiply loop
        addi $t0, $t0, 1
        add $t1, $zero, $zero                 ! $t1 = 0
        addi $t2, $a1, 1                      ! $t2 = $a1 + 1
        slt $t1, $t0, $t2                     ! $t1 = 1, if $t0 < $t2 (if not, $t1 = 0)
        bne $t1, $zero, AGAIN                 ! if $t1 = 1, loop again
        jalr $zero, $ra

initsp: .fill 0xA00000
