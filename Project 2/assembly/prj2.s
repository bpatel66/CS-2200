!=================================================================
! General conventions:
!   1) Stack grows from high addresses to low addresses, and the
!      top of the stack points to valid data
!
!   2) Register usage is as implied by assembler names and manual
!
!   3) Function Calling Convention:
!
!       Setup)
!       * Immediately upon entering a function, push the RA on the stack.
!       * Next, push all the registers used by the function on the stack.
!
!       Teardown)
!       * Load the return value in $v0.
!       * Pop any saved registers from the stack back into the registers.
!       * Pop the RA back into $ra.
!       * Return by executing jalr $zero, $ra.
!=================================================================

        ! vector table
vector0:
        .fill 0x00000000            ! device ID 0
        .fill 0x00000000            ! device ID 1
        .fill 0x00000000            ! ...
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000            ! device ID 15
        ! end vector table

main:   lea $sp, initsp                       ! initialize the stack pointer
        lw $sp, 0($sp)                        ! finish initialization

                                              ! Install timer interrupt handlers into vector table
        lea $t0, vector0
        lea $t1, timer_handler
        sw $t1, 0x1($t0)
        ei

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
ANS:      .fill 0                               ! should come out to 1024

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
FIN:      lw $fp, 0($fp)                        ! restore old frame pointer
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


timer_handler:

        addi $sp, $sp, -1        ! allocate space on the stack for $k0
        sw   $k0, 0x0($sp)       ! put $k0 to the stack
        ei                       ! enable interrupts

        addi $sp, $sp, -1        ! allocate space on the stack for $t0
        sw   $t0, 0x0($sp)       ! put $t0 on the stack
        addi $sp, $sp, -1        ! allocate space on the stack for $t1
        sw   $t1, 0x0($sp)       ! put $t1 on the stack
        addi $sp, $sp, -1
        sw   $t2,0x0($sp)

        lea  $t0, ticks1
        lw   $t1, 0x0($t0)
        lw   $t2, 0x0($t1)
        addi $t2, $t2, 1
        sw   $t2, 0x0($t1)


        lw   $t2,0x0($sp)
        addi $sp, $sp, 1
        lw   $t1, 0x0($sp)       ! pop $t1 off the stack
        addi $sp, $sp, 1         ! move stack pointer up
        lw   $t0, 0x0($sp)       ! pop $t0 off the stack
        addi $sp, $sp, 1         ! move stack pointer up

        di                       ! disable interrupts
        lw   $k0, 0x0($sp)       ! pop $k0 off the stack
        addi $sp, $sp, 1         ! move stack pointer up
        reti

initsp: .fill 0xA00000

ticks1: .fill 0xFFFFFD

