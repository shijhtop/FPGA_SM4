`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/25 09:07:08
// Design Name: 
// Module Name: uart_tx
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
 
module uart_tx #(
    parameter CLK_F    = 50000000, //主时钟频率
    parameter UART_B   = 9600     //串口波特率
    )(
    input    wire         clk, //主时钟，50MHz
    input    wire         rst_n, //复位，高电平有效
    input    wire         tx_pdvalid, //发送开始标志
    input    wire  [7:0]  tx_pdata, //串口接收到的并行数据
    output   reg          tx_done,
    output   reg          tx //串口发送的串行数据
    );
    

    localparam BAUD_CNT_MAX = CLK_F / UART_B; //波特率计数器的最大值
    
    reg   [ 1:0]   pdvalid_reg; //发送开始标志边沿检测寄存器 
    reg   [ 7:0]   pdata_reg; //发送数据寄存器
    reg            work_en; //发送使能信号
    reg   [15:0]   baud_cnt = 16'd0; //115200波特率计数器
    reg   [ 3:0]   bit_cnt = 4'd0; //位计数器


    always @ (posedge clk) begin
        if (!rst_n) begin
            tx_done <= 1'd0;
        end else begin 
            if ((bit_cnt == 4'd9) && (baud_cnt == BAUD_CNT_MAX / 2))
                tx_done <= 1'b1;
            else
                tx_done <= 1'b0;
        end
    end
/***************发送开始标志边沿检测*************/
    always @ (posedge clk) begin
        if (!rst_n) pdvalid_reg <= 1'b0;
        else pdvalid_reg <= {pdvalid_reg[0] , tx_pdvalid};
    end
    
/***************发送使能信号控制*************/
    always @ (posedge clk) begin
        if (!rst_n) begin
            work_en <= 1'd0;
        end else begin 
            if (pdvalid_reg == 2'b01)
                work_en <= 1'd1;
            else if ((bit_cnt == 4'd9) && (baud_cnt == BAUD_CNT_MAX / 2))
                work_en <= 1'd0;
            else
                work_en <= work_en;
        end
    end
    
/***************发送缓存*************/
    always @ (posedge clk) begin
        if (!rst_n) begin
            pdata_reg <= 8'd0;
        end else begin 
            if (pdvalid_reg == 2'b01)
                pdata_reg <= tx_pdata;
            else if ((bit_cnt == 4'd9) && (baud_cnt == BAUD_CNT_MAX / 2))
                pdata_reg <= 8'd0;
            else 
                pdata_reg <= pdata_reg;
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
        end
        else bit_cnt <= 4'd0;
    end
 
/***************发送*************/
    always @ (posedge clk) begin
        if (!rst_n) begin
            tx <= 1'd1;
        end else if (work_en) begin
            case (bit_cnt)
                4'd0:tx <= 1'd0;
                4'd1:tx <= pdata_reg[0];
                4'd2:tx <= pdata_reg[1];
                4'd3:tx <= pdata_reg[2];
                4'd4:tx <= pdata_reg[3];
                4'd5:tx <= pdata_reg[4];
                4'd6:tx <= pdata_reg[5];
                4'd7:tx <= pdata_reg[6];
                4'd8:tx <= pdata_reg[7];
                4'd9:tx <= 1'd1;
                default:;
            endcase
        end else begin
            tx <= 1'd1;
        end
    end
    
endmodule