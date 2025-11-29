`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:37:07 PM
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


module tap_controller (
    input  wire        TCK,
    input  wire        TMS,
    input  wire        TRST_N,
    output reg  [3:0]  tap_state
);

parameter TEST_LOGIC_RESET    = 4'd0;
parameter RUN_TEST_IDLE       = 4'd1;
parameter SELECT_DR_SCAN      = 4'd2;
parameter CAPTURE_DR          = 4'd3;
parameter SHIFT_DR            = 4'd4;
parameter EXIT1_DR            = 4'd5;
parameter PAUSE_DR            = 4'd6;
parameter EXIT2_DR            = 4'd7;
parameter UPDATE_DR           = 4'd8;
parameter SELECT_IR_SCAN      = 4'd9;
parameter CAPTURE_IR          = 4'd10;
parameter SHIFT_IR            = 4'd11;
parameter EXIT1_IR            = 4'd12;
parameter PAUSE_IR            = 4'd13;
parameter EXIT2_IR            = 4'd14;
parameter UPDATE_IR           = 4'd15;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        tap_state <= TEST_LOGIC_RESET;
    end else begin
        case (tap_state)
            TEST_LOGIC_RESET: tap_state <= (TMS) ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
            RUN_TEST_IDLE:    tap_state <= (TMS) ? SELECT_DR_SCAN : RUN_TEST_IDLE;
            SELECT_DR_SCAN:   tap_state <= (TMS) ? SELECT_IR_SCAN : CAPTURE_DR;
            CAPTURE_DR:       tap_state <= (TMS) ? EXIT1_DR : SHIFT_DR;
            SHIFT_DR:         tap_state <= (TMS) ? EXIT1_DR : SHIFT_DR;
            EXIT1_DR:         tap_state <= (TMS) ? UPDATE_DR : PAUSE_DR;
            PAUSE_DR:         tap_state <= (TMS) ? EXIT2_DR : PAUSE_DR;
            EXIT2_DR:         tap_state <= (TMS) ? UPDATE_DR : SHIFT_DR;
            UPDATE_DR:        tap_state <= (TMS) ? SELECT_DR_SCAN : RUN_TEST_IDLE;
            SELECT_IR_SCAN:   tap_state <= (TMS) ? TEST_LOGIC_RESET : CAPTURE_IR;
            CAPTURE_IR:       tap_state <= (TMS) ? EXIT1_IR : SHIFT_IR;
            SHIFT_IR:         tap_state <= (TMS) ? EXIT1_IR : SHIFT_IR;
            EXIT1_IR:         tap_state <= (TMS) ? UPDATE_IR : PAUSE_IR;
            PAUSE_IR:         tap_state <= (TMS) ? EXIT2_IR : PAUSE_IR;
            EXIT2_IR:         tap_state <= (TMS) ? UPDATE_IR : SHIFT_IR;
            UPDATE_IR:        tap_state <= (TMS) ? SELECT_DR_SCAN : RUN_TEST_IDLE;
            default:          tap_state <= TEST_LOGIC_RESET;
        endcase
    end
end

endmodule
