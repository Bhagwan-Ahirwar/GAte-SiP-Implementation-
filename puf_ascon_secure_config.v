`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:23:43 PM
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


//===========================================================================
// PUF-Ascon Secure Configuration Manager
//===========================================================================
module puf_ascon_secure_config (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         puf_generate,
    input  wire [4:0]   puf_challenge,
    output wire [15:0]  puf_response,
    output wire         puf_ready,
    input  wire         encrypt_start,
    input  wire [127:0] test_config_plain,
    input  wire [127:0] nonce_enc,
    output wire [127:0] encrypted_config,
    output wire [127:0] encryption_tag,
    output wire         encrypt_done,
    input  wire         decrypt_start,
    input  wire [127:0] test_config_cipher,
    input  wire [127:0] nonce_dec,
    input  wire [127:0] received_tag,
    output wire [127:0] decrypted_config,
    output wire         decryption_valid,
    output wire         decrypt_done
);

wire puf_enable;
wire puf_valid;

ro_puf_16bit puf_core (
    .clk(clk),
    .rst_n(rst_n),
    .enable(puf_enable),
    .challenge(puf_challenge),
    .response(puf_response),
    .response_valid(puf_valid)
);

assign puf_enable = puf_generate;
assign puf_ready = puf_valid;

wire [127:0] ascon_key;
wire key_ready;

puf_to_ascon_key key_derivation (
    .clk(clk),
    .rst_n(rst_n),
    .start(puf_valid | encrypt_start | decrypt_start),
    .puf_response(puf_response),
    .ascon_key(ascon_key),
    .done(key_ready)
);

ascon128_encrypt encryptor (
    .clk(clk),
    .rst_n(rst_n),
    .start(encrypt_start & key_ready),
    .key(ascon_key),
    .nonce(nonce_enc),
    .plaintext(test_config_plain),
    .ciphertext(encrypted_config),
    .tag(encryption_tag),
    .done(encrypt_done)
);

ascon128_decrypt decryptor (
    .clk(clk),
    .rst_n(rst_n),
    .start(decrypt_start & key_ready),
    .key(ascon_key),
    .nonce(nonce_dec),
    .ciphertext(test_config_cipher),
    .tag_in(received_tag),
    .plaintext(decrypted_config),
    .tag_valid(decryption_valid),
    .done(decrypt_done)
);

endmodule
    
