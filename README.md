# FIR Filter Design and Implementation  
**(211-Taps, 80 dB Attenuation)**

This repository contains the design and implementation of a low-pass Finite Impulse Response (FIR) filter as part of a course project. The project uses MATLAB for filter design and Verilog for the hardware implementation. The design is targeted toward achieving a stopband attenuation of at least 80 dB with a filter having approximately 211 taps.
## Project Overview

### Objective
The goal of this project is to:
- **Design a Low-Pass FIR Filter:** Using MATLAB to construct a filter with specified characteristics:
  - **Transition Region:** 0.2π to 0.23π rad/sample.
  - **Stopband Attenuation:** At least 80 dB.
  - **Number of Taps:** Initially 100, but extended to 211 taps to meet performance targets.
- **Decide Quantization:** Choose suitable quantization for filter coefficients as well as input, output, and intermediate data.
- **Hardware Implementation:** Implement the FIR filter using verilog. The project demonstrates multiple architectures:
  1. **Pipelining**
  2. **Reduced-Complexity Parallel Processing:** For parallelism factors L=2 and L=3.
  3. **Combined Pipelining and L=3 Parallel Processing**

## Repository Structure

The repository is organized into several key folders and files:

- **`/MATLAB/`**  
  Contains MATLAB scripts and functions used to design the FIR filter. Here you will find:
  - **Filter Design Script:** A script that constructs the 211-tap FIR filter meeting the specified transition band and stopband attenuation requirements.
  - **Coefficient Quantization:** Files and documentation regarding how the filter coefficients and data were quantized.
  - **Coefficient Text File:** A text file with the quantized filter coefficients, allowing for easy reference and reuse.
      
- **`/Verilog/`**  
  Includes the hardware implementation files:
  - **Verilog/VHDL Files:** Source code files implementing the FIR filter.
  - **Architecture Variants:** Separate subfolders or files for the different architectures:
    - Pipelined design.
    - Reduced-complexity parallel processing (L=2 and L=3).
    - Combined pipelining and L=3 parallel processing.
   
- **`/TestBench/`**  
  Contains the testbench files for all the Verilog code:
  - **Testbenches:** Simulation testbench files to verify and validate the functionality of the FIR filter across all architectural variations.

- **`/docs/`**  
  Documentation and additional resources:
  - **Power Consumption Summary Plots:** Detailed plots for all three Verilog architectures.
  - **Utilization Summary Plots:** Resource utilization comparisons for each architecture.
  - **Timing Summary Plots:** Timing analysis for the different Verilog implementations.
  - **MATLAB Response Plots:**  Visual comparisons between the original and quantized responses.
    
