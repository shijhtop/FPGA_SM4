`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/14 13:56:29
// Design Name: 
// Module Name: tb_key_exps
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


module tb_key_exps();
    reg           clk;
    reg           rst;
    reg           key_valid;
    reg   [127:0] key;
    reg           en_key_exps;
    reg           en_sm4;
    reg           encdec;
    wire          key_exps_done;
    wire  [ 31:0] rk_00;
    wire  [ 31:0] rk_01;
    wire  [ 31:0] rk_02;
    wire  [ 31:0] rk_03;
    wire  [ 31:0] rk_04;
    wire  [ 31:0] rk_05;
    wire  [ 31:0] rk_06;
    wire  [ 31:0] rk_07;
    wire  [ 31:0] rk_08;
    wire  [ 31:0] rk_09;
    wire  [ 31:0] rk_10;
    wire  [ 31:0] rk_11;
    wire  [ 31:0] rk_12;
    wire  [ 31:0] rk_13;
    wire  [ 31:0] rk_14;
    wire  [ 31:0] rk_15;
    wire  [ 31:0] rk_16;
    wire  [ 31:0] rk_17;
    wire  [ 31:0] rk_18;
    wire  [ 31:0] rk_19;
    wire  [ 31:0] rk_20;
    wire  [ 31:0] rk_21;
    wire  [ 31:0] rk_22;
    wire  [ 31:0] rk_23;
    wire  [ 31:0] rk_24;
    wire  [ 31:0] rk_25;
    wire  [ 31:0] rk_26;
    wire  [ 31:0] rk_27;
    wire  [ 31:0] rk_28;
    wire  [ 31:0] rk_29;
    wire  [ 31:0] rk_30;
    wire  [ 31:0] rk_31;


    always #10  clk = ~clk;

    initial begin
        clk = 0;
        key_valid = 0;
        en_sm4 = 0;
        en_key_exps = 0;
        rst = 1;
        #20
        rst = 0;
        key = 128'h0123_4567_89ab_cdef_fedc_ba98_7654_3210;
        encdec = 0;
        key_valid = 1;
        en_key_exps = 1;
        en_sm4 = 1;
        
    end
    
    key_exps ke(
        .clk(clk),
        .rst(rst),
        .key_valid(key_valid),
        .key(key),
        .en_key_exps(en_key_exps),
        .encdec(encdec),
        .en_sm4(en_sm4),
        .key_exps_done(key_exps_done),
        .rk_00(rk_00),
        .rk_01(rk_01),
        .rk_02(rk_02),
        .rk_03(rk_03),
        .rk_04(rk_04),
        .rk_05(rk_05),
        .rk_06(rk_06),
        .rk_07(rk_07),
        .rk_08(rk_08),
        .rk_09(rk_09),
        .rk_10(rk_10),
        .rk_11(rk_11),
        .rk_12(rk_12),
        .rk_13(rk_13),
        .rk_14(rk_14),
        .rk_15(rk_15),
        .rk_16(rk_16),
        .rk_17(rk_17),
        .rk_18(rk_18),
        .rk_19(rk_19),
        .rk_20(rk_20),
        .rk_21(rk_21),
        .rk_22(rk_22),
        .rk_23(rk_23),
        .rk_24(rk_24),
        .rk_25(rk_25),
        .rk_26(rk_26),
        .rk_27(rk_27),
        .rk_28(rk_28),
        .rk_29(rk_29),
        .rk_30(rk_30),
        .rk_31(rk_31)
    );
endmodule
