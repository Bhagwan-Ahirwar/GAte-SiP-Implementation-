`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:56:49 PM
// Design Name: 
// Module Name: tamper_detection_controller
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

module tamper_detection_controller (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        auth_success,
    input  wire        struct_test_fail,
    input  wire        embedded_auth_fail,
    output reg         tamper_flag,
    output reg  [3:0]  attack_type,
    output reg         stop_test,
    output wire        send_dummy_patterns,
    output reg  [7:0]  security_status
);

parameter ATTACK_NONE = 4'd0;
parameter ATTACK_MITM = 4'd1;
parameter ATTACK_TAMPER = 4'd2;

reg [2:0] tamper_state;
reg [7:0] dummy_counter;

parameter IDLE = 3'd0;
parameter CHECK_AUTH = 3'd1;
parameter DETECT_ATTACK = 3'd2;
parameter SEND_DUMMIES = 3'd3;
parameter REPORT = 3'd4;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tamper_state <= IDLE;
        tamper_flag <= 1'b0;
        attack_type <= ATTACK_NONE;
        stop_test <= 1'b0;
        security_status <= 8'hAA;
        dummy_counter <= 8'h0;
    end else begin
        case (tamper_state)
            IDLE: begin
                tamper_flag <= 1'b0;
                attack_type <= ATTACK_NONE;
                stop_test <= 1'b0;
                security_status <= 8'hAA;
                
                if (!auth_success) begin
                    tamper_state <= DETECT_ATTACK;
                    attack_type <= ATTACK_MITM;
                    security_status <= 8'h55;
                end else if (struct_test_fail && embedded_auth_fail) begin
                    tamper_state <= DETECT_ATTACK;
                    attack_type <= ATTACK_TAMPER;
                    security_status <= 8'hCC;
                end
            end
            
            DETECT_ATTACK: begin
                tamper_flag <= 1'b1;
                tamper_state <= SEND_DUMMIES;
                dummy_counter <= 8'h0;
            end
            
            SEND_DUMMIES: begin
                dummy_counter <= dummy_counter + 1'b1;
                if (dummy_counter >= 8'd20) begin
                    tamper_state <= REPORT;
                end
            end
            
            REPORT: begin
                stop_test <= 1'b1;
                tamper_state <= IDLE;
            end
        endcase
    end
end

assign send_dummy_patterns = (tamper_state == SEND_DUMMIES);

endmodule

