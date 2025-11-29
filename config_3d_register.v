`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:11:09 PM
// Design Name: 
// Module Name: config_3d_register
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
// 3D Configuration Register (3DCR)
//===========================================================================
module config_3d_register (
    input  wire       TCK,
    input  wire       TRST_N,
    input  wire       TDI,
    input  wire [3:0] tap_state,
    input  wire [3:0] IR,
    output reg  [7:0] config_reg,
    output wire       config_tdo
);

parameter CAPTURE_DR = 4'b0110;
parameter SHIFT_DR   = 4'b0010;
parameter UPDATE_DR  = 4'b0101;
parameter TAPCONFIG = 4'b0011;

reg [7:0] config_shift;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        config_reg <= 8'b00000001;
        config_shift <= 8'b0;
    end else begin
        if (IR == TAPCONFIG) begin
            case (tap_state)
                CAPTURE_DR: config_shift <= config_reg;
                SHIFT_DR:   config_shift <= {TDI, config_shift[7:1]};
                UPDATE_DR:  config_reg <= config_shift;
            endcase
        end
    end
end

assign config_tdo = config_shift[0];

endmodule

