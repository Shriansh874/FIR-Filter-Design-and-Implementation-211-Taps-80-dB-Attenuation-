`timescale 1ns / 1ps

module fir_filter_pipelined_l3 #(
    parameter N           = 211,   // Number of FIR taps
    parameter IN_WIDTH    = 16,    // Input data width
    parameter COEF_WIDTH  = 16,    // Coefficient width
    parameter MUL_WIDTH   = 32,    // Multiply result width
    parameter ACC_WIDTH   = 40     // Accumulator width
)(
    input  wire                        clk,
    input  wire                        rst_n,       // Active-low reset

    // Input sample interface
    input  wire signed [IN_WIDTH-1:0]  data_in,
    input  wire                        data_in_valid,

    // Output interface
    output reg  signed [ACC_WIDTH-1:0] data_out,
    output reg                         data_out_valid
);

    
    localparam integer L = 3;
    localparam integer NUM_CHUNKS = (N + L - 1) / L; // e.g. 211 => 71

    
    localparam signed [COEF_WIDTH-1:0] COEFF [0:N-1] = '{
        -1,   4,  10,  19,  29,  37,  42,  40,  30,  14,
        -4, -19, -26, -23, -11,   6,  21,  28,  23,   9,
       -11, -28, -33, -25,  -6,  18,  37,  40,  27,   1,
       -28, -48, -48, -27,   7,  42,  61,  55,  25, -19,
       -58, -76, -61, -19,  36,  79,  91,  65,   7, -58,
      -103,-107, -64,  11,  86, 130, 121,  57, -37,-122,
      -161,-131, -42,  73, 166, 193, 137,  16,-122,-218,
      -225,-134,  25, 187, 280, 258, 119, -86,-272,-356,
      -288, -86, 177, 389, 450, 316,  23,-318,-559,-580,
      -339,  95, 556, 842, 790, 356,-347,-1065,-1474,-1288,
      -367,1215,3169,5058,6425,6924,6425,5058,3169,1215,
      -367,-1288,-1474,-1065, -347, 356, 790, 842, 556,  95,
      -339, -580, -559, -318,  23, 316, 450, 389, 177, -86,
      -288, -356, -272,  -86, 119, 258, 280, 187,  25, -134,
      -225, -218, -122,   16, 137, 193, 166,  73, -42, -131,
      -161, -122, -37,   57, 121, 130,  86,  11, -64, -107,
      -103,  -58,   7,   65,  91,  79,  36, -19, -61,  -76,
       -58,  -19,  25,   55,  61,  42,   7, -27, -48,  -48,
       -28,    1,  27,   40,  37,  18,  -6, -25, -33,  -28,
       -11,    9,  23,   28,  21,   6, -11, -23, -26,  -19,
        -4,   14,  30,   40,  42,  37,  29,  19,  10,   4,
        -1
    };

    
    reg signed [IN_WIDTH-1:0] shift_reg [0:N-1];
    integer i;

    
    localparam ST_IDLE     = 0,
               ST_MULT_IN  = 1,
               ST_MULT_OUT = 2,
               ST_ADD1     = 3,
               ST_ADD2     = 4,
               ST_ACC      = 5,
               ST_DONE     = 6;

    reg [2:0] state;
    reg [7:0] chunk_idx; // up to ~70

    
    reg signed [ACC_WIDTH-1:0] accum_reg;

    
    reg signed [IN_WIDTH-1:0]  mult_in_A [0:L-1];
    reg signed [COEF_WIDTH-1:0]mult_in_B [0:L-1];

    
    reg signed [MUL_WIDTH-1:0] product_reg [0:L-1];

    // partial sums
    reg signed [ACC_WIDTH-1:0] partial_sum_reg1; 
    reg signed [ACC_WIDTH-1:0] partial_sum_reg2;

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all
            for (i = 0; i < N; i = i + 1) begin
                shift_reg[i] <= 0;
            end
            data_out          <= 0;
            data_out_valid    <= 0;
            accum_reg         <= 0;

            mult_in_A[0]      <= 0;
            mult_in_A[1]      <= 0;
            mult_in_A[2]      <= 0;
            mult_in_B[0]      <= 0;
            mult_in_B[1]      <= 0;
            mult_in_B[2]      <= 0;

            product_reg[0]    <= 0;
            product_reg[1]    <= 0;
            product_reg[2]    <= 0;

            partial_sum_reg1  <= 0;
            partial_sum_reg2  <= 0;
            chunk_idx         <= 0;
            state             <= ST_IDLE;
        end else begin
            // Default
            data_out_valid <= 0;

            case (state)

            
            ST_IDLE: begin
                if (data_in_valid) begin
                    // Shift new sample into shift_reg
                    for (i = N-1; i > 0; i = i - 1) begin
                        shift_reg[i] <= shift_reg[i-1];
                    end
                    shift_reg[0] <= data_in;

                    // Prepare
                    accum_reg         <= 0;
                    chunk_idx         <= 0;
                    // Clear pipeline
                    product_reg[0]    <= 0;
                    product_reg[1]    <= 0;
                    product_reg[2]    <= 0;
                    partial_sum_reg1  <= 0;
                    partial_sum_reg2  <= 0;

                    state <= ST_MULT_IN;
                end
            end

            
            ST_MULT_IN: begin
                integer base = chunk_idx * L; 
                // mult_in_A[0]
                if (base < N)  mult_in_A[0] <= shift_reg[base];
                else           mult_in_A[0] <= 0;
                if (base < N)  mult_in_B[0] <= COEFF[base];
                else           mult_in_B[0] <= 0;

                // mult_in_A[1]
                if (base+1 < N) mult_in_A[1] <= shift_reg[base+1];
                else            mult_in_A[1] <= 0;
                if (base+1 < N) mult_in_B[1] <= COEFF[base+1];
                else            mult_in_B[1] <= 0;

                // mult_in_A[2]
                if (base+2 < N) mult_in_A[2] <= shift_reg[base+2];
                else            mult_in_A[2] <= 0;
                if (base+2 < N) mult_in_B[2] <= COEFF[base+2];
                else            mult_in_B[2] <= 0;

                state <= ST_MULT_OUT;
            end

            
            ST_MULT_OUT: begin
                product_reg[0] <= mult_in_A[0] * mult_in_B[0];
                product_reg[1] <= mult_in_A[1] * mult_in_B[1];
                product_reg[2] <= mult_in_A[2] * mult_in_B[2];

                state <= ST_ADD1;
            end

            
            ST_ADD1: begin
                partial_sum_reg1 <= product_reg[0] + product_reg[1];
                state <= ST_ADD2;
            end

            
            ST_ADD2: begin
                partial_sum_reg2 <= partial_sum_reg1 + product_reg[2];
                state <= ST_ACC;
            end

            /
            ST_ACC: begin
                accum_reg <= accum_reg + partial_sum_reg2;

                // Next chunk
                chunk_idx <= chunk_idx + 1'b1;

                // If done => ST_DONE, else => ST_MULT_IN
                if (chunk_idx == (NUM_CHUNKS - 1)) begin
                    state <= ST_DONE;
                end else begin
                    state <= ST_MULT_IN;
                end
            end

            ST_DONE: begin
                data_out       <= accum_reg;
                data_out_valid <= 1;
                state <= ST_IDLE;
            end

            endcase
        end
    end

endmodule
