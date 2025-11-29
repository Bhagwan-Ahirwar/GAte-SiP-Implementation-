`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:23:00 PM
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


//===========================================================================
// PUF to Ascon Key Derivation
//===========================================================================
module puf_to_ascon_key (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [15:0] puf_response,
    output reg  [127:0] ascon_key,
    output reg         done
);

reg [3:0] state;
reg [3:0] round;
reg [127:0] temp_key;

parameter IDLE = 4'd0;
parameter INIT = 4'd1;
parameter MIX  = 4'd2;
parameter DONE_ST = 4'd3;

parameter [15:0] MIX_CONST_0 = 16'hA5C3;
parameter [15:0] MIX_CONST_1 = 16'h5A3C;
parameter [15:0] MIX_CONST_2 = 16'h3CA5;
parameter [15:0] MIX_CONST_3 = 16'hC35A;
parameter [15:0] MIX_CONST_4 = 16'h6969;
parameter [15:0] MIX_CONST_5 = 16'h9696;
parameter [15:0] MIX_CONST_6 = 16'hB4D2;
parameter [15:0] MIX_CONST_7 = 16'hD2B4;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        ascon_key <= 128'd0;
        temp_key <= 128'd0;
        done <= 1'b0;
        round <= 4'd0;
    end else begin
        case (state)
            IDLE: begin
                done <= 1'b0;
                if (start) begin
                    state <= INIT;
                    round <= 4'd0;
                    temp_key <= 128'd0;
                end
            end
            
            INIT: begin
                temp_key[15:0]    <= puf_response;
                temp_key[31:16]   <= puf_response ^ MIX_CONST_0;
                temp_key[47:32]   <= {puf_response[7:0], puf_response[15:8]} ^ MIX_CONST_1;
                temp_key[63:48]   <= ~puf_response ^ MIX_CONST_2;
                temp_key[79:64]   <= {puf_response[0], puf_response[15:1]} ^ MIX_CONST_3;
                temp_key[95:80]   <= puf_response ^ MIX_CONST_4;
                temp_key[111:96]  <= {puf_response[8:0], puf_response[15:9]} ^ MIX_CONST_5;
                temp_key[127:112] <= {puf_response[11:0], puf_response[15:12]} ^ MIX_CONST_6;
                state <= MIX;
            end
            
            MIX: begin
                case (round)
                    4'd0: temp_key <= {temp_key[126:0], temp_key[127]} ^ {puf_response, puf_response, puf_response, puf_response, puf_response, puf_response, puf_response, puf_response};
                    4'd1: temp_key <= {temp_key[119:0], temp_key[127:120]} ^ {MIX_CONST_7, temp_key[111:0]};
                    4'd2: temp_key <= temp_key ^ {temp_key[63:0], temp_key[127:64]};
                    4'd3: temp_key <= {temp_key[95:0], temp_key[127:96]} ^ {puf_response, temp_key[111:0]};
                    4'd4: temp_key <= temp_key ^ {~temp_key[31:0], temp_key[95:0]};
                    default: temp_key <= temp_key;
                endcase
                
                round <= round + 1'b1;
                if (round == 4'd4) begin
                    ascon_key <= temp_key;
                    state <= DONE_ST;
                end
            end
            
            DONE_ST: begin
                done <= 1'b1;
                if (!start) state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule

