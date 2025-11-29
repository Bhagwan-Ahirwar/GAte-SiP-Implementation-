`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:20:09 PM
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


//===========================================================================
// PUF Response to Number Converter
//===========================================================================
module puf_response_to_number (
    input  wire [15:0] puf_response,
    output reg  [15:0] response_number
);

always @(*) begin
    response_number = puf_response;
end

endmodule

