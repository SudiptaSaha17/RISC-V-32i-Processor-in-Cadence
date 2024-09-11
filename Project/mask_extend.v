module mask_extend (
    input [31:0] A,
    input [1:0] bit_no,
    output reg [31:0] B
);
    always @(*) begin
        casez(bit_no)
            2'b00: B = A;
          	2'b01: B = {16'b0, A[15:0]};
            2'b10: B = {24'b0, A[7:0]};
            2'b11: B = {28'b0, A[3:0]};

            default: B = 32'bx;
        endcase
    end
endmodule
