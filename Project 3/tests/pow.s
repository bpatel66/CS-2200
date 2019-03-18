main:	  lea $sp, initsp ;1                      ! initialize the stack pointer
        lw $sp, 0($sp)    ;2                    ! finish initialization

        lea $a0, BASE     ;3                    ! load base for pow
        lw $a0, 0($a0)    ;4
        lea $a1, EXP      ;5                    ! load power for pow
        lw $a1, 0($a1)    ;6
        lea $at, POW      ;7                    ! load address of pow
        jalr $ra, $at     ;8                    ! run pow
        lea $a0, ANS      ;9                    ! load base for pow
        sw $v0, 0($a0)    ;10

        halt              ;11

BASE:   .fill 2           ;12
EXP:    .fill 2           ;13
ANS:	  .fill 0         ;14                      ! should come out to 1024

POW:    addi $sp, $sp, -1 ;15                    ! allocate space for old frame pointer
        sw $fp, 0($sp)    ;16
        addi $fp, $sp, 0  ;17                    ! set new frame pinter
        add $t1, $zero, $zero                 ! $t1 = 0
        addi $t2, $zero, 1;19                    ! $t2 = 1
        slt $t1, $a1, $t2 ;20                    ! check if $a1 is 0 (if not, $t1 = 0)
        bne $t1, $zero, RET1 ;21                 ! if $t1 == 1, branch to RET1
        add $t1, $zero, $zero ;22                ! $t1 = 0
        addi $t2, $zero, 1 ;23                   ! $t2 = 1
        slt $t1, $a0, $t2  ;24                     ! if the base is 0, $t1 = 1
        bne $t1, $zero, RET0  ;25                ! if $t1 == 1, branch to RET0
        addi $a1, $a1, -1      ;26               ! decrement the power
        lea $at, POW        ;27                  ! load the address of POW
        addi $sp, $sp, -2   ;28                  ! push 2 slots onto the stack
        sw $ra, -1($fp)     ;29                  ! save RA to stack
        sw $a0, -2($fp)     ;30                  ! save arg 0 to stack
        jalr $ra, $at       ;31                  ! recursively call POW
        add $a1, $v0, $zero ;32                  ! store return value in arg 1
        lw $a0, -2($fp)     ;33                  ! load the base into arg 0
        lea $at, MULT       ;34                  ! load the address of MULT
        jalr $ra, $at       ;35                  ! multiply arg 0 (base) and arg 1 (running product)
        lw $ra, -1($fp)     ;36                  ! load RA from the stack
        addi $sp, $sp, 2    ;37
        addi $t1, $zero, 1  ;38                  ! $t1 = 1
        bne $zero, $t1, FIN ;39                  ! unconditional branch to FIN
RET1:   addi $v0, $zero, 1  ;40                  ! return a value of 1
        addi $t1, $zero, 1  ;41                  ! $t1 = 1
        bne $zero, $t1, FIN ;42                  ! unconditional branch to FIN
RET0:   add $v0, $zero, $zero ;43                 ! return a value of 0
FIN:	  lw $fp, 0($fp)   ;44                     ! restore old frame pointer
        addi $sp, $sp, 1   ;45                   ! pop off the stack
        jalr $zero, $ra    ;46

MULT:   add $v0, $zero, $zero  ;47               ! zero out return value
        addi $t0, $zero, 1
AGAIN:  add $v0, $v0, $a0                     ! multiply loop
        addi $t0, $t0, 1
        add $t1, $zero, $zero                 ! $t1 = 0
        addi $t2, $a1, 1                      ! $t2 = $a1 + 1
        slt $t1, $t0, $t2                     ! $t1 = 1, if $t0 < $t2 (if not, $t1 = 0)
        bne $t1, $zero, AGAIN                 ! if $t1 = 1, loop again
        jalr $zero, $ra

initsp: .fill 0xA00000
