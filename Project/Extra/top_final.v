module corefinal #(parameter DATA_LENGTH=32,ADDRESS_LENGTH=32) ( clk,rst,run_complete,core_select,addr_in,data_in,instruction_load_start,pselect,pwrite,pready, data_out);

    input clk;
    input rst;
    input core_select;

    //apb signals
    input [31:0] addr_in;
    input [31:0] data_in;
    input pselect;
    input pwrite;
    input pready;

    input instruction_load_start;

    output wire [31:0] data_out;
    output wire run_complete;
    
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
    //wire [31:0] Mem_Out_Data;

	wire 
	from_apb_mem_wr_en_wire,from_apb_mem_rd_en_wire,from_core_to_imem_en_wire,from_core_to_imem_wr_en_wire,from_core_to_imem_rd_en_wire,from_core_to_dmem_en_wire,from_core_to_dmem_wr_en_wire,from_core_to_dmem_rd_en_wire,from_top_to_spi_mosi_in,from_top_to_spi_miso_out,to_inst_mem_en_wire,to_inst_mem_wr_en_wire,to_inst_mem_rd_en_wire,to_data_mem_en_wire,to_data_mem_wr_en_wire,to_data_mem_rd_en_wire,from_spi_mem_en_wire,from_apb_mem_en_wire,from_spi_mem_wr_en_wire,from_spi_mem_rd_en_wire,to_apb_pwrite,to_apb_pready,to_apb_psel;

	wire [DATA_LENGTH-1:0] 
	from_apb_mem_address_wire,from_apb_mem_data_in_wire,from_apb_mem_data_out_wire,from_top_to_apb_out,from_core_to_imem_address_wire,from_core_to_imem_data_in_wire,from_core_to_dmem_address_wire,from_core_to_dmem_data_in_wire,from_imem_to_core_data_wire,from_spi_mem_address_wire,from_spi_mem_data_in_wire,from_spi_mem_data_out_wire,from_dmem_to_core_data_wire,to_data_mem_address_wire,to_data_mem_data_in_wire,to_inst_mem_address_wire,to_inst_mem_data_in_wire,from_top_to_apb_addr_in,from_top_to_apb_data_in;

	wire [1:0] from_apb_mem_data_length_wire,from_spi_mem_data_length_wire,from_core_to_dmem_data_length_wire,from_core_to_imem_data_length_wire,to_inst_mem_data_length_wire,to_data_mem_data_length_wire;
	wire [31:0] mem_address;
	wire [31:0] reg_read_data_2;
	wire mem_read_state;
	assign from_top_to_apb_addr_in = addr_in;
	assign from_top_to_apb_data_in = data_in;
	assign data_out = from_top_to_apb_out;

	assign to_apb_pready = pready;
	assign to_apb_pwrite = pwrite;
	assign to_apb_psel = pselect;


	assign to_inst_mem_en_wire = (instruction_load_start) ? from_apb_mem_en_wire : 1'b0;
	assign to_inst_mem_wr_en_wire = (instruction_load_start) ? from_apb_mem_wr_en_wire : 1'b0;
	assign to_inst_mem_rd_en_wire = (instruction_load_start) ? from_apb_mem_rd_en_wire : 1'b0;
	assign to_inst_mem_address_wire = (instruction_load_start) ? from_apb_mem_address_wire : {{DATA_LENGTH-1}{1'b0}};
	assign to_inst_mem_data_in_wire = (instruction_load_start) ? from_apb_mem_data_in_wire : {{DATA_LENGTH-1}{1'b0}};
	assign to_inst_mem_data_length_wire = (instruction_load_start) ? from_apb_mem_data_length_wire : 2'b0;  

	wire mem_rd_en;
	instruction_memory_wrapper #(DATA_LENGTH,ADDRESS_LENGTH) imem_wrapper (
		.clk(clk),
		.core_select(core_select),

		.from_core_mem_en(1'b1),
		.from_core_mem_wr_en(from_core_to_dmem_wr_en_wire),
		.from_core_mem_rd_en(mem_rd_en),
		.from_core_mem_address(mem_address),
		.from_core_mem_data_in(reg_read_data_2),
		.from_core_mem_data_length(from_core_to_imem_data_length_wire),

		.from_apb_mem_en(to_inst_mem_en_wire),
		.from_apb_mem_wr_en(to_inst_mem_wr_en_wire),
		.from_apb_mem_rd_en(to_inst_mem_rd_en_wire),
		.from_apb_mem_address(to_inst_mem_address_wire),
		.from_apb_mem_data_in(to_inst_mem_data_in_wire),
		.from_apb_mem_data_length(to_inst_mem_data_length_wire),

		.to_core_mem_data_out(from_imem_to_core_data_wire),
		.to_apb_mem_data_out(from_spi_mem_data_out_wire)
	);


	apb_slave #(DATA_LENGTH,ADDRESS_LENGTH) apb_mem(
		.from_top_clk(clk),
		.preset_n(rst),
		.pwrite(to_apb_pwrite),
		.psel(to_apb_psel),
		.pready(to_apb_pready),

		.from_top_apb_paddr(from_top_to_apb_addr_in),
		.from_top_apb_pwdata(from_top_to_apb_data_in),
		
		.prdata(from_top_to_apb_out),

		.to_mem_en(from_apb_mem_en_wire),
		.to_mem_wr_en(from_apb_mem_wr_en_wire),
		.to_mem_rd_en(from_apb_mem_rd_en_wire),
		.to_mem_address(from_apb_mem_address_wire),
		.to_mem_data_in(from_apb_mem_data_in_wire),
		.to_mem_data_length(from_apb_mem_data_length_wire),

		.from_mem_data_out(from_apb_mem_data_out_wire)

	);

    
riscV32i RISCV32i(
.clk(clk),
.reset_n(rst),
.from_imem_to_core_data(from_imem_to_core_data_wire),
.mem_rd_en(mem_rd_en),
.reg_read_data_2(reg_read_data_2),
.from_core_to_imem_data_length(from_core_to_imem_data_length_wire),
.from_core_to_dmem_wr_en(from_core_to_dmem_wr_en_wire),
.mem_address(mem_address),
.from_core_to_imem_wr_en(from_core_to_imem_wr_en_wire)
);

endmodule
