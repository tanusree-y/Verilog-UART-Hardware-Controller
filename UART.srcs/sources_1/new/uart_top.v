`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2026 14:16:24
// Design Name: 
// Module Name: uart_top
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


module uart_top(
input i_clk, i_rst_n, i_rx_serial,
output o_system_led, o_err_frame, o_err_overrun,
output [6:0] o_seg_pins
);

wire w_tick, w_rx_dv, w_fsm_read;
wire [7:0] w_rx_byte;

baud_gen #(.CLK_MAX_COUNT(326)) dut1 (.clk(i_clk), .rst_n(i_rst_n), .o_tick(w_tick));
uart_rx dut2 (.i_clk(i_clk), .i_rst_n(i_rst_n), .i_tick(w_tick), .i_rx_serial(i_rx_serial), .i_fsm_read(w_fsm_read), .o_rx_byte(w_rx_byte), .o_err_frame(o_err_frame), .o_err_overrun(o_err_overrun));
uart_decoder dut3 (.i_clk(i_clk), .i_rst_n(i_rst_n), .i_rx_dv(w_rx_dv), .i_rx_byte(w_rx_byte), .o_fsm_read(w_fsm_read), .o_seg_pins(o_seg_pins), .o_system_led(o_system_led));
endmodule
