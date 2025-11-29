`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:47:41 PM
// Design Name: 
// Module Name: ascon_permutation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ascon_permutation (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [127:0] state_in,
    input  wire [3:0]  round_num,
    output reg  [127:0] state_out
);

reg [4:0] round_constants [0:11];

initial begin
    round_constants[0]  = 5'hf0;
    round_constants[1]  = 5'he1;
    round_constants[2]  = 5'hd2;
    round_constants[3]  = 5'hc3;
    round_constants[4]  = 5'hb4;
    round_constants[5]  = 5'ha5;
    round_constants[6]  = 5'h96;
    round_constants[7]  = 5'h87;
    round_constants[8]  = 5'h78;
    round_constants[9]  = 5'h69;
    round_constants[10] = 5'h5a;
    round_constants[11] = 5'h4b;
end

reg [127:0] temp_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state_out <= 128'h0;
    end else begin
        temp_state = state_in ^ {120'h0, round_constants[round_num]};
        state_out <= temp_state ^ (temp_state >> 8);
    end
end

endmodule

