`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:41:28 PM
// Design Name: 
// Module Name: bypass_register
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


module bypass_register (
    input  wire        TCK,
    input  wire        TRST_N,
    input  wire        TDI,
    input  wire [3:0]  tap_state,
    input  wire [3:0]  IR,
    output wire        bypass_tdo
);

parameter SHIFT_DR = 4'd4;
parameter BYPASS = 4'hF;

reg bypass_ff;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        bypass_ff <= 1'b0;
    end else begin
        if (IR == BYPASS && tap_state == SHIFT_DR) begin
            bypass_ff <= TDI;
        end
    end
end

assign bypass_tdo = bypass_ff;

endmodule

