`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:42:50 PM
// Design Name: 
// Module Name: tdo_mux_secure
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


module tdo_mux_secure (
    input  wire [3:0]  tap_state,
    input  wire [3:0]  IR,
    input  wire        ir_tdo,
    input  wire        bypass_tdo,
    input  wire        idcode_tdo,
    input  wire        config_tdo,
    input  wire        wrapper_tdo,
    input  wire        puf_tdo,
    input  wire        sec_cfg_tdo,
    input  wire        stdo,
    output wire        TDO
);

parameter SHIFT_IR = 4'd11;
parameter SHIFT_DR = 4'd4;
parameter IDCODE = 4'h1;
parameter EXTEST = 4'h0;
parameter CONFIG_3D = 4'h3;
parameter PUF_CHALLENGE = 4'h6;
parameter SEC_CONFIG_ENC = 4'h7;
parameter BYPASS = 4'hF;

assign TDO = (tap_state == SHIFT_IR) ? ir_tdo :
             (tap_state == SHIFT_DR && IR == IDCODE) ? idcode_tdo :
             (tap_state == SHIFT_DR && IR == EXTEST) ? wrapper_tdo :
             (tap_state == SHIFT_DR && IR == CONFIG_3D) ? config_tdo :
             (tap_state == SHIFT_DR && IR == PUF_CHALLENGE) ? puf_tdo :
             (tap_state == SHIFT_DR && IR == SEC_CONFIG_ENC) ? sec_cfg_tdo :
             (tap_state == SHIFT_DR && IR == BYPASS) ? bypass_tdo : stdo;

endmodule

