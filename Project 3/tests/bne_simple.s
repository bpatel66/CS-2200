lea $a0, jump
addi $a1, $zero, 2
addi $a2, $zero, 3
nand $t0, $zero, $zero

jalr $k0, $a0
addi $t1, $zero, 1
halt

jump: addi $t1, $zero, 2
halt