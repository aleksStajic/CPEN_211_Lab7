`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10


module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    //Memory input/output
    wire [15:0] read_data;
    wire [15:0] dout_bus;
    wire [15:0] cpu_out;
    wire N, V, Z;
    wire [1:0] mem_cmd_bus;
    wire [8:0] mem_addr_bus;
    wire enable_tri;

    RAM MEM(~KEY[0], mem_addr_bus[7:0], mem_addr_bus[7:0], 0, 0, dout_bus); //instantiating RAM
    cpu CPU(~KEY[0], ~KEY[1], read_data, cpu_out, N, V, Z, mem_cmd_bus, mem_addr_bus); //CPU instantiation

    assign enable_tri = (`MREAD === mem_cmd_bus) & (mem_addr_bus[8] === 1'b0); //AND gate input to tri-state driver
    assign read_data = enable_tri ? dout_bus : {16{1'bz}}; //setting up tri-state driver logic    

endmodule

module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 32; 
  parameter addr_width = 4;
  parameter filename = "data.txt";

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

