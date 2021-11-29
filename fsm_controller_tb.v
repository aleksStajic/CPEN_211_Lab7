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


module fsm_control_tb;
    reg sim_clk, sim_reset, sim_s_in;
    reg [2:0] sim_opcode_in;
    reg [1:0] sim_op_in;
    wire [1:0] sim_nsel;
    wire sim_w_out;
    wire [8:0] sim_DP_CNTRL;
    reg err;

    fsm_control DUT(sim_clk, sim_reset, sim_s_in, sim_opcode_in, sim_op_in, sim_nsel, sim_w_out, sim_DP_CNTRL);

    initial begin
        forever begin
            sim_clk = 1'b0; #5;
            sim_clk = 1'b1; #5;
        end
    end

    task check_outputs;
        input [`SW-1:0] exp_state;
        input [8:0] exp_DP_CNTRL;
        input [1:0] exp_nsel;
        input exp_w_out;

    begin
        if(exp_state !== DUT.present_state) begin
            $display("Error at time %0d, state was %b, expected %b", $time, DUT.present_state, exp_state);
            err = 1'b1;
        end
        if(exp_DP_CNTRL !== sim_DP_CNTRL) begin
            $display("Error at time %0d, DP_CNTRL was %b, expected %b", $time, sim_DP_CNTRL, exp_DP_CNTRL);
            err = 1'b1;
        end
        if(exp_nsel !== sim_nsel) begin
            $display("Error at time %0d, nsel was %b, expected %b", $time, sim_nsel, exp_nsel);
            err = 1'b1;
        end
        if(exp_w_out !== sim_w_out) begin
            $display("Error at time %0d, w was %b, expected %b", $time, sim_w_out, exp_w_out);
            err = 1'b1;
        end
    end
    endtask

    initial begin
        err = 1'b0;
        sim_s_in = 1'b0;

        $display("Checking reset sends us to wait state");
        sim_reset = 1'b1; //assert reset
        #10;
        check_outputs(`S_WAIT, 9'd0, 2'b11, 1'b1);

        sim_reset = 1'b0; //turn reset off

        $display("With reset off, check that we stay in wait state until s is 1"); //sim_s_in is still 0
        #10;
        check_outputs(`S_WAIT, 9'd0, 2'b11, 1'b1);

        $display("Checking transition to DECODE state from wait state");
        sim_s_in = 1'b1;
        #10;
        check_outputs(`S_DECODE, 9'bxxxxxxxxx, 2'bxx, 1'b0); //w_out should be 0 now,
        // but opcodes are undefined so DP_CNTRL and nsel are also underfinded

        //Checking immediate MOV operation
        $display("Checking we transition to MOV state from decode when opcode is 110");
        sim_opcode_in = 3'b110; //set opcode
        sim_op_in = 2'b10; //set op
        #10;
        check_outputs(`S_WriteReg, 9'b000000101, 2'b00, 1'b0);

        $display("Checking transition from MOVIM state back to WAIT beginning");
        #10;
        check_outputs(`S_WAIT, 9'd0, 2'b11, 1'b1);

        $display("Checking transition from WAIT to DECODE again");
        sim_s_in = 1'b1;
        #10;
        check_outputs(`S_DECODE, 9'd0, 2'b11, 1'b0); //w_out should be 0 now, everthing else unchnaged

        //Checking ADD sequence
        $display("Checking transition from DECODE to GETA at start of addition sequence");
        sim_opcode_in = 3'b101; //set opcode
        sim_op_in = 2'b00; //set ALUop
        #10;
        check_outputs(`S_GETA, {4'b1000, 2'b00, 2'b00, 1'b0}, 2'b00, 1'b0);

        $display("Checking transition from GETA to GETB at next rising clk");
        #10;
        check_outputs(`S_GETB, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0);

        $display("Checking transition from GETB to ADD at next rising clk");
        #10;
        check_outputs(`S_ADD, {4'b0010, 2'b00, 2'b00, 1'b0}, 2'b11, 1'b0);

        $display("Checking transition from ADD to WriteReg at next rising clk");
        #10;
        check_outputs(`S_WriteReg,{4'b0000, 2'b00, 2'b00, 1'b1}, 2'b01, 1'b0);

        $display("Checking transition from WriteReg state back to WAIT beginning");
        #10;
        check_outputs(`S_WAIT, 9'd0, 2'b11, 1'b1);

        $display("Checking transition from WAIT to DECODE again");
        sim_s_in = 1'b1;
        #10;
        check_outputs(`S_DECODE, 9'd0, 2'b11, 1'b0); //w_out should be 0 now, everthing else unchnaged

        //Checking MOV shift sequenece 
        $display("Checking transition from DECODE to GETB for MOV shift operation");
        sim_opcode_in = 3'b110; //encoding for MOV operation
        sim_op_in = 2'b00; //encoding for MOV shift
        #10;
        check_outputs(`S_GETB, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0);

        $display("Checking transition from GETB to MOV_SH");
        #10;
        check_outputs(`S_MOVSH_ALU, {4'b0010, 2'b10, 2'b00, 1'b0}, 2'b01, 1'b0);

        $display("Checking transition from MOV_SH to Write_Reg");
        #10;
        check_outputs(`S_WriteReg,{4'b0000, 2'b00, 2'b00, 1'b1}, 2'b01, 1'b0);
        

        $display("Checking automatic transition from WriteReg back to wait state");
        #10;
        check_outputs(`S_WAIT, 9'd0, 2'b11, 1'b1);

        sim_s_in = 1'b1; //activate s
        #10; //gets us to decode state
        
        //check CMP sequence
        sim_opcode_in = 3'b101;
        sim_op_in = 2'b01;
        $display("Checking DECODE->GETA");
        #10;
        check_outputs(`S_GETA, {4'b1000, 2'b00, 2'b00, 1'b0}, 2'b00, 1'b0);

        $display("Checking GETA->GETB");
        #10;
        check_outputs(`S_GETB, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0);

        $display("Checking GETB->CMP");
        #10;
        check_outputs(`S_CMP, {4'b0001, 2'b00, 2'b00, 1'b0}, 2'b11, 1'b0); //s should be loaded

        $display("Checking CMP->WAIT");
        #10;
        check_outputs(`S_WAIT, 9'd0, 2'b11, 1'b1);   

        sim_s_in = 1'b1; //activate s
        #10; //gets us to decode state

        //Checking AND sequence
        $display("Chcecking DECODE->GETA");
        sim_opcode_in = 3'b101;
        sim_op_in = 2'b10;
        #10;
        check_outputs(`S_GETA, {4'b1000, 2'b00, 2'b00, 1'b0}, 2'b00, 1'b0);

        $display("Checking GETA->GETB");
        #10;
        check_outputs(`S_GETB, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0);

        $display("Checking GETB->AND");
        #10;
        check_outputs(`S_AND, {4'b0010, 2'b00, 2'b00, 1'b0}, 2'b11, 1'b0);

        $display("Checking AND->WRITEREG");
        #10;
        check_outputs(`S_WriteReg,{4'b0000, 2'b00, 2'b00, 1'b1}, 2'b01, 1'b0);

        $display("Checking WRITEREG->WAIT");
        #10;
        check_outputs(`S_WAIT, 9'd0, 2'b11, 1'b1);   

        sim_s_in = 1'b1; //activate s
        #10; //gets us to decode state

        //Checking MVN sequence
        $display("Chcecking DECODE->GETB");
        sim_opcode_in = 3'b101;
        sim_op_in = 2'b11;
        #10;
        check_outputs(`S_GETB, {4'b0100, 2'b00, 2'b00, 1'b0}, 2'b10, 1'b0); //getting Rm

        $display("Checking GETB->MVN");
        #10;
        check_outputs(`S_MVN, {4'b0010, 2'b10, 2'b00, 1'b0}, 2'b11, 1'b0);

        $display("Checking MVN->WRITEREG");
        #10;
        check_outputs(`S_WriteReg, {4'b0000, 2'b00, 2'b00, 1'b1}, 2'b01, 1'b0);

        $display("Checking WRITEREG->WAIT");
        #10;
        check_outputs(`S_WAIT, 9'd0, 2'b11, 1'b1); 
        
        #10;

        if(~err) begin
            $display("PASS we gud");
        end else begin
            $display("FAILED");
        end
        $stop;
    end
endmodule