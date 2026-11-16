quit -sim
vdel -all -lib work
vlib work
vmap work work

vlog -f filelist.f

vsim -voptargs="+acc" work.SYS_TOP_tb

do wave.do

run -all