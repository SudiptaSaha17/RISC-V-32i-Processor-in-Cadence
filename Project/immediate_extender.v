module extimm(
input [31:0] Instr,
output reg [31:0] immr
);



parameter B_Type = 7'b 1100011;
parameter I_Type1= 7'b 0000011;
parameter I_Type2= 7'b 0010011;
parameter I_Type3= 7'b 1100111;
parameter S_Type = 7'b 0100011;
parameter J_Type = 7'b 1101111;
parameter U_Type1= 7'b 0110111;
parameter U_Type2= 7'b 0010111;


wire [6:0] opcode = Instr[6:0];
wire [2:0] Funct = Instr[14:12];


always@(*)
begin
case(opcode)
	B_Type:
		case(Funct)
		
			3'b000:immr = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8],1'b0};
			3'b001:immr = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8],1'b0};
			3'b100:immr = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8],1'b0};
			3'b101:immr = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8],1'b0};
			3'b110:immr = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8],1'b0};
			3'b111:immr = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8],1'b0};
		endcase
	
	I_Type1:
		case(Funct)
			3'b000:immr = {{20{Instr[31]}}, Instr[31:20]};
			3'b001:immr = {{20{Instr[31]}}, Instr[31:20]};
			3'b010:immr = {{20{Instr[31]}}, Instr[31:20]};
			3'b100:immr = {20'b0, Instr[31:20]};
			3'b101:immr = {20'b0, Instr[31:20]};
		endcase
	I_Type2:
		case(Funct)
			3'b000:immr = {{20{Instr[31]}}, Instr[31:20]};
			3'b010:immr = {{20{Instr[31]}}, Instr[31:20]};
			3'b011:immr = {20'b0 , Instr[31:20]};
			3'b100:immr = {{20{Instr[31]}}, Instr[31:20]};
			3'b110:immr = {{20{Instr[31]}}, Instr[31:20]};
			3'b111:immr = {{20{Instr[31]}}, Instr[31:20]};
		endcase
	I_Type3: 
		case(Funct)
			3'b 000: immr = {{20{Instr[31]}}, Instr[31:20]};
		endcase
	S_Type:
		case(Funct)
			3'b000:immr ={{20{Instr[31]}},Instr[31:25],Instr[11:7]};
			3'b001:immr ={{20{Instr[31]}},Instr[31:25],Instr[11:7]};
			3'b010:immr ={{20{Instr[31]}},Instr[31:25],Instr[11:7]};
		endcase		
			
	J_Type:
		immr={{11{Instr[31]}},Instr[31],Instr[19:12],Instr[20],Instr[30:21],1'b0};
	U_Type1:
		immr = {12'b0, Instr[31:12]};
	U_Type2:
		immr = {12'b0, Instr[31:12]};
		
endcase
end


endmodule


