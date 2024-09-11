module non_architectural_register ( input clk,rst, input [31:0] p_data_in, input s,

output  reg [31:0] Q);

always @(posedge clk,negedge rst)      
    if (~rst) Q=32'b 0000;
  else
	begin
		if(s) Q<=p_data_in;
		else Q <= Q;
	end
endmodule
