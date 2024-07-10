`timescale 1ns / 1ps


module key_exps(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         encdec,
    input  wire         key_valid,
    input  wire [127:0] key,
    input  wire         en_key_exps,
    input  wire         en_sm4,

    output reg          key_exps_done,
    output reg  [ 31:0] rk_00,
    output reg  [ 31:0] rk_01,
    output reg  [ 31:0] rk_02,
    output reg  [ 31:0] rk_03,
    output reg  [ 31:0] rk_04,
    output reg  [ 31:0] rk_05,
    output reg  [ 31:0] rk_06,
    output reg  [ 31:0] rk_07,
    output reg  [ 31:0] rk_08,
    output reg  [ 31:0] rk_09,
    output reg  [ 31:0] rk_10,
    output reg  [ 31:0] rk_11,
    output reg  [ 31:0] rk_12,
    output reg  [ 31:0] rk_13,
    output reg  [ 31:0] rk_14,
    output reg  [ 31:0] rk_15,
    output reg  [ 31:0] rk_16,
    output reg  [ 31:0] rk_17,
    output reg  [ 31:0] rk_18,
    output reg  [ 31:0] rk_19,
    output reg  [ 31:0] rk_20,
    output reg  [ 31:0] rk_21,
    output reg  [ 31:0] rk_22,
    output reg  [ 31:0] rk_23,
    output reg  [ 31:0] rk_24,
    output reg  [ 31:0] rk_25,
    output reg  [ 31:0] rk_26,
    output reg  [ 31:0] rk_27,
    output reg  [ 31:0] rk_28,
    output reg  [ 31:0] rk_29,
    output reg  [ 31:0] rk_30,
    output reg  [ 31:0] rk_31
);
    localparam FK0	=	32'ha3b1bac6;
    localparam FK1	=	32'h56aa3350;
    localparam FK2	=	32'h677d9197;
    localparam FK3	=	32'hb27022dc;

    // FSM STATE
    localparam IDLE = 0;
    localparam EXPS = 1;

    wire [  4:0] rk_idx, ck_idx;
    wire [ 31:0] t_in, t_out;
    wire [ 31:0] k0, k1, k2, k3;
    wire [127:0] F;
    // REGISTER
    reg [ 31:0] w0, w1, w2, w3;
    reg [  4:0] round_cnt, reg_round_cnt;
    reg [ 31:0] ck;
    reg current_state;
    reg next_state;

    assign k0 = key[127:96] ^ FK0;   // K0
    assign k1 = key[ 95:64] ^ FK1;   // K1
    assign k2 = key[ 63:32] ^ FK2;   // K2
    assign k3 = key[ 31:00] ^ FK3;   // K3

    assign t_in = (round_cnt == 5'd0) ? (k1 ^ k2 ^ k3 ^ ck) : (w1 ^ w2 ^ w3 ^ ck);
    assign F = (round_cnt == 5'd0)	? {k1, k2, k3, t_out ^ k0} : {w1, w2, w3, t_out ^ w0};


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
                if(key_valid && en_key_exps && en_sm4) next_state = EXPS;
                else next_state = IDLE;
            EXPS:
                if(reg_round_cnt == 5'd31 || ~en_sm4) next_state = IDLE;
                else next_state = EXPS;
            default: next_state = IDLE;
        endcase
    end
    // word: 0, 1, 2, 3; 32 bits per word 
    always @(posedge clk) begin
        if (!rst_n) begin
            w0 <= 32'd0;
            w1 <= 32'd0;
            w2 <= 32'd0;
            w3 <= 32'd0;
        end else if (next_state == EXPS) begin
            {w0, w1, w2, w3} <= F;
        end        
    end
    // delay one period
    always @(posedge clk) begin
        if (!rst_n) 
            reg_round_cnt <= 5'd0;
        else if (next_state == EXPS)
            reg_round_cnt <= round_cnt;
        else reg_round_cnt <= 5'd0;
    end
    // couter
    always @(posedge clk) begin
        if (!rst_n) 
            round_cnt <= 5'd0;
        else if (next_state == EXPS)
            round_cnt <= round_cnt + 1;
        else round_cnt <= 5'd0;
    end
    // T
    transform T(
        .k_f(1'b1),
        .t_in(t_in),
        .t_out(t_out)
    );
    // expansion done
    always @(posedge clk) begin
        if (!rst_n) begin 
            key_exps_done <= 1'b0;
        end else if ((current_state == EXPS) && (next_state == IDLE)) begin
            key_exps_done <= 1'b1;
        end else begin 
            key_exps_done <= 1'b0;        
        end
    end  
    // rk
    assign rk_idx = (encdec == 1'b0) ? round_cnt : 5'b11111 - round_cnt;
    always @(posedge clk) begin
        if (!rst_n) begin
            rk_00  <= 32'd0;
            rk_01  <= 32'd0; 
            rk_02  <= 32'd0; 
            rk_03  <= 32'd0; 
            rk_04  <= 32'd0; 
            rk_05  <= 32'd0; 
            rk_06  <= 32'd0; 
            rk_07  <= 32'd0; 
            rk_08  <= 32'd0; 
            rk_09  <= 32'd0; 
            rk_10  <= 32'd0; 
            rk_11  <= 32'd0; 
            rk_12  <= 32'd0; 
            rk_13  <= 32'd0; 
            rk_14  <= 32'd0; 
            rk_15  <= 32'd0; 
            rk_16  <= 32'd0; 
            rk_17  <= 32'd0; 
            rk_18  <= 32'd0; 
            rk_19  <= 32'd0; 
            rk_20  <= 32'd0; 
            rk_21  <= 32'd0; 
            rk_22  <= 32'd0; 
            rk_23  <= 32'd0; 
            rk_24  <= 32'd0; 
            rk_25  <= 32'd0; 
            rk_26  <= 32'd0; 
            rk_27  <= 32'd0; 
            rk_28  <= 32'd0; 
            rk_29  <= 32'd0; 
            rk_30  <= 32'd0;
            rk_31  <= 32'd0; 
        end else if (next_state == EXPS) begin
            rk_00  <=  (rk_idx == 00) ? F[31:0] : rk_00;
            rk_01  <=  (rk_idx == 01) ? F[31:0] : rk_01;
            rk_02  <=  (rk_idx == 02) ? F[31:0] : rk_02;
            rk_03  <=  (rk_idx == 03) ? F[31:0] : rk_03;
            rk_04  <=  (rk_idx == 04) ? F[31:0] : rk_04;
            rk_05  <=  (rk_idx == 05) ? F[31:0] : rk_05;
            rk_06  <=  (rk_idx == 06) ? F[31:0] : rk_06;
            rk_07  <=  (rk_idx == 07) ? F[31:0] : rk_07;
            rk_08  <=  (rk_idx == 08) ? F[31:0] : rk_08;
            rk_09  <=  (rk_idx == 09) ? F[31:0] : rk_09;
            rk_10  <=  (rk_idx == 10) ? F[31:0] : rk_10;
            rk_11  <=  (rk_idx == 11) ? F[31:0] : rk_11;
            rk_12  <=  (rk_idx == 12) ? F[31:0] : rk_12;
            rk_13  <=  (rk_idx == 13) ? F[31:0] : rk_13;
            rk_14  <=  (rk_idx == 14) ? F[31:0] : rk_14;
            rk_15  <=  (rk_idx == 15) ? F[31:0] : rk_15;
            rk_16  <=  (rk_idx == 16) ? F[31:0] : rk_16;
            rk_17  <=  (rk_idx == 17) ? F[31:0] : rk_17;
            rk_18  <=  (rk_idx == 18) ? F[31:0] : rk_18;
            rk_19  <=  (rk_idx == 19) ? F[31:0] : rk_19;
            rk_20  <=  (rk_idx == 20) ? F[31:0] : rk_20;
            rk_21  <=  (rk_idx == 21) ? F[31:0] : rk_21;
            rk_22  <=  (rk_idx == 22) ? F[31:0] : rk_22;
            rk_23  <=  (rk_idx == 23) ? F[31:0] : rk_23;
            rk_24  <=  (rk_idx == 24) ? F[31:0] : rk_24;
            rk_25  <=  (rk_idx == 25) ? F[31:0] : rk_25;
            rk_26  <=  (rk_idx == 26) ? F[31:0] : rk_26;
            rk_27  <=  (rk_idx == 27) ? F[31:0] : rk_27;
            rk_28  <=  (rk_idx == 28) ? F[31:0] : rk_28;
            rk_29  <=  (rk_idx == 29) ? F[31:0] : rk_29;
            rk_30  <=  (rk_idx == 30) ? F[31:0] : rk_30;
            rk_31  <=  (rk_idx == 31) ? F[31:0] : rk_31;
        end
    end

    // ck_i
    assign ck_idx = round_cnt;
    always@(*)
        case(ck_idx)
            6'b00_0000:	ck	<=	32'h00070e15;
            6'b00_0001:	ck	<=	32'h1c232a31;
            6'b00_0010:	ck	<=	32'h383f464d;
            6'b00_0011:	ck	<=	32'h545b6269;
            6'b00_0100:	ck	<=	32'h70777e85;
            6'b00_0101:	ck	<=	32'h8c939aa1;
            6'b00_0110:	ck	<=	32'ha8afb6bd;
            6'b00_0111:	ck	<=	32'hc4cbd2d9;
            6'b00_1000:	ck	<=	32'he0e7eef5;
            6'b00_1001:	ck	<=	32'hfc030a11;
            6'b00_1010:	ck	<=	32'h181f262d;
            6'b00_1011:	ck	<=	32'h343b4249;
            6'b00_1100:	ck	<=	32'h50575e65;
            6'b00_1101:	ck	<=	32'h6c737a81;
            6'b0_1110:	ck	<=	32'h888f969d;
            6'b00_1111:	ck	<=	32'ha4abb2b9;
            6'b01_0000:	ck	<=	32'hc0c7ced5;
            6'b01_0001:	ck	<=	32'hdce3eaf1;
            6'b01_0010:	ck	<=	32'hf8ff060d;
            6'b01_0011:	ck	<=	32'h141b2229;
            6'b01_0100:	ck	<=	32'h30373e45;
            6'b01_0101:	ck	<=	32'h4c535a61;
            6'b01_0110:	ck	<=	32'h686f767d;
            6'b01_0111:	ck	<=	32'h848b9299;
            6'b01_1000:	ck	<=	32'ha0a7aeb5;
            6'b01_1001:	ck	<=	32'hbcc3cad1;
            6'b01_1010:	ck	<=	32'hd8dfe6ed;
            6'b01_1011:	ck	<=	32'hf4fb0209;
            6'b01_1100:	ck	<=	32'h10171e25;
            6'b01_1101:	ck	<=	32'h2c333a41;
            6'b01_1110:	ck	<=	32'h484f565d;
            6'b01_1111:	ck	<=	32'h646b7279;
            default:	ck	<=	32'h0;
        endcase
endmodule
