`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2026 17:39:22
// Design Name: 
// Module Name: baud_gen
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
module baud_gen#(//CLK_MAX_COUNT = 50000000/(9600*16)
parameter CLK_MAX_COUNT = 326)
(
input clk, rst_n,
output reg o_tick
    );
reg [8:0] r_clk_counter;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_clk_counter <= 0;
        o_tick <= 1'b0;
    end
    else begin
        if(r_clk_counter < CLK_MAX_COUNT - 1) begin
            r_clk_counter <= r_clk_counter + 1;
            o_tick <= 1'b0;
        end
        else begin
            r_clk_counter <= 0;
            o_tick <= 1'b1;
        end
    end
end
endmodule