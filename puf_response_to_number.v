`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:46:52 PM
// Design Name: 
// Module Name: puf_response_to_number
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


module puf_response_to_number (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] puf_response,     // 16-BIT RESPONSE INPUT
    input  wire        convert,
    output reg  [15:0] n_auth,           // 16-BIT N_AUTH OUTPUT
    output reg         conversion_done
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        n_auth <= 16'd0;
        conversion_done <= 1'b0;
    end else begin
        if (convert) begin
            n_auth <= puf_response;
            conversion_done <= 1'b1;
        end else begin
            conversion_done <= 1'b0;
        end
    end
end

endmodule

