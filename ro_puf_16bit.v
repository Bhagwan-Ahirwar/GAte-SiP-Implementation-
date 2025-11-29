`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:18:33 PM
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


//===========================================================================
// 16-Bit Ring Oscillator PUF
//===========================================================================
module ro_puf_16bit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,
    input  wire [4:0]  challenge,
    output reg  [15:0] response,
    output reg         response_valid
);

parameter NUM_ROS = 32;
parameter COUNT_WIDTH = 16;
parameter MEASURE_CYCLES = 1000;

wire [NUM_ROS-1:0] ro_outputs;

genvar i;
generate
    for (i = 0; i < NUM_ROS; i = i + 1) begin : ro_array
        ring_oscillator #(
            .NUM_STAGES(7 + (i % 2))
        ) ro_inst (
            .enable(enable),
            .osc_out(ro_outputs[i])
        );
    end
endgenerate

wire [COUNT_WIDTH-1:0] count_a, count_b;
reg [4:0] ro_select_a, ro_select_b;
reg counting_enable;

always @(*) begin
    ro_select_a = challenge;
    ro_select_b = challenge + 5'd16;
end

frequency_counter #(.COUNT_WIDTH(COUNT_WIDTH)) counter_a (
    .clk(clk),
    .rst_n(rst_n),
    .enable(counting_enable),
    .ro_signal(ro_outputs[ro_select_a]),
    .count(count_a)
);

frequency_counter #(.COUNT_WIDTH(COUNT_WIDTH)) counter_b (
    .clk(clk),
    .rst_n(rst_n),
    .enable(counting_enable),
    .ro_signal(ro_outputs[ro_select_b]),
    .count(count_b)
);

reg [2:0] state;
reg [3:0] bit_counter;
reg [15:0] cycle_counter;

parameter IDLE       = 3'b000;
parameter START_MEAS = 3'b001;
parameter MEASURING  = 3'b010;
parameter COMPARE    = 3'b011;
parameter DONE       = 3'b100;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        bit_counter <= 4'd0;
        cycle_counter <= 16'd0;
        response <= 16'd0;
        response_valid <= 1'b0;
        counting_enable <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                response_valid <= 1'b0;
                if (enable) begin
                    state <= START_MEAS;
                    bit_counter <= 4'd0;
                    response <= 16'd0;
                end
            end
            
            START_MEAS: begin
                counting_enable <= 1'b1;
                cycle_counter <= 16'd0;
                state <= MEASURING;
            end
            
            MEASURING: begin
                cycle_counter <= cycle_counter + 1'b1;
                if (cycle_counter >= MEASURE_CYCLES) begin
                    counting_enable <= 1'b0;
                    state <= COMPARE;
                end
            end
            
            COMPARE: begin
                if (count_a > count_b)
                    response[bit_counter] <= 1'b1;
                else
                    response[bit_counter] <= 1'b0;
                
                bit_counter <= bit_counter + 1'b1;
                
                if (bit_counter == 4'd15) begin
                    state <= DONE;
                end else begin
                    state <= START_MEAS;
                end
            end
            
            DONE: begin
                response_valid <= 1'b1;
                if (!enable) state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule

