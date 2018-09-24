//0516305 Bing Xun Song
`timescale 1ns / 1ps

module forwarding_unit(
		regwrite_wb,
		memwb_rd,
		regwrite_mem,
		exmem_rd,
		idex_rs,
		idex_rt,
		forwarda,
		forwardb
);

input regwrite_wb,regwrite_mem;
input [4:0] memwb_rd,exmem_rd,idex_rs,idex_rt;

output reg [1:0] forwarda,forwardb;

always @(*) begin
	if(regwrite_mem && (exmem_rd != 0) && (exmem_rd == idex_rs))
		forwarda = 2'b10;
	else if(regwrite_wb && (memwb_rd != 0) && !(regwrite_mem && (exmem_rd != 0) && (exmem_rd == idex_rs)) && (memwb_rd == idex_rs))
		forwarda = 2'b01;
	else
		forwarda = 2'b00;

end

always @(*) begin
	if(regwrite_mem && (exmem_rd != 0) && (exmem_rd == idex_rt))
		forwardb = 2'b10;
	else if(regwrite_wb && (memwb_rd != 0) && !(regwrite_mem && (exmem_rd != 0) && (exmem_rd == idex_rt)) && (memwb_rd == idex_rt))
		forwardb = 2'b01;
	else
		forwardb = 2'b00;
end

endmodule
