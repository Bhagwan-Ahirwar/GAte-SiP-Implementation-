`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 05:45:07 PM
// Design Name: 
// Module Name: ro_puf_16bit
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


module ro_puf_16bit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] challenge,        // 16-BIT CHALLENGE INPUT
    input  wire [3:0]  activation,       // 4-BIT ACTIVATION INPUT
    input  wire        generated,
    output reg  [15:0] puf_response,     // 16-BIT RESPONSE OUTPUT
    output reg         puf_ready
);

wire ro1_out, ro2_out;
reg ro1_enable, ro2_enable;
reg [15:0] count_max;

ring_oscillator ro1 (.enable(ro1_enable), .osc_out(ro1_out));
ring_oscillator ro2 (.enable(ro2_enable), .osc_out(ro2_out));

wire [15:0] ro1_count, ro2_count;
wire ro1_done, ro2_done;

frequency_counter fc1 (
    .clk(clk), .rst_n(rst_n),
    .osc_in(ro1_out), .start(ro1_enable),
    .count_max(count_max),
    .count_out(ro1_count), .count_done(ro1_done)
);

frequency_counter fc2 (
    .clk(clk), .rst_n(rst_n),
    .osc_in(ro2_out), .start(ro2_enable),
    .count_max(count_max),
    .count_out(ro2_count), .count_done(ro2_done)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ro1_enable <= 1'b0;
        ro2_enable <= 1'b0;
        count_max <= 16'd1000;
        puf_response <= 16'd0;
        puf_ready <= 1'b0;
    end else begin
        ro1_enable <= (activation[0] & generated);  // Bit 0: RO1 enable
        ro2_enable <= (activation[1] & generated);  // Bit 1: RO2 enable
        
        if (challenge[15:8] != 0)
            count_max <= challenge[15:8] * 16'd4;
        else
            count_max <= 16'd1000;
        
        if (generated) begin
            if (ro1_done && ro2_done) begin
                puf_response <= (ro1_count > ro2_count) ? 
                               (ro1_count - ro2_count) : 
                               (ro2_count - ro1_count);
                puf_ready <= 1'b1;
                ro1_enable <= 1'b0;
                ro2_enable <= 1'b0;
            end
        end else begin
            ro1_enable <= 1'b0;
            ro2_enable <= 1'b0;
            puf_ready <= 1'b0;
        end
    end
end

endmodule

