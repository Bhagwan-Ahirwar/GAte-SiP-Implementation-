`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:22:00 PM
// Design Name: 
// Module Name: puf_counter_integration
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
// PUF with Counter Integration
//===========================================================================
module puf_counter_integration (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        puf_generate,
    input  wire [4:0]  puf_challenge,
    output wire [15:0] puf_response,
    output wire        puf_ready,
    input  wire        counter_start,
    output wire [15:0] puf_number,
    output wire [15:0] current_count,
    output wire        scan_enable,
    output wire        count_done
);

wire puf_enable;
wire puf_valid;

ro_puf_16bit puf_core (
    .clk(clk),
    .rst_n(rst_n),
    .enable(puf_enable),
    .challenge(puf_challenge),
    .response(puf_response),
    .response_valid(puf_valid)
);

assign puf_enable = puf_generate;
assign puf_ready = puf_valid;

puf_response_to_number converter (
    .puf_response(puf_response),
    .response_number(puf_number)
);

puf_counter_scan_enable counter (
    .clk(clk),
    .rst_n(rst_n),
    .start(counter_start),
    .target_count(puf_number),
    .counter(current_count),
    .scan_enable(scan_enable),
    .count_done(count_done)
);

endmodule

