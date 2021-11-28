module regfile(data_in, writenum, write, readnum, clk, data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;
    wire [15:0] data_out;
    wire [7:0] write_dec_out;
    wire [7:0] read_dec_out;
    wire [7:0] enable_signal;
    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    
    //Instantiations
    mydec WRITEDEC(writenum, write_dec_out);
    mydec READDEC(readnum, read_dec_out);
    assign enable_signal = {8{write}} & write_dec_out;

    vDFFE #(16) r0(clk, enable_signal[0], data_in, R0);
    vDFFE #(16) r1(clk, enable_signal[1], data_in, R1);
    vDFFE #(16) r2(clk, enable_signal[2], data_in, R2);
    vDFFE #(16) r3(clk, enable_signal[3], data_in, R3);
    vDFFE #(16) r4(clk, enable_signal[4], data_in, R4);
    vDFFE #(16) r5(clk, enable_signal[5], data_in, R5);
    vDFFE #(16) r6(clk, enable_signal[6], data_in, R6);
    vDFFE #(16) r7(clk, enable_signal[7], data_in, R7);

    Mux8 MUX(R7, R6, R5, R4, R3, R2, R1, R0, read_dec_out, data_out);

endmodule



//This module was copied from the example
//on the Lab5 example slides
module vDFFE(clk, en, in, out) ;
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

module mydec(in, out); //3 to 8 binary to one-hot decoder
    input [2:0] in;
    output [7:0] out;
    
    assign out = 1 << in;
endmodule

module Mux8(a7, a6, a5, a4, a3, a2, a1, a0, s, b);
    input [15:0] a7, a6, a5, a4, a3, a2, a1, a0;
    input [7:0] s;
    output [15:0] b;
    reg [15:0] b;

    always @* begin
        case(s)
            8'b00000001 : b = a0;
            8'b00000010 : b = a1;
            8'b00000100 : b = a2;
            8'b00001000 : b = a3;
            8'b00010000 : b = a4;
            8'b00100000 : b = a5;
            8'b01000000 : b = a6;
            8'b10000000 : b = a7;

            default : b = {16{1'bx}};
        endcase
    end
endmodule




