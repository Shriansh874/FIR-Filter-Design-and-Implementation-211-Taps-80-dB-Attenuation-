`timescale 1ns / 1ps

module fir_filter_single_dsp_pipelined #(
    parameter N           = 211,
    parameter IN_WIDTH    = 16,
    parameter COEF_WIDTH  = 16,
    parameter MUL_WIDTH   = 32,
    parameter ACC_WIDTH   = 40
)(
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire signed [IN_WIDTH-1:0]  data_in,
    input  wire                        data_in_valid,
    output reg  signed [ACC_WIDTH-1:0] data_out,
    output reg                         data_out_valid
);

    localparam signed [COEF_WIDTH-1:0] COEFF [0:N-1] = '{
        -1, 4, 10, 19, 29, 37, 42, 40, 30, 14,
        -4, -19, -26, -23, -11, 6, 21, 28, 23, 9,
        -11, -28, -33, -25, -6, 18, 37, 40, 27, 1,
        -28, -48, -48, -27, 7, 42, 61, 55, 25, -19,
        -58, -76, -61, -19, 36, 79, 91, 65, 7, -58,
        -103, -107, -64, 11, 86, 130, 121, 57, -37, -122,
        -161, -131, -42, 73, 166, 193, 137, 16, -122, -218,
        -225, -134, 25, 187, 280, 258, 119, -86, -272, -356,
        -288, -86, 177, 389, 450, 316, 23, -318, -559, -580,
        -339, 95, 556, 842, 790, 356, -347, -1065, -1474, -1288,
        -367, 1215, 3169, 5058, 6425, 6924, 6425, 5058, 3169, 1215,
        -367, -1288, -1474, -1065, -347, 356, 790, 842, 556, 95,
        -339, -580, -559, -318, 23, 316, 450, 389, 177, -86,
        -288, -356, -272, -86, 119, 258, 280, 187, 25, -134,
        -225, -218, -122, 16, 137, 193, 166, 73, -42, -131,
        -161, -122, -37, 57, 121, 130, 86, 11, -64, -107,
        -103, -58, 7, 65, 91, 79, 36, -19, -61, -76,
        -58, -19, 25, 55, 61, 42, 7, -27, -48, -48,
        -28, 1, 27, 40, 37, 18, -6, -25, -33, -28,
        -11, 9, 23, 28, 21, 6, -11, -23, -26, -19,
        -4, 14, 30, 40, 42, 37, 29, 19, 10, 4,
        -1
    };

    reg signed [IN_WIDTH-1:0] shift_reg [0:N-1];
    integer j;
    localparam ST_IDLE = 0, ST_MULT = 1, ST_ADD = 2, ST_DONE = 3;
    reg [1:0] state;
    reg [8:0] tap_idx;
    reg signed [ACC_WIDTH-1:0] accum_reg;
    reg signed [MUL_WIDTH-1:0] product_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (j = 0; j < N; j = j + 1) begin
                shift_reg[j] <= 0;
            end
            data_out       <= 0;
            data_out_valid <= 0;
            state          <= ST_IDLE;
            tap_idx        <= 0;
            accum_reg      <= 0;
            product_reg    <= 0;
        end else begin
            data_out_valid <= 0;
            case (state)
            ST_IDLE: begin
                if (data_in_valid) begin
                    for (j = N-1; j > 0; j = j - 1) begin
                        shift_reg[j] <= shift_reg[j-1];
                    end
                    shift_reg[0] <= data_in;
                    accum_reg <= 0;
                    tap_idx   <= 0;
                    state <= ST_MULT;
                end
            end
            ST_MULT: begin
                product_reg <= shift_reg[tap_idx] * COEFF[tap_idx];
                state <= ST_ADD;
            end
            ST_ADD: begin
                accum_reg <= accum_reg + product_reg;
                tap_idx <= tap_idx + 1;
                if (tap_idx == (N-1)) begin
                    state <= ST_DONE;
                end else begin
                    state <= ST_MULT;
                end
            end
            ST_DONE: begin
                data_out <= accum_reg;
                data_out_valid <= 1;
                state <= ST_IDLE;
            end
            endcase
        end
    end

endmodule

