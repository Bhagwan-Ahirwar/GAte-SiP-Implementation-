`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:27:04 PM
// Design Name: 
// Module Name: ieee1838_puf_ascon_counter_complete
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
// Complete IEEE 1838 System with PUF, Ascon, and Counter
//===========================================================================
module ieee1838_puf_ascon_counter_complete (
    input  wire        TCK,
    input  wire        TMS,
    input  wire        TDI,
    input  wire        TRST_N,
    output wire        TDO,
    output wire        STCK,
    output wire        STMS,
    output wire        STDI,
    output wire        STRST_N,
    input  wire        STDO,
    input  wire [7:0]  func_in,
    output wire [7:0]  func_out,
    input  wire        scan_in,
    output wire        scan_out,
    output wire        scan_enable,
    input  wire [31:0] die_id
);

wire [3:0] tap_state;
wire [3:0] IR;
wire ir_tdo, bypass_tdo, idcode_tdo, config_tdo, wrapper_tdo;
wire puf_tdo, sec_cfg_tdo;
wire [7:0] config_reg;
wire [7:0] wrapper_out;
wire [15:0] puf_response;
wire [4:0] puf_challenge;
wire puf_generate, puf_ready;
wire counter_start;
wire [15:0] puf_number;
wire [15:0] current_count;
wire count_done;
wire [127:0] test_config_plain;
wire [127:0] test_config_cipher;
wire [127:0] nonce_enc, nonce_dec;
wire [127:0] received_tag;
wire [127:0] encrypted_config;
wire [127:0] encryption_tag;
wire [127:0] decrypted_config;
wire decryption_valid;
wire encrypt_start, decrypt_start;
wire encrypt_done, decrypt_done;

tap_controller tap_ctrl (.TCK(TCK), .TMS(TMS), .TRST_N(TRST_N), .tap_state(tap_state));
instruction_register ir_reg (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .IR_tdo(ir_tdo));
config_3d_register config_3d (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .config_reg(config_reg), .config_tdo(config_tdo));
die_wrapper_register dwr (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .func_in(func_in), .wrapper_out(wrapper_out), .wrapper_tdo(wrapper_tdo));
idcode_register idcode (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .die_id(die_id), .idcode_tdo(idcode_tdo));
bypass_register bypass (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .bypass_tdo(bypass_tdo));
stap_interface stap (.TCK(TCK), .TMS(TMS), .TDI(TDI), .TRST_N(TRST_N), .STDO(STDO), .config_reg(config_reg), .STCK(STCK), .STMS(STMS), .STDI(STDI), .STRST_N(STRST_N));

puf_authentication_with_counter puf_auth (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .puf_challenge(puf_challenge), .puf_generate(puf_generate), .puf_response(puf_response), .puf_ready(puf_ready), .puf_tdo(puf_tdo), .counter_start(counter_start), .puf_number(puf_number), .current_count(current_count), .scan_enable(scan_enable), .count_done(count_done));

puf_counter_integration puf_counter_sys (.clk(TCK), .rst_n(TRST_N), .puf_generate(puf_generate), .puf_challenge(puf_challenge), .puf_response(puf_response), .puf_ready(puf_ready), .counter_start(counter_start), .puf_number(puf_number), .current_count(current_count), .scan_enable(scan_enable), .count_done(count_done));

scan_chain_control scan_ctrl (.clk(TCK), .rst_n(TRST_N), .scan_enable(scan_enable), .scan_in(scan_in), .scan_out(scan_out), .func_data_in(func_in), .func_data_out(func_out));

secure_config_with_counter sec_cfg_reg (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .puf_number(puf_number), .current_count(current_count), .scan_enable(scan_enable), .count_done(count_done), .encrypted_config(encrypted_config), .encryption_tag(encryption_tag), .decrypted_config(decrypted_config), .decryption_valid(decryption_valid), .test_config_plain(test_config_plain), .test_config_cipher(test_config_cipher), .nonce_enc(nonce_enc), .nonce_dec(nonce_dec), .received_tag(received_tag), .encrypt_start(encrypt_start), .decrypt_start(decrypt_start), .sec_cfg_tdo(sec_cfg_tdo));

puf_ascon_secure_config sec_manager (.clk(TCK), .rst_n(TRST_N), .puf_generate(puf_generate), .puf_challenge(puf_challenge), .puf_response(puf_response), .puf_ready(puf_ready), .encrypt_start(encrypt_start), .test_config_plain(test_config_plain), .nonce_enc(nonce_enc), .encrypted_config(encrypted_config), .encryption_tag(encryption_tag), .encrypt_done(encrypt_done), .decrypt_start(decrypt_start), .test_config_cipher(test_config_cipher), .nonce_dec(nonce_dec), .received_tag(received_tag), .decrypted_config(decrypted_config), .decryption_valid(decryption_valid), .decrypt_done(decrypt_done));

tdo_mux_secure tdo_mux (.tap_state(tap_state), .IR(IR), .ir_tdo(ir_tdo), .bypass_tdo(bypass_tdo), .idcode_tdo(idcode_tdo), .config_tdo(config_tdo), .wrapper_tdo(wrapper_tdo), .puf_tdo(puf_tdo), .sec_cfg_tdo(sec_cfg_tdo), .TDO(TDO));

endmodule
