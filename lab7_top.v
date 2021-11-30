`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10
`define H0 7'b1000000
`define H1 7'b1111001
`define H2 7'b0100100
`define H3 7'b0110000
`define H4 7'b0011001
`define H5 7'b0010010
`define H6 7'b0000010
`define H7 7'b1111000
`define H8 7'b0000000
`define H9 7'b0011000
`define HA 7'b0001000
`define Hb 7'b0000011
`define HC 7'b1000110
`define Hd 7'b0100001
`define HE 7'b0000110
`define HF 7'b0001110


module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    //Memory input/output
    wire [15:0] read_data;
    wire [15:0] dout_RAM;
    wire [15:0] cpu_out;
    wire N, V, Z;
    wire [1:0] mem_cmd_bus;
    wire [8:0] mem_addr_bus;
    wire enable_tri;
    wire write;
    wire enable_tri_read;
    wire load_LED;
    wire [9:0] LEDR;

    RAM MEM(~KEY[0], mem_addr_bus[7:0], mem_addr_bus[7:0], write, cpu_out, dout_RAM); //instantiating RAM
    cpu CPU(~KEY[0], ~KEY[1], read_data, cpu_out, N, V, Z, LEDR[9], mem_cmd_bus, mem_addr_bus); //CPU instantiation
    vDFFE_LEDR #(8) LED(~KEY[0], load_LED, cpu_out[7:0], LEDR[7:0]);

    assign enable_tri = (`MREAD === mem_cmd_bus) & (mem_addr_bus[8] === 1'b0); //AND gate input to tri-state driver
    assign read_data = enable_tri ? dout_RAM : {16{1'bz}}; //setting up tri-state driver logic   

    assign write = (mem_cmd_bus === `MWRITE) & (mem_addr_bus[8] === 1'b0); //comparator for write input to RAM

    assign enable_tri_read = (mem_cmd_bus === `MREAD) && (mem_addr_bus === 9'h140); //tri-state enable for SWs

    assign read_data = enable_tri_read ? {8'd0, SW[7:0]} : {16{1'bz}}; //tri-state driver output for LED controlled read_data

    assign load_LED = (mem_cmd_bus === `MWRITE) && (mem_addr_bus === 9'h100); //tri-state enable for LEDs

    //Assigning Z, N, V outputs to DE1-SOC
    assign HEX5[0] = ~Z;
    assign HEX5[6] = ~N;
    assign HEX5[3] = ~V;

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(cpu_out[3:0],   HEX0);
  sseg H1(cpu_out[7:4],   HEX1);
  sseg H2(cpu_out[11:8],  HEX2);
  sseg H3(cpu_out[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = 1'b0;

endmodule

module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 16; 
  parameter addr_width = 8;
  parameter filename = "test.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule

module vDFFE_LEDR(clk, en, in, out) ;
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

module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;
  reg [6:0] segs;

  always @* begin
    case(in)
      4'd0 : segs = `H0;
      4'd1 : segs = `H1;
      4'd2 : segs = `H2;
      4'd3 : segs = `H3;
      4'd4 : segs = `H4;
      4'd5 : segs = `H5;
      4'd6 : segs = `H6;
      4'd7 : segs = `H7;
      4'd8 : segs = `H8;
      4'd9 : segs = `H9;
      4'd10 : segs = `HA;
      4'd11 : segs = `Hb;
      4'd12 : segs = `HC;
      4'd13 : segs = `Hd;
      4'd14 : segs = `HE;
      4'd15 : segs = `HF;

      default : segs = 7'bxxxxxxx;
    endcase
  end

  // NOTE: The code for sseg below is not complete: You can use your code from
  // Lab4 to fill this in or code from someone else's Lab4.  
  //
  // IMPORTANT:  If you *do* use someone else's Lab4 code for the seven
  // segment display you *need* to state the following three things in
  // a file README.txt that you submit with handin along with this code: 
  //
  //   1.  First and last name of student providing code
  //   2.  Student number of student providing code
  //   3.  Date and time that student provided you their code
  //
  // You must also (obviously!) have the other student's permission to use
  // their code.
  //
  // To do otherwise is considered plagiarism.
  //
  // One bit per segment. On the DE1-SoC a HEX segment is illuminated when
  // the input bit is 0. Bits 6543210 correspond to:
  //
  //    0000
  //   5    1
  //   5    1
  //    6666
  //   4    2
  //   4    2
  //    3333
  //
  // Decimal value | Hexadecimal symbol to render on (one) HEX display
  //             0 | 0
  //             1 | 1
  //             2 | 2
  //             3 | 3
  //             4 | 4
  //             5 | 5
  //             6 | 6
  //             7 | 7
  //             8 | 8
  //             9 | 9
  //            10 | A
  //            11 | b
  //            12 | C
  //            13 | d
  //            14 | E
  //            15 | D

endmodule

