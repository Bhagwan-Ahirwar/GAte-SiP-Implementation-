`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:54:00 PM
// Design Name: 
// Module Name: puf_ascon_secure_config
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


module puf_ascon_secure_config (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] puf_response,        // 16-BIT RESPONSE INPUT
    input  wire        puf_ready,
    input  wire [127:0] test_config_plain,
    output reg  [127:0] encrypted_config,
    output reg  [127:0] encryption_tag,
    output reg         encrypt_done
);

wire [127:0] ascon_key;
wire key_ready;
reg enc_start;

// ✓ CORRECTED: Internal wires to receive module outputs
wire [127:0] encrypted_config_wire;
wire [127:0] encryption_tag_wire;
wire encrypt_done_wire;

puf_to_ascon_key key_gen (
    .clk(clk), 
    .rst_n(rst_n),
    .puf_response(puf_response),            // 16-bit response
    .start(puf_ready),
    .ascon_key(ascon_key),
    .key_ready(key_ready)
);

// ✓ CORRECTED: Connect to wires, not registers
ascon128_encrypt encryptor (
    .clk(clk), 
    .rst_n(rst_n),
    .plaintext(test_config_plain),
    .key(ascon_key),
    .nonce(128'h0),
    .start(enc_start),
    .ciphertext(encrypted_config_wire),     // ✓ Wire output
    .tag(encryption_tag_wire),              // ✓ Wire output
    .encrypt_done(encrypt_done_wire)        // ✓ Wire output
);

// ✓ CORRECTED: Synchronously capture wire values to output registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        enc_start <= 1'b0;
        encrypted_config <= 128'h0;
        encryption_tag <= 128'h0;
        encrypt_done <= 1'b0;
    end else begin
        enc_start <= key_ready;
        
        // Capture wire outputs to register outputs
        encrypted_config <= encrypted_config_wire;
        encryption_tag <= encryption_tag_wire;
        encrypt_done <= encrypt_done_wire;
    end
end

endmodule


