`timescale 1ns/1ps

module tb_clock_subsystem();
    reg clk, rst_n, clk_en;
    reg [5:0] prescale;
    wire [7:0] div_ratio;
    wire div_clk;

    // Instantiate MUX and Divider
    CLKDIV_MUX u_mux (.IN(prescale), .OUT(div_ratio));
    Clock_Divider u_div (
        .i_ref_clk(clk),
        .i_rst_n(rst_n),
        .i_clk_en(clk_en),
        .i_div_ratio(div_ratio),
        .o_div_clk(div_clk)
    );

    always #5 clk = ~clk; // 100 MHz reference clock

    initial begin
        clk = 0; rst_n = 0; clk_en = 1; prescale = 6'b100000; // Prescale 32
        #20 rst_n = 1;
        
        #1000;
        if (div_ratio != 8'd32) 
            $error("[FAIL] CLKDIV_MUX: Prescale 32 mapped to %d (Expected 32)", div_ratio);
        else if (div_clk === 1'b0 || div_clk === 1'bx) 
            $error("[FAIL] Clock_Divider: Output clock is DEAD/STUCK at 0");
        else 
            $display("[PASS] Clock Subsystem functioning correctly.");
        $finish;
    end
endmodule