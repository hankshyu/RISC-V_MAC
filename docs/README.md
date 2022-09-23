# Implementation of a RISC-V compatible Multiply-Add-Fused Unit

## Abstract


## 1.Intorduction


RISC concept of attacking the most frequently used functuions by building simple hardware.

MAF implementation should be consistent with the basic RISC philosophy of heavily optimize units in order to rapidly carry out the most frequently expected function as fast as possible.

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


### 3.2. PreNormalizer

Before the Addend could be add with the partial products from the multiplier, proper alignment must take place. Our design overlaps the data aligment with the early pahses of multiplication, such design requires the capability of shifting the addend in either direction while each of these partial products are two times as wide as the input. In short, by executing multiplication and alignment in parallel, we must include a large shifter about 3 times the size of the mantissa.

In a normal floating point adder, the smaller exponent is aligned; nevertheless, it is very costy to implement a large shifter capable of shifting bidirectionally. A clean and more efficient impelmentation is mentioned in [8]. Alignment of the addend is implemented by placing the addend to leftmost of the product and shifts the addend to the right according to the exponent value; in other words the product is treated as having a fixed radix point and the addend is aligned to the radix point. Under such implementation, the shifting ranges also approxiamtely three times the width of the data plus some guard bits but only shift-right capbilities is needed to the shifter.


After the normalization of the exponent, if the mantissa of the addend is of 24 (length of the mantissa) plus two gurad bits greater than the product, the final mantissa is solely decided by the product's mantissa thus further shifting to the left is unnecessary. When the addend's most significatn bit is less than the product's least significant bit, the mantissa of the addend dominates the result so it's needless to further shift to the right. The value of shifting is also mentioned in [8] and is processed in the exponent processor in our design:

```
d:  the difference between the exponent of the addend and the product
mv: the shift amount of the addned for alignment

d = expA - (expB + ExpC -127)
mv = 27 - d 
```

### 3.3 End Around Carry (EAC) Adders

In an ordinary Multiply and add dataflow. The product should form before the add operation take place. However, the addend is added with the partial products comming out of the multiplier directly in our design. Such dataflow may cause a propagate of any carry outs that ought to be ignored, contaminating the final result. In other words, we should figure out whether there was a carry out of the sign extension prior to the last carry save adder, if the carry out is detected, no adjustment has to be made. On the other hand, if no carry out is detected, we must invert the result driving to the EAC Adders.

Floating points are represented as sign and magnitude format in IEEE-754, in consequence, the adder is only responsible of calculating the absolute value of the sum. However, it is very difficult to determine in advance which operand is bigger in the MAC dataflow. Even if we know which operand is greater, we would potnetially need two complementors for the sum and carry comming from the carry save adder, which is very inefficient. We need an adder that always output the magnitude of the result by coditionally complement one operand. This type of adder is called an "End Around carry" adder.

The mathematical model is presented in [9]. The logic is essentially driving the carry out of (P-B) into another adder's carry in. Such function could be implemented by two carry chains, using two adders calculating (P - B) and (B - P) respectively with a multiplexer selecting the answer of the two. [9] also mentioned another impelmentation similar to a cary lookahead adder, which is smaller in size but harder to implement.

### 3.4 Leading One Detector

Design of the Leading One detector is pivotal to the normalization process. Normalization stips away all leading sign bits so that the two bits adjacent to the radix point are of opposite polarity. To determinte how much to shift would be the responsibility of the Leading one detector. 

Back to the first processor contains a fused multiply-add dataflow [3], the RC/6000 processor also equipped a leading-zero anticipator (LZA) to process the leading zeros and ones in parallel with floating point addition. The algorithm is mentioned in [10] [11]. [12] further compares algorithms of detecting leading zeros/ones. 

Although running one detection and addition in parallel would acclerate the calculation, the hardware would grew significantly if the input bits grew wider. Another disadvantage of calculating the leading ones before the addition is done is the polarity of the additon is not yet determined, the hardware must incorporate the sign of the sum to calculate the correct amount of leading ones.

An easy solution is to only implement a parts of the LZA component. Despite the fact that it would only operate when the sum is calculated, leading to a slower design. The lightweight leading one detector could assume the input is always positive, since the output of the End around carry is always positive. By taking the advantage of the know polarity, our design uses much smaller area and with simplier algorithm with great scalbility.

### 3.5 Rounder
Since floating point has a fixed sized mantissa, bits that are less significant would be naturally truncated during the operation. For user to freely select their desired rounding mode, we must add extra bits called guard bit, round bit and sticky bit during arithmatic calculations. [13] explains why a guard bit is necessary to ensure the rounding works correctly.

RISCV "F" standard Extension supports 5 rounding modes: RNE, RTZ, RDN, RUP and RMM. IEEE754-2008[14] clearly defines the behaviour of rounding toward a directed orientation, which is how RTZ, RDN and RUP operate. [8] provided an easy way of implementation, simplefies 3 rounding mode into two: RI and RZ. RNE and RMM are a bit trickier, the floating point number nearest to infinty precise result is given. If the distance between two nearest floating-point are equally near, RNE delivers the one with and even least significant digit, where RMM delivers the larger magnitude. They are named as roundTiesToEven and roundTiestoAway in IEEE754-2008.

The floating-point control and status register in RISC-V also holds the accrued exception flags, NV, DZ, OF, UF and NX respectively. In the MAC dataflow, DV would never be raised so only 4 exception flags are judged in our design. Overflow and underflow flags are pretty intuitive. NV flag will be raised if any invalid operation take place. IEEE754-2008 7.2 [14] defines lists of invalid operations. NX flag stands for inexact, it would fire if the calculated result of our design does not equal to the absolute answer. By checking the contamination of the sticky bits, we could judge whether the flag shall be raise.

IEEE754-2008 also defined the default exception handling methods that we must obey. The job is also done by the rounder because rounding mode could affect the way underflow or overflow represents. For example, RTZ carries positive overflow to the format's largest finite nubmer while RUP carries to positive infinity. After all the adjustments,  output from the rounder drives the output of the module.

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

[9] Schwarz, Eric. (2007). Binary Floating-Point Unit Design. 10.1007/978-0-387-34047-0_8. 

[10] E. Hokenek and R. K. Montoye, "Leading-zero anticipator (LZA) in the IBM RISC System/6000 floating-point execution unit," in IBM Journal of Research and Development, vol. 34, no. 1, pp. 71-77, Jan. 1990, doi: 10.1147/rd.341.0071.

[11] H. Suzuki, H. Morinaka, H. Makino, Y. Nakase, K. Mashiko and T. Sumi, "Leading-zero anticipatory logic for high-speed floating point addition," in IEEE Journal of Solid-State Circuits, vol. 31, no. 8, pp. 1157-1164, Aug. 1996, doi: 10.1109/4.508263.

[12] M. S. Schmookler and K. J. Nowka, "Leading zero anticipation and detection-a comparison of methods," Proceedings 15th IEEE Symposium on Computer Arithmetic. ARITH-15 2001, 2001, pp. 7-12, doi: 10.1109/ARITH.2001.930098.

[13] https://pages.cs.wisc.edu/~david/courses/cs552/S12/handouts/guardbits.pdf

[14] "IEEE Standard for Floating-Point Arithmetic," in IEEE Std 754-2008 , vol., no., pp.1-70, 29 Aug. 2008, doi: 10.1109/IEEESTD.2008.4610935.