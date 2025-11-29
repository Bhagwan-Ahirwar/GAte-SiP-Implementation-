`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:55:10 PM
// Design Name: 
// Module Name: db_crp_manager
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


module db_crp_manager(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] chiplet_id,
    input  wire [3:0]  query_type,
    output reg  [15:0] challenge,           // 16-BIT CHALLENGE OUTPUT
    output reg  [3:0]  puf_activation,      // 4-BIT ACTIVATION OUTPUT
    output reg  [127:0] auth_stimuli,
    output reg  [15:0] response,            // 16-BIT RESPONSE OUTPUT
    output reg         data_valid
);

parameter NUM_CHIPLETS = 4;

reg [31:0] db_chiplet_id [0:NUM_CHIPLETS-1];
reg [15:0] db_challenge [0:NUM_CHIPLETS-1];
reg [3:0]  db_activation [0:NUM_CHIPLETS-1];
reg [15:0] db_response [0:NUM_CHIPLETS-1];
reg [127:0] db_auth_stim [0:NUM_CHIPLETS-1];

initial begin
    db_chiplet_id[0] = 32'h00007f6d;
    db_challenge[0] = 16'h1433;
    db_activation[0] = 4'h9;
    db_response[0] = 16'h02BE;
    db_auth_stim[0] = 128'h011101111011101110111011101110;
    
    db_chiplet_id[1] = 32'h0000e09a;
    db_challenge[1] = 16'h1433;
    db_activation[1] = 4'h9;
    db_response[1] = 16'h02ED;
    db_auth_stim[1] = 128'h010101010101010101010101010101;
    
    db_chiplet_id[2] = 32'h0000bd1a;
    db_challenge[2] = 16'h1433;
    db_activation[2] = 4'h9;
    db_response[2] = 16'h11B9;
    db_auth_stim[2] = 128'h011110001111000111100011110000;
    
    db_chiplet_id[3] = 32'h000081ab;
    db_challenge[3] = 16'h1433;
    db_activation[3] = 4'h9;
    db_response[3] = 16'h0FA0;
    db_auth_stim[3] = 128'h001010100010101000101010001010;
end

integer i, found_idx;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        challenge <= 16'h0;
        puf_activation <= 4'h0;
        response <= 16'h0;
        data_valid <= 1'b0;
    end else begin
        found_idx = -1;
        for (i = 0; i < NUM_CHIPLETS; i = i + 1) begin
            if (db_chiplet_id[i] == chiplet_id) begin
                found_idx = i;
            end
        end
        
        if (found_idx >= 0) begin
            data_valid <= 1'b1;
            case (query_type)
                4'd0: challenge <= db_challenge[found_idx];
                4'd1: puf_activation <= db_activation[found_idx];
                4'd2: response <= db_response[found_idx];
                4'd3: auth_stimuli <= db_auth_stim[found_idx];
                default: data_valid <= 1'b0;
            endcase
        end else begin
            data_valid <= 1'b0;
        end
    end
end

endmodule

