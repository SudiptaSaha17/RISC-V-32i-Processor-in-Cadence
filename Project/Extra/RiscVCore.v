module riscV32i(
input clk,reset_n,
input [31:0] from_imem_to_core_data,
output mem_rd_en,
output [31:0] mem_address,
output [31:0] reg_read_data_2,
output [1:0] from_core_to_imem_data_length,
output from_core_to_dmem_wr_en
//output from_core_to_imem_wr_en

);

	wire [6:0] OPCode;
    wire [2:0] Funct;
    wire [4:0] pSTATE;
    wire bit30;
    wire RegW;
    wire IRWrite;
    
    wire [2:0] ALU_Control;
    wire [1:0] AluSrcB;
    wire[1:0]  MaskEn;
    wire [3:0] ALUFlag;
    wire [1:0] ResultSrc;
    wire [1:0] AluSrcA;


	Datapath_Unit DATAPATH(
		.clk(clk),
        .rst(reset_n),
        .ALUControlIn(ALU_Control),
        .AdrSrc(AdrSrc),
        .IRWrite(IRWrite),
        .NextPC(NextPC),
        .MemW(from_core_to_dmem_wr_en),
        .RegW(RegW),
        .AluSrcA(AluSrcA),
        .PCNextSrc(PCNextSrc),
        .ShiftSrc(ShiftSrc),
        .RegWSrc(RegWSrc),
        .ResultSrc(ResultSrc),
        .AluSrcB(AluSrcB),
        .MaskEn(MaskEn),
        .Instr(from_imem_to_core_data),
        .OPCode(OPCode),
        .Funct(Funct),
        .ALUFlag(ALUFlag),
        .bit30(bit30),
        .mem_address(mem_address),
        .reg_read_data_2(reg_read_data_2),
        .mem_read_state(mem_read_state)
    );

    FSM_ALUControl fsm_DUT(
        .clk(clk),
        .rst(reset_n),
        .bit30(from_imem_to_core_data[30]),
        .OPCode(from_imem_to_core_data[6:0]),
        .Funct(from_imem_to_core_data[14:12]),
        .ALUFlag(ALUFlag),
        .AdrSrc(AdrSrc),
        .IRWrite(IRWrite),
        .NextPC(NextPC),
        .MemW(from_core_to_dmem_wr_en_wire),
        .RegW(RegW),
        .AluSrcA(AluSrcA),
        .PCNextSrc(PCNextSrc),
        .ShiftSrc(ShiftSrc),
        .RegWSrc(RegWSrc),
        .mem_read_state(mem_read_state),
        .ResultSrc(ResultSrc),
        .AluSrcB(AluSrcB),
        .MaskEn(MaskEn),
        .ALU_Control(ALU_Control),
        .mem_rd_en(mem_rd_en),
        .data_length(from_core_to_imem_data_length)
    );
    
    endmodule
    

