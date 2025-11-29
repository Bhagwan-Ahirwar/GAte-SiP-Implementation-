`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:39:54 PM
// Design Name: 
// Module Name: die_wrapper_register
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


module die_wrapper_register (
    input  wire        TCK,
    input  wire        TRST_N,
    input  wire        TDI,
    input  wire [3:0]  tap_state,
    input  wire [3:0]  IR,
    input  wire [7:0]  func_in,
    output reg  [7:0]  wrapper_out,
    output wire        wrapper_tdo
);

parameter SHIFT_DR = 4'd4;
parameter CAPTURE_DR = 4'd3;
parameter UPDATE_DR = 4'd8;
parameter EXTEST = 4'h0;

reg [7:0] wrapper_shift;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        wrapper_out <= 8'h00;
        wrapper_shift <= 8'h00;
    end else begin
        if (IR == EXTEST) begin
            case (tap_state)
                CAPTURE_DR: wrapper_shift <= func_in;
                SHIFT_DR: wrapper_shift <= {TDI, wrapper_shift[7:1]};
                UPDATE_DR: wrapper_out <= wrapper_shift;
            endcase
        end
    end
end

assign wrapper_tdo = wrapper_shift[0];

endmodule

