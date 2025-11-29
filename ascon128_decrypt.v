`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:15:43 PM
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


//===========================================================================
// Ascon-128 Decryption
//===========================================================================
module ascon128_decrypt (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] nonce,
    input  wire [127:0] ciphertext,
    input  wire [127:0] tag_in,
    output reg  [127:0] plaintext,
    output reg          tag_valid,
    output reg          done
);

parameter [63:0] IV = 64'h80400c0600000000;

reg [319:0] state;
reg [319:0] perm_state_in;
wire [319:0]perm_state_out;
reg perm_start;
wire perm_done;
reg [4:0] perm_rounds;

ascon_permutation perm (
    .clk(clk),
    .rst_n(rst_n),
    .start(perm_start),
    .rounds(perm_rounds),
    .state_in(perm_state_in),
    .state_out(perm_state_out),
    .done(perm_done)
);

reg [3:0] dec_state;
parameter DEC_IDLE   = 4'd0;
parameter DEC_INIT   = 4'd1;
parameter DEC_PERM_A = 4'd2;
parameter DEC_ABSORB = 4'd3;
parameter DEC_PERM_B = 4'd4;
parameter DEC_SQUEEZE= 4'd5;
parameter DEC_FINAL  = 4'd6;
parameter DEC_VERIFY = 4'd7;
parameter DEC_DONE   = 4'd8;

reg [127:0] computed_tag;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dec_state <= DEC_IDLE;
        done <= 1'b0;
        tag_valid <= 1'b0;
        perm_start <= 1'b0;
        plaintext <= 128'd0;
    end else begin
        case (dec_state)
            DEC_IDLE: begin
                done <= 1'b0;
                tag_valid <= 1'b0;
                if (start) dec_state <= DEC_INIT;
            end
            
            DEC_INIT: begin
                state[319:256] <= IV;
                state[255:128] <= key;
                state[127:0]   <= nonce;
                dec_state <= DEC_PERM_A;
                perm_rounds <= 5'd12;
            end
            
            DEC_PERM_A: begin
                if (!perm_start && !perm_done) begin
                    perm_state_in <= state;
                    perm_start <= 1'b1;
                end else if (perm_done) begin
                    perm_start <= 1'b0;
                    state <= perm_state_out;
                    state[255:128] <= perm_state_out[255:128] ^ key;
                    dec_state <= DEC_ABSORB;
                end
            end
            
            DEC_ABSORB: begin
                plaintext <= state[127:0] ^ ciphertext;
                state[127:0] <= ciphertext;
                dec_state <= DEC_PERM_B;
                perm_rounds <= 5'd6;
            end
            
            DEC_PERM_B: begin
                if (!perm_start && !perm_done) begin
                    perm_state_in <= state;
                    perm_start <= 1'b1;
                end else if (perm_done) begin
                    perm_start <= 1'b0;
                    state <= perm_state_out;
                    dec_state <= DEC_SQUEEZE;
                end
            end
            
            DEC_SQUEEZE: begin
                state[191:128] <= state[191:128] ^ key[127:64];
                state[127:64]  <= state[127:64] ^ key[63:0];
                dec_state <= DEC_FINAL;
                perm_rounds <= 5'd12;
            end
            
            DEC_FINAL: begin
                if (!perm_start && !perm_done) begin
                    perm_state_in <= state;
                    perm_start <= 1'b1;
                end else if (perm_done) begin
                    perm_start <= 1'b0;
                    state <= perm_state_out;
                    computed_tag <= perm_state_out[255:128] ^ key;
                    dec_state <= DEC_VERIFY;
                end
            end
            
            DEC_VERIFY: begin
                if (computed_tag == tag_in) begin
                    tag_valid <= 1'b1;
                end else begin
                    tag_valid <= 1'b0;
                    plaintext <= 128'hDEADBEEFDEADBEEFDEADBEEFDEADBEEF;
                end
                dec_state <= DEC_DONE;
            end
            
            DEC_DONE: begin
                done <= 1'b1;
                if (!start) dec_state <= DEC_IDLE;
            end
            
            default: dec_state <= DEC_IDLE;
        endcase
    end
end

endmodule

