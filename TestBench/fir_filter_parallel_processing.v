`timescale 1ns / 1ps

module fir_filter_educed_parallel_tb_L2;

  parameter N          = 211;
  parameter IN_WIDTH   = 16;
  parameter COEF_WIDTH = 16;
  parameter MUL_WIDTH  = 32;
  parameter ACC_WIDTH  = 40;
  parameter L          = 2;

  reg  clk;
  reg  rst_n;
  reg  signed [IN_WIDTH-1:0]  data_in;
  reg                         data_in_valid;
  wire signed [ACC_WIDTH-1:0] data_out;
  wire                        data_out_valid;

  fir_filter_educed_parallel #(
    .N         (N),
    .IN_WIDTH  (IN_WIDTH),
    .COEF_WIDTH(COEF_WIDTH),
    .MUL_WIDTH (MUL_WIDTH),
    .ACC_WIDTH (ACC_WIDTH),
    .L         (L)
  ) dut (
    .clk           (clk),
    .rst_n         (rst_n),
    .data_in       (data_in),
    .data_in_valid (data_in_valid),
    .data_out      (data_out),
    .data_out_valid(data_out_valid)
  );

  initial begin
    clk = 0;
    forever #7.5 clk = ~clk;
  end

  initial begin
    rst_n         = 0;
    data_in       = 0;
    data_in_valid = 0;
    #30;
    rst_n = 1;
    #15;
    data_in       = 16'h4000;
    data_in_valid = 1;
    #15;
    data_in_valid = 0;
    wait (data_out_valid == 1);
    #1;
    $display("t=%0dns => FIR output for sample1 = %d", $time, data_out);
    data_in       = 16'h0000;
    data_in_valid = 1;
    #15;
    data_in_valid = 0;
    wait (data_out_valid == 1);
    #1;
    $display("t=%0dns => FIR output for sample2 = %d", $time, data_out);
    #50;
    $stop;
  end

  always @(posedge clk) begin
    if (rst_n && data_out_valid) begin
      $display("t=%0dns => data_out=%d", $time, data_out);
    end
  end

endmodule

