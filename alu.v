module ALU(Ain,Bin,ALUop,out, N, V, Z);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;  
    reg [15:0] out; 
    output Z;
    output N;
    output V;
    reg Z;
    reg N;
    reg V;

    always @* begin
        case(ALUop)
            2'b00 : out = Ain + Bin;
            2'b01 : out = Ain - Bin;
            2'b10 : out = Ain & Bin;
            2'b11 : out = ~Bin;

            default : out = {16{1'bx}};
        endcase

        //If output is 0, Z=1, otherwise Z=0
        if(out === 16'd0) begin
            Z = 1'b1;
        end else begin
            Z = 1'b0;
        end

        //If output is negative, MSB is 1 (2's complement), N=1, otherwise N=0
        if(out[15] === 1'b1) begin
            N = 1'b1;
        end else begin
            N = 1'b0;
        end

        if(ALUop === 2'b01) begin //overflow detection for subtraction, Bin will automatically have a negative sign (Ain + (-Bin))
            if((Ain[15] === ~Bin[15]) && (Ain[15] !== out[15])) begin 
               V = 1'b1; 
            end else begin
                V = 1'b0;
            end
        end else if(ALUop === 2'b00) begin //overflow detection for addition
            if((Ain[15] === Bin[15]) && (Bin[15] !== out[15])) begin 
               V = 1'b1; 
            end else begin
                V = 1'b0;
            end
        end else begin
            V = 1'b0;
        end
    end
endmodule