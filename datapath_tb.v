`define ONE 1'b1
`define ZERO 1'b0
`define R0 3'b000
`define R1 3'b001
`define R2 3'b010
`define R3 3'b011
`define R4 3'b100
`define R5 3'b101
`define R6 3'b110
`define R7 3'b111

module datapath_tb();

    //inputs
    reg [2:0] sim_readnum, sim_writenum;
    reg sim_write;
    reg sim_asel, sim_bsel;
    reg [1:0] sim_vsel;
    reg sim_loada, sim_loadb, sim_loadc, sim_loads;
    reg [1:0] sim_ALUop, sim_shift;
    reg [15:0] sim_datapath_in;
    reg sim_clk;
    reg [15:0] sim_sximm5;
    reg [15:0] sim_mdata;
    reg [7:0] sim_PC;

    //outputs
    wire sim_Z_out, sim_N_out, sim_V_out; 
    wire [15:0] sim_datapath_out; 

    reg err;

    datapath DP ( .clk      (sim_clk), 
                    // recall from Lab 4 that KEY0 is 1 when NOT pushed
                
                // register operand fetch stage
                .readnum     (sim_readnum),
                .vsel        (sim_vsel),
                .loada       (sim_loada),
                .loadb       (sim_loadb),

                // computation stage (sometimes called "execute")
                .shift       (sim_shift),
                .asel        (sim_asel),
                .bsel        (sim_bsel),
                .ALUop       (sim_ALUop),
                .loadc       (sim_loadc),
                .loads       (sim_loads),

                // set when "writing back" to register file
                .writenum    (sim_writenum),
                .write       (sim_write),  
                .datapath_in (sim_datapath_in),

                // outputs
                .Z_out       (sim_Z_out),
                .N_out       (sim_N_out),
                .V_out       (sim_V_out),
                .datapath_out (sim_datapath_out),
                .mdata (sim_mdata),
                .PC (sim_PC),
                .sximm5 (sim_sximm5)
             );

    initial begin
        sim_clk = 0; //clk off
        #5;
        forever begin
            sim_clk = 1; //clk on
            #5;
            sim_clk = 0; //clk off
            #5;
        end
    end

    task my_checker; //verifies correct datapath_out and z_out  
        input [15:0] expected_output;  // datapath_out
        input expected_Z; // z_out
    begin
        if( sim_datapath_out !== expected_output ) begin
            $display("ERROR at time %0d ** DP_out is %b, expected %b", $time, sim_datapath_out ,expected_output);
            err = 1'b1;
        end
        else $display("Passed datapath test case at time %0d", $time);
        if(sim_Z_out !== expected_Z) begin
            $display("ERROR at time %0d ** Z is %b, expected %b", $time, sim_Z_out, expected_Z);
            err = 1'b1;
        end
        else $display("Passed z_out test case at time %0d", $time);
        // %0d suprresses leading zeros that cause blank spaces 
        // to be displayed in console
    end
    endtask

    task enable_abcs; //enables/disables a,b,c,s registers
        input a_load;
        input b_load;
        input c_load;
        input s_load;
    begin
        sim_loada = a_load;
        sim_loadb = b_load;
        sim_loadc = c_load;
        sim_loads = s_load;
    end
    endtask

    task sel_vab; //sets v,a,b mux sel values
        input [1:0] sel_v;
        input sel_a;
        input sel_b;
    begin
        sim_vsel = sel_v;
        sim_asel = sel_a;
        sim_bsel = sel_b;
    end
    endtask

    task write_prep; //preps regfile for writing
        input [2:0] write_reg;
    begin
        sim_write = 1;
        sim_writenum = write_reg;
    end
    endtask

    task set_ops; //sets ALU and Shifter Opertaions
        input [2:0] op_alu;
        input [2:0] op_shifter;
    begin
        sim_ALUop = op_alu;
        sim_shift = op_shifter;
    end
    endtask


    /* List of Test Cases
        1) 4 + 2 ALU operations
            -special cases: overflow and negative result from subtraction
        2) 4 + 1 Shifter Operations
            -special case op4: with "copy MSB" for both 0 and 1 
        3) Immeidiate Operand/ Immediate Operation 
        4) Z_out = 1 */

    initial begin
        err = 1'b0;
        #10; //start changing values on falling edge of clk 

        // set datapath behaviour
        enable_abcs(0,0,0,0);
        sel_vab(2'b10,1'bx,1'bx);
        set_ops(2'bxx,2'bxx); 

        // Initialize the values in some registers

        //Write datapath_in value to register 0
        sim_datapath_in = 16'b1111000011001111; // shifter testing value 1
        write_prep(`R0); #10; //write above value to R0 on next rising clk
        //sim_readnum = `R0; #20;
        if(DP.REGFILE.R0 !== 16'b1111000011001111) begin //check if write was successful
            $display("ERROR at time %0d, R0 contains %b, expected %b", $time, DP.REGFILE.R0, 16'b1111000011001111);
            err = 1'b1;
        end

        //Write datapath_in value to register 1
        sim_datapath_in = 16'd32; 
        write_prep(`R1); #10; //write above value to R1 on next rising clk
        //sim_readnum = `R1; #20;
        if(DP.REGFILE.R1 !== 16'd32) begin //check if write was successful
            err = 1'b1;
        end

        //Write datapath_in value to register 2
        sim_datapath_in = 16'd10; 
        write_prep(`R2); #10; //write above value to R2 on next rising clk
        //sim_readnum = `R2; #20;
        if(DP.REGFILE.R2 !== 16'd10) begin //check if write was successful
            err = 1'b1;
        end

        //Write datapath_in value to register 3
        sim_datapath_in = 16'd62783; 
        write_prep(`R3); #10; //write above value to R2 on next rising clk
        //sim_readnum = `R3; #20;
        if(DP.REGFILE.R3 !== 16'd62783) begin //check if write was successful
            err = 1'b1;
        end

        //Write datapath_in value to register 4
        sim_datapath_in = 16'b0111000011001111;
        write_prep(`R4); #10;
        //sim_readnum = `R4; #20;
        if(DP.REGFILE.R4 !== 16'b0111000011001111) begin //check if write was successful
            err = 1'b1;
        end

        //Write datapath_in value to register 5
        sim_datapath_in = 16'd1;
        write_prep(`R5); #10;
        if(DP.REGFILE.R5 !== 16'd1) begin //check if write was successful
            err = 1'b1;
        end

        //Write datapath_in value to register 6
        sim_datapath_in = 16'd2;
        write_prep(`R6); #10;
        if(DP.REGFILE.R6 !== 16'd2) begin //check if write was successful
            err = 1'b1;
        end

        //Write datapath_in value to register 7
        sim_datapath_in = 16'd3;
        write_prep(`R7); #10;
        if(DP.REGFILE.R7 !== 16'd3) begin //check if write was successful
            err = 1'b1;
        end

        /*At time 90us , r0-r4 have values*/
        sim_write = 0;  

        //--------------------------------------------//
        // Shifter Operations Test Cases              //
        //--------------------------------------------//

        // Initialize datapath for Shifter Operations
        enable_abcs(1,1,1,1);
        sel_vab(2'b10,1,0);
        sim_readnum = `R0; #10; // R0 value will copy to RB next pos clk

        // Shifter Opcode 00 Test - No effect
        set_ops(2'b00,2'b00); #10;
        my_checker(16'b1111000011001111,0);

        // Shifter Opcode 01 Test - Reg B LSL by 1 bit, LSB is 0
        set_ops(2'b00,2'b01); #10;
        my_checker(16'b1110000110011110,0);

        // Shifter Opcode 10 Test - Reg B RSL by 1 bit, MSB is 0
        set_ops(2'b00,2'b10); #10;
        my_checker(16'b0111100001100111,0);

        // Shifter Opcode 11 Test #1 - Reg B RSL by 1 bit, MSB = B[15] (1)
        set_ops(2'b00,2'b11); #10;
        my_checker(16'b1111100001100111,0);

        // Shifter Opcode 11 Test #2 - Reg B RSL by 1 bit, MSB = B[15] (0)
        sim_readnum = `R4; #10;
        #10; //to account for Reg C changing
        my_checker(16'b0011100001100111,0);

        /* Shifter Testing Finishes at 160us */

        //--------------------------------------------//
        // ALU Operations Test Cases                  //
        //--------------------------------------------//

        // Initialize datapath for bitwise ALU Opertions
        enable_abcs(0,1,1,1); // enable all reg except A
        sim_readnum = `R3; #10; // copy R3 to Reg B on next rising clk
        sel_vab(2'b10,0,0);
        // Reg B= 16'd62783, Reg A = 16'b0111000011001111
        // OR Reg B = 16'b1111010100111111 

        // ALU Opcode 10 - bitwise AND
        set_ops(2'b10,2'b00); #10;
        my_checker(16'd62783 & 16'b0111000011001111, 0);

        // ALU Opcode 11 - bitwise NOT
        set_ops(2'b11,2'b00); #10;
        my_checker(~(16'b1111010100111111), 0);

        /* Bitwise ALU testing finishes at 190us */

        // initialize datapath for "adder" ALU Operations
        sim_readnum = `R2; #10;
        enable_abcs(1,0,1,1);
        sim_readnum = `R1; #10;
        //reg A = 16'd32 , reg B = 16'd10

        // ALU Opcode 00 - Binary Addition "+"
        set_ops(2'b00,2'b00); #10
        my_checker(16'd32 + 16'd10, 0);
        

        // ALU Opcode 01 - Binary subtraction "-"
        set_ops(2'b01,2'b00); #10;
        my_checker(16'd32 - 16'd10, 0);

        /* "Adder" ALU testing finishes at 230us */

        // Initialize datapath for ALU overflow case
        sim_readnum = `R0; #10;
        enable_abcs(0,1,1,1); 
        sim_readnum = `R4; #10;
        // reg A = 16'b1111000011001111, reg B = 16'b0111000011001111
        
        // ALU Opcode 00 - Binary Addition with overflow
        set_ops(2'b00,2'b00); #10
        my_checker(16'b0110000110011110, 0);
        // result should be 17'b10110000110011110 but overflow results
        // in 16'b0110000110011110

        // Initialize datapath for ALU negative result case
        sim_readnum = `R1; #10;
        enable_abcs(1,0,1,1); 
        sim_readnum = `R2; #10;
        //reg B = 16'd32 , reg A = 16'd10

        // ALU Opcode 01 - Binary Subtraction resulting in neg num
        set_ops(2'b01,2'b00); #10
        my_checker(16'd10 - 16'd32, 0);

        /* ALU Special Cases testing finishes at 290us*/

        //------------------------------------------------------------//
        // Checking datapath_out input to register file with vsel = 0 //
        //------------------------------------------------------------//
        
        //Writing datapath_out to register R4
        write_prep(`R4);
        sel_vab(2'b00, 0, 0);
        #10;
        
        sim_write = 0;
        enable_abcs(0,1,1,1); //enabling RB to store R4
        sel_vab(2'b00, 1, 0);
        set_ops(2'b00, 2'b00);
        sim_readnum = `R4; #20;
        my_checker(16'd10 - 16'd32, 0);


        //--------------------------------------------//
        // Immediate Operation Test Case              //
        //--------------------------------------------//
        
        //R2 is in RA, R2 = 10
        //ALU Opcode 00 - checking binary addition with immediate operand
        enable_abcs(0, 0, 1, 1);
        set_ops(2'b00, 2'b00);
        sel_vab(2'b10, 0, 1);
        sim_datapath_in = 16'd10;
        sim_sximm5 = 16'd10;
        #10;
        my_checker(16'd20, 0); //output should be 10+10 = 20

        //Checking R2 & 16'd10
        //ALU Opcode 10 - checking bitwise AND with immediate operand
        set_ops(2'b10, 2'b00);
        #10;
        my_checker(16'd10, 0); //output should just be value in R2

        //Checking ~16'd10
        //ALU Opcode 11 - checking bitwise NOT of immediate operand
        set_ops(2'b11, 2'b00);
        #10;
        my_checker(~16'd10, 0);

        //--------------------------------------------//
        // Z_out = 1 Case                             //
        //--------------------------------------------//

        //Checking R2 - 10, with immediate operand
        //ALU Opcode 01 - checking binary subtraction with immediate operand
        set_ops(2'b01, 2'b00);
        #10;
        my_checker(16'd0, 1); //output of subtraction should be 0, Z_out should be 1


        //-------------------------------------------//
        // Checking overflow with subtraction        //
        //-------------------------------------------//

        sel_vab(2'b10, 0, 0);
        enable_abcs(0, 0, 0, 0);

        //Write datapath_in value to register 0
        sim_datapath_in = 16'd2; // shifter testing value 1
        write_prep(`R0); #10; //write above value to R0 on next rising clk
        //sim_readnum = `R0; #20;
        if(DP.REGFILE.R0 !== 16'd2) begin //check if write was successful
            $display("ERROR at time %0d, R0 contains %b, expected %b", $time, DP.REGFILE.R0, 16'd2);
            err = 1'b1;
        end

        //Write #2 to R1
        sim_datapath_in = 16'd7; // shifter testing value 1
        write_prep(`R1); #10; //write above value to R0 on next rising clk
        //sim_readnum = `R0; #20;
        if(DP.REGFILE.R1 !== 16'd7) begin //check if write was successful
            $display("ERROR at time %0d, R1 contains %b, expected %b", $time, DP.REGFILE.R1, 16'd7);
            err = 1'b1;
        end

        //Checking subtraction output
        //Load R0 into reg A
        enable_abcs(1, 0, 0, 0);
        sim_readnum = `R0; #10;
        //Load R1 into Reg B
        enable_abcs(0, 1, 0, 0);
        sim_readnum = `R1; #10;
        //Compute R0 - R1 = 2 - 7
        enable_abcs(0, 0, 1, 1);
        set_ops(2'b01,2'b00); #10
        my_checker(16'd2 - 16'd7, 0);
        
        #10;
        if (~err) $display("PASSED ALL we gud");
        $stop;
    end
endmodule