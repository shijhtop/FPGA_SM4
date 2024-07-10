`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/25 13:11:29
// Design Name: 
// Module Name: sm4_fpga
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


module sm4_fpga(
    input   wire   clk,
    input   wire   rst_n,
    input   wire   rx,
    output  wire   tx
    );
    localparam CLK_F    = 50_000_000;
    localparam UART_B   = 9600;
    localparam UART_DW  = 8;
    localparam SM4_DW   = 128;
    // SM4
    reg                 en_sm4 = 1'b1;
    reg                 encdec = 1'b1;
    reg                 en_key_exps = 1'b1;
    reg                 key_valid = 1'b1;
    reg  [      127:0]  key = 127'h0123_4567_89ab_cdef_fedc_ba98_7654_3210;
    wire                key_exps_done;
    reg  [ SM4_DW-1:0]  bdi;
    reg                 bdi_valid;
    wire [ SM4_DW-1:0]  bdo;
    wire                bdo_valid;
    // Uart
    reg                 tx_pdvalid;
    reg  [UART_DW-1:0]  tx_pdata;
    wire                tx_done;

    wire                rx_pdvalid;
    wire [UART_DW-1:0]  rx_pdata;

    // Register or Memory
    reg  [        1:0]  rx_pdvalid_reg;
    reg  [ SM4_DW-1:0]  bdi_reg;
    reg  [        4:0]  rxpd_cnt = 5'd0;
    
    reg  [UART_DW-1:0]  tx_pd_mem [SM4_DW/UART_DW-1:0];
    reg  [        4:0]  txpd_cnt = 5'd0;
    reg                 tx_work_en;

/************************ Iutput ********************************/
    /* rx parallel data valid */
    always @(posedge clk) begin
        if (!rst_n)
            rx_pdvalid_reg <= 2'b00;
        else if (rx_pdvalid)
            rx_pdvalid_reg <= {rx_pdvalid_reg[0], rx_pdvalid};
        else rx_pdvalid_reg <= 2'b00;
    end

    /* rx parallel data buffer */
    always @(posedge clk) begin
        if (!rst_n) begin
            bdi_reg <= 128'd0;
            rxpd_cnt <= 5'd0;
        end else if (rx_pdvalid_reg == 2'b01) begin
            bdi_reg <= {bdi_reg[SM4_DW-1-8:0], rx_pdata};
            rxpd_cnt <= rxpd_cnt + 1'b1;
        end else if (rxpd_cnt == 5'd16) begin
            rxpd_cnt <= 5'd0;
        end
    end
    /* put rx pd buffer into bdi */
    always @(posedge clk) begin
        if (!rst_n) begin
            bdi <= 128'd0;
            bdi_valid <= 1'd0;
        end else if (rxpd_cnt == 5'd16) begin
            bdi <= bdi_reg;
            bdi_valid <= 1'b1;
        end else begin
            bdi <= 128'd0;
            bdi_valid <= 1'b0;
        end
    end    

/************************ Output ********************************/
    /* put bdo into tx buffer */
    integer i;
    always @(posedge clk) begin : fortx
        if (!rst_n) begin
            for(i=0; i<SM4_DW/UART_DW; i=i+1)
                tx_pd_mem[i] <= 8'd0;
        end else if (bdo_valid) begin
            {
                tx_pd_mem[00],tx_pd_mem[01],tx_pd_mem[02],tx_pd_mem[03],
                tx_pd_mem[04],tx_pd_mem[05],tx_pd_mem[06],tx_pd_mem[07],
                tx_pd_mem[08],tx_pd_mem[09],tx_pd_mem[10],tx_pd_mem[11],
                tx_pd_mem[12],tx_pd_mem[13],tx_pd_mem[14],tx_pd_mem[15]
            } <= bdo;
        end
    end 
    /* tx work enable  */
    always @(posedge clk) begin
        if (!rst_n)
            tx_work_en <= 1'b0;
        else if (bdo_valid)
            tx_work_en <= 1'b1;
        else if (txpd_cnt == 5'd16)
            tx_work_en <= 1'b0;
    end     
    // tx
    always @(posedge clk) begin
        if (!rst_n) begin
            txpd_cnt <= 5'd0;
            tx_pdata <= 8'd0;
            tx_pdvalid <= 1'b0;
        end else if (tx_work_en && (txpd_cnt == 5'd0 || tx_done)) begin
            tx_pdata <= tx_pd_mem[txpd_cnt];
            tx_pdvalid <= 1'b1;
            txpd_cnt <= txpd_cnt + 1'b1;
        end else begin
            tx_pdvalid <= 1'b0;
            if (txpd_cnt == 5'd16) txpd_cnt <= 5'd0;
            if (tx_done) tx_pdata <= 8'd0;
        end 
    end    

    always @(posedge clk) begin
        if (!rst_n) begin
            en_key_exps <= 1'b1;
        end else en_key_exps <= 1'b0;
    end
/************************************/
/*********** Module Unit ****************/
/************************************/
    sm4_core sm4_unit(
        .clk(clk),
        .rst_n(rst_n),
        // flag
        .en_sm4(en_sm4),
        .encdec(encdec), // 0 en or 1 de
        // key exp
        .en_key_exps(en_key_exps),
        .key(key),
        .key_valid(key_valid),
        .key_exps_done(key_exps_done),
        // data in or out
        .bdi(bdi), // block data input 
        .bdi_valid(bdi_valid),
        .bdo(bdo), // block data output 
        .bdo_valid(bdo_valid)
    );

    uart #(
        .CLK_F(CLK_F),
        .UART_B(UART_B)
    ) uart_unit (
        .clk(clk),
        .rst_n(rst_n),
        /* data input */
        .tx_pdvalid(tx_pdvalid),
        .tx_pdata(tx_pdata),
        /* data output */
        .rx_pdvalid(rx_pdvalid),
        .rx_pdata(rx_pdata),
        /* Uart */
        .rx(rx),
        .tx(tx),
        /* flag */
        .tx_done(tx_done)
    ); 
endmodule
