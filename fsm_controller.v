`define SW 4 //placeholder
`define S_WAIT 4'b0000//wait state
`define S_DECODE 4'b0001
`define S_GETA 4'b0011
`define S_GETB 4'b0010
`define S_ADD 4'b0110
`define S_CMP 4'b0111
`define S_AND 4'b0101
`define S_MVN 4'b0100
`define S_MOVSH_ALU 4'b1100
`define S_WriteReg 4'b1000

`define OPCODE_MOV 3'b110
`define OPCODE_ALU 3'b101

//First testing MOV instruction, with immediate operand

module fsm_control(clk, reset, s_in, opcode_in, op_in, nsel, w_out, DP_CNTRL);
    input clk, reset, s_in;
    output w_out;
    output [1:0] nsel;
    input [2:0] opcode_in;
    input [1:0] op_in;
    output [8:0] DP_CNTRL; //output signals going straight from FSM to datapath
                          //loada,loadb,loadc,loads,asel,bsel,vsel,write
    wire [`SW-1:0] present_state;
    reg [`SW-1:0] next_state;
    wire [`SW-1:0] next_state_reset;

    reg w_out;
    reg [8:0] DP_CNTRL;
    reg [1:0] nsel;

    vDFF_CNTRL #(`SW) U0(clk, next_state_reset, present_state); //instantiating flip-flop

    assign next_state_reset = reset ? `S_WAIT : next_state; //if reset is pressed, we move to the wait state

    always @* begin
        case(present_state)
            `S_WAIT : if(s_in === 1'b0) begin
                {next_state, DP_CNTRL, nsel, w_out} = {`S_WAIT, 9'd0, 2'b11, 1'b1};
            end else if(s_in === 1'b1) begin
                {next_state, DP_CNTRL, nsel, w_out} = {`S_DECODE, 9'd0, 2'b11, 1'b1};
            end else begin
                {next_state, DP_CNTRL, nsel, w_out} = {`S_WAIT, 9'd0, 2'b11, 1'b1};
            end

            `S_DECODE : if(opcode_in === `OPCODE_MOV && op_in === 2'b10) begin
                {next_state, DP_CNTRL, nsel, w_out} = {`S_WriteReg, 9'd0, 2'b11, 1'b0};
            end else if(opcode_in === `OPCODE_MOV && op_in === 2'b00) begin
                {next_state, DP_CNTRL, nsel, w_out} = {`S_GETB, 9'd0, 2'b11, 1'b0};
            end else if(opcode_in === `OPCODE_ALU) begin
                if (op_in === 2'b11) begin // MVN case
                    {next_state, DP_CNTRL, nsel, w_out} = {`S_GETB, 9'd0, 2'b11, 1'b0};
                end else begin 
                    {next_state, DP_CNTRL, nsel, w_out} = {`S_GETA, 9'd0, 2'b11, 1'b0};
                end
            end else begin
                {next_state, DP_CNTRL, nsel, w_out} = {`S_DECODE, 9'bxxxxxxxxx, 2'bxx, 1'b0};
            end

            `S_GETA : {next_state, DP_CNTRL, nsel, w_out} = {`S_GETB, {4'b1000, 2'b00, 2'b00, 1'b0}, 2'b00, 1'b0}; //Rn
            
            `S_GETB : //GetB state, conditions for ALU operation and MOV operations
            if(opcode_in === `OPCODE_ALU) begin
                if(op_in === 2'b00) begin //ADD condition for ALU
                    {next_state, DP_CNTRL, nsel, w_out} = {`S_ADD, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0}; //Rm 
                end else if (op_in === 2'b01) begin //CMP condition for ALU
                    {next_state, DP_CNTRL, nsel, w_out} = {`S_CMP, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0}; //Rm 
                end else if (op_in === 2'b10) begin //AND condition for ALU
                    {next_state, DP_CNTRL, nsel, w_out} = {`S_AND, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0}; //Rm 
                end else if (op_in === 2'b11) begin //NOT condition for ALU
                    {next_state, DP_CNTRL, nsel, w_out} = {`S_MVN, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0}; //Rm 
                end 
                else begin
                    {next_state, DP_CNTRL, nsel, w_out} = {`S_GETB, {4'bxxxx, 2'bxx, 2'bxx, 1'bx}, 2'bxx, 1'b0}; //Rm 
                end
            end else if(opcode_in === `OPCODE_MOV && op_in === 2'b00) begin //MOV operation with shift condition
                {next_state, DP_CNTRL, nsel, w_out} = {`S_MOVSH_ALU, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0}; //Rm 
            end else begin
                {next_state, DP_CNTRL, nsel, w_out} = {`S_GETB, 9'bxxxxxxxxx, 2'bxx, 1'b0}; //default, stay in GetB
            end

            `S_MOVSH_ALU : {next_state, DP_CNTRL, nsel, w_out} = {`S_WriteReg, {4'b0010, 2'b10, 2'b00, 1'b0}, 2'b01, 1'b0}; //Rd  //if doing register MOV, make sure to set asel = 1, since doing implicit "add" with 0
                  
            `S_ADD : {next_state, DP_CNTRL, nsel, w_out} = {`S_WriteReg, {4'b0010, 2'b00, 2'b00, 1'b0}, 2'b11, 1'b0}; // no nsel

            `S_CMP : {next_state, DP_CNTRL, nsel, w_out} = {`S_WAIT, {4'b0001, 2'b00, 2'b00, 1'b0}, 2'b11, 1'b0}; // no nsel

            `S_AND : {next_state, DP_CNTRL, nsel, w_out} = {`S_WriteReg, {4'b0010, 2'b00, 2'b00, 1'b0}, 2'b11, 1'b0}; // no nsel

            `S_MVN : {next_state, DP_CNTRL, nsel, w_out} = {`S_WriteReg, {4'b0010, 2'b10, 2'b00, 1'b0}, 2'b11, 1'b0}; // no nsel

            `S_WriteReg : 
            //if doing immediate MOV, make sure vsel is 2
            if(opcode_in === `OPCODE_MOV && op_in === 2'b10) begin //if immediate move, write to Rn
                {next_state, DP_CNTRL, nsel, w_out} = {`S_WAIT, {4'b0000, 2'b00, 2'b10, 1'b1}, 2'b00, 1'b0}; //Rn  
            end else begin //else, we set vsel to 0
                {next_state, DP_CNTRL, nsel, w_out} = {`S_WAIT, {4'b0000, 2'b00, 2'b00, 1'b1}, 2'b01, 1'b0}; //Rd
            end

            default : {next_state, DP_CNTRL, nsel, w_out} = {{`SW{1'bx}}, 9'bxxxxxxxxx, 2'bxx, 1'bx}; //default is undefined

        endcase
    end
endmodule

module vDFF_CNTRL(clk, in, out);
	parameter n = 1; // width of in and out
    input clk;
    input [n-1:0] in;
    output [n-1:0] out;
	reg [n-1:0] out;

    always @(posedge clk) begin
        out = in;
    end
endmodule