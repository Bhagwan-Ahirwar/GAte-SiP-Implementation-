`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:49:32 PM
// Design Name: 
// Module Name: ascon128_decrypt
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

module ascon128_decrypt (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [127:0] ciphertext,
    input  wire [127:0] key,
    input  wire [127:0] nonce,
    input  wire [127:0] received_tag,
    input  wire        start,
    output reg  [127:0] plaintext,
    output reg         tag_valid,
    output reg         decrypt_done
);

reg [127:0] state;
reg [3:0] round;
reg [127:0] perm_in, perm_out;

ascon_permutation perm (
    .clk(clk), .rst_n(rst_n),
    .state_in(perm_in),
    .round_num(round),
    .state_out(perm_out)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 128'h0;
        plaintext <= 128'h0;
        tag_valid <= 1'b0;
        decrypt_done <= 1'b0;
        round <= 4'h0;
    end else begin
        if (start) begin
            if (round < 4'd12) begin
                perm_in <= state ^ ciphertext;
                plaintext <= state ^ ciphertext;
                state <= perm_out;
                round <= round + 1'b1;
            end else begin
                tag_valid <= (state ^ key == received_tag);
                decrypt_done <= 1'b1;
            end
        end else begin
            state <= key ^ nonce;
            round <= 4'h0;
            decrypt_done <= 1'b0;
        end
    end
end

endmodule

