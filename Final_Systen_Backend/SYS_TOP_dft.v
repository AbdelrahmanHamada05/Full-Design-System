module SYS_TOP #(
    parameter DATA_WIDTH    = 8,
    parameter RF_ADDR       = 4,
    parameter NUM_OF_CHAINS = 3
) (
    // Scan Ports
    input  wire                       scan_clk,
    input  wire                       scan_rst,
    input  wire                       test_mode,
    input  wire                       SE,
    input  wire [NUM_OF_CHAINS-1:0]   SI,
    output wire [NUM_OF_CHAINS-1:0]   SO,

    // Functional Ports
    input  wire                       RST_N,
    input  wire                       UART_CLK,
    input  wire                       REF_CLK,
    input  wire                       UART_RX_IN,
    output wire                       UART_TX_O,
    output wire                       parity_error,
    output wire                       framing_error
);

    // Clock and Reset MUXing for Test Mode
    wire ref_clk_muxed  = test_mode ? scan_clk : REF_CLK;
    wire uart_clk_muxed = test_mode ? scan_clk : UART_CLK;
    wire rst_n_muxed    = test_mode ? scan_rst : RST_N;

    // Internal Wires
    wire        rst_sync_ref;
    wire        rst_sync_uart;
    wire        gate_clk;
    wire        rx_clk;
    wire        tx_clk;
    
    wire [7:0]  rx_pdata;
    wire        rx_dvld;
    wire [7:0]  sync_rx_pdata;
    wire        sync_rx_dvld;

    wire [7:0]  rf_rd_data;
    wire        rf_rd_data_vld;
    wire        rf_wr_en;
    wire        rf_rd_en;
    wire [3:0]  rf_addr;
    wire [7:0]  rf_wr_data;

    wire [15:0] alu_out;
    wire        alu_out_vld;
    wire [3:0]  alu_fun;
    wire        alu_en;
    wire        clkg_en;

    wire [7:0]  fifo_wr_data;
    wire        fifo_wr_inc;
    wire        fifo_full;
    wire        fifo_empty;
    wire [7:0]  fifo_rd_data;

    wire        tx_busy;
    wire        tx_busy_pulse;
    wire        clk_div_en;

    // Reset Synchronizers
    RST_Sync u_rst_sync_ref (
        .CLK(ref_clk_muxed),
        .RST(rst_n_muxed),
        .SYNC_RST(rst_sync_ref)
    );

    RST_Sync u_rst_sync_uart (
        .CLK(uart_clk_muxed),
        .RST(rst_n_muxed),
        .SYNC_RST(rst_sync_uart)
    );

    // Clock Divider (UART_CLK -> RX_CLK & TX_CLK)
    Clock_Divider U1_ClkDiv (
        .i_ref_clk(uart_clk_muxed),
        .i_rst_n(rst_sync_uart),
        .i_clk_en(clk_div_en),
        .i_div_ratio(8'd1), // Fixed typo (was 8 me'd1)
        .o_div_clk(rx_clk)
    );

    Clock_Divider U0_ClkDiv (
        .i_ref_clk(uart_clk_muxed),
        .i_rst_n(rst_sync_uart),
        .i_clk_en(clk_div_en),
        .i_div_ratio(8'd32),
        .o_div_clk(tx_clk)
    );

    // Clock Gate (ALU Clock)
    CLK_GATE U0_CLK_GATE (
        .CLK(ref_clk_muxed),
        .CLK_EN(clkg_en),
        .GATED_CLK(gate_clk)
    );

    // UART Top Module
    UART #(.DATA_WIDTH(8)) u_uart (
        .RST_RX(rst_sync_uart),
        .CLK_RX(rx_clk),
        .RX_IN(UART_RX_IN),
        .Prescale(6'd32),
        .PAR_EN(1'b1),
        .PAR_TYP(1'b0),
        .RX_OUT_P_DATA(rx_pdata),
        .RX_OUT_VLD(rx_dvld),
        .Parity_Error(parity_error),
        .Stop_Error(framing_error),

        .RST_TX(rst_sync_uart),
        .CLK_TX(tx_clk),
        .TX_IN_P_DATA(fifo_rd_data),
        .TX_IN_VLD(!fifo_empty),
        .TX_OUT_S_DATA(UART_TX_O),
        .Busy(tx_busy)
    );

    // Pulse Generator for FIFO Read Pop
    Pulse_Gen_Neg U0_PULSE_GEN (
        .CLK(tx_clk),
        .RST(rst_sync_uart),
        .lvl_sig(tx_busy),
        .pulse_sig(tx_busy_pulse)
    );

    // Async FIFO
    Async_fifo #(
        .D_SIZE(8),
        .A_SIZE(3),
        .P_SIZE(4),
        .F_DEPTH(8)
    ) u_async_fifo (
        .i_w_clk(ref_clk_muxed),
        .i_w_rstn(rst_sync_ref),
        .i_w_inc(fifo_wr_inc),
        .i_w_data(fifo_wr_data),
        .o_full(fifo_full),

        .i_r_clk(tx_clk),
        .i_r_rstn(rst_sync_uart),
        .i_r_inc(tx_busy_pulse),
        .o_r_data(fifo_rd_data),
        .o_empty(fifo_empty)
    );

    // Data Synchronizer (UART_RX -> REF_CLK domain)
    Data_Sync #(.NUM_STAGES(2), .BUS_WIDTH(8)) u_data_sync (
        .CLK(ref_clk_muxed),
        .RST(rst_sync_ref),
        .unsync_bus(rx_pdata),
        .bus_enable(rx_dvld),
        .sync_bus(sync_rx_pdata),
        .enable_pulse(sync_rx_dvld)
    );

    // System Controller
    SYS_CTRL u_sys_ctrl (
        .CLK(ref_clk_muxed),
        .RST(rst_sync_ref),
        .RdData(rf_rd_data),
        .RdData_Valid(rf_rd_data_vld),
        .WrEn(rf_wr_en),
        .RdEn(rf_rd_en),
        .Address(rf_addr),
        .WrData(rf_wr_data),
        .ALU_OUT(alu_out),
        .ALU_OUT_Valid(alu_out_vld),
        .ALU_FUN(alu_fun),
        .ALU_EN(alu_en),
        .CLKG_EN(clkg_en),
        .RX_P_DATA(sync_rx_pdata),
        .RX_D_VLD(sync_rx_dvld),
        .TX_P_DATA(fifo_wr_data),
        .TX_D_VLD(fifo_wr_inc),
        .FIFO_FULL(fifo_full),
        .clk_div_en(clk_div_en)
    );

    // Register File
    RegFile #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) u_regfile (
        .CLK(ref_clk_muxed),
        .RST(rst_sync_ref),
        .WrEn(rf_wr_en),
        .RdEn(rf_rd_en),
        .Address(rf_addr),
        .WrData(rf_wr_data),
        .RdData(rf_rd_data),
        .RdData_Valid(rf_rd_data_vld)
    );

    // ALU Module
    ALU #(.OPERAND_WIDTH(8), .RESULT_WIDTH(16)) u_alu (
        .CLK(gate_clk),
        .RST(rst_sync_ref),
        .A(u_regfile.REG0),
        .B(u_regfile.REG1),
        .ALU_FUN(alu_fun),
        .ALU_EN(alu_en),
        .ALU_OUT(alu_out),
        .OUT_VALID(alu_out_vld)
    );

endmodule