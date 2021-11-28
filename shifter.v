module shifter(in,shift,sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;
    // fill out the rest

    reg [15:0] sout;
    
    always @* begin
        case (shift) // only shifts bits
            2'b00 : sout = in;
            2'b01 : sout = in << 1;
            2'b10 : sout = in >> 1;
            2'b11 : sout = in >> 1;
            default : sout = 16'bxxxxxxxxxxxxxxxx;
        endcase

        if (shift == 2'b10) begin
            sout[15] = 1'b0;
        end
        else if (shift == 2'b11) begin
            sout[15] = in[15];
        end
    end

endmodule
