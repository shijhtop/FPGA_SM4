`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 15:15:33
// Design Name: 
// Module Name: transform
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


module transform(
    input  wire        k_f, // k_f == 1, T about key expansion
    input  wire [31:0] t_in,
    output wire [31:0] t_out
);

    wire [7:0] a0, a1, a2, a3;
    wire [7:0] b0, b1, b2, b3;
    wire [31:0] tmp, out0, out1; // if k_f == 1 then t_out = out1 else t_out = out0

    assign {a0, a1, a2, a3} = t_in;
    assign tmp = {b0, b1, b2, b3};
    assign out0 = tmp ^ {tmp[29:0],tmp[31:30]} ^ {tmp[21:0],tmp[31:22]} ^ {tmp[13:0],tmp[31:14]} ^ {tmp[7:0],tmp[31:8]};
    assign out1 = tmp ^ {tmp[18:0],tmp[31:19]} ^ {tmp[8:0],tmp[31:9]};
    assign t_out = (k_f == 1'b1) ? out1 : out0;

    sbox s0(
        .s_in(a0),
        .s_out(b0)
    );
    sbox s1(
        .s_in(a1),
        .s_out(b1)
    );
    sbox s2(
        .s_in(a2),
        .s_out(b2)
    );
    sbox s3(
        .s_in(a3),
        .s_out(b3)
    );
endmodule
