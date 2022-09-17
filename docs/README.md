# Implementation of a RISC-V compatible Multiply-Add-Fused Unit

## Abstract


## 1.Intorduction

floating point operation is curcial in modern day

Designs with a compound operation has performance advantage over separate add and multiply datapaths.

Multiply fused add unit leads to more efficient superscaler cpu design, the scheduler could 

Horner's reule for transforming a set of equations into a series of multiply-adds. 

First processor to contain a fused multiply-add dataflow ins IBM RS/6000 in 1990

## 2.Related Work

Binary floating-point units are available on every microprocessor and are
very common in embedded applications including game systems. Most designs
center around a fused multiply-add dataflow due to its simplicity and performance advantage over separate multiply and add pipelines. One technique used
for increasing performance is to use Horner’s rule for transforming a set of
equations into a series of multiply-adds [2]. This numerical analysis technique
is very common and takes full advantage of this type of dataflow.
The first processor to contain a fused multiply-add dataflow was the first
IBM RS/6000 workstation which was introduced around 1990 [3]. Many of the
hardware implementation algorithms of this machine are still popular today.
The optimizing compiler was key to enabling C programs to be expanded into
a series of fused multiply-adds.


## 3.Architecture
![overall architecture](Flowchart.png)
### 3.1. Multiplier

The design of the multiplier involvers creating a partial product array made up of multiples of multiplicands(R4Booth), and sum them up to form the product(WallaceTree). One of the key factor in designing a multiplier is to determine to radix of the multiplier. 
Chosing the smaller radix creates loads of partial products that is easy to create and choose from, but harder to sum due to the quantity. On the other hand, a larger radix has fewer partial products to add from, but it's more difficut to create the partial product array. 

Radix-10 multiplication is what we are most familiar with, often carry out by hand. Decimal format is optimal for financial applications and may become more popular in the future by the publication of the revision to IEEE 754 floating point standard [1]. Binary is yet the choise for most desingers for the sake of it's mathematical properties and performance advantage.

Assume both the multiplier and the multiplicand has N bit. Radix-2, the most naive binary, would require large counter tree to sum up N partial products. Radix-4 multiplication will reduce the number of partial product to ceil((N+1)/2), half the number compare to radix-2. The downside is the partial product ranges from 0x 1x 2x 3x the multiplicand, 3x multiple may require extra delay and area to form since it's non-trivial.

Booth showed a technique to record digits in both positive and negative. Such transformation eliminates two cosecutive ones thus eliminates the 3x multiple. A Booth radix-4 scanning simplifies the multiples to signed 0x 1x and 2x. 
Under implementation, the scanning process involves examining 3 bits of the multiplier, compare it to the Modified Booth's Recording Table to determine the multiplicand selected. The logic could be simplified to the equation below:

Modified Booth's Recording Table
| Bit i + 1   |   Bit i   |   Bit i - 1   |   Multiplicand selected   |
|:------:|:----:|:----:|:----:|
|     0       |    0      |       0       |   0 x Multiplicand        |
|     0       |    0      |       1       |  +1 x Multiplicand        |
|     0       |    1      |       0       |  +1 x Multiplicand        |
|     0       |    1      |       1       |  +2 x Multiplicand        |
|     1       |    0      |       0       |  -2 x Multiplicand        |
|     1       |    0      |       1       |  -1 x Multiplicand        |
|     1       |    1      |       0       |  -1 x Multiplicand        |
|     1       |    1      |       1       |   0 x Multiplicand        |
    
```
mul1x_o = bit (i) xor bit(i - 1)
mul2x_o = bit(i+1)bit(i)bit(i-1) == (100 or 011)
mulsign_o = bit (i + 1)
```

The fact that multiplicand may be negative is disturbing because we must sign extend the multiplicand to acquire the correct result. The intuitive way is by sign extending every single bit on the left of the partial product. [4] mentioned an elegent way of acquiring the same result while the sign of the partial product only effects two bits of the partial product, greatly improves the potential wiring of the design and is adopted in our proposed multiplier.


![WallaceTree](WallaceTree.png)
The next step of multiplication is to sum the partial products, a hardware structure named Wallace tree is implemented to reduce critical path. Wallace trees are usually composed of carry save adders, also called counters. Traditionally, they intake 3 partial sums to output a sum and carry. 4;2 counters was introduced in [5] and were further optimized and designed[6] [7]. By mixing the use of 3:2 counter and 4:2 counter results in optimal design when minimizing delay.


### 3.2. Exponent Processor & PreNormalizer

Before the Addend could be add with the sum and carry from the multiplier, proper alignment must take place. Furthermore, by executing multiplication and alignment in parallel, we must include a large shifter about 3 times the size of the mantissa in our design. [8] clearly explains the way of implementation

### 3.3 End Around Carry (EAC) Adders

**suppresion of sign extension**

### 3.4 Leading One Detector

### 3.5 Normalizer 

### 3.6 Rounder


## 4.Implementation Results


## 5.Conclusion


## References
[1]: “IEEE standard for floating-point arithmetic, ANSI/IEEE Std 754R,” The Institute of
Electrical and Electronic Engineers, Inc., In progress, http://754r.ucbtest.org/ drafts/754r.pdf .

[2] Knuth, D. “The Art of Computer Programming, Vol. 2: Seminumerical Algorithms,
3rd ed.” Addison-Wesley, Reading, MA, 1998, 467–469.

[3] Montoye, R.K.; Hokenek, E.; Runyon, S.L. “Design of the IBM RISC System/6000
floating-point execution unit”, IBM J. Res. Dev., 1990, 34(1), 59–70.

[4] Appendix A Sign Extension in Booth Multipliers, http://i.stanford.edu/pub/cstr/reports/csl/tr/94/617/CSL-TR-94-617.appendix.pdf

[5] Weinberger, A. “4:2 carry-save adder module”, IBM Technical Disclosure Bull., 1981,
23, 3811–3814.

[6] D. Radhakrishnan and A. P. Preethy, "Low power CMOS pass logic 4-2 compressor for high-speed multiplication," Proceedings of the 43rd IEEE Midwest Symposium on Circuits and Systems (Cat.No.CH37144), 2000, pp. 1296-1298 vol.3, doi: 10.1109/MWSCAS.2000.951453.

[7] K. Prasad and K. K. Parhi, "Low-power 4-2 and 5-2 compressors," Conference Record of Thirty-Fifth Asilomar Conference on Signals, Systems and Computers (Cat.No.01CH37256), 2001, pp. 129-133 vol.1, doi: 10.1109/ACSSC.2001.986892.

[8] Zhaolin Li, Xinyue Zhang, Gongqiong Liz and Runde Zhou, "Design of a fully pipelined single-precision floating-point unit," 2007 7th International Conference on ASIC, 2007, pp. 60-63, doi: 10.1109/ICASIC.2007.4415567.



