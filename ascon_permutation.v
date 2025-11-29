`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:14:20 PM
// Design Name: 
// Module Name: ascon_permutation
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
// Ascon Permutation Module
//===========================================================================
module ascon_permutation (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [4:0]  rounds,
    input  wire [319:0] state_in,
    output reg  [319:0] state_out,
    output reg         done
);

reg [63:0] x0, x1, x2, x3, x4;
reg [4:0] round_counter;
reg [1:0] perm_state;

wire [63:0] round_constant;
assign round_constant = {56'h00, 8'hF0 - {3'b000, round_counter}};

parameter IDLE = 2'b00;
parameter PERM = 2'b01;
parameter DONE = 2'b10;

function [4:0] sbox;
    input [4:0] in;
    reg [4:0] t;
    begin
        t[0] = in[4] ^ in[3] ^ in[2] ^ in[1] ^ in[0];
        t[1] = in[4] ^ in[2];
        t[2] = in[4] ^ in[3] ^ in[1];
        t[3] = in[4] ^ in[0];
        t[4] = in[3] ^ in[2];
        
        sbox[0] = t[0] ^ (~t[1] & t[2]);
        sbox[1] = t[1] ^ (~t[2] & t[3]);
        sbox[2] = t[2] ^ (~t[3] & t[4]);
        sbox[3] = t[3] ^ (~t[4] & t[0]);
        sbox[4] = t[4] ^ (~t[0] & t[1]);
    end
endfunction

function [63:0] linear_x0;
    input [63:0] x;
    begin
        linear_x0 = x ^ ({x[18:0], x[63:19]}) ^ ({x[27:0], x[63:28]});
    end
endfunction

function [63:0] linear_x1;
    input [63:0] x;
    begin
        linear_x1 = x ^ ({x[60:0], x[63:61]}) ^ ({x[38:0], x[63:39]});
    end
endfunction

function [63:0] linear_x2;
    input [63:0] x;
    begin
        linear_x2 = x ^ ({x[0], x[63:1]}) ^ ({x[5:0], x[63:6]});
    end
endfunction

function [63:0] linear_x3;
    input [63:0] x;
    begin
        linear_x3 = x ^ ({x[9:0], x[63:10]}) ^ ({x[16:0], x[63:17]});
    end
endfunction

function [63:0] linear_x4;
    input [63:0] x;
    begin
        linear_x4 = x ^ ({x[6:0], x[63:7]}) ^ ({x[40:0], x[63:41]});
    end
endfunction

task apply_sbox;
    integer i;
    reg [4:0] slice_in, slice_out;
    begin
        for (i = 0; i < 64; i = i + 1) begin
            slice_in = {x4[i], x3[i], x2[i], x1[i], x0[i]};
            slice_out = sbox(slice_in);
            {x4[i], x3[i], x2[i], x1[i], x0[i]} = slice_out;
        end
    end
endtask

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        perm_state <= IDLE;
        round_counter <= 5'd0;
        done <= 1'b0;
        x0 <= 64'd0;
        x1 <= 64'd0;
        x2 <= 64'd0;
        x3 <= 64'd0;
        x4 <= 64'd0;
    end else begin
        case (perm_state)
            IDLE: begin
                done <= 1'b0;
                if (start) begin
                    x0 <= state_in[63:0];
                    x1 <= state_in[127:64];
                    x2 <= state_in[191:128];
                    x3 <= state_in[255:192];
                    x4 <= state_in[319:256];
                    round_counter <= 5'd0;
                    perm_state <= PERM;
                end
            end
            
            PERM: begin
                x2 <= x2 ^ round_constant;
                apply_sbox();
                x0 <= linear_x0(x0);
                x1 <= linear_x1(x1);
                x2 <= linear_x2(x2);
                x3 <= linear_x3(x3);
                x4 <= linear_x4(x4);
                round_counter <= round_counter + 1'b1;
                
                if (round_counter == rounds - 1) begin
                    perm_state <= DONE;
                end
            end
            
            DONE: begin
                state_out <= {x4, x3, x2, x1, x0};
                done <= 1'b1;
                perm_state <= IDLE;
            end
            
            default: perm_state <= IDLE;
        endcase
    end
end

endmodule

