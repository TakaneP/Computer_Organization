//0516305 Bing Xun Song
`timescale 1ns / 1ps

module MUX_3to1(
	data0_i,
	data1_i,
	data2_i,
	select_i,
	data_o
);

parameter size = 0;	

input [size-1:0] data0_i,data1_i,data2_i;

input [1:0] select_i;

output reg [size-1:0] data_o;

always @(*) begin
	if(select_i == 0)
		data_o = data0_i;
	else if(select_i == 1)
		data_o = data1_i;
	else
		data_o = data2_i;
end

endmodule
