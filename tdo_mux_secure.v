`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:26:22 PM
// Design Name: 
// Module Name: tdo_mux_secure
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
// TDO Multiplexer
//===========================================================================
module tdo_mux_secure (
    input  wire [3:0] tap_state,
    input  wire [3:0] IR,
    input  wire       ir_tdo,
    input  wire       bypass_tdo,
    input  wire       idcode_tdo,
    input  wire       config_tdo,
    input  wire       wrapper_tdo,
    input  wire       puf_tdo,
    input  wire       sec_cfg_tdo,
    output reg        TDO
);

parameter SHIFT_IR = 4'b1010;
parameter SHIFT_DR = 4'b0010;
parameter BYPASS     = 4'b1111;
parameter IDCODE     = 4'b0001;
parameter EXTEST     = 4'b0000;
parameter INTEST     = 4'b0010;
parameter TAPCONFIG  = 4'b0011;
parameter SAMPLE     = 4'b0100;
parameter PUF_AUTH      = 4'b0110;
parameter SEC_CONFIG_ENC = 4'b0111;
parameter SEC_CONFIG_DEC = 4'b1000;

always @(*) begin
    case (tap_state)
        SHIFT_IR: TDO = ir_tdo;
        SHIFT_DR: begin
            case (IR)
                BYPASS:     TDO = bypass_tdo;
                IDCODE:     TDO = idcode_tdo;
                TAPCONFIG:  TDO = config_tdo;
                EXTEST:     TDO = wrapper_tdo;
                INTEST:     TDO = wrapper_tdo;
                SAMPLE:     TDO = wrapper_tdo;
                PUF_AUTH:      TDO = puf_tdo;
                SEC_CONFIG_ENC: TDO = sec_cfg_tdo;
                SEC_CONFIG_DEC: TDO = sec_cfg_tdo;
                default:    TDO = 1'b0;
            endcase
        end
        default: TDO = 1'bZ;
    endcase
end

endmodule

