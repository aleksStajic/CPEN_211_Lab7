module lab7_top_tb;
    reg [3:0] sim_KEY;
    reg [9:0] sim_SW;
    wire [9:0] sim_LEDR;
    wire [6:0] sim_HEX0, sim_HEX1, sim_HEX2, sim_HEX3, sim_HEX4, sim_HEX5;
    reg err;
    integer i;

    //instantiating lab7_top
    lab7_top DUT(sim_KEY,sim_SW,sim_LEDR,sim_HEX0,sim_HEX1,sim_HEX2,sim_HEX3,sim_HEX4,sim_HEX5);

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
        #60;
        if(DUT.CPU.DP.REGFILE.R0 !== 16'd7) begin
            $display("ERROR at time %0d, register held %b, expected %b", $time, DUT.CPU.DP.REGFILE.R0, 16'd7);
            err = 1'b1;
        end

        #50;
        if(DUT.CPU.DP.REGFILE.R1 !== 16'd2) begin
            $display("ERROR at time %0d, register held %b, expected %b", $time, DUT.CPU.DP.REGFILE.R1, 16'd2);
            err = 1'b1;
        end
        #70;
        if(DUT.CPU.out !== 16'd16) begin
            $display("ERROR at time %0d, cpu out was %b, expected %b", $time, DUT.CPU.out, 16'd16);
            err = 1'b1;
        end
        #10;
        if(DUT.CPU.DP.REGFILE.R2 !== 16'd16) begin
            $display("ERROR at time %0d, register held %b, expected %b", $time, DUT.CPU.DP.REGFILE.R2, 16'd16);
            err = 1'b1;
        end


        if(~err) $display("PASS we gud");
        $stop;
        
    end

endmodule