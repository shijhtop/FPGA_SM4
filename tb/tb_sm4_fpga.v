`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/25 15:59:25
// Design Name: 
// Module Name: tb_sm4_fpga
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


module tb_sm4_fpga();

    reg   clk;
    reg   rst_n;
    reg   rx;
    wire  tx;
    reg [7:0] udata_mem [15:0];

    always #10 clk = ~clk;

    initial begin
        // {
        //     udata_mem[00],udata_mem[01],udata_mem[02],udata_mem[03],
        //     udata_mem[04],udata_mem[05],udata_mem[06],udata_mem[07],
        //     udata_mem[08],udata_mem[09],udata_mem[10],udata_mem[11],
        //     udata_mem[12],udata_mem[13],udata_mem[14],udata_mem[15]
        // } <= 128'h0123456789abcdeffedcba9876543210;
        {
            udata_mem[00],udata_mem[01],udata_mem[02],udata_mem[03],
            udata_mem[04],udata_mem[05],udata_mem[06],udata_mem[07],
            udata_mem[08],udata_mem[09],udata_mem[10],udata_mem[11],
            udata_mem[12],udata_mem[13],udata_mem[14],udata_mem[15]
        } <= 128'h681EDF34D206965E86B3E94F536E4246;
        clk = 1'b0;
        rst_n= 1'b0;
        rx = 1;
        #20
        rst_n = 1'b1;
        #(33*20)
        get_byte();
    end

    task get_byte;
        integer i;
        for (i = 0; i < 16; i = i + 1) begin
            get_bit(udata_mem[i]);
        end        
    endtask

    task get_bit;
        input wire [7:0] udata;
        integer i;
        for (i = 0; i < 10; i = i + 1) begin
            case(i)
                0: rx = 1'b0;
                1: rx = udata[0];
                2: rx = udata[1];
                3: rx = udata[2];
                4: rx = udata[3];
                5: rx = udata[4];
                6: rx = udata[5];
                7: rx = udata[6];
                8: rx = udata[7];
                9: rx = 1'b1;
            endcase
            #(5208*20);
        end
    endtask


    sm4_fpga sm4_fpga_unit(
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .tx(tx)
    );
endmodule
