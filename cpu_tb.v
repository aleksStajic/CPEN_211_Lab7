module cpu_tb;
    reg sim_clk, sim_reset, sim_s, sim_load;
    reg [15:0] sim_in;
    wire [15:0] out;
    wire N, V, Z, w;
    reg err;

    cpu DUT(sim_clk, sim_reset, sim_s, sim_load, sim_in, out, N, V, Z, w); //instantiating CPU

    initial begin
        forever begin
            sim_clk = 1'b0; #5;
            sim_clk = 1'b1; #5;
        end
    end

    initial begin
        err = 1'b0;
        sim_reset = 1'b1; //asserting reset
        #10;
        sim_reset = 1'b0;

        /* finished testing reset at 10ps, let's add values to R0 and R1*/

        sim_in = 16'b1101000000000010; //MOV R0, #2 decoded instruction
        sim_load = 1'b1;
        sim_s = 1'b1; //activate s
        #30; //for reasons reasoned by us
        if(DUT.DP.REGFILE.R0 !== 16'd2) begin
            $display("ERROR at time %0d, R0 was %b, expected %b", $time, DUT.DP.REGFILE.R0, 16'd2);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 1 at time %0d", $time);
        end

        sim_in = {3'b110,2'b10,3'b001,8'b00000101}; //MOV R1, #5 decoded instruction
        sim_load = 1'b1;
        sim_s = 1'b1; //activate s
        #30;
        if(DUT.DP.REGFILE.R1 !== 16'd5) begin
            $display("ERROR at time %0d, R1 was %b, expected %b", $time, DUT.DP.REGFILE.R1, 16'd5);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 2 at time %0d", $time);
        end

        /*finished adding to R0 and R1 at 70ps, let's ADD some numbers!!!*/

        //should be in wait state at end of last CHECK
        sim_in = {3'b101,2'b00,3'b000,8'b01000001}; //ADD R2, R0, R1
        sim_load = 1'b1; //activate instruction register
        sim_s = 1'b1; //activate s
        #50;
        
        //Check that the output of datapath is the output of R0 + R1
        if (DUT.DP.datapath_out !== 16'd7) begin
            $display("ERROR at time %0d, datapath_out was %b, expected %b", $time, DUT.DP.datapath_out, 16'd7);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 3 at time %0d", $time);
        end

        #10;

        //Checking that R0 + R1 was correctly written to register R2
        if(DUT.DP.REGFILE.R2 !== 16'd7) begin
            $display("ERROR at time %0d, R2 was %b, expected %b", $time, DUT.DP.REGFILE.R2, 16'd7);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 4 at time %0d", $time);
        end

        //Checking MOV operation with registers (not immediate move)
        //Checking MOV R3, R2
        sim_in = {3'b110, 2'b00, 3'b000, 3'b011, 2'b00, 3'b010};
        #50;

        //Checking that R3 indeed contains the value of R2, which was 7 from last operation
        if(DUT.DP.REGFILE.R3 !== 16'd7) begin
            $display("ERROR at time %0d, R3 was %b, expected %b", $time, DUT.DP.REGFILE.R3, 16'd7);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 5 at time %0d", $time);
        end

        //Checking MOV operation with registers, and a LSL
        //Checking MOV R4, R1, LSL #1
        sim_in = {3'b110, 2'b00, 3'b000, 3'b100, 2'b01, 3'b001};
        #50;

        //Checking that R4 = 10, which is R1, LSL #1 = 5 * 2
        if(DUT.DP.REGFILE.R4 !== 16'd10) begin
            $display("ERROR at time %0d, R4 was %b, expected %b", $time, DUT.DP.REGFILE.R4, 16'd10);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 6 at time %0d", $time);
        end

        //Checking MOV immediate operation, with negative number
        //Checking MOV R5, #-1
        sim_in = {3'b110, 2'b10, 3'b101, 8'b11111111};
        #30;

        if(DUT.DP.REGFILE.R5 !== 16'b1111111111111111) begin
            $display("ERROR at time %0d, R5 was %b, expected %b", $time, DUT.DP.REGFILE.R5, 16'b1111111111111111);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 7 at time %0d", $time);
        end

        //Checking 3rd register MOV, with LSR, preserving MSB
        //Checking MOV R6, R5
        sim_in = {3'b110, 2'b00, 3'b000, 3'b110, 2'b11, 3'b101};
        #50;
        if(DUT.DP.REGFILE.R6 !== 16'b1111111111111111) begin
            $display("ERROR at time %0d, R6 was %b, expected %b", $time, DUT.DP.REGFILE.R6, 16'b1111111111111111);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 8 at time %0d", $time);
        end

        /* finished testing 3 operations of both MOV_SH and MOV_IMM at time 310ps */

        //Current register values for R0->R6 2 5 7 7 10 -1 -1

        //Checking CMP R2, R3 // 7 and 7
        sim_in = {3'b101, 2'b01, 3'b010, 3'b000, 2'b00, 3'b011};
        #50;
        if(Z == 1'b0) begin
            $display("ERROR at time %0d, Z was %b, expected %b", $time, Z, 1'b1);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 9 at time %0d", $time);
        end

        //Checking CMP R0, R4 // 2 and 10
        sim_in = {3'b101, 2'b01, 3'b000, 3'b000, 2'b00, 3'b100};
        #50;
        if(V == 1'b1) begin
            $display("ERROR at time %0d, V was %b, expected %b", $time, V, 1'b0);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 10 at time %0d", $time);
        end

        //Checking CMP R1, R6 // 5 and -1
        sim_in = {3'b101, 2'b01, 3'b001, 3'b000, 2'b00, 3'b110};
        #50;
        if(Z == 1'b1) begin
            $display("ERROR at time %0d, Z was %b, expected %b", $time, Z, 1'b0);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 11 at time %0d", $time);
        end
        
        //Checking CMP R4, R1, LSL #1 // 10 and 5 << 1  should be equal
        sim_in = {3'b101, 2'b01, 3'b100, 3'b000, 2'b01, 3'b001};
        #50;
        if(Z == 1'b0) begin
            $display("ERROR at time %0d, Z was %b, expected %b", $time, Z, 1'b1);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 12 at time %0d", $time);
        end

        /* finished CMP testing at time 510ps, starting to test AND operations*/

        //Current register values for R0->R6 2 5 7 7 10 -1 -1

        //Checking AND R7, R2, R4
        sim_in = {3'b101, 2'b10, 3'b010, 3'b111, 2'b00, 3'b100};
        #60;
        if(DUT.DP.REGFILE.R7 !== 16'b0000000000000010) begin
            $display("ERROR at time %0d, R7 was %b, expected %b", $time, DUT.DP.REGFILE.R7, 16'b0000000000000010);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 13 at time %0d", $time);
        end

        //Current register values for R0->R7 2 5 7 7 10 -1 -1 2

        //Checking AND R3, R5, R2, LSL #1
        sim_in = {3'b101, 2'b10, 3'b101, 3'b011, 2'b01, 3'b010};
        #60;
        if(DUT.DP.REGFILE.R3 !== 16'b0000000000001110) begin
            $display("ERROR at time %0d, R3 was %b, expected %b", $time, DUT.DP.REGFILE.R3, 16'b0000000000001110);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 14 at time %0d", $time);
        end

        //Current register values for R0->R7 2 5 7 14 10 -1 -1 2

        //Checking AND R0, R6, R5, LSR #1
        sim_in = {3'b101, 2'b10, 3'b110, 3'b000, 2'b10, 3'b101};
        #60;
        if(DUT.DP.REGFILE.R0 !== 16'b0111111111111111) begin
            $display("ERROR at time %0d, R3 was %b, expected %b", $time, DUT.DP.REGFILE.R0, 16'b0111111111111111);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 15 at time %0d", $time);
        end

        /* finished CMP testing at time 690ps, starting to test NOT operations*/

        //Current register values for R0->R7 32767 5 7 14 10 -1 -1 2

        //Checking MVN R5, R5
        sim_in = {3'b101, 2'b11, 3'b000, 3'b101, 2'b00, 3'b101};
        #50;
        if(DUT.DP.REGFILE.R5 !== 16'd0) begin
            $display("ERROR at time %0d, R6 was %b, expected %b", $time, DUT.DP.REGFILE.R5, 16'd0);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 16 at time %0d", $time);
        end

        //Current register values for R0->R7 32767 5 7 14 10 0 -1 2

        //Checking MVN R2, R0
        sim_in = {3'b101, 2'b11, 3'b000, 3'b010, 2'b00, 3'b000};
        #50;
        if(DUT.DP.REGFILE.R2 !== 16'd32768) begin
            $display("ERROR at time %0d, R2 was %b, expected %b", $time, DUT.DP.REGFILE.R2, 16'd32768);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 17 at time %0d", $time);
        end

        //Current register values for R0->R7 32767 5 32768 14 10 0 -1 2

        //Checking MVN R0, R4, LSL #1
        sim_in = {3'b101, 2'b11, 3'b000, 3'b000, 2'b01, 3'b100};
        #50;
        if(DUT.DP.REGFILE.R0 !== ~16'd20) begin
            $display("ERROR at time %0d, R0 was %b, expected %b", $time, DUT.DP.REGFILE.R0, ~16'd20);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 18 at time %0d", $time);
        end

        /* finished MVN testing at time 830ps*/

        /* Checking more ADD operations, with shifting included */
        //Current register vues for R0->R7  65515 5 32768 14 10 0 -1 2

        //Checking ADD R3, R3, R6, LSL #1
        sim_in = {3'b101, 2'b00, 3'b011, 3'b011, 2'b01, 3'b110};
        #60;
        if(DUT.DP.REGFILE.R3 !== 16'd12) begin
            $display("ERROR at time %0d, R3 was %b, expected %b", $time, DUT.DP.REGFILE.R3, 16'd12);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 19 at time %0d", $time);
        end

        //Checking ADD R4, R6, R2, LSR #1
        sim_in = {3'b101, 2'b00, 3'b110, 3'b100, 2'b11, 3'b010};
        #60;
        if(DUT.DP.REGFILE.R4 !== 16'b1011111111111111) begin
            $display("ERROR at time %0d, R4 was %b, expected %b", $time, DUT.DP.REGFILE.R4, 16'b1011111111111111);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 19 at time %0d", $time);
        end

        //Checking CMP, 0x8000, 2 -> FAILED AUTOGRADER CHECK
        //MOV R0, 8'b10000000
        sim_in = {3'b110, 2'b10, 3'b000, 8'b10000000};
        #30;
        if(DUT.DP.REGFILE.R0 !== 16'b1111111110000000) begin
            $display("ERROR at time %0d, R0 was %b, expected %b", $time, DUT.DP.REGFILE.R0, 16'b1111111110000000);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 19 at time %0d", $time);
        end       

        //MOV R1, #2
        sim_in = {3'b110, 2'b10, 3'b001, 8'd2};
        #30;
        if(DUT.DP.REGFILE.R1 !== 16'd2) begin
            $display("ERROR at time %0d, R0 was %b, expected %b", $time, DUT.DP.REGFILE.R1, 16'd2);
            err = 1'b1;
        end else begin
            $display("PASSED CHECK 20 at time %0d", $time);
        end        

        #10; //just to see a little more
        $stop;
    end
endmodule

