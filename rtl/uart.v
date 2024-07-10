`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/25 09:56:50
// Design Name: 
// Module Name: uart
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


module uart #(
    parameter CLK_F    = 50_000_000, //主时钟频率
    parameter UART_B   = 9600     //串口波特率 
    )(
    input  wire        clk,
    input  wire        rst_n,
    /* data input */
    input  wire        tx_pdvalid,
    input  wire  [7:0] tx_pdata,
    /* data output */
    output wire        rx_pdvalid,
    output wire  [7:0] rx_pdata,
    /* Uart */
    input  wire        rx,
    output wire        tx,
    /* flag */
    output wire        tx_done
    );



    uart_rx #(
        .CLK_F(CLK_F), //主时钟频率
        .UART_B(UART_B)    //串口波特率
    ) urx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx), 
        .rx_pdata(rx_pdata),
        .rx_pdvalid(rx_pdvalid)
    );

    uart_tx #(
        .CLK_F(CLK_F), //主时钟频率
        .UART_B(UART_B)    //串口波特率
    ) utx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_pdata(tx_pdata),
        .tx_pdvalid(tx_pdvalid),
        .tx(tx),
        .tx_done(tx_done)
    );
endmodule
