`timescale 1ns / 1ps

module fir_filter_pipelined_l3_tb;

  parameter N           = 211;
  parameter IN_WIDTH    = 16;
  parameter COEF_WIDTH  = 16;
  parameter MUL_WIDTH   = 32;
  parameter ACC_WIDTH   = 40;

  reg clk;
  reg rst_n;
  reg signed [IN_WIDTH-1:0] data_in;
  reg data_in_valid;
  wire signed [ACC_WIDTH-1:0] data_out;
  wire data_out_valid;

  // Instantiate the combined pipelining + L=3 parallel FIR
  fir_filter_pipelined_l3 #(
    .N          (N),
    .IN_WIDTH   (IN_WIDTH),
    .COEF_WIDTH (COEF_WIDTH),
    .MUL_WIDTH  (MUL_WIDTH),
    .ACC_WIDTH  (ACC_WIDTH)
  ) dut (
    .clk           (clk),
    .rst_n         (rst_n),
    .data_in       (data_in),
    .data_in_valid (data_in_valid),
    .data_out      (data_out),
    .data_out_valid(data_out_valid)
  );

  // Clock generation: 10 ns => 100 MHz
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    // Reset
    rst_n         = 0;
    data_in       = 0;
    data_in_valid = 0;
    #50;

    // Deassert reset
    rst_n = 1;
    #10;

    // Send one sample (impulse)
    data_in       = 16'h4000;  // e.g., +0.5 in Q1.15
    data_in_valid = 1;
    #10;
    data_in_valid = 0;

    // Wait until data_out_valid
    wait (data_out_valid == 1);
    #1;
    $display("T=%0dns => Output for sample1 = %d", $time, data_out);

    // Send another sample (e.g., zero)
    data_in       = 16'h0000;
    data_in_valid = 1;
    #10;
    data_in_valid = 0;

    wait (data_out_valid == 1);
    #1;
    $display("T=%0dns => Output for sample2 = %d", $time, data_out);

    #50;
    $stop;
  end

  // Print each output
  always @(posedge clk) begin
    if (rst_n && data_out_valid) begin
      $display("T=%0dns => data_out_valid=1, data_out=%d", $time, data_out);
    end
  end

endmodule
