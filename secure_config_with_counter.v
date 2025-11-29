`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 07:24:29 PM
// Design Name: 
// Module Name: secure_config_with_counter
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
// Secure Configuration Register with Counter Status
//===========================================================================
module secure_config_with_counter (
    input  wire         TCK,
    input  wire         TRST_N,
    input  wire         TDI,
    input  wire [3:0]   tap_state,
    input  wire [3:0]   IR,
    input  wire [15:0]  puf_number,
    input  wire [15:0]  current_count,
    input  wire         scan_enable,
    input  wire         count_done,
    input  wire [127:0] encrypted_config,
    input  wire [127:0] encryption_tag,
    input  wire [127:0] decrypted_config,
    input  wire         decryption_valid,
    output reg  [127:0] test_config_plain,
    output reg  [127:0] test_config_cipher,
    output reg  [127:0] nonce_enc,
    output reg  [127:0] nonce_dec,
    output reg  [127:0] received_tag,
    output reg          encrypt_start,
    output reg          decrypt_start,
    output wire         sec_cfg_tdo
);

parameter CAPTURE_DR = 4'b0110;
parameter SHIFT_DR   = 4'b0010;
parameter UPDATE_DR  = 4'b0101;
parameter SEC_CONFIG_ENC = 4'b0111;
parameter SEC_CONFIG_DEC = 4'b1000;

reg [511:0] shift_reg;
reg [9:0] bit_counter;

always @(posedge TCK or negedge TRST_N) begin
    if (!TRST_N) begin
        test_config_plain <= 128'd0;
        test_config_cipher <= 128'd0;
        nonce_enc <= 128'd0;
        nonce_dec <= 128'd0;
        received_tag <= 128'd0;
        encrypt_start <= 1'b0;
        decrypt_start <= 1'b0;
        shift_reg <= 512'd0;
        bit_counter <= 10'd0;
    end else begin
        encrypt_start <= 1'b0;
        decrypt_start <= 1'b0;
        
        if (IR == SEC_CONFIG_ENC) begin
            case (tap_state)
                CAPTURE_DR: begin
                    shift_reg[511:384] <= encrypted_config;
                    shift_reg[383:256] <= encryption_tag;
                    shift_reg[255:240] <= puf_number;
                    shift_reg[239:224] <= current_count;
                    shift_reg[223] <= scan_enable;
                    shift_reg[222] <= count_done;
                    bit_counter <= 10'd0;
                end
                
                SHIFT_DR: begin
                    shift_reg <= {TDI, shift_reg[511:1]};
                    bit_counter <= bit_counter + 1'b1;
                end
                
                UPDATE_DR: begin
                    nonce_enc <= shift_reg[127:0];
                    test_config_plain <= shift_reg[255:128];
                    encrypt_start <= 1'b1;
                end
            endcase
        end
        
        if (IR == SEC_CONFIG_DEC) begin
            case (tap_state)
                CAPTURE_DR: begin
                    shift_reg[511:384] <= decrypted_config;
                    shift_reg[383] <= decryption_valid;
                    shift_reg[382:367] <= puf_number;
                    shift_reg[366:351] <= current_count;
                    shift_reg[350] <= scan_enable;
                    shift_reg[349] <= count_done;
                    bit_counter <= 10'd0;
                end
                
                SHIFT_DR: begin
                    shift_reg <= {TDI, shift_reg[511:1]};
                    bit_counter <= bit_counter + 1'b1;
                end
                
                UPDATE_DR: begin
                    nonce_dec <= shift_reg[127:0];
                    test_config_cipher <= shift_reg[255:128];
                    received_tag <= shift_reg[383:256];
                    decrypt_start <= 1'b1;
                end
            endcase
        end
    end
end

assign sec_cfg_tdo = shift_reg[0];

endmodule
