`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2026 11:28:52
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
input i_clk, i_rst_n, i_tick, i_rx_serial, i_fsm_read,
output reg o_rx_dv, o_err_frame, o_err_overrun,
output reg [7:0] o_rx_byte 
);

localparam IDLE = 2'b00;
localparam START_BIT = 2'b01;
localparam DATA_BITS = 2'b10;
localparam STOP_BIT = 2'b11;

reg [1:0] r_state;
reg [3:0] r_tick_count;
reg [2:0] r_bit_index;
reg [7:0] r_rx_data;

reg r_rx_sync_0, r_rx_sync_1;
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        r_rx_sync_0 <= 1'b1;
        r_rx_sync_1 <= 1'b1;
    end
    else begin
        r_rx_sync_0 <= i_rx_serial;
        r_rx_sync_1 <= r_rx_sync_0;
    end
end
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        r_state <= IDLE;
        r_tick_count <= 0;
        r_bit_index <= 0;
        r_rx_data <= 0;
        o_rx_dv <= 1'b0;
        o_rx_byte <= 0;
        o_err_frame <= 1'b0;
        o_err_overrun <= 1'b0;
    end
    else begin
        if(o_rx_dv && !i_fsm_read) begin
            o_err_overrun <= 1'b1;
        end else if(i_fsm_read) begin
        o_err_overrun <= 1'b0;
        end
        if(i_tick) begin
            case(r_state)
            IDLE: begin
                o_rx_dv <= 1'b0;
                r_tick_count <= 0;
                r_bit_index <= 0;
                if(r_rx_sync_1 == 1'b0) r_state <= START_BIT;
            end
            START_BIT: begin
                if(r_tick_count == 7) begin
                    if(r_rx_sync_1 == 1'b0) begin
                        r_tick_count <= 0;
                        r_state <= DATA_BITS;
                    end
                    else begin
                        r_state <= IDLE;
                    end
                end
                else begin
                    r_tick_count <= r_tick_count + 1;
                end
            end
            DATA_BITS: begin
                if(r_tick_count < 15) begin
                    r_tick_count <= r_tick_count + 1;
                end
                else begin
                    r_tick_count <= 0;
                    r_rx_data[r_bit_index] <= r_rx_sync_1;
                    
                    if(r_bit_index < 7) begin
                        r_bit_index <= r_bit_index + 1;
                    end
                    else begin
                        r_bit_index <= 0;
                        r_state <= STOP_BIT;
                    end
                end
            end
            STOP_BIT: begin
                if(r_tick_count < 15) begin
                    r_tick_count <= r_tick_count + 1;
                end
                else begin
                    if(r_rx_sync_1 == 1'b1) begin
                        o_err_frame <= 1'b0;
                        o_rx_byte <= r_rx_data;
                        o_rx_dv <= 1'b1;
                    end
                    else begin
                        o_err_frame <= 1'b1;
                        o_rx_dv <= 1'b0;
                    end
                    r_state <= IDLE;
                end
            end
            default: r_state <= IDLE;
            endcase
        end
    end
end
endmodule