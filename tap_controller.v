`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:09:41 PM
// Design Name: 
// Module Name: tap_controller
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
// TAP Controller Module - IEEE 1149.1 Standard
//===========================================================================
module tap_controller (
    input  wire       TCK,
    input  wire       TMS,
    input  wire       TRST_N,
    output reg  [3:0] tap_state
);

parameter TEST_LOGIC_RESET = 4'b1111;
parameter RUN_TEST_IDLE    = 4'b1100;
parameter SELECT_DR_SCAN   = 4'b0111;
parameter CAPTURE_DR       = 4'b0110;
parameter SHIFT_DR         = 4'b0010;
parameter EXIT1_DR         = 4'b0001;
parameter PAUSE_DR         = 4'b0011;
parameter EXIT2_DR         = 4'b0000;
parameter UPDATE_DR        = 4'b0101;
parameter SELECT_IR_SCAN   = 4'b0100;
parameter CAPTURE_IR       = 4'b1110;
parameter SHIFT_IR         = 4'b1010;
parameter EXIT1_IR         = 4'b1001;
parameter PAUSE_IR         = 4'b1011;
parameter EXIT2_IR         = 4'b1000;
parameter UPDATE_IR        = 4'b1101;

reg [3:0] next_tap_state;

always @(*) begin
    case (tap_state)
        TEST_LOGIC_RESET: next_tap_state = TMS ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
        RUN_TEST_IDLE:    next_tap_state = TMS ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
        SELECT_DR_SCAN:   next_tap_state = TMS ? SELECT_IR_SCAN   : CAPTURE_DR;
        CAPTURE_DR:       next_tap_state = TMS ? EXIT1_DR         : SHIFT_DR;
        SHIFT_DR:         next_tap_state = TMS ? EXIT1_DR         : SHIFT_DR;
        EXIT1_DR:         next_tap_state = TMS ? UPDATE_DR        : PAUSE_DR;
        PAUSE_DR:         next_tap_state = TMS ? EXIT2_DR         : PAUSE_DR;
        EXIT2_DR:         next_tap_state = TMS ? UPDATE_DR        : SHIFT_DR;
        UPDATE_DR:        next_tap_state = TMS ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
        SELECT_IR_SCAN:   next_tap_state = TMS ? TEST_LOGIC_RESET : CAPTURE_IR;
        CAPTURE_IR:       next_tap_state = TMS ? EXIT1_IR         : SHIFT_IR;
        SHIFT_IR:         next_tap_state = TMS ? EXIT1_IR         : SHIFT_IR;
        EXIT1_IR:         next_tap_state = TMS ? UPDATE_IR        : PAUSE_IR;
        PAUSE_IR:         next_tap_state = TMS ? EXIT2_IR         : PAUSE_IR;
        EXIT2_IR:         next_tap_state = TMS ? UPDATE_IR        : SHIFT_IR;
        UPDATE_IR:        next_tap_state = TMS ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
        default:          next_tap_state = TEST_LOGIC_RESET;
    endcase
end

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N)
        tap_state <= TEST_LOGIC_RESET;
    else
        tap_state <= next_tap_state;
end

endmodule
