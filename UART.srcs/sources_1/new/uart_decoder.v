`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2026 13:47:48
// Design Name: 
// Module Name: uart_decoder
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


module uart_decoder(
input i_clk, i_rst_n, i_rx_dv,
input [7:0] i_rx_byte,
output reg o_fsm_read, o_system_led,
output reg [6:0] o_seg_pins
);

localparam CMD_TOGGLE_LED = 8'h41;
localparam CMD_SET_7SEG = 8'h42;

localparam STATE_GET_CMD = 1'b0;
localparam STATE_GET_DATA = 1'b1;

reg r_state;
reg [3:0] r_saved_number;

always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        r_state <= STATE_GET_CMD;
        o_system_led <= 1'b0;
        r_saved_number <= 4'h0;
        o_fsm_read <= 1'b0;
    end
    else begin
        o_fsm_read <=  1'b0;
        if(i_rx_dv) begin
            o_fsm_read <= 1'b1;
            case(r_state)
                STATE_GET_CMD: begin
                    case(i_rx_byte)
                        CMD_TOGGLE_LED: begin
                            o_system_led <= ~o_system_led;
                            r_state <= STATE_GET_CMD;
                        end
                        CMD_SET_7SEG: begin
                            r_state <= STATE_GET_DATA;
                        end
                        default: r_state <= STATE_GET_CMD;
                    endcase
                end
                STATE_GET_DATA: begin
                    if(i_rx_byte <=8'd9) begin
                        r_saved_number <= i_rx_byte[3:0];
                    end
                    r_state <= STATE_GET_CMD;
                end
            endcase
        end
    end
end
always@(*) begin
    case(r_saved_number)
        4'd0: o_seg_pins = 7'b0111111;
        4'd1: o_seg_pins = 7'b0000110;
        4'd2: o_seg_pins = 7'b1011011;
        4'd3: o_seg_pins = 7'b1001111;
        4'd4: o_seg_pins = 7'b1100110;
        4'd5: o_seg_pins = 7'b1101101;
        4'd6: o_seg_pins = 7'b1111101;
        4'd7: o_seg_pins = 7'b0000111;
        4'd8: o_seg_pins = 7'b1111111;
        4'd9: o_seg_pins = 7'b1101111;
        default: o_seg_pins = 7'b1000000;
    endcase
end
endmodule