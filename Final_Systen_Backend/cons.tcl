
# Constraints
# ----------------------------------------------------------------------------
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load
#
# 9. Operating Condition

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### 
# 1. Master Clock Definitions 
# 2. Generated Clock Definitions
# 3. Clock Latencies
# 4. Clock Uncertainties
# 4. Clock Transitions
####################################################################################

set CLK_SETUP_SKEW 0.2
set CLK_HOLD_SKEW  0.1
set CLK_RISE       0.05
set CLK_FALL       0.05

# clock periods (ns)
set REF_CLK_PER   20
set UART_CLK_PER  271.27
set ALU_CLK_PER   $REF_CLK_PER
set RX_CLK_PER    $UART_CLK_PER
set TX_CLK_PER    [expr 32*$UART_CLK_PER]

# ---------------------------------------------------------------- master clocks
create_clock -name REF_CLK  -period $REF_CLK_PER  -waveform "0 [expr $REF_CLK_PER/2]"  [get_ports REF_CLK]
create_clock -name UART_CLK -period $UART_CLK_PER -waveform "0 [expr $UART_CLK_PER/2]" [get_ports UART_CLK]

# ------------------------------------------------------------- generated clocks
# ALU_CLK : gated REF_CLK, ratio 1
create_generated_clock -name ALU_CLK -source [get_ports REF_CLK]  -divide_by 1  [get_pins U0_CLK_GATE/GATED_CLK]

# RX_CLK : UART_CLK, ratio 1 (default prescale 32)
create_generated_clock -name RX_CLK  -source [get_ports UART_CLK] -divide_by 1  [get_pins U1_ClkDiv/o_div_clk]

# TX_CLK : UART_CLK / 32
create_generated_clock -name TX_CLK  -source [get_ports UART_CLK] -divide_by 32 [get_pins U0_ClkDiv/o_div_clk]

# ------------------------------------------------- uncertainty, transition, dont_touch
set MASTER_CLKS "REF_CLK UART_CLK"
set ALL_CLKS    "REF_CLK UART_CLK ALU_CLK RX_CLK TX_CLK"

foreach clk $ALL_CLKS {
    set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $clk]
    set_clock_uncertainty -hold  $CLK_HOLD_SKEW  [get_clocks $clk]
}

foreach clk $MASTER_CLKS {
    set_clock_transition -rise $CLK_RISE [get_clocks $clk]
    set_clock_transition -fall $CLK_FALL [get_clocks $clk]
}

set_dont_touch_network [get_clocks $ALL_CLKS]

####################################################################################
           #########################################################
                  #### Section 2 : Clocks Relationships ####
           #########################################################
####################################################################################

# REF_CLK domain (REF_CLK, ALU_CLK) and UART_CLK domain (UART_CLK, RX_CLK, TX_CLK) are asynchronous
set_clock_groups -asynchronous -group [get_clocks {REF_CLK ALU_CLK}] \
                               -group [get_clocks {UART_CLK RX_CLK TX_CLK}]

####################################################################################
           #########################################################
             #### Section 3 : set input/output delay on ports ####
           #########################################################
####################################################################################

# 20% of the clock period of the clock each port is related to
set in_RX_delay   [expr 0.2*$RX_CLK_PER]
set out_RX_delay  [expr 0.2*$RX_CLK_PER]
set out_TX_delay  [expr 0.2*$TX_CLK_PER]

# Constrain Input Paths (all inputs except the clocks and the reset)
set_input_delay  $in_RX_delay  -clock RX_CLK [get_ports UART_RX_IN]

# Constrain Output Paths (all outputs)
set_output_delay $out_TX_delay -clock TX_CLK [get_ports UART_TX_O]
set_output_delay $out_RX_delay -clock RX_CLK [get_ports {parity_error framing_error}]

####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_ports UART_RX_IN]

####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################

set_load 0.1 [get_ports {UART_TX_O parity_error framing_error}]

####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################


####################################################################################
           #########################################################
                  #### Section 8 : multicycle path ####
           #########################################################
####################################################################################


####################################################################################
           #########################################################
                  #### Section 9 : Max/Min Delay path ####
           #########################################################
####################################################################################

