`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:52:13 PM
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


module puf_counter_integration (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        puf_generate,
    input  wire [15:0] puf_challenge,       // 16-BIT CHALLENGE
    input  wire [3:0]  puf_activation_ctrl, // 4-BIT ACTIVATION
    output wire [15:0] puf_response,        // 16-BIT RESPONSE
    output wire        puf_ready,
    input  wire        counter_start,
    output wire [15:0] puf_number,
    output wire [15:0] current_count,
    output wire        scan_enable,
    output wire        count_done
);

ro_puf_16bit puf ( 
    .clk(clk), .rst_n(rst_n),
    .challenge(puf_challenge),              // 16-bit challenge
    .activation(puf_activation_ctrl),       // 4-bit activation
    .generated(puf_generate),
    .puf_response(puf_response),            // 16-bit response
    .puf_ready(puf_ready)
);

puf_response_to_number conv (
    .clk(clk), .rst_n(rst_n),
    .puf_response(puf_response),            // 16-bit input
    .convert(puf_ready),
    .n_auth(puf_number),                    // 16-bit output
    .conversion_done(count_done)
);

puf_counter_scan_enable counter (
    .clk(clk), .rst_n(rst_n),
    .n_auth(puf_number),
    .l_scan(16'd256),
    .counter_start(counter_start),
    .se_signal(scan_enable),
    .current_count(current_count)
);

endmodule

