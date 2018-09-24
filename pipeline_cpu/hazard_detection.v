//0516305 Bing Xun Song
`timescale 1ns / 1ps

module hazard_detection(
	memread_ex,
	idex_rt,
	ifid_rs,
	ifid_rt,
	branch,
	hazard_flag,
	pc_write,
	ifid_write,
	branch_flag
);

input memread_ex,branch;
input [4:0] idex_rt,ifid_rs,ifid_rt;

output reg hazard_flag,pc_write,ifid_write,branch_flag;


always@(*) begin
	if(memread_ex && ((idex_rt == ifid_rs) || (idex_rt == ifid_rt))) begin
		hazard_flag = 1;
		pc_write = 1;
		ifid_write = 1;
	end
	else begin
		hazard_flag = 0;
		pc_write = 0;
		ifid_write = 0;
	end
end
always@(*) begin
	if(branch)
		branch_flag = 1;
	else
		branch_flag = 0;
end

endmodule

