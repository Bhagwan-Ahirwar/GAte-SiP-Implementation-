`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:35:35 PM
// Design Name: 
// Module Name: gate_sip_soc
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


module gate_sip_soc (
    input  wire        TCK,
    input  wire        TMS,
    input  wire        TDI,
    input  wire        TRST_N,
    output wire        TDO,
    
    input  wire [7:0]  func_in_die0,
    output wire [7:0]  func_out_die0,
    input  wire [7:0]  func_in_die1,
    output wire [7:0]  func_out_die1,
    input  wire [7:0]  func_in_die2,
    output wire [7:0]  func_out_die2,
    
    input  wire        scan_in,
    output wire        scan_out_die0,
    output wire        scan_out_die1,
    output wire        scan_out_die2,
    
    output wire [7:0]  security_status_die0,
    output wire [7:0]  security_status_die1,
    output wire [7:0]  security_status_die2,
    output wire [2:0]  tamper_detected
);

parameter DIE0_ID = 32'h00001000;
parameter DIE1_ID = 32'h00002000;
parameter DIE2_ID = 32'h00003000;

parameter SCAN_LEN_DIE0 = 16'd256;
parameter SCAN_LEN_DIE1 = 16'd512;
parameter SCAN_LEN_DIE2 = 16'd1024;

wire stck_die0, stms_die0, stdi_die0, strst_n_die0, stdo_die0;
wire stck_die1, stms_die1, stdi_die1, strst_n_die1, stdo_die1;

gate_sip_chiplet die0 (.TCK(TCK), .TMS(TMS), .TDI(TDI), .TRST_N(TRST_N), .TDO(TDO), .STCK(stck_die0), .STMS(stms_die0), .STDI(stdi_die0), .STRST_N(strst_n_die0), .STDO(1'b0), .func_in(func_in_die0), .func_out(func_out_die0), .scan_in(scan_in), .scan_out(scan_out_die0), .scan_enable(), .die_id(DIE0_ID), .scan_chain_length(SCAN_LEN_DIE0), .security_status(security_status_die0), .tamper_detected(tamper_detected[0]));

gate_sip_chiplet die1 (.TCK(stck_die0), .TMS(stms_die0), .TDI(stdi_die0), .TRST_N(strst_n_die0), .TDO(stdo_die0), .STCK(stck_die1), .STMS(stms_die1), .STDI(stdi_die1), .STRST_N(strst_n_die1), .STDO(stdo_die1), .func_in(func_in_die1), .func_out(func_out_die1), .scan_in(scan_out_die0), .scan_out(scan_out_die1), .scan_enable(), .die_id(DIE1_ID), .scan_chain_length(SCAN_LEN_DIE1), .security_status(security_status_die1), .tamper_detected(tamper_detected[1]));

gate_sip_chiplet die2 (.TCK(stck_die1), .TMS(stms_die1), .TDI(stdi_die1), .TRST_N(strst_n_die1), .TDO(stdo_die1), .STCK(), .STMS(), .STDI(), .STRST_N(), .STDO(1'b0), .func_in(func_in_die2), .func_out(func_out_die2), .scan_in(scan_out_die1), .scan_out(scan_out_die2), .scan_enable(), .die_id(DIE2_ID), .scan_chain_length(SCAN_LEN_DIE2), .security_status(security_status_die2), .tamper_detected(tamper_detected[2]));

endmodule
