onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab7_top_tb/sim_KEY
add wave -noupdate /lab7_top_tb/err
add wave -noupdate /lab7_top_tb/DUT/CPU/in
add wave -noupdate /lab7_top_tb/DUT/CPU/out
add wave -noupdate /lab7_top_tb/DUT/CPU/PC
add wave -noupdate /lab7_top_tb/DUT/CPU/IR_out
add wave -noupdate /lab7_top_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /lab7_top_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /lab7_top_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab7_top_tb/DUT/CPU/FSM/TOP_CNTRL
add wave -noupdate /lab7_top_tb/DUT/CPU/FSM/present_state
add wave -noupdate /lab7_top_tb/DUT/CPU/FSM/MEM_CMD
add wave -noupdate /lab7_top_tb/DUT/CPU/FSM/DP_CNTRL
add wave -noupdate /lab7_top_tb/DUT/dout_bus
add wave -noupdate /lab7_top_tb/DUT/MEM/dout
add wave -noupdate /lab7_top_tb/DUT/mem_cmd_bus
add wave -noupdate /lab7_top_tb/DUT/mem_addr_bus
add wave -noupdate /lab7_top_tb/DUT/MEM/read_address
add wave -noupdate /lab7_top_tb/DUT/MEM/read_address
add wave -noupdate /lab7_top_tb/DUT/enable_tri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {199 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 279
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {133 ps} {204 ps}
