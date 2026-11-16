`timescale 1ns/1ps

module tb_uart_rx();
    reg clk, rst_n, rx_in;
    wire [7:0] p_data;
    wire data_valid, parity_err, framing_err;
    
    // Instantiate UART_RX
    UART_RX #(.DATA_WIDTH(8)) u_rx (
        .CLK(clk), .RST(rst_n), .RX_IN(rx_in),
        .prescale(6'd32), .PAR_EN(1'b1), .PAR_TYP(1'b0),
        .P_DATA(p_data), .data_valid(data_valid),
        .Parity_Error(parity_err), .Stop_Error(framing_err)
    );

    // 3.6864 MHz Oversampling Clock (Period ~271.267 ns)
    always #135.633 clk = ~clk;

    task send_byte(input [7:0] byte_in);
        integer i;
        begin
            // Start bit
            @(posedge clk);
            rx_in <= 1'b0;
            repeat(32) @(posedge clk);
            
            // 8 Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_in <= byte_in[i];
                repeat(32) @(posedge clk);
            end
            
            // Even Parity bit
            rx_in <= ^byte_in;
            repeat(32) @(posedge clk);
            
            // Stop bit
            rx_in <= 1'b1;
            repeat(32) @(posedge clk);
        end
    endtask

    initial begin
        clk = 0; rst_n = 0; rx_in = 1;
        #500 rst_n = 1;
        
        send_byte(8'hBB);
        
        @(posedge clk);
        if (data_valid && p_data === 8'hBB)
            $display("[PASS] UART_RX received 0xBB correctly.");
        else
            $error("[FAIL] UART_RX failed: P_DATA = 0x%h, DATA_VALID = %b", p_data, data_valid);
            
        $finish;
    end
endmodule