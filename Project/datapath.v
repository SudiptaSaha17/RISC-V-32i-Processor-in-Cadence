module Datapath_Unit(
	input clk, rst,
	input [2:0] ALUControlIn,
	input AdrSrc, IRWrite, NextPC, MemW, RegW, PCNextSrc, ShiftSrc, RegWSrc,
	input [1:0] ResultSrc, AluSrcB, MaskEn,AluSrcA,
	input [31:0] Instr,
	output [6:0] OPCode,
	output [2:0] Funct,
	output [3:0] ALUFlag,
	output bit30,
	output [31:0]mem_address,
	output [31:0] reg_read_data_2,
	input mem_read_state
	
);

wire [31:0] PC,OLDPC, Read_Data_1, Read_Data_2, ALUOut, MemData;
wire [31:0] pc_next;
wire [4:0] reg_write_dest;
wire [31:0] reg_write_data;
wire [4:0] reg_read_addr_1;
wire [31:0] reg_read_data_1;
wire [4:0] reg_read_addr_2;

wire [31:0] ext_im;
reg [31:0] ALU_Operand_A, ALU_Operand_sub_B;
reg [31:0] ALU_Operand_B;
wire [31:0] ALUResult;
reg [31:0] Result;
wire [31:0] mask_data;

wire [31:0] MEM_Instr;
wire [31:0] Mem_Out_Data;
assign MEM_Instr=mem_read_state?MEM_Instr:Instr;
assign Mem_Out_Data=mem_read_state?Instr:Mem_Out_Data;

non_architectural_register PC_reg (.clk(clk),.rst(rst), .p_data_in(pc_next), .s(NextPC), .Q(PC));
non_architectural_register oldpc_reg(.clk(clk),.rst(rst),.p_data_in(PC),.s(IRWrite),.Q(OLDPC));
//AdrSrc MUX
assign mem_address = (AdrSrc==1'b1) ? Result : PC;


//data_memory_wrapper Instr_Memory(.clk(clk),.core_select(1),.from_core_mem_rd_en(1),.from_core_mem_address(mem_address),.to_core_mem_data_out(MEM_Instr));


//
//non_architectural_register Instr_reg (.clk(clk),.rst(rst), .p_data_in(Instr), .s(IRWrite), .Q(MEM_Instr));

// register file
assign reg_write_dest = MEM_Instr[11:7];

assign reg_read_addr_1 = MEM_Instr[19:15];
assign reg_read_addr_2 = MEM_Instr[24:20];


 // GENERAL PURPOSE REGISTERs
 GPRs reg_file
 (
  .clk(clk),
  .rst(rst),
  .reg_write_en(RegW),
  .reg_write_dest(reg_write_dest),
  .reg_write_data(reg_write_data),
  .reg_read_addr_1(reg_read_addr_1),
  .reg_read_data_1(reg_read_data_1),
  .reg_read_addr_2(reg_read_addr_2),
  .reg_read_data_2(reg_read_data_2)
 );
 
 
non_architectural_register Read_reg_1 (
	.clk(clk),
	.rst(rst), 
	.p_data_in(reg_read_data_1),
	.s(1'b1), 
	.Q(Read_Data_1)
);

non_architectural_register Read_reg_2 (
	.clk(clk),
	.rst(rst), 
	.p_data_in(reg_read_data_2), 
	.s(1'b1), 
	.Q(Read_Data_2)
);
 

// immediate extend
extimm Immediate_Extender(.Instr(MEM_Instr),.immr(ext_im));
 
// ALU control unit
//alu_control alu_control(.clk(clk), .ALU_Control(ALUControlIn),.OPCode(MEM_Instr[6:0]), .Funct(MEM_Instr[14:12]), .bit30(MEM_Instr[30]));

assign bit30 = MEM_Instr[30];


always @(*) begin

	// multiplexer alu_src
	case (AluSrcA)
			
			2'b01: ALU_Operand_A = PC;
			2'b00: ALU_Operand_A=Read_Data_1;
			2'b10: ALU_Operand_A=OLDPC;
		endcase
	
	ALU_Operand_sub_B = (ShiftSrc==1'b1) ? MEM_Instr[24:20] : Read_Data_2;
	
	case(AluSrcB)
		2'b00: ALU_Operand_B = ALU_Operand_sub_B;
		2'b01: ALU_Operand_B = ext_im;
		2'b10: ALU_Operand_B = 32'd4;
	endcase
end

//ALU Operation and Flag
ALU alu_unit(
	.a(ALU_Operand_A),
	.b(ALU_Operand_B),
	.alu_control(ALUControlIn),
	.result(ALUResult),
	.ALUFlag(ALUFlag),
	.rst(rst)
);


non_architectural_register ALU_Result_reg (
	.clk(clk),
	.rst(rst), 
	.p_data_in(ALUResult), 
	.s(1'b1), 
	.Q(ALUOut)
);

//Mask Extend block
mask_extend mask_extend(.A(Mem_Out_Data),.bit_no(MaskEn),.B(mask_data));

non_architectural_register Mem_Read_Data (.clk(clk),.rst(rst), .p_data_in(mask_data), .s(1'b1), .Q(MemData));

always @(*)
begin
	case(ResultSrc)
		2'b00: Result = ALUOut;
		2'b01: Result = MemData;
		2'b10: Result = ALUResult;
		2'b11: Result = ALUOut;
	endcase
end
// write back
assign reg_write_data = (RegWSrc == 1'b1)?  ext_im: Result;

assign pc_next = (PCNextSrc == 1'b1)? Result: Read_Data_2; 

endmodule



