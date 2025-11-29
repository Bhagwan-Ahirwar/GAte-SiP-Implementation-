`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 06:12:30 PM
// Design Name: 
// Module Name: gate_sip_chiplet
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


module gate_sip_chiplet (
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
    
    input  wire [31:0] die_id,
    input  wire [15:0] scan_chain_length,
    
    output wire [7:0]  security_status,
    output wire        tamper_detected
);

wire [3:0] tap_state;
tap_controller tap_ctrl (.TCK(TCK), .TMS(TMS), .TRST_N(TRST_N), .tap_state(tap_state));

wire [3:0] IR;
wire ir_tdo;
instruction_register ir_reg (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .IR_tdo(ir_tdo));

wire [7:0] config_reg;
wire config_tdo;
config_3d_register config_3d (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .config_reg(config_reg), .config_tdo(config_tdo));

wire [7:0] wrapper_out;
wire wrapper_tdo;
die_wrapper_register dwr (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .func_in(func_in), .wrapper_out(wrapper_out), .wrapper_tdo(wrapper_tdo));

wire idcode_tdo;
idcode_register idcode (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .die_id(die_id), .idcode_tdo(idcode_tdo));

wire bypass_tdo;
bypass_register bypass (.TCK(TCK), .TRST_N(TRST_N), .TDI(TDI), .tap_state(tap_state), .IR(IR), .bypass_tdo(bypass_tdo));

stap_interface stap (.TCK(TCK), .TMS(TMS), .TDI(TDI), .TRST_N(TRST_N), .STDO(STDO), .config_reg(config_reg), .STCK(STCK), .STMS(STMS), .STDI(STDI), .STRST_N(STRST_N));

wire [15:0] db_challenge;
wire [3:0]  db_puf_activation;
wire [127:0] db_auth_stimuli;
wire [15:0] db_puf_response;
wire db_data_valid;

db_crp_manager db_manager (.clk(TCK), .rst_n(TRST_N), .chiplet_id(die_id), .query_type(4'd0), .challenge(db_challenge), .puf_activation(db_puf_activation), .response(db_puf_response), .auth_stimuli(db_auth_stimuli), .data_valid(db_data_valid));

wire [15:0] puf_response;
wire puf_ready;
wire [15:0] puf_number;
wire [15:0] current_count;
wire puf_se_signal;
wire puf_tdo = 1'b0;

puf_counter_integration puf_sys (.clk(TCK), .rst_n(TRST_N), .puf_generate(1'b1), .puf_challenge(db_challenge), .puf_activation_ctrl(db_puf_activation), .puf_response(puf_response), .puf_ready(puf_ready), .counter_start(1'b1), .puf_number(puf_number), .current_count(current_count), .scan_enable(puf_se_signal), .count_done());

wire [127:0] auth_pattern_out;
wire is_dummy, is_auth, auth_se_ctrl, auth_capture, auth_success, auth_tampering;

authentication_pattern_manager auth_mgr (.clk(TCK), .rst_n(TRST_N), .auth_start(puf_ready), .n_auth(puf_number), .l_scan(scan_chain_length), .auth_stimuli(db_auth_stimuli), .auth_response_expected({112'h0, db_puf_response}), .pattern_out(auth_pattern_out), .is_dummy_pattern(is_dummy), .is_auth_pattern(is_auth), .scan_enable_ctrl(auth_se_ctrl), .pattern_valid(), .response_match(auth_success), .tampering_detected(auth_tampering));

wire tamper_flag, tamper_stop;
tamper_detection_controller tamper_ctrl (.clk(TCK), .rst_n(TRST_N), .auth_success(auth_success), .struct_test_fail(1'b0), .embedded_auth_fail(auth_tampering), .tamper_flag(tamper_flag), .attack_type(), .stop_test(tamper_stop), .send_dummy_patterns(), .security_status(security_status));

wire [127:0] encrypted_config, encryption_tag;
puf_ascon_secure_config sec_mgr (.clk(TCK), .rst_n(TRST_N), .puf_response(puf_response), .puf_ready(puf_ready), .test_config_plain(128'h0), .encrypted_config(encrypted_config), .encryption_tag(encryption_tag), .encrypt_done());

tdo_mux_secure tdo_mux (.tap_state(tap_state), .IR(IR), .ir_tdo(ir_tdo), .bypass_tdo(bypass_tdo), .idcode_tdo(idcode_tdo), .config_tdo(config_tdo), .wrapper_tdo(wrapper_tdo), .puf_tdo(puf_tdo), .sec_cfg_tdo(1'b0), .stdo(STDO), .TDO(TDO));

wire internal_logic_out;
assign internal_logic_out = func_in + 8'd1;
assign func_out = (IR == 4'h0) ? wrapper_out : internal_logic_out;
assign scan_out = scan_in;
assign scan_enable = (IR == 4'h0) ? puf_se_signal : auth_se_ctrl;
assign tamper_detected = tamper_flag;

endmodule


