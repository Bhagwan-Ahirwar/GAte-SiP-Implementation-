`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:25:35 PM
// Design Name: 
// Module Name: scan_chain_control
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
// Scan Chain Control
//===========================================================================
module scan_chain_control (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        scan_enable,
    input  wire        scan_in,
    output wire        scan_out,
    input  wire [7:0]  func_data_in,
    output wire [7:0]  func_data_out
);

reg [7:0] scan_chain;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scan_chain <= 8'd0;
    end else begin
        if (scan_enable) begin
            scan_chain <= {scan_in, scan_chain[7:1]};
        end else begin
            scan_chain <= func_data_in;
        end
    end
end

assign scan_out = scan_chain[0];
assign func_data_out = scan_chain;

endmodule

