`timescale 1ns/1ps

module tb_pulse_gen();
    reg clk, rst_n, lvl_sig;
    wire pulse_sig;

    Pulse_Gen u_pulse (.CLK(clk), .RST(rst_n), .lvl_sig(lvl_sig), .pulse_sig(pulse_sig));

    always #10 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; lvl_sig = 0;
        #30 rst_n = 1;
        
        // Rising edge transition (Busy becomes 1)
        @(posedge clk); lvl_sig = 1;
        @(posedge clk);
        if (pulse_sig === 1'b1)
            $error("[FAIL] Pulse_Gen triggered on RISING edge! (Pops FIFO before TX finishes)");
            
        #100;
        // Falling edge transition (Busy drops to 0 when TX finishes)
        @(posedge clk); lvl_sig = 0;
        @(posedge clk);
        if (pulse_sig === 1'b1)
            $display("[PASS] Pulse_Gen correctly triggered on FALLING edge.");
        else
            $error("[FAIL] Pulse_Gen did not trigger pulse on FALLING edge.");
            
        $finish;
    end
endmodule