# Implementation of a RISC-V compatible Multiply-Add Fused Unit

***The full paper could be found [here](docs/Implementation%20of%20a%20RISC-V%20compatible%20Multiply-Add%20Fused%20Unit.pdf)***

## Abstract

The floating-point Multiply-Add Fused (MAF, also known as Multiply-ACcumulate, MAC) unit is popular in modern microprocessor design due to its efficiency and performance advantages. The design aims to speed up scientific computations, multimedia applications, and in particular, convolutional neural networks for machine learning tasks. This study implements a MAF unit with RISC-V ”F” extension compatibility, incorporating standard IEEE 754-2008 exception handling, NaN propagation, and denormalized number support. Five distinct rounding modes and accrued exception flags are also supported in the proposed design. We test our implementation with carefully crafted corner cases and random generated floating-point numbers to verify its correctness.

**Index Terms—Floating-Point Unit, Multiply-Add fused, Multiply Accumulate, RISC-V**

## 1.Intorduction
Floating-point operations play a crucial role in modern day computing, especially when the machine learning domain flourishes. The growing computational power makes training sophisticated models possible. To apply the machine learning models in real life applications typically requires floating-points computations, which is  demanding since large amount of real time data must be processed. Moreover, deep learning algorithms with exhaustive need of floating-point computational capabilities, such as neural networks, grew its popularity recently. These applications further challenge the floating-point processing power of the microprocessors. Among all floating-point operations, add-and-multiply are the most demanding one, the combination appears in the convolution layers of convolutional neural networks, digital filtering, and many other computing models’ architecture.

Floating-point units are available on most microprocessors nowadays. Most designs center around a fused multiply-add dataflow due to its simplicity and performance advantage over separate multiplier and adder pipelines. It combines two basic operations with only one rounding error and shares hardware components to save chip area. Such design is also consistent with the basic RISC philosophy of heavily optimize key units in order to rapidly carry out the most frequently expected functions. Furthermore, the existence of fused multiply-add unit leads to more efficient superscalar CPU design since three floating-point instructions: add, multiply, and fused multiply-add could be scheduled to the same functional unit.

To take full advantage of the MAF dataflow, [3] transforms a set of equations into a series of multiply-adds by a numerical analysis technique called Horner's rule. [4] presents a general method to convert any transform algorithm into MAF optimized algorithms. [5] presents a framework for automatically generating MAF code for every linear DSP transform. The above-mentioned examples shows that the MAF architecture is recognized in modern computing and could receive optimization at the software level.

## 3. Overall Maf Unit Architecture

![maf](docs/Flowchart.png)
