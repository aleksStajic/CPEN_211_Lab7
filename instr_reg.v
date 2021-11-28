module instr_reg(clk, load_i, instr_reg_in, instr_reg_out);
    input load_i, clk;
    input [15:0] instr_reg_in;
    output [15:0] instr_reg_out;

    vDFFE_IR #(16) instr_register(clk, load_i, instr_reg_in, instr_reg_out);

endmodule

module vDFFE_IR(clk, en, in, out) ;
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