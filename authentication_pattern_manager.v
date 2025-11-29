`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:55:52 PM
// Design Name: 
// Module Name: authentication_pattern_manager
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

module authentication_pattern_manager (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        auth_start,
    input  wire [15:0] n_auth,              // 16-BIT N_AUTH
    input  wire [15:0] l_scan,
    input  wire [127:0] auth_stimuli,
    input  wire [127:0] auth_response_expected,
    output reg  [127:0] pattern_out,
    output wire        is_dummy_pattern,
    output wire        is_auth_pattern,
    output wire        scan_enable_ctrl,
    output reg         pattern_valid,
    output reg         response_match,
    output reg         tampering_detected
);

reg [2:0] auth_state;
reg [15:0] cycle_counter;
reg [31:0] lfsr;

parameter IDLE = 3'd0;
parameter INITIAL_DUMMY = 3'd1;
parameter INTERMEDIATE_DUMMY = 3'd2;
parameter AUTH_STIMULI = 3'd3;
parameter RESPONSE_CHECK = 3'd4;

wire lfsr_out = lfsr[0] ^ lfsr[1] ^ lfsr[3] ^ lfsr[4];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lfsr <= 32'hABCD1234;
    end else begin
        lfsr <= {lfsr[30:0], lfsr_out};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        auth_state <= IDLE;
        cycle_counter <= 16'd0;
        pattern_out <= 128'h0;
        pattern_valid <= 1'b0;
        response_match <= 1'b0;
        tampering_detected <= 1'b0;
    end else begin
        case (auth_state)
            IDLE: begin
                pattern_valid <= 1'b0;
                if (auth_start) begin
                    auth_state <= INITIAL_DUMMY;
                    cycle_counter <= 16'd0;
                end
            end
            
            INITIAL_DUMMY: begin
                pattern_out <= {lfsr[31:0], lfsr[31:0], lfsr[31:0], lfsr[31:0]};
                pattern_valid <= 1'b1;
                cycle_counter <= cycle_counter + 1'b1;
                if (cycle_counter >= 16'd9) begin
                    auth_state <= INTERMEDIATE_DUMMY;
                    cycle_counter <= 16'd0;
                end
            end
            
            INTERMEDIATE_DUMMY: begin
                pattern_out <= {lfsr[31:0], lfsr[31:0], lfsr[31:0], lfsr[31:0]};
                pattern_valid <= 1'b1;
                cycle_counter <= cycle_counter + 1'b1;
                if (cycle_counter >= (n_auth - 1)) begin
                    auth_state <= AUTH_STIMULI;
                    cycle_counter <= 16'd0;
                end
            end
            
            AUTH_STIMULI: begin
                pattern_out <= auth_stimuli;
                pattern_valid <= 1'b1;
                cycle_counter <= cycle_counter + 1'b1;
                if (cycle_counter >= (l_scan - 1)) begin
                    auth_state <= RESPONSE_CHECK;
                end
            end
            
            RESPONSE_CHECK: begin
                if (auth_response_expected != 128'h0) begin
                    response_match <= 1'b1;
                    tampering_detected <= 1'b0;
                end else begin
                    response_match <= 1'b0;
                    tampering_detected <= 1'b1;
                end
                auth_state <= IDLE;
            end
        endcase
    end
end

assign is_dummy_pattern = (auth_state == INITIAL_DUMMY) || (auth_state == INTERMEDIATE_DUMMY);
assign is_auth_pattern = (auth_state == AUTH_STIMULI);
assign scan_enable_ctrl = (auth_state == INITIAL_DUMMY || auth_state == INTERMEDIATE_DUMMY) ? 1'b1 : 1'b0;

endmodule

