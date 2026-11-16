################################################################################
# Design Compiler DFT Synthesis Script (dft_script.tcl)
################################################################################

set top_module SYS_TOP

define_design_lib work -path ./work

set PROJECT_DIR   /home/ICer/SYSTEM
set STD_CELLS_DIR $PROJECT_DIR/std_cells
set RTL_DIR       $PROJECT_DIR

lappend search_path $STD_CELLS_DIR

foreach blk {ALU Async_FIFO Clock_Divider Clock_DIV_MUX Clock_Gating Data_Sync Pulse_Gen Register_File Reset_Sync SYS_CTRL TOP UART/UART_RX UART/UART_TOP UART/UART_TX} {
    lappend search_path $RTL_DIR/$blk
}

set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

set target_library [list $SSLIB $TTLIB $FFLIB]
set link_library   [list * $SSLIB $TTLIB $FFLIB]

set_svf SYS_TOP_dft.svf

######################## Read RTL Files ########################################
set file_format verilog

read_file -format $file_format ALU.v
read_file -format $file_format Async_fifo.v
read_file -format $file_format ASYNC_FIFO_f.v
read_file -format $file_format DF_SYNC.v
read_file -format $file_format FIFO_MEM_CNTRL.v
read_file -format $file_format fifo_rd.v
read_file -format $file_format FIFO_WR.v
read_file -format $file_format Clock_Divider.v
read_file -format $file_format CLKDIV_MUX.v
read_file -format $file_format CLK_GATE.v
read_file -format $file_format Data_Sync.v
read_file -format $file_format FF.v
read_file -format $file_format Multi_FF.v
read_file -format $file_format MUX_21_REG.v
read_file -format $file_format Pulse_Gen_Pos.v
read_file -format $file_format Pulse_Gen.v
read_file -format $file_format RegFile.v
read_file -format $file_format RST_Sync.v
read_file -format $file_format SYS_CTRL.v
read_file -format $file_format SYS_TOP_dft.v
read_file -format $file_format data_sampling.v
read_file -format $file_format deserializer.v
read_file -format $file_format edge_bit_counter.v
read_file -format $file_format par_check.v
read_file -format $file_format RX_FSM.v
read_file -format $file_format stp_check.v
read_file -format $file_format strt_check.v
read_file -format $file_format UART_RX.v
read_file -format $file_format UART.v
read_file -format $file_format parity_calc.v
read_file -format $file_format serializer.v
read_file -format $file_format TX_FSM.v
read_file -format $file_format UART_TX.v

current_design $top_module
link
check_design

# Source DFT Constraints
source -echo ./cons_dft.tcl

# Initial Synthesis Compile
set_fix_multiple_port_nets -all -buffer_constants
compile -scan

################################################################################
# DFT Compiler Configuration & Insertion
################################################################################

# Step 1: Scan Chains Architecture
set_scan_configuration -chain_count 3 \
                       -clock_mixing no_mix \
                       -style multiplexed_flip_flop

# Step 2: Define DFT Signals
set_dft_signal -view existing_dft -type ScanClock   -port scan_clk  -timing [list 45 55]
set_dft_signal -view existing_dft -type Reset       -port scan_rst  -active_state 0
set_dft_signal -view existing_dft -type TestMode    -port test_mode -active_state 1

set_dft_signal -view spec         -type ScanEnable   -port SE        -active_state 1
set_dft_signal -view spec         -type ScanDataIn   -port SI
set_dft_signal -view spec         -type ScanDataOut  -port SO

# Step 3: Create Test Protocol
create_test_protocol

# Step 4: Pre-DFT Design Rule Checking
dft_drc > dft_drc_pre.rpt

# Step 5: Preview DFT
preview_dft -show all > preview_dft.rpt

# Step 6: Insert DFT
insert_dft

# Step 7: Post-DFT Design Rule Checking
dft_drc > dft_drc_post.rpt
dft_drc -coverage_estimation > dft_coverage.rpt

################################################################################
# Save Netlist, Output Files & Reports
################################################################################
change_names -rules verilog -hierarchy

write_file -format verilog -hierarchy -output SYS_TOP_dft_netlist.v
write_file -format ddc     -hierarchy -output SYS_TOP_dft_netlist.ddc
write_sdc  -nosplit SYS_TOP_dft.sdc
write_sdf           SYS_TOP_dft.sdf
write_test_protocol -output SYS_TOP_dft.spf

set_svf -off

report_area -hierarchy                      > dft_area.rpt
report_power -hierarchy                     > dft_power.rpt
report_timing -max_paths 100 -delay_type min > dft_hold.rpt
report_timing -max_paths 100 -delay_type max > dft_setup.rpt
report_scan_path -view Existing_dft -chain all > scan_chains.rpt
check_design                                > dft_check_design.rpt