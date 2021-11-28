module cpu(clk,reset,s,load,in,out,N,V,Z, mem_cmd, mem_addr);
    input clk, reset, s, load;
    input [15:0] in;
    output [15:0] out;
    output N, V, Z, w;

    //Memory outputs
    output [1:0] mem_cmd;
    output [8:0] mem_addr;
    //--------------------
    
    wire [2:0] opcode_out;
    wire [1:0] op_out;
    wire [1:0] shift_out;
    wire [1:0] ALUop_out;
    wire [15:0] sximm5_out;
    wire [15:0] sximm8_out;
    wire [2:0] readnum_out;
    wire [2:0] writenum_out;
    wire [1:0] nsel_fsm; // output from fsm
    wire [15:0] IR_out;
    wire [8:0] dp_cntrl;

    //Memory wires
    wire load_pc;
    wire [8:0] next_pc;
    wire [8:0] PC;
    wire reset_pc;
    wire addr_sel;
    wire [8:0] mem_addr;
    wire [1:0] mem_cmd;

    datapath DP(.clk(clk), // recall from Lab 4 that KEY0 is 1 when NOT pushed

                // register operand fetch stage
                .readnum(readnum_out),
                .vsel(dp_cntrl[2:1]),
                .loada(dp_cntrl[8]),
                .loadb(dp_cntrl[7]),

                // computation stage (sometimes called "execute")
                .shift(shift_out),
                .asel(dp_cntrl[4]),
                .bsel(dp_cntrl[3]),
                .ALUop(ALUop_out),
                .loadc(dp_cntrl[6]),
                .loads(dp_cntrl[5]),

                // set when "writing back" to register file
                .writenum(writenum_out),
                .write(dp_cntrl[0]),  
                .datapath_in(sximm8_out),

                // outputs
                .Z_out(Z),
                .V_out(V),
                .N_out(N),
                .datapath_out(out),
                .mdata(16'd0),
                .PC(8'd0),
                .sximm5(sximm5_out)
    );

    instr_reg IR(clk, load, in, IR_out); //instantiating instruction register

    instr_dec ID(.ID_in (IR_out), 
                .opcode (opcode_out), 
                .op (op_out), 
                .nsel_fsm (nsel_fsm), 
                .readnum (readnum_out), 
                .writenum (writenum_out), 
                .ALUop (ALUop_out), 
                .sximm5 (sximm5_out), 
                .sximm8 (sximm8_out), 
                .shift (shift_out)
                );

    fsm_control FSM(.clk(clk),
                    .reset(reset),
                    .s_in(s), 
                    .opcode_in(opcode_out), 
                    .op_in(op_out), 
                    .nsel(nsel_fsm), 
                    .w_out (w), 
                    .DP_CNTRL(dp_cntrl)
                 );

    
    vDFFE_PC PCREG(clk, load_pc, next_pc, PC); //instantiating program counter register with load enable

    assign next_pc = reset_pc ? 9'd0 : PC + 1'b1; //intantiating PC multiplexer

    assign mem_addr = addr_sel ? PC : 9'd0;


endmodule

//This module was copied from the example
//on the Lab5 example slides
module vDFFE_PC(clk, en, in, out) ;
  parameter n = 1;  // width
  input clk, en ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = en ? in : out;

  always @(posedge clk)
    out = next_out;  
endmodule
