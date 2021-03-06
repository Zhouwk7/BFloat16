# BFloat16
# 软件功能

利用 RISC32IM 指令集，纯汇编代码实现 BFloat16 数据类型的加减操作

# 汇编仿真测试平台

http://www.kvakil.me/venus/
venus 平台可以实现RV32IM指令的仿真，并且提供所有能使用RV32IM指令表示的伪指令

# bfloat16 简介

深度学习促使了人们对新的浮点数格式的兴趣。通常（深度学习）算法并不需要64位，甚至32位的浮点数精度。更低的精度可以使在内存中存放更多数据成为可能，并且减少在内存中移动进出数据的时间。低精度浮点数的电路也会更加简单。这些好处结合在一起，带来了明显了计算速度的提升。

bfloat16，BF16格式的浮点数已经成为深度学习事实上的标准。已有一些深度学习“加速器”支持了这种格式，比如Google的TPU。Intel的处理与在未来也可能支持。

BF16浮点数在格式，介于FP16和FP32之间。（FP16和FP32是 IEEE 754-2008定义的16位和32位的浮点数格式。）

|--------+------+-----+----------+----------+  
| Format | Bits | sign| Exponent | Fraction |  
|--------+------+-----+----------+----------|  
| FP32   |   32 |  1  |   8      |     23   |  
| FP16   |   16 |  1  |   5      |     10   |  
| BF16   |   16 |  1  |   8      |     7    |  
|--------+------+-----+----------+----------+  

BF16的指数位比FP16多，跟FP32一样，不过小数位比较少。这样设计说明了设计者希望在16bits的空间中，通过降低精度（比FP16的精度还低）的方式，来获得更大的数值空间（Dynamic Range）。

运算过程，如下：
 
 X = (-1)^sign * (1 + Fraction) * 2^(Exponent - 127)