addi $a0, $zero, 5      ! a0 = 5
addi $a1, $a0, -4       ! a1 = 1, but stalls

slt $a2, $a1, $a0       ! a2 = 1, since a1 < a0 is true

lea $t0, label          ! $t0 = label
jalr $ra, $t0

addi $s1, $zero, 1      ! $s1 = 1
halt

label: addi $s0, $zero, 420 ! $s0 = 1a4
jalr $zero, $ra

