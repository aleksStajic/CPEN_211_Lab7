onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {CPU Signals}
add wave -noupdate /cpu_tb/sim_clk
add wave -noupdate /cpu_tb/sim_reset
add wave -noupdate /cpu_tb/sim_s
add wave -noupdate /cpu_tb/sim_load
add wave -noupdate /cpu_tb/sim_in
add wave -noupdate /cpu_tb/out
add wave -noupdate /cpu_tb/N
add wave -noupdate /cpu_tb/V
add wave -noupdate /cpu_tb/Z
add wave -noupdate /cpu_tb/w
add wave -noupdate /cpu_tb/err
add wave -noupdate -divider {DP Signals}
add wave -noupdate /cpu_tb/DUT/dp_cntrl
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R0
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R1
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R2
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R3
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R4
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R5
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R6
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R7
add wave -noupdate /cpu_tb/DUT/DP/datapath_out
add wave -noupdate -divider {ALU Status}
add wave -noupdate /cpu_tb/DUT/DP/ALU_N
add wave -noupdate /cpu_tb/DUT/DP/ALU_V
add wave -noupdate /cpu_tb/DUT/DP/ALU_Z
add wave -noupdate -divider {REG A,B,C Signals}
add wave -noupdate /cpu_tb/DUT/DP/A/en
add wave -noupdate /cpu_tb/DUT/DP/A/out
add wave -noupdate /cpu_tb/DUT/DP/B/en
add wave -noupdate /cpu_tb/DUT/DP/B/out
add wave -noupdate /cpu_tb/DUT/DP/C/en
add wave -noupdate /cpu_tb/DUT/DP/C/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {973 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {1 ns}
