`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:43:43 PM
// Design Name: 
// Module Name: ring_oscillator
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


module ring_oscillator (
    input  wire        enable,
    output wire        osc_out
);

wire inv1, inv2, inv3, inv4, inv5, inv6, inv7;

assign inv1 = ~(enable & osc_out);
assign inv2 = ~inv1;
assign inv3 = ~inv2;
assign inv4 = ~inv3;
assign inv5 = ~inv4;
assign inv6 = ~inv5;
assign inv7 = ~inv6;
assign osc_out = inv7;

endmodule

