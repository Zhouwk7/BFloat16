#Lab 2 Skeleton File
#2/1/2019 Nima Ganjehloo

.data
# 5=16544 1=16256 4=16512 6=16576 -5=49312 
x: .word 49312 # -5
y: .word 16576 # 6
#x: .word 16544 # 5
#y: .word 16256 # 1
#x: .word 49312 # -5
#y: .word 16256 # 1

z: .word 0 # expected result 5+1 is 16576 or 6,   5 - 1 = 4 或 16512 if operation is 1
operation: .word 0 #0 is add, 1 is subtract
nemask: .word 32895 #1000 0000 0111 1111
signmask: .word 32767 #0111 1111 1111 1111


.text
main:
la t0, operation
lw t0, 0(t0) # bool doSubtract = false

la t1, x
la t2, y
lw t1, 0(t1) # t1 has x in bfloat16 representation
lw t2, 0(t2) # t2 has 

#your program starts here

srli s1, t1, 15 # x 的符号
srli s2, t2, 15 # y 的符号
add t5, x0, x0 # 用于记录z符号
case_xn_yp: # case 1: x-，y+
beq s1,x0,end_case_xn_yp
bne s2,x0,end_case_xn_yp
la t3, signmask
lw t3, 0(t3)
bne t0, x0, case_xn_yp_op1
# 改变x符号，交换x,y且op变成减法
and t1, t3, t1
add t3, t1, x0
add t1, t2, x0
add t2, t3, x0
addi t0, x0, 1
jal end_case_xn_yp
case_xn_yp_op1:
# 相当于-（'x+' + 'y+’）
and t1, t1, t3
add t0, x0, x0
addi t5, x0, 1 
end_case_xn_yp:

# case 2: x+,y+
# 1、特殊情况处理
case_xp_yp:
bne t1, t2, xney 
bne t0, x0, opeq1
srli s1, t1, 7  # "x=y" && "+"(指数＋1，没有对溢出进行处理)
andi s1, s1, 255 # x exponent
addi s1, s1, 1
la s2, nemask
lw s2, 0(s2)
and t1, t1, s2 # clean exponent
slli s1, s1, 7
or s1, t1, s1
jal storeZ
opeq1:	# "x=y" && "-"
and s1, s1, x0
jal storeZ
# 2、正常情况处理
xney:
srli s1, t1, 7 
andi s1, s1, 255 # x exponent
srli s2, t2, 7 
andi s2, s2, 255 # y exponent
andi s3, t1, 127 # x fraction
addi s3, s3, 128 # 1.xxxx
andi s4, t2, 127 # y fraction
addi s4, s4, 128 # 1.xxxx

# 对齐
blt s1, s2, s1lts2 # s1<s2
sub s5, s1, s2 # s1-s2
srl s4, s4, s5
add s2, s1, x0
jal ends1lts2
s1lts2:
sub s5, s2, s1
srl s3, s3, s5
add s1, s2, x0
ends1lts2:

beq t0, x0, opeq
blt s3, s4, s3lts4 #operation = 1
sub s5, s3, s4
addi s6, x0, 0 # z的符号
jal ends3lts4
s3lts4: # s3<s4
sub s5, s4, s3
addi s6, x0, 1 # z的符号
ends3lts4:
jal endopeq
opeq:
add s5, s3, s4
add s6, x0, x0 # z的符号
endopeq:

# 归一化
ori t4, x0, 255 # t4=255
blt s5, t4, nors
srli s5, s5, 1 
addi s7, s1, 1 # s7为z的指数
jal endze
nors: # 确定左移位数
addi s8, x0, 7
loop:
srl s9, s5, s8
andi s9, s9, 1
addi s8, s8, -1 
beq s9, x0, loop
addi s9, x0, 6
sub s8, s9, s8 # s8左移位数
sll s5, s5, s8
sub s7, s1, s8
endze:

# 计算最终的z
beq t5, x0, sign0
addi s6, x0, 1
slli s6, s6, 15 # 符号字段
jal endsign0
sign0:
addi s6, x0, 0
endsign0:
slli s7, s7, 7 # 指数字段
or s1, s6, s7
andi s5, s5, 127 # 小数字段
or s1, s1, s5
#store the final result in z
storeZ:
la t3,z
sw s1,0(t3)
#print the z as an integer and exit
print:
addi a0, x0, 1
lw a1, 0(t3)
ecall
#exit
exit:
addi a0, x0, 10
ecall #exit
