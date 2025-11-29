`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:17:52 PM
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


//===========================================================================
// Frequency Counter
//===========================================================================
module frequency_counter #(
    parameter COUNT_WIDTH = 16
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    enable,
    input  wire                    ro_signal,
    output reg [COUNT_WIDTH-1:0]   count
);

reg ro_signal_d1, ro_signal_d2;
wire rising_edge;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ro_signal_d1 <= 1'b0;
        ro_signal_d2 <= 1'b0;
    end else begin
        ro_signal_d1 <= ro_signal;
        ro_signal_d2 <= ro_signal_d1;
    end
end

assign rising_edge = ro_signal_d1 & ~ro_signal_d2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= {COUNT_WIDTH{1'b0}};
    end else if (!enable) begin
        count <= {COUNT_WIDTH{1'b0}};
    end else if (rising_edge) begin
        count <= count + 1'b1;
    end
end

endmodule

