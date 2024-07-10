`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/15 11:21:38
// Design Name: 
// Module Name: sm4_core
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


module sm4_core(
    input  wire             clk,
    input  wire             rst_n,

    input  wire             en_sm4,
    input  wire             encdec, // en or de
    input  wire             en_key_exps,
    input  wire   [127:0]   key,
    input  wire             key_valid,
    output wire             key_exps_done,

    input  wire   [127:0]   bdi, // block data input 
    input  wire             bdi_valid,

    output wire   [127:0]   bdo,
    output wire             bdo_valid
);


    wire [ 31:0] rk [31:0]; // round key
    wire [127:0] rvs_rf_31;   // reversed output
    wire [ 31:0] w0, w1, w2, w3;
    wire [127:0] rf [31:0]; // round function output

    reg         bdi_valid_reg;
    reg [127:0] bdi_reg;
    reg [ 31:0] reg_output_flag; 
    reg [127:0] reg_rf [31:0];    // round output of x
    reg [  4:0] rk_idx [31:0];


    // FSM STATE
    localparam IDLE      = 2'b00; 
    localparam KEY_EXPS  = 2'b01;
    localparam ENCDEC    = 2'b11;


    reg [1:0] current_state;
    reg [1:0] next_state;
    // FSM Current State Update
    always @(posedge clk) begin
        if(!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    // FSM Next State Update
    always @(*) begin
        case(current_state)
            IDLE:
                if (en_sm4 & en_key_exps) next_state = KEY_EXPS;
                else next_state = IDLE;
            KEY_EXPS:
                if (~en_sm4) next_state = IDLE;
                else if (key_exps_done) next_state = ENCDEC;
                else next_state = KEY_EXPS;
            ENCDEC:
                if (~en_sm4) next_state = IDLE;
                else if (en_key_exps) next_state = KEY_EXPS;
                else next_state = ENCDEC;
            default: next_state = IDLE;
        endcase
    end

    // buffer
    always @(posedge clk) begin
        if (!rst_n) begin
            bdi_reg <= 128'd0;
            bdi_valid_reg <= 1'b0;
        end else if (bdi_valid) begin
            bdi_reg <= bdi;
            bdi_valid_reg <= bdi_valid;
        end else bdi_valid_reg <= 1'b0;
    end
    // output flag
    always @(posedge clk) begin
        if (!rst_n) begin
            reg_output_flag <= 32'd0;
        end else if ((next_state == ENCDEC) && bdi_valid_reg) begin
            reg_output_flag <= {reg_output_flag[30:0], 1'b1};
        end else begin
            reg_output_flag <= {reg_output_flag[30:0], 1'b0};
        end
    end
    assign bdo_valid = reg_output_flag[31];

    round_func rf_unit_00 (.rf_in(bdi_reg),        .rk(rk[00]), .rf_out(rf[00]));
    round_func rf_unit_01 (.rf_in(reg_rf[00]), .rk(rk[01]), .rf_out(rf[01]));
    round_func rf_unit_02 (.rf_in(reg_rf[01]), .rk(rk[02]), .rf_out(rf[02]));
    round_func rf_unit_03 (.rf_in(reg_rf[02]), .rk(rk[03]), .rf_out(rf[03]));
    round_func rf_unit_04 (.rf_in(reg_rf[03]), .rk(rk[04]), .rf_out(rf[04]));
    round_func rf_unit_05 (.rf_in(reg_rf[04]), .rk(rk[05]), .rf_out(rf[05]));
    round_func rf_unit_06 (.rf_in(reg_rf[05]), .rk(rk[06]), .rf_out(rf[06]));
    round_func rf_unit_07 (.rf_in(reg_rf[06]), .rk(rk[07]), .rf_out(rf[07]));
    round_func rf_unit_08 (.rf_in(reg_rf[07]), .rk(rk[08]), .rf_out(rf[08]));
    round_func rf_unit_09 (.rf_in(reg_rf[08]), .rk(rk[09]), .rf_out(rf[09]));
    round_func rf_unit_10 (.rf_in(reg_rf[09]), .rk(rk[10]), .rf_out(rf[10]));
    round_func rf_unit_11 (.rf_in(reg_rf[10]), .rk(rk[11]), .rf_out(rf[11]));
    round_func rf_unit_12 (.rf_in(reg_rf[11]), .rk(rk[12]), .rf_out(rf[12]));
    round_func rf_unit_13 (.rf_in(reg_rf[12]), .rk(rk[13]), .rf_out(rf[13]));
    round_func rf_unit_14 (.rf_in(reg_rf[13]), .rk(rk[14]), .rf_out(rf[14]));
    round_func rf_unit_15 (.rf_in(reg_rf[14]), .rk(rk[15]), .rf_out(rf[15]));
    round_func rf_unit_16 (.rf_in(reg_rf[15]), .rk(rk[16]), .rf_out(rf[16]));
    round_func rf_unit_17 (.rf_in(reg_rf[16]), .rk(rk[17]), .rf_out(rf[17]));
    round_func rf_unit_18 (.rf_in(reg_rf[17]), .rk(rk[18]), .rf_out(rf[18]));
    round_func rf_unit_19 (.rf_in(reg_rf[18]), .rk(rk[19]), .rf_out(rf[19]));
    round_func rf_unit_20 (.rf_in(reg_rf[19]), .rk(rk[20]), .rf_out(rf[20]));
    round_func rf_unit_21 (.rf_in(reg_rf[20]), .rk(rk[21]), .rf_out(rf[21]));
    round_func rf_unit_22 (.rf_in(reg_rf[21]), .rk(rk[22]), .rf_out(rf[22]));
    round_func rf_unit_23 (.rf_in(reg_rf[22]), .rk(rk[23]), .rf_out(rf[23]));
    round_func rf_unit_24 (.rf_in(reg_rf[23]), .rk(rk[24]), .rf_out(rf[24]));
    round_func rf_unit_25 (.rf_in(reg_rf[24]), .rk(rk[25]), .rf_out(rf[25]));
    round_func rf_unit_26 (.rf_in(reg_rf[25]), .rk(rk[26]), .rf_out(rf[26]));
    round_func rf_unit_27 (.rf_in(reg_rf[26]), .rk(rk[27]), .rf_out(rf[27]));
    round_func rf_unit_28 (.rf_in(reg_rf[27]), .rk(rk[28]), .rf_out(rf[28]));
    round_func rf_unit_29 (.rf_in(reg_rf[28]), .rk(rk[29]), .rf_out(rf[29]));
    round_func rf_unit_30 (.rf_in(reg_rf[29]), .rk(rk[30]), .rf_out(rf[30]));
    round_func rf_unit_31 (.rf_in(reg_rf[30]), .rk(rk[31]), .rf_out(rf[31]));
    
    assign {w0, w1, w2, w3} = rf[31];
    assign rvs_rf_31 = {w3, w2, w1, w0};

// 待写
    always@(posedge clk) if(!rst_n) reg_rf[00] <= 128'd0; else reg_rf[00] <= rf[00];
    always@(posedge clk) if(!rst_n) reg_rf[01] <= 128'd0; else reg_rf[01] <= rf[01];
    always@(posedge clk) if(!rst_n) reg_rf[02] <= 128'd0; else reg_rf[02] <= rf[02];
    always@(posedge clk) if(!rst_n) reg_rf[03] <= 128'd0; else reg_rf[03] <= rf[03];
    always@(posedge clk) if(!rst_n) reg_rf[04] <= 128'd0; else reg_rf[04] <= rf[04];
    always@(posedge clk) if(!rst_n) reg_rf[05] <= 128'd0; else reg_rf[05] <= rf[05];
    always@(posedge clk) if(!rst_n) reg_rf[06] <= 128'd0; else reg_rf[06] <= rf[06];
    always@(posedge clk) if(!rst_n) reg_rf[07] <= 128'd0; else reg_rf[07] <= rf[07];
    always@(posedge clk) if(!rst_n) reg_rf[08] <= 128'd0; else reg_rf[08] <= rf[08];
    always@(posedge clk) if(!rst_n) reg_rf[09] <= 128'd0; else reg_rf[09] <= rf[09];
    always@(posedge clk) if(!rst_n) reg_rf[10] <= 128'd0; else reg_rf[10] <= rf[10];
    always@(posedge clk) if(!rst_n) reg_rf[11] <= 128'd0; else reg_rf[11] <= rf[11];
    always@(posedge clk) if(!rst_n) reg_rf[12] <= 128'd0; else reg_rf[12] <= rf[12];
    always@(posedge clk) if(!rst_n) reg_rf[13] <= 128'd0; else reg_rf[13] <= rf[13];
    always@(posedge clk) if(!rst_n) reg_rf[14] <= 128'd0; else reg_rf[14] <= rf[14];
    always@(posedge clk) if(!rst_n) reg_rf[15] <= 128'd0; else reg_rf[15] <= rf[15];
    always@(posedge clk) if(!rst_n) reg_rf[16] <= 128'd0; else reg_rf[16] <= rf[16];
    always@(posedge clk) if(!rst_n) reg_rf[17] <= 128'd0; else reg_rf[17] <= rf[17];
    always@(posedge clk) if(!rst_n) reg_rf[18] <= 128'd0; else reg_rf[18] <= rf[18];
    always@(posedge clk) if(!rst_n) reg_rf[19] <= 128'd0; else reg_rf[19] <= rf[19];
    always@(posedge clk) if(!rst_n) reg_rf[20] <= 128'd0; else reg_rf[20] <= rf[20];
    always@(posedge clk) if(!rst_n) reg_rf[21] <= 128'd0; else reg_rf[21] <= rf[21];
    always@(posedge clk) if(!rst_n) reg_rf[22] <= 128'd0; else reg_rf[22] <= rf[22];
    always@(posedge clk) if(!rst_n) reg_rf[23] <= 128'd0; else reg_rf[23] <= rf[23];
    always@(posedge clk) if(!rst_n) reg_rf[24] <= 128'd0; else reg_rf[24] <= rf[24];
    always@(posedge clk) if(!rst_n) reg_rf[25] <= 128'd0; else reg_rf[25] <= rf[25];
    always@(posedge clk) if(!rst_n) reg_rf[26] <= 128'd0; else reg_rf[26] <= rf[26];
    always@(posedge clk) if(!rst_n) reg_rf[27] <= 128'd0; else reg_rf[27] <= rf[27];
    always@(posedge clk) if(!rst_n) reg_rf[28] <= 128'd0; else reg_rf[28] <= rf[28];
    always@(posedge clk) if(!rst_n) reg_rf[29] <= 128'd0; else reg_rf[29] <= rf[29];
    always@(posedge clk) if(!rst_n) reg_rf[30] <= 128'd0; else reg_rf[30] <= rf[30];
    always@(posedge clk) if(!rst_n) reg_rf[31] <= 128'd0; else reg_rf[31] <= rvs_rf_31;
    
    assign bdo = reg_rf[31];

    // Key Expansion
    key_exps ke(
        .clk(clk),
        .rst_n(rst_n),
        .en_sm4(en_sm4),
        .encdec(encdec),
        .key_valid(key_valid),
        .key(key),
        .en_key_exps(en_key_exps),
        .key_exps_done(key_exps_done),
        .rk_00(rk[00]),
        .rk_01(rk[01]),
        .rk_02(rk[02]),
        .rk_03(rk[03]),
        .rk_04(rk[04]),
        .rk_05(rk[05]),
        .rk_06(rk[06]),
        .rk_07(rk[07]),
        .rk_08(rk[08]),
        .rk_09(rk[09]),
        .rk_10(rk[10]),
        .rk_11(rk[11]),
        .rk_12(rk[12]),
        .rk_13(rk[13]),
        .rk_14(rk[14]),
        .rk_15(rk[15]),
        .rk_16(rk[16]),
        .rk_17(rk[17]),
        .rk_18(rk[18]),
        .rk_19(rk[19]),
        .rk_20(rk[20]),
        .rk_21(rk[21]),
        .rk_22(rk[22]),
        .rk_23(rk[23]),
        .rk_24(rk[24]),
        .rk_25(rk[25]),
        .rk_26(rk[26]),
        .rk_27(rk[27]),
        .rk_28(rk[28]),
        .rk_29(rk[29]),
        .rk_30(rk[30]),
        .rk_31(rk[31])
    );
    
endmodule
