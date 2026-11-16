# ==============================================================================
# DFT Design Constraints (cons_dft.tcl)
# ==============================================================================

set CLK_SETUP_SKEW 0.2
set CLK_HOLD_SKEW  0.1
set CLK_RISE       0.05
set CLK_FALL       0.05

# Base Clock Periods
set REF_CLK_PER   20
set UART_CLK_PER  271.27
set SCAN_CLK_PER  100
set RX_CLK_PER    $UART_CLK_PER
set TX_CLK_PER    [expr 32 * $UART_CLK_PER]

# ---------------------------------------------------------------- Master Clocks
create_clock -name REF_CLK  -period $REF_CLK_PER  -waveform "0 [expr $REF_CLK_PER/2]"  [get_ports REF_CLK]
create_clock -name UART_CLK -period $UART_CLK_PER -waveform "0 [expr $UART_CLK_PER/2]" [get_ports UART_CLK]
create_clock -name SCAN_CLK -period $SCAN_CLK_PER -waveform "0 [expr $SCAN_CLK_PER/2]" [get_ports scan_clk]

# ------------------------------------------------------------- Generated Clocks
create_generated_clock -name ALU_CLK -source [get_ports REF_CLK]  -divide_by 1  [get_pins U0_CLK_GATE/GATED_CLK]
create_generated_clock -name RX_CLK  -source [get_ports UART_CLK] -divide_by 1  [get_pins U1_ClkDiv/o_div_clk]
create_generated_clock -name TX_CLK  -source [get_ports UART_CLK] -divide_by 32 [get_pins U0_ClkDiv/o_div_clk]

# ------------------------------------------------- Uncertainty & Transitions
set ALL_CLKS "REF_CLK UART_CLK SCAN_CLK ALU_CLK RX_CLK TX_CLK"
set MASTER_CLKS "REF_CLK UART_CLK SCAN_CLK"

foreach clk $ALL_CLKS {
    set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $clk]
    set_clock_uncertainty -hold  $CLK_HOLD_SKEW  [get_clocks $clk]
}

foreach clk $MASTER_CLKS {
    set_clock_transition -rise $CLK_RISE [get_clocks $clk]
    set_clock_transition -fall $CLK_FALL [get_clocks $clk]
}

set_dont_touch_network [get_clocks $ALL_CLKS]

# ----------------------------------------------------------- Clock Grouping
set_clock_groups -asynchronous \
    -group [get_clocks {REF_CLK ALU_CLK}] \
    -group [get_clocks {UART_CLK RX_CLK TX_CLK}] \
    -group [get_clocks {SCAN_CLK}]

# ------------------------------------------------------- Input/Output Delays
set in_scan_delay  [expr 0.2 * $SCAN_CLK_PER]
set out_scan_delay [expr 0.2 * $SCAN_CLK_PER]
set in_RX_delay    [expr 0.2 * $RX_CLK_PER]
set out_RX_delay   [expr 0.2 * $RX_CLK_PER]
set out_TX_delay   [expr 0.2 * $TX_CLK_PER]

# Functional IO Delays
set_input_delay  $in_RX_delay  -clock RX_CLK [get_ports UART_RX_IN]
set_output_delay $out_TX_delay -clock TX_CLK [get_ports UART_TX_O]
set_output_delay $out_RX_delay -clock RX_CLK [get_ports {parity_error framing_error}]

# Scan IO Delays
set_input_delay  $in_scan_delay  -clock SCAN_CLK [get_ports {SI[*] SE}]
set_output_delay $out_scan_delay -clock SCAN_CLK [get_ports {SO[*]}]

# ------------------------------------------------------------ Driving Cells
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_ports {UART_RX_IN SI[*] SE}]

# ------------------------------------------------------------- Output Load
set_load 0.1 [get_ports {UART_TX_O parity_error framing_error SO[*]}]

# ---------------------------------------------------------- Case Analysis
set_case_analysis 1 [get_ports test_mode]

# ----------------------------------------------------- Operating Conditions
set_operating_conditions \
    -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" \
    -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"