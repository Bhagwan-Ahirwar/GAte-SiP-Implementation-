`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:44:22 PM
// Design Name: 
// Module Name: frequency_counter
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


module frequency_counter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        osc_in,
    input  wire        start,
    input  wire [15:0] count_max,
    output reg  [15:0] count_out,
    output reg         count_done
);

reg [15:0] time_counter;
reg [15:0] osc_counter;
reg prev_osc;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        time_counter <= 16'd0;
        osc_counter <= 16'd0;
        prev_osc <= 1'b0;
        count_out <= 16'd0;
        count_done <= 1'b0;
    end else begin
        if (start) begin
            if (time_counter < count_max) begin
                if (osc_in && !prev_osc) begin
                    osc_counter <= osc_counter + 1'b1;
                end
                prev_osc <= osc_in;
                time_counter <= time_counter + 1'b1;
                count_done <= 1'b0;
            end else begin
                count_out <= osc_counter;
                count_done <= 1'b1;
            end
        end else begin
            time_counter <= 16'd0;
            osc_counter <= 16'd0;
            prev_osc <= 1'b0;
            count_done <= 1'b0;
        end
    end
end

endmodule

