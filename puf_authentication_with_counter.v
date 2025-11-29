`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:19:27 PM
// Design Name: 
// Module Name: puf_authentication_with_counter
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
// PUF Authentication with Counter Control
//===========================================================================
module puf_authentication_with_counter (
    input  wire        TCK,
    input  wire        TRST_N,
    input  wire        TDI,
    input  wire [3:0]  tap_state,
    input  wire [3:0]  IR,
    output wire [4:0]  puf_challenge,
    output wire        puf_generate,
    input  wire [15:0] puf_response,
    input  wire        puf_ready,
    output wire        puf_tdo,
    output wire        counter_start,
    output wire [15:0] puf_number,
    input  wire [15:0] current_count,
    input  wire        scan_enable,
    input  wire        count_done
);

parameter CAPTURE_DR = 4'b0110;
parameter SHIFT_DR   = 4'b0010;
parameter UPDATE_DR  = 4'b0101;
parameter PUF_AUTH = 4'b0110;

reg [4:0] challenge_reg;
reg [4:0] challenge_shift;
reg [15:0] response_shift;
reg puf_trigger;
reg counter_trigger;

puf_response_to_number converter (
    .puf_response(puf_response),
    .response_number(puf_number)
);

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        challenge_reg <= 5'd0;
        challenge_shift <= 5'd0;
        response_shift <= 16'd0;
        puf_trigger <= 1'b0;
        counter_trigger <= 1'b0;
    end else begin
        puf_trigger <= 1'b0;
        counter_trigger <= 1'b0;
        
        if (IR == PUF_AUTH) begin
            case (tap_state)
                CAPTURE_DR: begin
                    if (puf_ready) begin
                        response_shift <= puf_response;
                    end else begin
                        response_shift <= 16'hDEAD;
                    end
                end
                
                SHIFT_DR: begin
                    challenge_shift <= {TDI, challenge_shift[4:1]};
                    response_shift <= {TDI, response_shift[15:1]};
                end
                
                UPDATE_DR: begin
                    challenge_reg <= challenge_shift;
                    puf_trigger <= 1'b1;
                    if (puf_ready) begin
                        counter_trigger <= 1'b1;
                    end
                end
            endcase
        end
    end
end

assign puf_challenge = challenge_reg;
assign puf_generate = puf_trigger;
assign counter_start = counter_trigger;
assign puf_tdo = response_shift[0];

endmodule

