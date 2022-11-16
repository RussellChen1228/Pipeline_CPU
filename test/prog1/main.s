.data
test1: .word 16,2,4,16,4,10,12,2,14,8,4,14,6,4,2,10,12,6,10,2,14,14,6,8,16,8,16,6,12,10,8,123
test2: .word 470,405,225,197,126,122,56,33,-81,-275,-379,-409,-416,-496,-500
test3: .word 412,-474,443,171,-23,247,221,7,40,221,-90,61,-9,49,-80,-80,221,-379,-161,-397,-173,276,-197,221,-12,-145,101
TEST1_SIZE: .word 32
TEST2_SIZE: .word 15
TEST3_SIZE: .word 27

.text
.globl main

main:

    # load address
    la    s1, test1        # s1 = test1
    la    s2, test2        # s2 = test2
    la    s3, test3        # s3 = test3
    # load size
    la    s4, TEST1_SIZE   # load address
    lw    s4, 0(s4)        # s4 = size1
	mv    s10, s4
    la    s5, TEST2_SIZE   # load address
    lw    s5, 0(s5)        # s5 = size2
    la    s6, TEST3_SIZE   # load address
    lw    s6, 0(s6)        # s6 = size3
    
    # stack 
    addi  sp, sp, -4       # stack space
    sw    ra, 0(sp)        # store ra to stack
    
    # Merge sort 1
    mv    a0, s1           # a0 = test1 position
    li    a1, 0            # a1 = start
    addi  a2, s4, -1       # a2 = size1 - 1
    jal   ra, mergesort    # func call
    # Merge sort 2
    mv    a0, s2           # a0 = test2 position
    li    a1, 0            # a1 = start
    addi  a2, s5, -1       # a2 = size2 - 1
    jal   ra, mergesort    # func call
    # Merge sort 3
    mv    a0, s3           # a0 = test3 position
    li    a1, 0            # a1 = start
    addi  a2, s6, -1       # a2 = size3 - 1
    jal   ra, mergesort    # func call
    
    li    t0, 0x9000   # t0 in position
    jal    for1


   
mergesort:
    
    blt   a1, a2, if      # if statement
    ret                   # ret

if:
    # push stack
    addi  sp, sp, -16
    sw    ra, 0(sp)
    sw    s0, 4(sp)
    sw    s1, 8(sp)
    sw    s2, 12(sp)
    
    mv    s0, a1        # s0 = start
    mv    s2, a2        # s2 = end
    add   s1, a1, a2    # s1 = mid*2
    srai  s1, s1, 1     # s1 = mid
    
    # ms(arr, start, mid)
    mv    a1, s0
    mv    a2, s1
    jal   ra, mergesort
    # ms(arr, mid+1, end)
    addi  a1, s1, 1    # pass mid+1 to a1
    mv    a2, s2
    jal   ra, mergesort # go to mergesort
    # ms(arr, start, mid, end)
    mv    a1, s0
    mv    a2, s1
    mv    a3, s2
    jal   ra, merge
    
    # pop stack
    lw    ra, 0(sp)  # load mem's value
    lw    s0, 4(sp)
    lw    s1, 8(sp)
    lw    s2, 12(sp)
    addi  sp, sp, 16 # release stack mem
    
    ret

merge:
    
    addi  sp, sp, -8    # stack mem space 
    sw    s0, 0(sp)    # store s0 into 0sp
    sw    s1, 4(sp)    # store s1 into 4sp
    
    sub   t0, a3, a1    # t0 = end - start = temp_size - 1
    addi  t0, t0, 1    # t0 += 1  = temp_size
    slli  t1, t0, 2     # t1 = t0 * 4
    sub   sp, sp , t1    # sp -= t1
    
    li    t1, 0    # t1 to zero
    
for:
    bge   t1 ,t0, endfor    # i >= temp_size -> end
    
    add   t2, t1, a1        # t2 = t1 + a1 (t2 = i + start)
    slli  t2, t2, 2        # t2 *= 4   address position 
    add   t2, t2, a0        # t2 += a0   add start position
    lw    t2, 0(t2)        # t2  = 0(t2)    load arr[i+start] into t2
    slli  t3, t1, 2        # t3  =  t1 * 4 
    add   t3, t3, sp        # t3  = t3 + sp  => tmp[i] position
    sw    t2, 0(t3)        # store t2 into temp[i]
    
    addi  t1, t1, 1        # t1 += 1 
    j     for

endfor:
    li    t1, 0            # t1 = 0  left index
    sub   t2, a2, a1        # t2 = right index
    addi  t2, t2, 1         # t2 = right index
    addi  t3, t2, -1        # t3 = left_max 
    sub   t4, a3, a1        # t4 = right_max
    mv    t5, a1            # t5 = start (arr_index)
    
while1:
    bgt   t1, t3, while2    # compare condiction if > goto second while
    bgt   t2, t4, while2    # compare condiction if > goto second while
    # if
    slli  s0, t1, 2        # s0 = t1 * 4
    add   s0, s0, sp        # s0 += sp
    lw    s0, 0(s0)        # load 0(s0) into s0
    slli  s1, t2, 2        # s1 = t2 * 4
    add   s1, s1, sp        # s1 += sp
    lw    s1, 0(s1)        # 0(s1) = s1
    bgt   s0, s1, while1_else # compare condiction
    # if inside
    slli  s1, t5, 2    # s1 = start * 4 
    add   s1, s1, a0    # s1 += start
    sw    s0, 0(s1)    # s0 -> 0(s1)
    addi  t5, t5, 1    # (arr_index)++
    addi  t1, t1, 1    # left index ++
    j    while1

while1_else:
    slli  s0, t5, 2    # s0 = start *4
    add   s0, s0, a0    # s0 += arr position
    sw    s1, 0(s0)    # s1 into 0(s0)
    addi  t5, t5, 1    # (arr_index)++    
    addi  t2, t2, 1    # right index ++
    j    while1        # go back
    
while2:
    bgt   t1, t3, while3     # left index > left_max goto while 3
    slli  s0, t1, 2            # s0 = t1 * 4
    add   s0, s0, sp         # s0 += sp
    lw    s0, 0(s0)            # load s0 from s0
    slli  s1, t5, 2            # s1 = t5 * 4    
    add   s1, s1, a0        # s1 += a0
    sw    s0, 0(s1)        # store s0 into 0(s1)
    addi  t5, t5, 1        # arr_index ++
    addi  t1, t1, 1        # left_index ++
    
    j    while2        

while3:
    bgt   t2, t4, end        # compare if right index > right max -> end
    slli  s0, t2, 2        # s0 = t2 * 4 
    add   s0, s0, sp        # s0 += sp
    lw    s0, 0(s0)        # load s0 0(s0)
    slli  s1, t5, 2        # s1 = t5 * 4 
    add   s1, s1, a0        # s1 = s1 + a0 
    sw    s0, 0(s1)        # store s0 into 0(s1)
    addi  t5, t5, 1        # add_index ++
    addi  t2, t2, 1        # right index ++
    
    j    while3

end:
    
    slli  t0, t0, 2        # t0 *4
    add   sp, sp, t0        # sp += t0 
    lw    s0, 0(sp)        # load what you store from start
    lw    s1, 4(sp)        # same up
    addi  sp, sp, 8        # release stack
    
    ret
for1:
	
    addi  s4, s4, -1       # s4 -= 1
    bltz  s4, endfor1      # less than zero -> endfor
    slli  t1, s4, 2        # addr *= 4
    add   t2, t1, t0       # add bias 
    add   t3, t1, s1       # add bias 
    lw    t3, 0(t3)        # load value into t3
    sw    t3, 0(t2)        # store word in position 
    
    j    for1              # force goto for1
    
endfor1:
    li t0, 0x9000      # setup second position start
	mv s11, s10
    slli s10, s10, 2
	add  t0, t0, s10
	mv	 s10, s11
	mv	 s11 , s5
	add  s11, s11, s10
for2:
    addi  s5, s5, -1       # same as for1
    bltz  s5, endfor2
    slli  t1, s5, 2
    add   t2, t1, t0
    add   t3, t1, s2
    lw    t3, 0(t3)
    sw    t3, 0(t2)
    
    j    for2            # same as for1
endfor2:
    li  t0, 0x9000
	slli s11, s11, 2
	add t0, s11, t0
    
for3:
    addi  s6, s6, -1        # same as for1
    bltz  s6, endfor3
    slli  t1, s6, 2
    add   t2, t1, t0
    add   t3, t1, s3
    lw    t3, 0(t3)
    sw    t3, 0(t2)
    
    j    for3            # same as for1
    
endfor3:
    lw    ra, 0(sp)     # load return address
    addi  sp, sp, 4        # release stack memory
    ret                # return    

main_exit:
  ret