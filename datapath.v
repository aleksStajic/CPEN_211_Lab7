module datapath (clk, // recall from Lab 4 that KEY0 is 1 when NOT pushed

                // register operand fetch stage
                readnum,
                vsel,
                loada,
                loadb,

                // computation stage (sometimes called "execute")
                shift,
                asel,
                bsel,
                ALUop,
                loadc,
                loads,

                // set when "writing back" to register file
                writenum,
                write,  
                datapath_in, //sximm8 sign extended

                // outputs
                Z_out,
                V_out,
                N_out,
                datapath_out,
                mdata,
                PC,
                sximm5
);
    input [15:0] sximm5;
    input [15:0] mdata;
    input [15:0] datapath_in; //new "datapath_in" is effectively sximm8 (sign extended imm8)
    input [7:0] PC;
    input clk;
    input [2:0] readnum;
    input [2:0] writenum;
    input write;
    input [1:0] vsel; //changed vsel to 2 bits wide for updates 
    input asel;
    input bsel;
    input [1:0] shift;
    input loada;
    input loadb;
    input loadc;
    input loads;
    input [1:0] ALUop;
    output Z_out;
    output N_out;
    output V_out;
    output [15:0] datapath_out;
    wire [15:0] data_in;
    wire [15:0] data_out;
    wire [15:0] loada_out;
    wire [15:0] loadb_out;
    wire [15:0] ALU_out;
    wire ALU_Z;
    wire ALU_N;
    wire ALU_V;
    wire [15:0] shift_out;
    wire [15:0] Ain_out;
    wire [15:0] Bin_out;


    //"instantiating muxs"
    vselMux REGMUX(mdata, datapath_in, PC, datapath_out, vsel, data_in); //updated MUX controlling input to regfile
    assign Ain_out = asel ? 16'd0 : loada_out;
    assign Bin_out = bsel ? sximm5 : shift_out; //added sximm5 as our new immediate operand to B mux

    //Instantation of regfile, ALU, shifter, registers with load enable
    vDFFE_DP #(16) A(clk, loada, data_out, loada_out); //instantiate register with load A
    vDFFE_DP #(16) B(clk, loadb, data_out, loadb_out); //instantiate register with load B
    vDFFE_DP #(16) C(clk, loadc, ALU_out , datapath_out); //instantiate register with load C
    vDFFE_DP #(1) SZ(clk, loads, ALU_Z , Z_out); //instantiate status register for Z flag 
    vDFFE_DP #(1) SN(clk, loads, ALU_N , N_out); //instantiate status register for N flag
    vDFFE_DP #(1) SV(clk, loads, ALU_V , V_out); //instantiate status register for V flag
    shifter SHIFTER(loadb_out, shift, shift_out);
    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);
    ALU alu(Ain_out, Bin_out, ALUop, ALU_out, ALU_N, ALU_V, ALU_Z);
endmodule

//This module was copied from the example
//on the Lab5 example slides
module vDFFE_DP(clk, en, in, out) ;
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

//Modified mux controlling inputs to register file in datapath
module vselMux(mdata_in, sximm8_in, PC_in, C_in, vsel_in, vsel_out); //sximm8_in is datapath_in
  input [15:0] mdata_in;
  input [15:0] sximm8_in;
  input [7:0] PC_in;
  input [15:0] C_in;
  input [1:0] vsel_in;
  output [15:0] vsel_out;
  reg [15:0] vsel_out;

  always @* begin
    case(vsel_in)
      2'd0 : vsel_out = C_in;
      2'd1 : vsel_out = {8'd0, PC_in}; //extending program counter to 16 bits
      2'd2 : vsel_out = sximm8_in;
      2'd3 : vsel_out = mdata_in;

      default : vsel_out = {16{1'bx}};
    endcase
  end
endmodule
