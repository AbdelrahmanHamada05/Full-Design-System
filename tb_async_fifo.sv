`timescale 1ns/1ps

module tb_async_fifo();
    reg w_clk, w_rst_n, w_inc;
    reg [7:0] w_data;
    reg r_clk, r_rst_n, r_inc;
    wire [7:0] r_data;
    wire w_full, r_empty;

    Async_fifo #(.D_SIZE(8), .F_DEPTH(8)) u_fifo (
        .i_w_clk(w_clk), .i_w_rstn(w_rst_n), .i_w_inc(w_inc), .i_w_data(w_data), .o_full(w_full),
        .i_r_clk(r_clk), .i_r_rstn(r_rst_n), .i_r_inc(r_inc), .o_r_data(r_data), .o_empty(r_empty)
    );

    always #10  w_clk = ~w_clk;  // 50 MHz Write Clock
    always #135.633 r_clk = ~r_clk; // 3.6864 MHz Read Clock

    initial begin
        w_clk = 0; w_rst_n = 0; w_inc = 0; w_data = 8'h0;
        r_clk = 0; r_rst_n = 0; r_inc = 0;
        
        #100;
        w_rst_n = 1; r_rst_n = 1;

        // Push byte 0x3F into FIFO
        @(posedge w_clk); 
        w_data <= 8'h3F; 
        w_inc  <= 1'b1;
        
        @(posedge w_clk); 
        w_inc  <= 1'b0;

        // Wait 3 Read-Clock edges for synchronizer to cross clock domains
        repeat(3) @(posedge r_clk);
        #1; // Sample immediately after edge

        if (r_empty)
            $error("[FAIL] Async_fifo: o_empty stayed HIGH after write!");
        else if (r_data !== 8'h3F)
            $error("[FAIL] Async_fifo: Read data mismatch! Got 0x%h, Expected 0x3F", r_data);
        else
            $display("[PASS] Async_fifo cross-clock transfer verified.");
            
        $finish;
    end
endmodule