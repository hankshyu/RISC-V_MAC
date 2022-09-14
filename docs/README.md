# Implementation of a RISC-V compatible Multiply-Add-Fused Unit

## Abstract


## 1.Intorduction

floating point operation is curcial in modern day

Designs with a compound operation has performance advantage over separate add and multiply datapaths.

Multiply fused add unit leads to more efficient superscaler cpu design, the scheduler could 

Horner's reule for transforming a set of equations into a series of multiply-adds. 

First processor to contain a fused multiply-add dataflow ins IBM RS/6000 in 1990

<<<<<<< HEAD
## 2.Related Work

=======
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
>>>>>>> cb385ca664ab8bd2614955c0b31021f849d82a42


## 4.Architecture


### 1.Prenormalizer



## 5.Implementation Results


## 6.Conclusion


## References
