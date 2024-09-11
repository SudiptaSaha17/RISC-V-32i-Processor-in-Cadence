module FSM_ALUControl(
input clk, rst,bit30,
input [6:0] OPCode,
input [2:0] Funct,
input [3:0] ALUFlag,
output reg AdrSrc, IRWrite, NextPC, MemW, RegW, PCNextSrc, ShiftSrc, RegWSrc,mem_rd_en,
output reg [1:0] ResultSrc, AluSrcB, MaskEn, AluSrcA,
output reg [2:0] ALU_Control,
output reg [1:0] data_length,
output reg mem_read_state
);

parameter FETCH         = 5'b00000;
parameter DECODE        = 5'b00001;
parameter MEMADR        = 5'b00010;
parameter MEMREAD       = 5'b00011;
parameter MEMWB         = 5'b00100;
parameter MEMWRITE      = 5'b00101;
parameter EXECUTER      = 5'b00110;
parameter EXECUTEI      = 5'b00111;
parameter EXECUTESH     = 5'b01000;
parameter ALUWB         = 5'b01001;
parameter BRANCH_VALID  = 5'b01010;
parameter BRANCH_JUMP	= 5'b01011;
parameter BRANCH_FOUR	= 5'b01100;
parameter J				= 5'b01101;
parameter JALR			= 5'b01110;
parameter JAL 			= 5'b01111;
parameter LUI			= 5'b10000;
parameter AUIPC         = 5'b10001;



parameter B_Type = 7'b 1100011;
parameter I_Type1= 7'b 0000011; //Load
parameter I_Type2= 7'b 0010011; //Execution
parameter I_Type3= 7'b 1100111; //JALR
parameter S_Type = 7'b 0100011;
parameter J_Type = 7'b 1101111;
parameter U_Type1= 7'b 0110111; //lui
parameter U_Type2= 7'b 0010111; //auipc
parameter R_Type = 7'b 0110011;


reg [4:0] pSTATE;
reg [4:0] nSTATE;

wire N = ALUFlag[3];
wire Z = ALUFlag[2];
wire C = ALUFlag[1];
wire V = ALUFlag[0];

reg NextPCEN;

// Next State Logic
always @(*)
	begin
	case(pSTATE)
		
		FETCH:
			nSTATE = DECODE;
		DECODE:
		begin
			case(OPCode)
				I_Type1:
					nSTATE = MEMADR;
				S_Type: nSTATE = MEMADR;
				R_Type:
					nSTATE =EXECUTER;
				I_Type2:
					begin
						case(Funct)
							3'b000:nSTATE = EXECUTEI;
							3'b010:nSTATE = EXECUTEI;
							3'b011:nSTATE = EXECUTEI;
							3'b100:nSTATE = EXECUTEI;
							3'b110:nSTATE = EXECUTEI;
							3'b111:nSTATE = EXECUTEI;
							3'b001:nSTATE = EXECUTESH;
							3'b101:nSTATE = EXECUTESH;
						endcase
					end
					
				B_Type: 	nSTATE = BRANCH_VALID;
				J_Type: 	nSTATE = J;
				I_Type3: 	nSTATE = J;
				U_Type1:	nSTATE = LUI;
				U_Type2: 	nSTATE = AUIPC;
					
			endcase
		end
		
		MEMADR:
			if(OPCode[5])
				nSTATE = MEMWRITE;
			else
				nSTATE = MEMREAD;
		
		MEMREAD:
			nSTATE = MEMWB;
			
		MEMWB:
			nSTATE = FETCH;
		
		MEMWRITE:
			nSTATE = FETCH;
			
		EXECUTER:
			nSTATE = ALUWB;
		
		EXECUTEI:
			nSTATE = ALUWB;
			
		EXECUTESH:
			nSTATE = ALUWB;
		
		ALUWB:
			nSTATE = FETCH;
		
		BRANCH_VALID:
			begin
				case(Funct)
					3'b000: 
						begin
							if(Z) nSTATE = BRANCH_JUMP;
							else nSTATE = BRANCH_FOUR;
						end
					3'b001:
						begin
							if(Z) nSTATE = BRANCH_FOUR;
							else nSTATE = BRANCH_JUMP;	
						end
					3'b100:
						begin
							if(N^C) nSTATE = BRANCH_JUMP;
							else nSTATE = BRANCH_FOUR;
						end					
					3'b101:
						begin
							if(N^C) nSTATE = BRANCH_FOUR;
							else nSTATE = BRANCH_JUMP;
						end
					3'b110:
						begin
							if(C) nSTATE = BRANCH_FOUR;
							else nSTATE = BRANCH_JUMP;
						end
					3'b111:
						begin
							if(C) nSTATE = BRANCH_JUMP;
							else nSTATE = BRANCH_FOUR;
						end
					//default:
						//nSTATE = FETCH;
				endcase
			end
		LUI:
			nSTATE = FETCH;
		AUIPC:
			nSTATE = FETCH;
			
		BRANCH_JUMP:
			nSTATE = FETCH;
		BRANCH_FOUR:
			nSTATE = FETCH;
			
		J:
			begin
				if(OPCode[3]) nSTATE = JAL;
				else	nSTATE = JALR;
			end
			
		JAL:
			nSTATE = FETCH;
		JALR:
			nSTATE = FETCH;
      default: nSTATE=FETCH;
	endcase
	end
	

// Output Logic
always @(*)
	begin
	case(pSTATE)
     		FETCH:
          begin
			AdrSrc = 0;
			AluSrcA = 2'b01;
			AluSrcB = 2'b10;
			ALU_Control = 3'b000;
			ResultSrc = 2'b10;
			IRWrite = 1;
			NextPC = NextPCEN ? 0:1;
			PCNextSrc = 1;
			MaskEn = 2'b00;
			RegWSrc = 0;
			RegW = 0;
			MemW = 0;
			mem_rd_en=1;
			mem_read_state=0;
			
          end
		  
		DECODE:
			begin
				IRWrite = 0;
				NextPC = NextPCEN?1:0;
				MaskEn = 2'b00;
				RegW = 0;
				MemW = 0;
				mem_rd_en=0;
				
            end
		
		MEMADR:
			begin
				AluSrcA = 2'b00;
				AluSrcB = 2'b01;
				ALU_Control = 3'b000;
				IRWrite = 0;
				NextPC = 0;
				MaskEn = 2'b00;
				RegW = 0;
				MemW = 0;
				AdrSrc=1;
				NextPCEN=0;
            end
			
		MEMREAD:
          begin
			AdrSrc = 1;
			ResultSrc = 2'b00;
			IRWrite = 0;
			NextPC = 0;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 0;
			mem_rd_en=1;
			mem_read_state=1;
          end
		
		MEMWB:
          begin
			AdrSrc = 1;
			ResultSrc = 2'b01;
			IRWrite = 0;
			NextPC = 0;
			MaskEn = 2'b00;
			RegWSrc = 0;
			RegW = 1;
			MemW = 0;
			mem_rd_en=0;
			mem_read_state=1;
          end
		
		MEMWRITE:
          begin
			AdrSrc = 1'b1;
			ResultSrc = 2'b00;
			IRWrite = 0;
			NextPC = 0;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 1;
			
			case(Funct)
				3'b000: data_length=2'b10;
				3'b001: data_length=2'b01;
				3'b010: data_length=2'b00;
			endcase
			
          end
		
		EXECUTER:
          begin
			AluSrcA = 2'b00;
			AluSrcB = 2'b00;
			IRWrite = 0;
			NextPC = 0;
			ShiftSrc = 0;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 0;
			NextPCEN=0;
			case(Funct)
			    3'b000:
				    if(bit30 == 1) ALU_Control = 3'b001;
				    else	ALU_Control = 3'b000;
			    3'b001:	ALU_Control = 3'b111;
			    3'b010: ALU_Control = 3'b001;
			    3'b011: ALU_Control = 3'b001;
			    3'b100: ALU_Control = 3'b100;
			    3'b101: 
				    if(bit30 == 1) ALU_Control = 3'b110;
				    else	ALU_Control = 3'b101;
			    3'b110: ALU_Control = 3'b011;
			    3'b111: ALU_Control = 3'b010;
		    endcase
			

          end
		
		EXECUTEI:
          begin
			AluSrcA = 2'b00;
			AluSrcB = 2'b01;
			IRWrite = 0;
			NextPC = 0;
			ShiftSrc = 0;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 0;
			NextPCEN=0;
			case(Funct)
			    3'b000: ALU_Control = 3'b000;
			    3'b010: ALU_Control = 3'b001;
			    3'b011: ALU_Control = 3'b001;
			    3'b100: ALU_Control = 3'b100;
			    3'b110: ALU_Control = 3'b011;
			    3'b111: ALU_Control = 3'b010;
		    endcase
		
          end
		  
		EXECUTESH:
			begin
			AluSrcA = 2'b00;
			AluSrcB = 2'b00;
			IRWrite = 0;
			NextPC = 0;
			ShiftSrc = 1;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 0;
			NextPCEN=0;
			case(Funct)
			    3'b001:	ALU_Control = 3'b111;
			    3'b101:
				    begin
				    if(bit30 == 1) ALU_Control = 3'b110;
				    else ALU_Control = 3'b101;
				    end
		    endcase
			end
			
		ALUWB:
			begin
			ResultSrc = 2'b00;
			IRWrite = 0;
			NextPC = 0;
			MaskEn = 2'b00;
			RegWSrc = 0;
			RegW = 1;
			MemW = 0;
            end
			
		BRANCH_VALID:
          begin
			AluSrcA = 2'b00;
			AluSrcB = 2'b00;
			ALU_Control = 3'b001;
			IRWrite = 0;
			NextPC = 0;
			ShiftSrc = 0;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 0;
			NextPCEN=0;
          end
		
		BRANCH_JUMP:
			begin
			AluSrcA = 2'b10;
			AluSrcB = 2'b01;
			ALU_Control = 3'b000;
			ResultSrc = 2'b10;
			IRWrite = 0;
			NextPC = 1;
			PCNextSrc = 1;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 0;
			NextPCEN = 1;
			end
			
		BRANCH_FOUR:
			begin
			AluSrcA = 2'b01;
			AluSrcB = 2'b10;
			ALU_Control = 3'b000;
			ResultSrc = 2'b10;
			IRWrite = 0;
			NextPC = 0;
			PCNextSrc = 1;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 0;
			end
			
		J:
			begin
			AluSrcA = 2'b10;
			AluSrcB = 2'b10;
			ResultSrc = 2'b10;
			IRWrite = 0;
			NextPC = 0;
			MaskEn = 2'b00;
			RegWSrc = 0;
			RegW = 1;
			MemW = 0;
			ALU_Control = 3'b000;
			NextPCEN=0;
			end
			
			
		JALR:
			begin
			AluSrcA = 2'b00;
			AluSrcB = 2'b01;
			ResultSrc = 2'b10;
			IRWrite = 0;
			NextPC = 1;
			PCNextSrc = 1;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 0;
			ALU_Control = 3'b000;
			end
			
		JAL:
			begin
			AluSrcA = 2'b10;
			AluSrcB = 2'b01;
			ResultSrc = 2'b10;
			IRWrite = 0;
			NextPC = 1;
			PCNextSrc = 1;
			MaskEn = 2'b00;
			RegW = 0;
			MemW = 0;
			ALU_Control = 3'b000;
			NextPCEN = 1;
			end
			
		LUI:
			begin
			IRWrite = 0;
			NextPC = 0;
			MaskEn = 2'b00;
			RegWSrc = 1;
			RegW = 1;
			MemW = 0;
			NextPCEN=0;
			end
			
		AUIPC:
			begin
			AluSrcA = 2'b10;
			AluSrcB = 2'b01;
			ResultSrc = 2'b10;
			IRWrite = 0;
			NextPC = 0;
			MaskEn = 2'b00;
			RegWSrc = 0;
			RegW = 1;
			MemW = 0;
			ALU_Control = 3'b000;
			NextPCEN=0;
			end
		
	endcase
	end
	
	
	
// Present State Register
always @(posedge clk, negedge rst)
	begin
		if(~rst)
			pSTATE <= FETCH;
		else
			pSTATE <= nSTATE;
	end
	
endmodule
