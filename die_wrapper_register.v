`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:11:46 PM
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


//===========================================================================
// Die Wrapper Register (DWR)
//===========================================================================
module die_wrapper_register (
    input  wire       TCK,
    input  wire       TRST_N,
    input  wire       TDI,
    input  wire [3:0] tap_state,
    input  wire [3:0] IR,
    input  wire [7:0] func_in,
    output reg  [7:0] wrapper_out,
    output wire       wrapper_tdo
);

parameter CAPTURE_DR = 4'b0110;
parameter SHIFT_DR   = 4'b0010;
parameter UPDATE_DR  = 4'b0101;
parameter EXTEST = 4'b0000;
parameter INTEST = 4'b0010;
parameter SAMPLE = 4'b0100;

reg [7:0] wrapper_cells_in;
reg [7:0] wrapper_shift;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        wrapper_cells_in <= 8'b0;
        wrapper_out <= 8'b0;
        wrapper_shift <= 8'b0;
    end else begin
        if (IR == EXTEST || IR == INTEST || IR == SAMPLE) begin
            case (tap_state)
                CAPTURE_DR: begin
                    if (IR == EXTEST)
                        wrapper_shift <= wrapper_cells_in;
                    else if (IR == SAMPLE)
                        wrapper_shift <= func_in;
                    else
                        wrapper_shift <= func_in;
                end
                SHIFT_DR: wrapper_shift <= {TDI, wrapper_shift[7:1]};
                UPDATE_DR: begin
                    if (IR == EXTEST || IR == INTEST)
                        wrapper_out <= wrapper_shift;
                end
            endcase
        end
    end
end

assign wrapper_tdo = wrapper_shift[0];

endmodule

