`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:17:10 PM
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


//===========================================================================
// Ring Oscillator
//===========================================================================
module ring_oscillator #(
    parameter NUM_STAGES = 7
)(
    input  wire enable,
    output wire osc_out
);

wire [NUM_STAGES:0] ro_chain;
assign ro_chain[0] = enable & ro_chain[NUM_STAGES];

genvar i;
generate
    for (i = 0; i < NUM_STAGES; i = i + 1) begin : inv_chain
        not #1 inv_stage (ro_chain[i+1], ro_chain[i]);
    end
endgenerate

assign osc_out = ro_chain[NUM_STAGES];

endmodule

