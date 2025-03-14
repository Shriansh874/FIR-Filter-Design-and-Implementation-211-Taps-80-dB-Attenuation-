# FIR Filter Design and Implementation  
**(211-Taps, 80 dB Attenuation)**

This repository contains the design and implementation of a low-pass Finite Impulse Response (FIR) filter as part of a course project. The filter coefficients are calculated using MATLAB and then directly implemented in Verilog for hardware realization. The design targets a stopband attenuation of at least 80 dB and utilizes a filter with 211 taps.

## Project Overview

### Objective
The goal of this project is to:
- **Design a Low-Pass FIR Filter:** 
  - Use MATLAB to construct a filter with the following characteristics:
    - **Transition Region:** 0.2π to 0.23π rad/sample.
    - **Stopband Attenuation:** At least 80 dB.
    - **Number of Taps:** Initially 100, but extended to 211 taps to meet performance targets.
- **Coefficient Calculation and Quantization:**  
  - Compute the filter coefficients in MATLAB.
  - Perform appropriate quantization for the coefficients as well as the input, output, and intermediate data.
- **Hardware Implementation:**  
  - Implement the FIR filter in Verilog using the MATLAB-calculated coefficients.
  - Demonstrate multiple architectures including:
    1. **Pipelining**
    2. **Reduced-Complexity Parallel Processing:** (with parallelism factors L=2 and L=3)
    3. **Combined Pipelining and L=3 Parallel Processing**

## Repository Structure

The repository is organized into several key folders and files:

- **`/MATLAB/`**  
  Contains MATLAB scripts and functions used to design the FIR filter. In this folder, you will find:
  - **Filter Design Script:** A MATLAB script that calculates the 211-tap FIR filter coefficients meeting the specified transition band and stopband attenuation requirements.
  - **Coefficient Quantization:** Documentation and scripts regarding the quantization process for filter coefficients and data.
  - **Coefficient Export File:** A text file containing the quantized filter coefficients, which are then used in the Verilog implementation.

- **`/Verilog/`**  
  Includes the hardware implementation files where the MATLAB-generated coefficients are integrated:
  - **Verilog Files:** Source code files that implement the FIR filter using the computed coefficients.
  - **Architecture Variants:** Separate subfolders or files for the different architectures:
    - Pipelined design.
    - Reduced-complexity parallel processing (L=2 and L=3).
    - Combined pipelining and L=3 parallel processing.

- **`/TestBench/`**  
  Contains the testbench files for all the Verilog implementations:
  - **Testbenches:** Simulation files that verify and validate the functionality of the FIR filter across all architectural variations.

- **`/docs/`**  
  Documentation and additional resources:
  - **Power Consumption Summary Plots:** Detailed plots for all three Verilog architectures.
  - **Utilization Summary Plots:** Resource utilization comparisons for each architecture.
  - **Timing Summary Plots:** Timing analysis for the different Verilog implementations.
  - **MATLAB Response Plots:** Visual comparisons between the original MATLAB filter response and the quantized response used in Verilog.

In summary, the process begins with the MATLAB-based computation and quantization of the FIR filter coefficients, which are then incorporated into the Verilog designs. This workflow ensures that the filter’s performance is accurately translated from simulation to hardware.

