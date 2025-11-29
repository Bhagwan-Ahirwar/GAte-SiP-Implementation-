`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:12:21 PM
// Design Name: 
// Module Name: idcode_register
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
// IDCODE Register
//===========================================================================
module idcode_register (
    input  wire        TCK,
    input  wire        TRST_N,
    input  wire        TDI,
    input  wire [3:0]  tap_state,
    input  wire [3:0]  IR,
    input  wire [31:0] die_id,
    output wire        idcode_tdo
);

parameter CAPTURE_DR = 4'b0110;
parameter SHIFT_DR   = 4'b0010;
parameter IDCODE = 4'b0001;

reg [31:0] idcode_shift;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        idcode_shift <= 32'b0;
    end else begin
        if (IR == IDCODE) begin
            case (tap_state)
                CAPTURE_DR: idcode_shift <= die_id;
                SHIFT_DR:   idcode_shift <= {TDI, idcode_shift[31:1]};
            endcase
        end
    end
end

assign idcode_tdo = idcode_shift[0];

endmodule

