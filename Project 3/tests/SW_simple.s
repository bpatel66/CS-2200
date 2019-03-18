lea $a0, VALUE
addi $a1, $zero, 5
noop
noop
noop
sw  $a1, 0($a0)
halt
VALUE: .fill 1