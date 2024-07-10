`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/18 14:50:42
// Design Name: 
// Module Name: tb_sm4_core
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


module tb_sm4_core();
    reg             clk;
    reg             rst;

    reg             en_sm4;
    reg             encdec; // en or de
    reg             en_key_exps;
    reg   [127:0]   key;
    reg             key_valid;
    wire            key_exps_done;
    reg   [127:0]   bdi; // block data input 
    reg             bdi_valid;

    wire  [127:0]   bdo;
    wire            bdo_valid;

    initial begin
        clk = 0;
        rst = 1;
        en_sm4 = 0;
        key_valid = 0;
        bdi_valid = 0;
        #20
        rst = 0;
        en_sm4 = 1;
        encdec = 1;
        en_key_exps = 1;
        key_valid = 1;
        key = 128'h0123456789abcdeffedcba9876543210;
        bdi_valid = 1'b0;
        bdi = 128'h0;


    end

    always #10 clk = ~clk;

    always @(*) begin
        if (key_exps_done) begin
            bdi_valid = 1'b1;
            //bdi = 128'h0123456789abcdeffedcba9876543210;
            bdi = 128'h681e_df34_d206_965e_86b3_e94f_536e_4246;
            en_key_exps = 1'b0;
        end
        if (bdo_valid) bdi_valid = 1'b0;
    end
    sm4_core sm4_test(
    .clk(clk),
    .rst(rst),
    .en_key_exps(en_key_exps),
    .en_sm4(en_sm4),
    .encdec(encdec), // en or de
    .key_exps_done(key_exps_done),
    .key(key),
    .key_valid(key_valid),

    .bdi(bdi), // block data input 
    .bdi_valid(bdi_valid),

    .bdo(bdo),
    .bdo_valid(bdo_valid)
);
endmodule
