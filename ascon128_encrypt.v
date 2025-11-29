`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:14:58 PM
// Design Name: 
// Module Name: ascon128_encrypt
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
// Ascon-128 Encryption
//===========================================================================
module ascon128_encrypt (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] nonce,
    input  wire [127:0] plaintext,
    output reg  [127:0] ciphertext,
    output reg  [127:0] tag,
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

reg [3:0] enc_state;
parameter ENC_IDLE   = 4'd0;
parameter ENC_INIT   = 4'd1;
parameter ENC_PERM_A = 4'd2;
parameter ENC_ABSORB = 4'd3;
parameter ENC_PERM_B = 4'd4;
parameter ENC_SQUEEZE= 4'd5;
parameter ENC_FINAL  = 4'd6;
parameter ENC_DONE   = 4'd7;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        enc_state <= ENC_IDLE;
        done <= 1'b0;
        perm_start <= 1'b0;
        ciphertext <= 128'd0;
        tag <= 128'd0;
    end else begin
        case (enc_state)
            ENC_IDLE: begin
                done <= 1'b0;
                if (start) enc_state <= ENC_INIT;
            end
            
            ENC_INIT: begin
                state[319:256] <= IV;
                state[255:128] <= key;
                state[127:0]   <= nonce;
                enc_state <= ENC_PERM_A;
                perm_rounds <= 5'd12;
            end
            
            ENC_PERM_A: begin
                if (!perm_start && !perm_done) begin
                    perm_state_in <= state;
                    perm_start <= 1'b1;
                end else if (perm_done) begin
                    perm_start <= 1'b0;
                    state <= perm_state_out;
                    state[255:128] <= perm_state_out[255:128] ^ key;
                    enc_state <= ENC_ABSORB;
                end
            end
            
            ENC_ABSORB: begin
                ciphertext <= state[127:0] ^ plaintext;
                state[127:0] <= state[127:0] ^ plaintext;
                enc_state <= ENC_PERM_B;
                perm_rounds <= 5'd6;
            end
            
            ENC_PERM_B: begin
                if (!perm_start && !perm_done) begin
                    perm_state_in <= state;
                    perm_start <= 1'b1;
                end else if (perm_done) begin
                    perm_start <= 1'b0;
                    state <= perm_state_out;
                    enc_state <= ENC_SQUEEZE;
                end
            end
            
            ENC_SQUEEZE: begin
                state[191:128] <= state[191:128] ^ key[127:64];
                state[127:64]  <= state[127:64] ^ key[63:0];
                enc_state <= ENC_FINAL;
                perm_rounds <= 5'd12;
            end
            
            ENC_FINAL: begin
                if (!perm_start && !perm_done) begin
                    perm_state_in <= state;
                    perm_start <= 1'b1;
                end else if (perm_done) begin
                    perm_start <= 1'b0;
                    state <= perm_state_out;
                    tag <= perm_state_out[255:128] ^ key;
                    enc_state <= ENC_DONE;
                end
            end
            
            ENC_DONE: begin
                done <= 1'b1;
                if (!start) enc_state <= ENC_IDLE;
            end
            
            default: enc_state <= ENC_IDLE;
        endcase
    end
end

endmodule

