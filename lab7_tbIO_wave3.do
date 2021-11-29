onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TB
add wave -noupdate /lab7_topIO_tb/err
add wave -noupdate /lab7_topIO_tb/sim_KEY
add wave -noupdate /lab7_topIO_tb/sim_LEDR
add wave -noupdate /lab7_topIO_tb/sim_SW
add wave -noupdate /lab7_topIO_tb/DUT/CPU/FSM/present_state
add wave -noupdate -divider RAM
add wave -noupdate /lab7_topIO_tb/DUT/MEM/read_address
add wave -noupdate /lab7_topIO_tb/DUT/MEM/write_address
add wave -noupdate /lab7_topIO_tb/DUT/MEM/din
add wave -noupdate /lab7_topIO_tb/DUT/MEM/dout
add wave -noupdate -divider {RAM Contents}
add wave -noupdate {/lab7_topIO_tb/DUT/MEM/mem[0]}
add wave -noupdate {/lab7_topIO_tb/DUT/MEM/mem[1]}
add wave -noupdate {/lab7_topIO_tb/DUT/MEM/mem[2]}
add wave -noupdate {/lab7_topIO_tb/DUT/MEM/mem[3]}
add wave -noupdate {/lab7_topIO_tb/DUT/MEM/mem[4]}
add wave -noupdate {/lab7_topIO_tb/DUT/MEM/mem[5]}
add wave -noupdate {/lab7_topIO_tb/DUT/MEM/mem[6]}
add wave -noupdate {/lab7_topIO_tb/DUT/MEM/mem[7]}
add wave -noupdate {/lab7_topIO_tb/DUT/MEM/mem[8]}
add wave -noupdate -divider DUT
add wave -noupdate /lab7_topIO_tb/DUT/mem_addr_bus
add wave -noupdate /lab7_topIO_tb/DUT/mem_cmd_bus
add wave -noupdate -divider CPU
add wave -noupdate /lab7_topIO_tb/DUT/CPU/next_pc
add wave -noupdate /lab7_topIO_tb/DUT/CPU/PC
add wave -noupdate /lab7_topIO_tb/DUT/CPU/IR_out
add wave -noupdate /lab7_topIO_tb/DUT/CPU/in
add wave -noupdate /lab7_topIO_tb/DUT/CPU/out
add wave -noupdate -divider Regfile
add wave -noupdate /lab7_topIO_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /lab7_topIO_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /lab7_topIO_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab7_topIO_tb/DUT/CPU/DP/REGFILE/R3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {488 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 253
configure wave -valuecolwidth 110
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
WaveRestoreZoom {0 ps} {330 ps}
