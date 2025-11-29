`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:12:57 PM
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


//===========================================================================
// Bypass Register
//===========================================================================
module bypass_register (
    input  wire       TCK,
    input  wire       TRST_N,
    input  wire       TDI,
    input  wire [3:0] tap_state,
    input  wire [3:0] IR,
    output wire       bypass_tdo
);

parameter CAPTURE_DR = 4'b0110;
parameter SHIFT_DR   = 4'b0010;
parameter BYPASS = 4'b1111;

reg bypass_reg;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N)
        bypass_reg <= 1'b0;
    else if (IR == BYPASS) begin
        case (tap_state)
            CAPTURE_DR: bypass_reg <= 1'b0;
            SHIFT_DR:   bypass_reg <= TDI;
        endcase
    end
end

assign bypass_tdo = bypass_reg;

endmodule

