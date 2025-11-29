`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:10:28 PM
// Design Name: 
// Module Name: instruction_register
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
// Instruction Register Module (Extended)
//===========================================================================
module instruction_register (
    input  wire       TCK,
    input  wire       TRST_N,
    input  wire       TDI,
    input  wire [3:0] tap_state,
    output reg  [3:0] IR,
    output wire       IR_tdo
);

parameter CAPTURE_IR = 4'b1110;
parameter SHIFT_IR   = 4'b1010;
parameter UPDATE_IR  = 4'b1101;

parameter BYPASS     = 4'b1111;
parameter IDCODE     = 4'b0001;
parameter EXTEST     = 4'b0000;
parameter INTEST     = 4'b0010;
parameter TAPCONFIG  = 4'b0011;
parameter SAMPLE     = 4'b0100;
parameter PUF_AUTH      = 4'b0110;
parameter SEC_CONFIG_ENC = 4'b0111;
parameter SEC_CONFIG_DEC = 4'b1000;

reg [3:0] IR_shift;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        IR <= IDCODE;
        IR_shift <= 4'b0000;
    end else begin
        case (tap_state)
            CAPTURE_IR: IR_shift <= 4'b0101;
            SHIFT_IR:   IR_shift <= {TDI, IR_shift[3:1]};
            UPDATE_IR:  IR <= IR_shift;
            default:    IR_shift <= IR_shift;
        endcase
    end
end

assign IR_tdo = IR_shift[0];

endmodule

