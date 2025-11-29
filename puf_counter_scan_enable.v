`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:51:18 PM
// Design Name: 
// Module Name: puf_counter_scan_enable
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


module puf_counter_scan_enable (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] n_auth,           // 16-BIT N_AUTH
    input  wire [15:0] l_scan,
    input  wire        counter_start,
    output reg         se_signal,
    output reg  [15:0] current_count
);

reg [15:0] auth_cycle_counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        se_signal <= 1'b1;
        auth_cycle_counter <= 16'd0;
        current_count <= 16'd0;
    end else begin
        if (counter_start) begin
            if (auth_cycle_counter < n_auth) begin
                se_signal <= 1'b1;
            end else if (auth_cycle_counter < (n_auth + l_scan)) begin
                se_signal <= 1'b0;
            end else begin
                se_signal <= 1'b1;
            end
            
            auth_cycle_counter <= auth_cycle_counter + 1'b1;
            current_count <= auth_cycle_counter;
        end else begin
            se_signal <= 1'b1;
            auth_cycle_counter <= 16'd0;
            current_count <= 16'd0;
        end
    end
end

endmodule

