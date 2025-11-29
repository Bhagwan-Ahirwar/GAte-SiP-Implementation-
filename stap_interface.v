`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:42:14 PM
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

module stap_interface (
    input  wire        TCK,
    input  wire        TMS,
    input  wire        TDI,
    input  wire        TRST_N,
    input  wire        STDO,
    input  wire [7:0]  config_reg,
    output wire        STCK,
    output wire        STMS,
    output wire        STDI,
    output wire        STRST_N
);

assign STCK   = (config_reg[0]) ? TCK : 1'b0;
assign STMS   = (config_reg[0]) ? TMS : 1'b0;
assign STDI   = (config_reg[0]) ? TDI : 1'b0;
assign STRST_N = (config_reg[0]) ? TRST_N : 1'b1;

endmodule

