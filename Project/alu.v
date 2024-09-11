module ALU(
	input  [31:0] a,  //src1
	input  [31:0] b,  //src2
	input  [2:0] alu_control,
	input rst, //function sel
	output reg [31:0] result,  //result
	output reg [3:0] ALUFlag 
	);


	reg [31:0] sum;
	reg Co;
	reg [31:0] resultFlag;

	reg N,Z,C,V;


	always @(*)
	begin 
	 case(alu_control)
	 3'b000: result = a + b; 
	 3'b001: result = a - b; 
	 3'b010: result = a&b;
	 3'b011: result = a|b;
	 3'b100: result = a^b;
	 3'b101: result = a>>b; 
	 3'b110: result = a>>>b;
	 3'b111: result = a<<b;
	 default:result = a + b;
	 endcase
	end


	always @(*) begin
		if(!rst) begin
			{N,Z,C,V} = 4'b0;
		end
		else begin
		  {Co, sum} = alu_control[0]?(a-b):(a+b);

			case(alu_control)
				3'b000: resultFlag = sum;
				3'b001: resultFlag = sum;
				3'b010: resultFlag = a & b;
				3'b011: resultFlag = a | b;

				default: resultFlag = sum;
			endcase
		end
	end


	always @ (*) begin

	V <= (~(a[31] ^ a[31] ^ alu_control[0])) & (sum[31] ^ a[31]) & (~alu_control[1]);
	C <= ~alu_control[1] & Co;
	N <= resultFlag[31];
	Z <= &(~resultFlag);
	ALUFlag<={N,Z,C,V};
	end
endmodule
