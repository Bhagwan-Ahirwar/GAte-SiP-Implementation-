`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:13:34 PM
// Design Name: 
// Module Name: stap_interface
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
// STAP Interface
//===========================================================================
module stap_interface (
    input  wire       TCK,
    input  wire       TMS,
    input  wire       TDI,
    input  wire       TRST_N,
    input  wire       STDO,
    input  wire [7:0] config_reg,
    output wire       STCK,
    output wire       STMS,
    output wire       STDI,
    output wire       STRST_N
);

wire stap_enable  = config_reg[0];
wire bypass_mode  = config_reg[1];

assign STCK    = stap_enable ? TCK : 1'b0;
assign STMS    = stap_enable ? TMS : 1'b0;
assign STDI    = stap_enable ? (bypass_mode ? TDI : STDO) : 1'b0;
assign STRST_N = stap_enable ? TRST_N : 1'b0;

endmodule

