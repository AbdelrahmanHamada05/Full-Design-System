########################### Define Top Module ############################
                                                   
set top_module SYS_TOP

##################### Define Working Library Directory ######################
                                                   
define_design_lib work -path ./work

################## Design Compiler Library Files #setup ######################

puts "###########################################"
puts "#      #setting Design Libraries           #"
puts "###########################################"

# ---- adjust these two paths to your virtual machine ----
set PROJECT_DIR   /home/ICer/SYSTEM
set STD_CELLS_DIR $PROJECT_DIR/std_cells         ;# folder that contains the .db files
set RTL_DIR       $PROJECT_DIR                   ;# the RTL block folders are directly inside SYSTEM

#Add the path of the libraries to the search_path variable
lappend search_path $STD_CELLS_DIR

#Add the path of every RTL block folder to the search_path variable
foreach blk {ALU \
             Async_FIFO \
             Clock_Divider \
             Clock_DIV_MUX \
             Clock_Gating \
             Data_Sync \
             Pulse_Gen \
             Register_File \
             Reset_Sync \
             SYS_CTRL \
             TOP \
             UART/UART_RX \
             UART/UART_TOP \
             UART/UART_TX} {
    lappend search_path $RTL_DIR/$blk
}

set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

## Standard Cell libraries 
set target_library [list $SSLIB $TTLIB $FFLIB]

## Standard Cell & Hard Macros libraries 
set link_library [list * $SSLIB $TTLIB $FFLIB]  

######################## Formality guidance (SVF) ###########################
# records the tool transformations so Formality can verify the netlist

set_svf SYS_TOP.svf

######################## Reading RTL Files #################################

puts "###########################################"
puts "#             Reading RTL Files           #"
puts "###########################################"

set file_format verilog

# ALU
read_file -format $file_format ALU.v

# Async_FIFO
read_file -format $file_format Async_fifo.v
read_file -format $file_format ASYNC_FIFO_f.v
read_file -format $file_format DF_SYNC.v
read_file -format $file_format FIFO_MEM_CNTRL.v
read_file -format $file_format fifo_rd.v
read_file -format $file_format FIFO_WR.v

# Clock_Divider
read_file -format $file_format Clock_Divider.v

# Clock_DIV_MUX
read_file -format $file_format CLKDIV_MUX.v

# Clock_Gating
read_file -format $file_format CLK_GATE.v

# Data_Sync
read_file -format $file_format Data_Sync.v
read_file -format $file_format FF.v
read_file -format $file_format Multi_FF.v
read_file -format $file_format MUX_21_REG.v
read_file -format $file_format Pulse_Gen_Pos.v

# Pulse_Gen
read_file -format $file_format Pulse_Gen.v

# Register_File
read_file -format $file_format RegFile.v

# Reset_Sync
read_file -format $file_format RST_Sync.v

# SYS_CTRL
read_file -format $file_format SYS_CTRL.v

# TOP
read_file -format $file_format SYS_TOP.v

# UART/UART_RX
read_file -format $file_format data_sampling.v
read_file -format $file_format deserializer.v
read_file -format $file_format edge_bit_counter.v
read_file -format $file_format par_check.v
read_file -format $file_format RX_FSM.v
read_file -format $file_format stp_check.v
read_file -format $file_format strt_check.v
read_file -format $file_format UART_RX.v

# UART/UART_TOP
read_file -format $file_format UART.v

# UART/UART_TX
read_file -format $file_format parity_calc.v
read_file -format $file_format serializer.v
read_file -format $file_format TX_FSM.v
read_file -format $file_format UART_TX.v

###################### Defining toplevel ###################################

current_design $top_module

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## Liniking All The Design Parts ########"
puts "###############################################"

link 

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## checking design consistency ##########"
puts "###############################################"

check_design

############################### Path groups ################################
puts "###############################################"
puts "################ Path groups ##################"
puts "###############################################"

group_path -name INREG -from [all_inputs]
group_path -name REGOUT -to [all_outputs]
group_path -name INOUT -from [all_inputs] -to [all_outputs]

#################### Define Design Constraints #########################
puts "###############################################"
puts "############ Design Constraints #### ##########"
puts "###############################################"

source -echo ./cons.tcl

###################### Mapping and optimization ########################
puts "###############################################"
puts "########## Mapping & Optimization #############"
puts "###############################################"

# avoid 'assign' statements in the netlist (ports tied together / to constants)
set_fix_multiple_port_nets -all -buffer_constants

compile -map_effort high

#############################################################################
# Write out Design after initial compile
#############################################################################

change_names -rules verilog -hierarchy

write_file -format verilog -hierarchy -output SYS_TOP_netlist.v
write_file -format ddc -hierarchy -output SYS_TOP_netlist.ddc
write_sdc  -nosplit SYS_TOP.sdc
write_sdf           SYS_TOP.sdf

# stop recording guidance for Formality
set_svf -off

################# reporting #######################

report_area -hierarchy > area.rpt
report_power -hierarchy > power.rpt
report_timing -max_paths 100 -delay_type min > hold.rpt
report_timing -max_paths 100 -delay_type max > setup.rpt
report_clock -attributes > clocks.rpt
report_constraint -all_violators > constraints.rpt
report_qor > qor.rpt
check_design > check_design.rpt

################# starting graphical user interface #######################

#gui_start

#exit
