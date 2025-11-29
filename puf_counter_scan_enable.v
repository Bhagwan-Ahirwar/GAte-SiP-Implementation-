`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:21:02 PM
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


//===========================================================================
// PUF Counter with Scan Enable Control
//===========================================================================
module puf_counter_scan_enable (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [15:0] target_count,
    output reg  [15:0] counter,
    output reg         scan_enable,
    output reg         count_done
);

reg counting;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 16'd0;
        scan_enable <= 1'b0;
        count_done <= 1'b0;
        counting <= 1'b0;
    end else begin
        if (start && !counting) begin
            counter <= 16'd0;
            counting <= 1'b1;
            scan_enable <= 1'b1;
            count_done <= 1'b0;
        end else if (counting) begin
            if (counter < target_count) begin
                counter <= counter + 1'b1;
                scan_enable <= 1'b1;
            end else begin
                count_done <= 1'b1;
                scan_enable <= 1'b0;
                counting <= 1'b0;
            end
        end else begin
            scan_enable <= 1'b0;
            count_done <= 1'b0;
        end
    end
end

endmodule

