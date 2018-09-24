//0516305 Bing Xun Song
`timescale 1ns / 1ps

module branch_mux(
	data0_i,
	data1_i,
	data2_i,
	data3_i,
	select_i,
	data_o
);


input  data0_i,data1_i,data2_i,data3_i;

input [1:0] select_i;

output reg  data_o;

always@(*) begin
	if(select_i == 0)
		data_o = data0_i;
	else if(select_i == 1)
		data_o = data1_i;
	else if(select_i == 2)
		data_o = data2_i;
	else
		data_o = data3_i;
end

endmodule
