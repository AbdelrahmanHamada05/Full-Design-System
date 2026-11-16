
######################### Formality : post-synthesis ##########################
# reference      = RTL
# implementation = SYS_TOP_netlist.v written by Design Compiler
# run from the syn folder:   fm_shell -f fm_syn.tcl | tee fm_syn.log

set synopsys_auto_setup true

set top     SYS_TOP
set RTL_DIR /home/ICer/SYSTEM
set LIB_DIR /home/ICer/SYSTEM/std_cells

# guidance recorded by Design Compiler (must be set before reading the designs)
set_svf ./SYS_TOP.svf

set db_list [list $LIB_DIR/scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db \
                  $LIB_DIR/scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db \
                  $LIB_DIR/scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db]

###################### Reference design (RTL) ###################################
set rtl_files [list \
    $RTL_DIR/ALU/ALU.v \
    $RTL_DIR/Async_FIFO/Async_fifo.v \
    $RTL_DIR/Async_FIFO/ASYNC_FIFO_f.v \
    $RTL_DIR/Async_FIFO/DF_SYNC.v \
    $RTL_DIR/Async_FIFO/FIFO_MEM_CNTRL.v \
    $RTL_DIR/Async_FIFO/fifo_rd.v \
    $RTL_DIR/Async_FIFO/FIFO_WR.v \
    $RTL_DIR/Clock_Divider/Clock_Divider.v \
    $RTL_DIR/Clock_DIV_MUX/CLKDIV_MUX.v \
    $RTL_DIR/Clock_Gating/CLK_GATE.v \
    $RTL_DIR/Data_Sync/Data_Sync.v \
    $RTL_DIR/Data_Sync/FF.v \
    $RTL_DIR/Data_Sync/Multi_FF.v \
    $RTL_DIR/Data_Sync/MUX_21_REG.v \
    $RTL_DIR/Data_Sync/Pulse_Gen_Pos.v \
    $RTL_DIR/Pulse_Gen/Pulse_Gen.v \
    $RTL_DIR/Register_File/RegFile.v \
    $RTL_DIR/Reset_Sync/RST_Sync.v \
    $RTL_DIR/SYS_CTRL/SYS_CTRL.v \
    $RTL_DIR/TOP/SYS_TOP.v \
    $RTL_DIR/UART/UART_RX/data_sampling.v \
    $RTL_DIR/UART/UART_RX/deserializer.v \
    $RTL_DIR/UART/UART_RX/edge_bit_counter.v \
    $RTL_DIR/UART/UART_RX/par_check.v \
    $RTL_DIR/UART/UART_RX/RX_FSM.v \
    $RTL_DIR/UART/UART_RX/stp_check.v \
    $RTL_DIR/UART/UART_RX/strt_check.v \
    $RTL_DIR/UART/UART_RX/UART_RX.v \
    $RTL_DIR/UART/UART_TOP/UART.v \
    $RTL_DIR/UART/UART_TX/parity_calc.v \
    $RTL_DIR/UART/UART_TX/serializer.v \
    $RTL_DIR/UART/UART_TX/TX_FSM.v \
    $RTL_DIR/UART/UART_TX/UART_TX.v]

read_verilog -container r -libname WORK $rtl_files
read_db -container r $db_list
set_top r:/WORK/$top

###################### Implementation design (netlist) ##########################
read_verilog -container i -libname WORK -netlist ./SYS_TOP_netlist.v
read_db -container i $db_list
set_top i:/WORK/$top

###################### Matching ################################################
match
report_unmatched_points > unmatched_points.rpt

###################### Verification ############################################
set successful [verify]

if {!$successful} {
    diagnose
    analyze_points -failing
}

report_passing_points    > passing_points.rpt
report_failing_points    > failing_points.rpt
report_aborted_points    > aborted_points.rpt
report_unverified_points > unverified_points.rpt

if {$successful} {
    puts "###### FORMALITY POST-SYNTHESIS: VERIFICATION SUCCEEDED ######"
} else {
    puts "###### FORMALITY POST-SYNTHESIS: VERIFICATION FAILED ######"
}

#start_gui
#exit
