onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {TESTBENCH CLOCKS & RESETS}
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/REF_CLK
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/UART_CLK
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/RST_N

add wave -noupdate -divider {UART SERIAL LINES}
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/UART_RX_IN
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/UART_TX_O

add wave -noupdate -divider {SYSTEM CONTROLLER (FSM)}
add wave -noupdate -format Literal -radix hexadecimal /SYS_TOP_tb/DUT/U0_SYS_CTRL/current_state
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/DUT/U0_SYS_CTRL/RX_D_VLD
add wave -noupdate -format Literal -radix hexadecimal /SYS_TOP_tb/DUT/U0_SYS_CTRL/RX_P_DATA

add wave -noupdate -divider {REGISTER FILE INTERFACE}
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/DUT/U0_RegFile/WrEn
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/DUT/U0_RegFile/RdEn
add wave -noupdate -format Literal -radix hexadecimal /SYS_TOP_tb/DUT/U0_RegFile/Address
add wave -noupdate -format Literal -radix hexadecimal /SYS_TOP_tb/DUT/U0_RegFile/WrData
add wave -noupdate -format Literal -radix hexadecimal /SYS_TOP_tb/DUT/U0_RegFile/RdData

add wave -noupdate -divider {ALU INTERFACE}
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/DUT/U0_ALU/EN
add wave -noupdate -format Literal -radix hexadecimal /SYS_TOP_tb/DUT/U0_ALU/ALU_FUN
add wave -noupdate -format Literal -radix decimal /SYS_TOP_tb/DUT/U0_ALU/A
add wave -noupdate -format Literal -radix decimal /SYS_TOP_tb/DUT/U0_ALU/B
add wave -noupdate -format Literal -radix decimal /SYS_TOP_tb/DUT/U0_ALU/ALU_OUT
add wave -noupdate -format Logic -radix hexadecimal /SYS_TOP_tb/DUT/U0_ALU/OUT_VALID

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 220
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2