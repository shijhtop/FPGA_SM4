`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 21:17:37
// Design Name: 
// Module Name: round_func
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


module round_func(
    input   wire  [127:00]  rf_in    ,
    input   wire  [ 31:00]  rk       ,
    output  wire  [127:00]  rf_out   
);
    wire [31:00] x0, x1, x2, x3 ;
    wire [31:00] t_in, t_out    ;

    assign {x0, x1, x2, x3} = rf_in            ;
    assign t_in   = x1 ^ x2 ^ x3 ^ rk          ;
    assign rf_out = {x1, x2, x3, t_out ^ x0}   ;
    // T  
    transform T(
        .k_f(1'b0)      ,
        .t_in(t_in)     ,
        .t_out(t_out)
    );
endmodule
