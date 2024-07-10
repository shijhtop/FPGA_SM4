`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/25 09:05:04
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

`timescale 1ns / 1ps
 
module uart_rx #(
    parameter CLK_F    = 50000000, //主时钟频率
    parameter UART_B   = 9600     //串口波特率
    )(
    input    wire          clk, //主时钟，50MHz
    input    wire          rst_n, //复位，高电平有效
    input    wire          rx, //发送给串口的串行数据
    output   reg   [7:0]   rx_pdata, //串口接收后的并行数据
    output   reg           rx_pdvalid //接收完成标志
    );
    
    localparam BAUD_CNT_MAX = CLK_F / UART_B; //波特率计数器的最大值
    
    reg   [ 1:0]   rx_reg_1; //用于消除输入串行数据的亚稳态
    reg   [ 1:0]   rx_reg_2; //输入串行数据边沿检测寄存器
    reg            work_en; //接收使能信号
    reg   [15:0]   baud_cnt = 16'd0; //波特率计数器
    reg   [ 3:0]   bit_cnt = 4'd0; //位计数器
    reg   [ 7:0]   pdata_reg; //接收数据寄存器
 
    
/***************消除输入串行数据亚稳态*************/
    always @ (posedge clk) begin
        if (!rst_n) rx_reg_1 <= 2'b00;
        else rx_reg_1 <= {rx_reg_1[0], rx};
    end
 
/***************输入串行数据边沿检测*************/
    always @ (posedge clk) begin
        if (!rst_n) rx_reg_2 <= 2'b00;
        else rx_reg_2 <= {rx_reg_2[0], rx_reg_1[1]};
    end
 
/***************接收使能信号控制*************/
    always @ (posedge clk) begin
        if (!rst_n) begin
            work_en <= 1'd0;
        end else begin 
            if (rx_reg_2 == 2'b10)
                work_en <= 1'd1;
            else if ((bit_cnt == 4'd9) && (baud_cnt == BAUD_CNT_MAX / 2))
                work_en <= 1'd0;
            else 
                work_en <= work_en;
        end
    end
 
/***************波特率计数器控制*************/
    always @ (posedge clk) begin
        if (!rst_n) begin
            baud_cnt <= 16'd0;
        end else if (work_en) begin
            if (baud_cnt == BAUD_CNT_MAX - 1)
                baud_cnt <= 16'd0;
            else
                baud_cnt <= baud_cnt + 1'b1;
        end else begin
            baud_cnt <= 16'd0;
        end
    end
 
/***************位计数器控制*************/
    always @ (posedge clk) begin
        if (!rst_n) begin
            bit_cnt <= 4'd0;
        end else if (work_en) begin
            if (baud_cnt == BAUD_CNT_MAX - 1)
                bit_cnt <= bit_cnt + 1'b1;
            else
                bit_cnt <= bit_cnt;
        end else begin
            bit_cnt <= 4'd0;
        end
    end
 
/***************接收缓存*************/
    always @ (posedge clk) begin
        if (!rst_n) begin
            pdata_reg <= 8'd0;
        end else if (work_en) begin
            if (baud_cnt == BAUD_CNT_MAX / 2) begin
                case (bit_cnt)
                    4'd1:pdata_reg[0] <= rx_reg_2[1];
                    4'd2:pdata_reg[1] <= rx_reg_2[1];
                    4'd3:pdata_reg[2] <= rx_reg_2[1];
                    4'd4:pdata_reg[3] <= rx_reg_2[1];
                    4'd5:pdata_reg[4] <= rx_reg_2[1];
                    4'd6:pdata_reg[5] <= rx_reg_2[1];
                    4'd7:pdata_reg[6] <= rx_reg_2[1];
                    4'd8:pdata_reg[7] <= rx_reg_2[1];
                    default:;
                endcase
            end else begin
                pdata_reg <= pdata_reg;
            end
        end else begin
            pdata_reg <= 8'd0;
        end
    end
 
/***************输出*************/
    always @ (posedge clk) begin
        if (!rst_n)
            rx_pdata <= 8'd0;
        else if (bit_cnt == 4'd9)
            rx_pdata <= pdata_reg;
        else
            rx_pdata <= 8'd0;
    end
 
/***************输出标志控制*************/
    always @ (posedge clk) begin
        if (!rst_n)
            rx_pdvalid <= 1'd0;
        else if (bit_cnt == 4'd9)
            rx_pdvalid <= 1'd1;
        else
            rx_pdvalid <= 1'b0;
    end
    
endmodule