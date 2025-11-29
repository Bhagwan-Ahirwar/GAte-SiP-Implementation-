`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:38:22 PM
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


module instruction_register (
    input  wire        TCK,
    input  wire        TRST_N,
    input  wire        TDI,
    input  wire [3:0]  tap_state,
    output reg  [3:0]  IR,
    output wire        IR_tdo
);

parameter SHIFT_IR = 4'd11;
parameter CAPTURE_IR = 4'd10;
parameter UPDATE_IR = 4'd15;

reg [3:0] ir_shift;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        IR <= 4'hF;
        ir_shift <= 4'hF;
    end else begin
        case (tap_state)
            CAPTURE_IR: ir_shift <= {2'b01, IR[3:2]};
            SHIFT_IR: ir_shift <= {TDI, ir_shift[3:1]};
            UPDATE_IR: IR <= ir_shift;
        endcase
    end
end

assign IR_tdo = ir_shift[0];

endmodule


