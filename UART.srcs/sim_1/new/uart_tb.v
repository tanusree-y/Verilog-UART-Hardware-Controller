`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2026 14:41:54
// Design Name: 
// Module Name: uart_tb
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


module uart_tb();

reg clk, rst_n, rx_serial;
wire system_led, err_frame, err_overrun;
wire [6:0] seg_pins;

//50 MHz and 9600 baud & 20 ns period
localparam BIT_PERIOD = 104160;

uart_top dut(.i_clk(clk), .i_rst_n(rst_n), .i_rx_serial(rx_serial), .o_system_led(system_led), .o_err_frame(err_frame), .o_err_overrun(err_overrun), .o_seg_pins(seg_pins));

always #10 clk = ~clk;

task send_serial_byte (input [7:0] byte_data, input send_valid_stop);
    integer bit_idx;
    begin
        rx_serial = 1'b0;
        #BIT_PERIOD;
        
        for(bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
            rx_serial = byte_data[bit_idx];
            #BIT_PERIOD;
        end
        
        if(send_valid_stop) rx_serial = 1'b1;
        else rx_serial = 1'b0;
        #BIT_PERIOD;
    end
endtask
initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    rx_serial = 1'b1;
    #200;
    rst_n = 1'b1;
    #1000;
    $display("[SIM_TIME: %0t] Sending command: Toggle LED", $time);
    send_serial_byte(8'hA1, 1'b1);
    #200000;
    $display("[SIM_TIME: %0t] Sending command sequence: Show 5 on display", $time);
    send_serial_byte(8'hB2, 1'b1);
    #50000;
    send_serial_byte(8'h05, 1'b1);
    #200000;
    $display("[SIM_TIME: %0t] Injecting intentional framing error", $time);
    send_serial_byte(8'hFF, 1'b0);
    #200000;
    $display("[SIM_TIME: %0t] Simulation completed successfully!", $time);
    $finish;
end
endmodule