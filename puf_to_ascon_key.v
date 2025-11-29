`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:53:12 PM
// Design Name: 
// Module Name: puf_to_ascon_key
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


module puf_to_ascon_key (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] puf_response,     // 16-BIT RESPONSE INPUT
    input  wire        start,
    output reg  [127:0] ascon_key,
    output reg         key_ready
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ascon_key <= 128'h0;
        key_ready <= 1'b0;
    end else begin
        if (start) begin
            ascon_key <= {puf_response, puf_response, puf_response, puf_response,
                         puf_response, puf_response, puf_response, puf_response};
            key_ready <= 1'b1;
        end else begin
            key_ready <= 1'b0;
        end
    end
end

endmodule

