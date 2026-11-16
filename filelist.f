./Register_File/RegFile.v
./TOP/SYS_TOP.v

./SYS_CTRL/SYS_CTRL.v

./ALU/ALU.v

./Clock_Gating/CLK_GATE.v

./Clock_DIV_MUX/CLKDIV_MUX.v

./UART/UART_TOP/UART.v

./UART/UART_RX/UART_RX.v
./UART/UART_RX/RX_FSM.v
./UART/UART_RX/deserializer.v
./UART/UART_RX/par_check.v
./UART/UART_RX/edge_bit_counter.v
./UART/UART_RX/data_sampling.v
./UART/UART_RX/strt_check.v
./UART/UART_RX/stp_check.v

./UART/UART_TX/TX_FSM.v
./UART/UART_TX/serializer.v
./UART/UART_TX/parity_calc.v
./UART/UART_TX/UART_TX.v

./Async_FIFO/fifo_rd.v
./Async_FIFO/fifo_mem.v
./Async_FIFO/Async_fifo.v
./Async_FIFO/fifo_wr.v
./Async_FIFO/DF_SYNC.v
./Async_FIFO/FIFO_MEM_CNTRL.v
./Async_FIFO/ASYNC_FIFO_f.v

./Reset_Sync/RST_Sync.v

./Clock_Divider/Clock_Divider.v

./Data_Sync/Multi_FF.v
./Data_Sync/MUX_21_REG.v
./Data_Sync/FF.v
./Data_Sync/Data_Sync.v
./Data_Sync/Pulse_Gen_Pos.v
./Pulse_Gen/Pulse_Gen.v


./SYS_TOP_tb.sv
./tb_clock_subsystem.sv
./tb_sys_ctrl.sv
./tb_uart_rx.sv
./tb_pulse_gen.sv