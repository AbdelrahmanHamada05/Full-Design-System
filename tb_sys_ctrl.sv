`timescale 1ns/1ps

module tb_sys_ctrl();
    reg clk, rst_n, rx_vld, fifo_full, alu_vld, rd_vld;
    reg [7:0] rx_pdata, rd_data;
    reg [15:0] alu_out;
    
    wire [3:0] addr;
    wire [7:0] wr_data;
    wire wr_en, rd_en, alu_en, clkg_en, fifo_w_inc;
    wire [7:0] fifo_w_data;

    SYS_CTRL u_ctrl (
        .CLK(clk), 
        .RST(rst_n), 
        .RX_P_DATA(rx_pdata), 
        .RX_D_VLD(rx_vld),
        .RdData(rd_data), 
        .RdData_Valid(rd_vld),
        .ALU_OUT(alu_out), 
        .ALU_OUT_Valid(alu_vld),      // Fixed port name
        .FIFO_FULL(fifo_full),
        .Address(addr), 
        .WrEn(wr_en), 
        .RdEn(rd_en), 
        .WrData(wr_data),
        .ALU_EN(alu_en), 
        .CLKG_EN(clkg_en),
        .TX_D_VLD(fifo_w_inc),         // Fixed port name
        .TX_P_DATA(fifo_w_data)        // Fixed port name
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; rx_vld = 0; rx_pdata = 0; rd_vld = 0; alu_vld = 0; fifo_full = 0;
        #50 rst_n = 1;

        // Command 0xBB (Read Register)
        @(posedge clk); 
        rx_pdata <= 8'hBB; 
        rx_vld   <= 1'b1;

        @(posedge clk); 
        rx_vld   <= 1'b0;
        
        // Send Address 0x04
        @(posedge clk); 
        rx_pdata <= 8'h04; 
        rx_vld   <= 1'b1;

        @(posedge clk); 
        rx_vld   <= 1'b0;

        // Simulate RegFile response
        @(posedge clk); 
        rd_data  <= 8'h3F; 
        rd_vld   <= 1'b1;

        @(posedge clk); 
        rd_vld   <= 1'b0;

        // SYS_CTRL moves RD_WAIT -> RD_PUSH; sample on the active write pulse
        @(posedge clk);
        if (fifo_w_inc && fifo_w_data === 8'h3F)
            $display("[PASS] SYS_CTRL correctly handled 0xBB Read Command.");
        else
            $error("[FAIL] SYS_CTRL failed to trigger FIFO write for 0xBB Read Command. (inc=%b, data=0x%h)", fifo_w_inc, fifo_w_data);

        $finish;
    end
endmodule