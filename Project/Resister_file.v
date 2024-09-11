//`timescale 1ns / 1ps
// fpga4student.com 
// FPGA projects, VHDL projects, Verilog projects 
// Verilog code for RISC Processor 
// Verilog code for register file
module GPRs(
 input    clk,
 // write port
 input    reg_write_en,
 input  [4:0] reg_write_dest,
 input  [31:0] reg_write_data,
 //read port 1
 input rst,
 input  [4:0] reg_read_addr_1,
 output  [31:0] reg_read_data_1,
 //read port 2
 input  [4:0] reg_read_addr_2,
 output  [31:0] reg_read_data_2
);
reg [31:0] reg_array [31:0];

always @(posedge rst)
    begin
    reg_array[0] <= 32'b0;
    reg_array[1] <= 32'b0;
    reg_array[2] <= 32'b0;
    reg_array[3] <= 32'b0;
    reg_array[4] <= 32'b0;
    reg_array[5] <= 32'b0;
    reg_array[6] <= 32'b0;
    reg_array[7] <= 32'b0;
    reg_array[8] <= 32'b0;
    reg_array[9] <= 32'b0;
    reg_array[10] <= 32'b0;
    reg_array[11] <= 32'b0;
    reg_array[12] <= 32'b0;
    reg_array[13] <= 32'b0;
    reg_array[14] <= 32'b0;
    reg_array[15] <= 32'b0;
    reg_array[16] <= 32'b0;
    reg_array[17] <= 32'b0;
    reg_array[18] <= 32'b0;
    reg_array[19] <= 32'b0;
    reg_array[20] <= 32'b0;
    reg_array[21] <= 32'b0;
    reg_array[22] <= 32'b0;
    reg_array[23] <= 32'b0;
    reg_array[24] <= 32'b0;
    reg_array[25] <= 32'b0;
    reg_array[26] <= 32'b0;
    reg_array[27] <= 32'b0;
    reg_array[28] <= 32'b0;
    reg_array[29] <= 32'b0;
    reg_array[30] <= 32'b0;
    reg_array[31] <= 32'b0;
    end

//integer i;
 // write port
 //reg [2:0] i;

 //for(i=0;i<32;i=i+1)
 // begin
 //  reg_array[i] <= 32'd0;
 //end

always @ (posedge clk) 
begin
   if(reg_write_en ) begin
    reg_array[reg_write_dest] <= reg_write_dest?reg_write_data:32'b0;
   end
end
 

assign reg_read_data_1 = reg_array[reg_read_addr_1];
assign reg_read_data_2 = reg_array[reg_read_addr_2];


endmodule
