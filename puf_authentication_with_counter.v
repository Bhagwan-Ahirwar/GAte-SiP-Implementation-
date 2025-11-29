`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:50:25 PM
// Design Name: 
// Module Name: puf_authentication_with_counter
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


module puf_authentication_with_counter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] n_auth,           // 16-BIT N_AUTH
    input  wire [15:0] l_scan,
    input  wire        auth_start,
    input  wire [127:0] auth_stimuli,
    input  wire [127:0] auth_response_expected,
    output reg  [127:0] pattern_out,
    output wire        is_dummy,
    output wire        is_auth,
    output wire        se_signal,
    output reg         auth_capture,
    output reg         auth_success,
    output reg         tampering_detected
);

reg [2:0] auth_state;
reg [15:0] cycle_counter;
reg [15:0] bit_counter;

parameter IDLE = 3'd0;
parameter INITIAL_DUMMY = 3'd1;
parameter INTERMEDIATE_DUMMY = 3'd2;
parameter AUTH_STIMULI = 3'd3;
parameter RESPONSE_CHECK = 3'd4;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        auth_state <= IDLE;
        cycle_counter <= 16'd0;
        bit_counter <= 16'd0;
        pattern_out <= 128'h0;
        auth_capture <= 1'b0;
        auth_success <= 1'b0;
        tampering_detected <= 1'b0;
    end else begin
        case (auth_state)
            IDLE: begin
                if (auth_start) begin
                    auth_state <= INITIAL_DUMMY;
                    cycle_counter <= 16'd0;
                end
            end
            
            INITIAL_DUMMY: begin
                pattern_out <= 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
                cycle_counter <= cycle_counter + 1'b1;
                if (cycle_counter >= 16'd10) begin
                    auth_state <= INTERMEDIATE_DUMMY;
                    cycle_counter <= 16'd0;
                end
            end
            
            INTERMEDIATE_DUMMY: begin
                pattern_out <= 128'h55555555555555555555555555555555;
                cycle_counter <= cycle_counter + 1'b1;
                if (cycle_counter >= (n_auth - 1)) begin
                    auth_state <= AUTH_STIMULI;
                    cycle_counter <= 16'd0;
                    bit_counter <= 16'd0;
                end
            end
            
            AUTH_STIMULI: begin
                pattern_out <= auth_stimuli;
                bit_counter <= bit_counter + 1'b1;
                if (bit_counter >= (l_scan - 1)) begin
                    auth_state <= RESPONSE_CHECK;
                    auth_capture <= 1'b1;
                end
            end
            
            RESPONSE_CHECK: begin
                auth_capture <= 1'b0;
                if (auth_response_expected == 128'h0) begin
                    auth_success <= 1'b1;
                end else begin
                    tampering_detected <= 1'b1;
                end
                auth_state <= IDLE;
            end
        endcase
    end
end

assign is_dummy = (auth_state == INITIAL_DUMMY) || (auth_state == INTERMEDIATE_DUMMY);
assign is_auth = (auth_state == AUTH_STIMULI);
assign se_signal = (auth_state == INITIAL_DUMMY || auth_state == INTERMEDIATE_DUMMY) ? 1'b1 : 1'b0;

endmodule

