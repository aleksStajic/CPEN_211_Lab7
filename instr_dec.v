module instr_dec(ID_in, opcode, op, nsel_fsm, readnum, writenum, ALUop, sximm5, sximm8, shift);
    input [15:0] ID_in;

    output [2:0] opcode;
    output [1:0] op;
    assign opcode = ID_in[15:13];
    assign op = ID_in[12:11];

    input [1:0] nsel_fsm; //from FSM :)
    wire [2:0] nsel_mux_out;
    wire [2:0] Rn = ID_in[10:8];
    wire [2:0] Rd = ID_in[7:5];
    wire [2:0] Rm = ID_in[2:0];
    output [2:0] readnum;
    output [2:0] writenum;

    output [15:0] sximm8;
    output [15:0] sximm5;
    wire [7:0] imm8 = ID_in[7:0];
    wire [4:0] imm5 = ID_in[4:0];

    output [1:0] ALUop;
    assign ALUop = ID_in[12:11];

    output [1:0] shift;
    assign shift = ID_in[4:3];

    nsel_mux NSEL_MUX(Rn, Rd, Rm, nsel_fsm, nsel_mux_out); //instatiating mux for register Rn, Rd, Rm select
    sign_extend #(8) U0(imm8, sximm8); //instantiating sign extender for immediate 8 operand
    sign_extend #(5) U1(imm5, sximm5); //instantiating sign extender for immediate 5 operand

    assign readnum = nsel_mux_out;
    assign writenum = nsel_mux_out;

endmodule

//Mux to select between Rn, Rd, Rm to control what is driven onto readnum and writenum
module nsel_mux(rn, rd, rm, nsel_fsm_in, nsel_mux_output);
    input [2:0] rn, rd, rm;
    input [1:0] nsel_fsm_in;
    output [2:0] nsel_mux_output;
    reg [2:0] nsel_mux_output;

    always @* begin
        case(nsel_fsm_in)
            2'b00 : nsel_mux_output = rn; 
            2'b01 : nsel_mux_output = rd; 
            2'b10 : nsel_mux_output = rm;
            2'b11 : nsel_mux_output = 3'bxxx;
            default: nsel_mux_output = 3'bxxx;

        endcase
    end

endmodule


//Parameterized module for sign extending a binary value
module sign_extend(imm_in, sximm_out);
    parameter n = 1;
    input [n-1:0] imm_in;
    output [15:0] sximm_out;
    reg [15:0] sximm_out;

    always @* begin
        case(imm_in[n-1])
            1'b1 : sximm_out = {{(16-n){1'b1}}, imm_in}; //sign extends all 1s
            1'b0 : sximm_out = {{(16-n){1'b0}}, imm_in}; //sign extends all 0s

            default : sximm_out = {16{1'bx}};
        endcase
    end
endmodule