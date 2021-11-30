`define R0 3'b000
`define R1 3'b001
`define R2 3'b010
`define R3 3'b011
`define R4 3'b100
`define R5 3'b101
`define R6 3'b110
`define R7 3'b111

`define SW_addr 9'h140
`define LEDR_addr 9'h100

module lab7_topIO_tb;
    reg [3:0] sim_KEY;
    reg [9:0] sim_SW;
    wire [9:0] sim_LEDR;
    wire [6:0] sim_HEX0, sim_HEX1, sim_HEX2, sim_HEX3, sim_HEX4, sim_HEX5;
    reg err;
    //integer i;

    integer test_number = 1;

    //instantiating lab7_top
    lab7_top DUT(sim_KEY,sim_SW,sim_LEDR,sim_HEX0,sim_HEX1,sim_HEX2,sim_HEX3,sim_HEX4,sim_HEX5);

    task check_reg_val;
        input [15:0] reg_val;
        input [15:0] exp_val;
        input reg_num;
    begin
        if (reg_val !== exp_val) begin
            $display("ERROR in test %0d at time %0d, R%0d held %b, expected %b", test_number, $time, reg_num, reg_val, exp_val);
            err = 1'b1;
        end else begin
            $display("Passed test %0d for R%0d at time %0d",test_number, reg_num, $time);
        end
    end
    endtask
    
    task check_regs;
        input [2:0] regNum;
        input [15:0] exp_val;
    begin
        if (regNum === `R0) begin
            check_reg_val(DUT.CPU.DP.REGFILE.R0, exp_val, 0);
        end else if (regNum === `R1) begin
            check_reg_val(DUT.CPU.DP.REGFILE.R1, exp_val, 1);
        end else if (regNum === `R2) begin
            check_reg_val(DUT.CPU.DP.REGFILE.R2, exp_val, 2);
        end else if (regNum === `R3) begin
            check_reg_val(DUT.CPU.DP.REGFILE.R3, exp_val, 3);
        end else if (regNum === `R4) begin
            check_reg_val(DUT.CPU.DP.REGFILE.R4, exp_val, 4);
        end else if (regNum === `R5) begin
            check_reg_val(DUT.CPU.DP.REGFILE.R5, exp_val, 5);
        end else if (regNum === `R6) begin
            check_reg_val(DUT.CPU.DP.REGFILE.R6, exp_val, 6);
        end else if (regNum === `R7) begin
            check_reg_val(DUT.CPU.DP.REGFILE.R7, exp_val, 7);
        end
        test_number = test_number + 1;
    end
    endtask

    initial begin
        forever begin
            sim_KEY[0] = 1'b1; #5; //starting at clk = 0
            sim_KEY[0] = 1'b0; #5;
        end
    end

    //Sample instructions to test operation
    //MOV R0, #5

    initial begin
        err = 1'b0;
        sim_KEY[1] = 1'b0; //asserting reset
        #10; //now we are in reset state
        sim_KEY[1] = 1'b1; //turning off reset
        #10; //get out of reset
        sim_SW[7:0] = 8'b00110100;

        /* Put addreses of SW and LEDR in R0 and R1 */

        #50 // MOV R0, #80
        $display("Finished 'MOV R0, #80' at time %0d, R0 = %0d",$time, DUT.CPU.DP.REGFILE.R0);
        #70 // MOV R0, R0, LSL #1 // R0 = 160
        $display("Finished 'MOV R0, R0, LSL #1' at time %0d, R0 = %0d",$time, DUT.CPU.DP.REGFILE.R0);
        #70 // MOV R0, R0, LSL #1 // R0 = 320
        $display("Finished 'MOV R0, R0, LSL #1' at time %0d, R0 = %0d",$time, DUT.CPU.DP.REGFILE.R0);
        #50 // MOV R1, #64
        $display("Finished 'MOV R1, #64' at time %0d, R1 = %0d",$time, DUT.CPU.DP.REGFILE.R1);
        #70 // MOV R1, R1, LSL #1 // R1 = 128
        $display("Finished 'MOV R1, R1, LSL #1' at time %0d, R1 = %0d",$time, DUT.CPU.DP.REGFILE.R1);
        #70 // MOV R1, R1, LSL #1 // R1 = 256
        $display("Finished 'MOV R1, R1, LSL #1' at time %0d, R1 = %0d",$time, DUT.CPU.DP.REGFILE.R1);

        /* Starting to test IO */

        #90 // LDR R2, [R0] // R0 = 320

        #50 // MOV R3, #77
        #80 // STR R3, [R1] // R1 = 256 

        $display("finished at time %0d" , $time);

        #40;
        //if(~err) $display("PASS we gud");
        
        $stop;
        
    end

endmodule

//Task for checking contents of a given register (work in progress)
    //task check_reg;
    //   input [2:0] check_reg;
    //    input [15:0] exp_val;

    //    begin
    //        for(i = 0; i < 9; i = i + 1) begin
    //            if(i === check_reg) begin
    //                if(exp_val !== DUT.CPU.DP.REGFILE.Ri) begin
    //                    $display("ERROR at time %0d, register held %b, expected %b", $time, DUT.CPU.DP.REGFILE.Ri, exp_val);
    //                    err = 1'b1;
    //                end
    //            end
    //        end
    //    end
    //endtask
