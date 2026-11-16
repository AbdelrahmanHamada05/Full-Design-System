`timescale 1ns/1ps
//==============================================================================
// SYS_TOP testbench
//   REF_CLK  = 50 MHz, UART_CLK = 3.6864 MHz, default UART config (parity on, even,
//   prescale 32, divide ratio 32 -> 115200 baud)
//
//   Test cases
//     TC1  Register File Write  (0xAA)   incl. configuration writes to 0x2 / 0x3
//     TC2  Register File Read   (0xBB)
//     TC3  ALU with operands    (0xCC)
//     TC4  ALU without operands (0xDD)   all 14 ALU functions, checked by a reference model
//     TC5  Error handling                bad parity frame / bad stop frame are rejected
//     TC6  Recovery                      valid command is accepted after the bad frames
//   Machine readable lines are printed as  RESULT|<tc>|<description>|<PASS/FAIL>|<t_start_ns>|<t_end_ns>
//==============================================================================
module SYS_TOP_tb ();

    parameter DATA_WIDTH = 8;
    parameter RF_ADDR    = 4;

    parameter  REF_CLK_PERIOD  = 20.0;       // 50 MHz
    parameter  UART_CLK_PERIOD = 271.267;    // 3.6864 MHz
    localparam real BIT_PERIOD = 32.0 * UART_CLK_PERIOD;   // 115200 baud

    // Command opcodes
    localparam [7:0] CMD_RF_WRITE    = 8'hAA;
    localparam [7:0] CMD_RF_READ     = 8'hBB;
    localparam [7:0] CMD_ALU_WITH_OP = 8'hCC;
    localparam [7:0] CMD_ALU_NO_OP   = 8'hDD;

    // ALU functions
    localparam [3:0] ALU_ADD  = 4'b0000,
                     ALU_SUB  = 4'b0001,
                     ALU_MUL  = 4'b0010,
                     ALU_DIV  = 4'b0011,
                     ALU_AND  = 4'b0100,
                     ALU_OR   = 4'b0101,
                     ALU_NAND = 4'b0110,
                     ALU_NOR  = 4'b0111,
                     ALU_XOR  = 4'b1000,
                     ALU_XNOR = 4'b1001,
                     ALU_EQ   = 4'b1010,
                     ALU_GT   = 4'b1011,
                     ALU_SHR  = 4'b1100,
                     ALU_SHL  = 4'b1101;

    reg   RST_N, UART_CLK, REF_CLK, UART_RX_IN;
    wire  UART_TX_O, parity_error, framing_error;

    // DUT
    SYS_TOP #(.DATA_WIDTH(DATA_WIDTH), .RF_ADDR(RF_ADDR)) DUT (
        .RST_N         (RST_N),
        .UART_CLK      (UART_CLK),
        .REF_CLK       (REF_CLK),
        .UART_RX_IN    (UART_RX_IN),
        .UART_TX_O     (UART_TX_O),
        .parity_error  (parity_error),
        .framing_error (framing_error)
    );

    // Clocks
    always #(REF_CLK_PERIOD  / 2.0) REF_CLK  = ~REF_CLK;
    always #(UART_CLK_PERIOD / 2.0) UART_CLK = ~UART_CLK;

    //--------------------------------------------------------------------------
    // Bookkeeping
    //--------------------------------------------------------------------------
    integer errors      = 0;
    integer tc_errors   = 0;
    integer checks      = 0;
    real    tc_start    = 0.0;
    integer i;

    reg [7:0] rx_data;
    reg       rx_par_ok, rx_stp_ok, rx_start_ok;

    // sticky monitors for the error outputs and for TX activity
    reg par_err_seen = 0, stp_err_seen = 0, tx_activity = 0;
    always @(posedge parity_error) par_err_seen = 1;
    always @(posedge framing_error) stp_err_seen = 1;
    always @(negedge UART_TX_O)    tx_activity  = 1;

    //--------------------------------------------------------------------------
    // Reference model of the ALU (16-bit result)
    //--------------------------------------------------------------------------
    function [15:0] alu_ref (input [7:0] a, input [7:0] b, input [3:0] f);
        begin
            case (f)
                ALU_ADD : alu_ref = a + b;
                ALU_SUB : alu_ref = a - b;
                ALU_MUL : alu_ref = a * b;
                ALU_DIV : alu_ref = (b == 0) ? 16'd0 : a / b;
                ALU_AND : alu_ref = {8'd0, a & b};
                ALU_OR  : alu_ref = {8'd0, a | b};
                ALU_NAND: alu_ref = {8'd0, ~(a & b)};
                ALU_NOR : alu_ref = {8'd0, ~(a | b)};
                ALU_XOR : alu_ref = {8'd0, a ^ b};
                ALU_XNOR: alu_ref = {8'd0, ~(a ^ b)};
                ALU_EQ  : alu_ref = (a == b) ? 16'd1 : 16'd0;
                ALU_GT  : alu_ref = (a >  b) ? 16'd2 : 16'd0;
                ALU_SHR : alu_ref = {8'd0, a} >> 1;
                ALU_SHL : alu_ref = {8'd0, a} << 1;
                default : alu_ref = 16'd0;
            endcase
        end
    endfunction

    //--------------------------------------------------------------------------
    // UART master tasks
    //--------------------------------------------------------------------------
    // send one frame on RX_IN (start, 8 data bits LSB first, even parity, stop)
    task send_frame (input [7:0] data, input bad_parity, input bad_stop);
        integer k;
        begin
            UART_RX_IN = 1'b0;                          // start bit
            #(BIT_PERIOD);
            for (k = 0; k < 8; k = k + 1) begin
                UART_RX_IN = data[k];                   // LSB first
                #(BIT_PERIOD);
            end
            UART_RX_IN = (^data) ^ bad_parity;          // even parity
            #(BIT_PERIOD);
            UART_RX_IN = bad_stop ? 1'b0 : 1'b1;        // stop bit
            #(BIT_PERIOD);
            UART_RX_IN = 1'b1;
        end
    endtask

    task send (input [7:0] data);
        begin
            send_frame(data, 1'b0, 1'b0);
        end
    endtask

    // receive one frame from TX_OUT and check start / parity / stop bits
    task receive_frame;
        integer k;
        reg     par_bit, stop_bit;
        begin
            @(negedge UART_TX_O);
            #(BIT_PERIOD / 2.0);                        // middle of the start bit
            rx_start_ok = (UART_TX_O === 1'b0);
            for (k = 0; k < 8; k = k + 1) begin
                #(BIT_PERIOD);
                rx_data[k] = UART_TX_O;
            end
            #(BIT_PERIOD);
            par_bit   = UART_TX_O;
            #(BIT_PERIOD);
            stop_bit  = UART_TX_O;
            rx_par_ok = (par_bit === (^rx_data));       // even parity
            rx_stp_ok = (stop_bit === 1'b1);
        end
    endtask

    task check_value (input [15:0] got, input [15:0] exp, input [8*40-1:0] what);
        begin
            checks = checks + 1;
            if (got === exp)
                $display("      [ok]   %0s = 0x%0h", what, got);
            else begin
                $display("      [FAIL] %0s : expected 0x%0h, got 0x%0h", what, exp, got);
                errors = errors + 1;  tc_errors = tc_errors + 1;
            end
        end
    endtask

    // receive one byte and check the frame format
    task expect_byte (input [7:0] exp, input [8*40-1:0] what);
        begin
            receive_frame;
            if (!rx_start_ok || !rx_par_ok || !rx_stp_ok) begin
                $display("      [FAIL] %0s : bad TX frame format (start_ok=%b parity_ok=%b stop_ok=%b)",
                         what, rx_start_ok, rx_par_ok, rx_stp_ok);
                errors = errors + 1;  tc_errors = tc_errors + 1;
            end
            check_value({8'd0, rx_data}, {8'd0, exp}, what);
        end
    endtask

    //--------------------------------------------------------------------------
    // Command tasks
    //--------------------------------------------------------------------------
    task rf_write (input [7:0] addr, input [7:0] data);
        begin
            send(CMD_RF_WRITE); send(addr); send(data);
            $display("      RF write  addr=0x%0h data=0x%0h", addr, data);
        end
    endtask

    task rf_read (input [7:0] addr, input [7:0] exp);
        begin
            send(CMD_RF_READ); send(addr);
            expect_byte(exp, "RF read data");
        end
    endtask

    task alu_with_op (input [7:0] a, input [7:0] b, input [3:0] f);
        reg [15:0] exp;
        begin
            exp = alu_ref(a, b, f);
            send(CMD_ALU_WITH_OP); send(a); send(b); send({4'b0, f});
            $display("      ALU (0xCC) A=%0d B=%0d FUN=0x%0h", a, b, f);
            expect_byte(exp[7:0],  "ALU result LSB");
            expect_byte(exp[15:8], "ALU result MSB");
        end
    endtask

    task alu_no_op (input [7:0] a, input [7:0] b, input [3:0] f);
        reg [15:0] exp;
        begin
            exp = alu_ref(a, b, f);
            send(CMD_ALU_NO_OP); send({4'b0, f});
            $display("      ALU (0xDD) A=%0d B=%0d (stored) FUN=0x%0h", a, b, f);
            expect_byte(exp[7:0],  "ALU result LSB");
            expect_byte(exp[15:8], "ALU result MSB");
        end
    endtask

    task tc_begin (input [8*60-1:0] name);
        begin
            tc_errors = 0;
            tc_start  = $realtime;
            $display("\n[%0.0f ns] %0s", $realtime, name);
        end
    endtask

    task tc_end (input integer num, input [8*60-1:0] name);
        begin
            if (tc_errors == 0)
                $display("RESULT|TC%0d|%0s|PASS|%0d|%0d", num, name, to_ns(tc_start), to_ns($realtime));
            else
                $display("RESULT|TC%0d|%0s|FAIL|%0d|%0d", num, name, to_ns(tc_start), to_ns($realtime));
        end
    endtask

    // helper: time in whole ns
    function integer to_ns (input real t);
        begin
            to_ns = t;
        end
    endfunction

    //--------------------------------------------------------------------------
    // Waveform dump of the interesting signals (compile with +define+DUMP)
    //--------------------------------------------------------------------------
`ifdef DUMP
    initial begin
        $dumpfile("sys_top.vcd");
        $dumpvars(0, RST_N, UART_RX_IN, UART_TX_O, parity_error, framing_error);
        $dumpvars(0, DUT.UART_RX_OUT, DUT.UART_RX_V_OUT, DUT.UART_RX_SYNC, DUT.UART_RX_V_SYNC,
                     DUT.RF_WrEn, DUT.RF_RdEn, DUT.RF_Address, DUT.RF_WrData, DUT.RF_RdData,
                     DUT.RF_RdData_VLD, DUT.ALU_EN, DUT.ALU_FUN, DUT.ALU_OUT, DUT.ALU_OUT_VLD,
                     DUT.CLKG_EN, DUT.Operand_A, DUT.Operand_B, DUT.UART_Config, DUT.DIV_RATIO,
                     DUT.UART_TX_IN, DUT.UART_TX_VLD, DUT.FIFO_FULL, DUT.UART_TX_V_SYNC,
                     DUT.UART_TX_SYNC, DUT.UART_TX_Busy, DUT.UART_TX_Busy_PULSE);
    end
`endif

    //--------------------------------------------------------------------------
    // Main test sequence
    //--------------------------------------------------------------------------
    initial begin
        REF_CLK = 0; UART_CLK = 0; RST_N = 1; UART_RX_IN = 1;

        $display("=================================================");
        $display("          STARTING SYS_TOP TESTBENCH             ");
        $display("=================================================");

        // reset
        #5;
        RST_N = 1'b0;
        #100;
        RST_N = 1'b1;
        repeat (20) @(posedge UART_CLK);        // let the synchronized resets release

        //----------------------------------------------------------------------
        tc_begin("TC1: Register File Write (0xAA)");
        rf_write(8'h02, 8'h81);     // configuration: parity enable, even, prescale 32
        rf_write(8'h03, 8'h20);     // configuration: division ratio 32
        rf_write(8'h04, 8'h3F);
        rf_write(8'h0F, 8'hA5);
        tc_end(1, "Register File Write (0xAA)");

        //----------------------------------------------------------------------
        tc_begin("TC2: Register File Read (0xBB)");
        rf_read(8'h04, 8'h3F);
        rf_read(8'h0F, 8'hA5);
        rf_read(8'h02, 8'h81);      // configuration registers read back
        rf_read(8'h03, 8'h20);
        tc_end(2, "Register File Read (0xBB)");

        //----------------------------------------------------------------------
        tc_begin("TC3: ALU operation WITH operands (0xCC)");
        alu_with_op(8'd25,  8'd10, ALU_ADD);     // 35
        alu_with_op(8'd25,  8'd10, ALU_SUB);     // 15
        alu_with_op(8'd200, 8'd3,  ALU_MUL);     // 600 = 0x0258 (uses the MSB byte)
        alu_with_op(8'd100, 8'd7,  ALU_DIV);     // 14
        tc_end(3, "ALU with operands (0xCC)");

        //----------------------------------------------------------------------
        tc_begin("TC4: ALU operation WITHOUT operands (0xDD), all functions");
        alu_with_op(8'd182, 8'd45, ALU_ADD);     // load operands A=182, B=45
        for (i = 0; i < 14; i = i + 1)
            alu_no_op(8'd182, 8'd45, i[3:0]);
        tc_end(4, "ALU without operands (0xDD)");

        //----------------------------------------------------------------------
        tc_begin("TC5: Error handling (bad parity / bad stop frames)");
        par_err_seen = 0; stp_err_seen = 0; tx_activity = 0;
        send_frame(CMD_RF_READ, 1'b1, 1'b0);     // read command with wrong parity
        check_value({15'd0, par_err_seen}, 16'd1, "parity_error raised");
        send(8'h04);                             // would be the address; 0x04 is not a command
        repeat (200) @(posedge UART_CLK);
        check_value({15'd0, tx_activity}, 16'd0, "no response to bad parity frame");

        send_frame(CMD_RF_READ, 1'b0, 1'b1);     // read command with stop bit = 0
        repeat (10) @(posedge UART_CLK);         // the DUT flags the error a few clocks after the stop bit
        check_value({15'd0, stp_err_seen}, 16'd1, "framing_error raised");
        send(8'h04);
        repeat (200) @(posedge UART_CLK);
        check_value({15'd0, tx_activity}, 16'd0, "no response to bad stop frame");
        tc_end(5, "Error handling");

        //----------------------------------------------------------------------
        tc_begin("TC6: Normal operation after the bad frames");
        rf_read(8'h04, 8'h3F);
        alu_with_op(8'd7, 8'd9, ALU_ADD);        // 16
        tc_end(6, "Recovery after errors");

        $display("\n=================================================");
        $display("checks = %0d, errors = %0d", checks, errors);
        if (errors == 0) $display("          ALL TEST CASES PASSED                  ");
        else             $display("          TEST FAILED                            ");
        $display("=================================================");
        $finish;
    end

    // watchdog
    initial begin
        #50_000_000;
        $display("TIMEOUT: testbench did not finish");
        $finish;
    end

endmodule
