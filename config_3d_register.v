`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:39:12 PM
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


module config_3d_register (
    input  wire        TCK,
    input  wire        TRST_N,
    input  wire        TDI,
    input  wire [3:0]  tap_state,
    input  wire [3:0]  IR,
    output reg  [7:0]  config_reg,
    output wire        config_tdo
);

parameter SHIFT_DR = 4'd4;
parameter CAPTURE_DR = 4'd3;
parameter UPDATE_DR = 4'd8;
parameter CONFIG_3D = 4'h3;

reg [7:0] config_shift;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        config_reg <= 8'h00;
        config_shift <= 8'h00;
    end else begin
        if (IR == CONFIG_3D) begin
            case (tap_state)
                CAPTURE_DR: config_shift <= config_reg;
                SHIFT_DR: config_shift <= {TDI, config_shift[7:1]};
                UPDATE_DR: config_reg <= config_shift;
            endcase
        end
    end
end

assign config_tdo = config_shift[0];

endmodule
