//0516305 Bing Xun Song
//Subject:     CO project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Luke
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	//instr_jr_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	//Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o,
	Branch_type
	//jr_o,
	//jal_o
	);
     
//I/O ports
input  [6-1:0] instr_op_i;
wire [5:0] instr_jr_i = 0;
output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
output         RegDst_o;
output         Branch_o;
//output	       Jump_o;
output	       MemRead_o;
output         MemWrite_o;
output	       MemtoReg_o;
output [1:0]   Branch_type;
//output	       jr_o;
//output	       jal_o;
//Internal Signals
reg    [3-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg            RegDst_o;
reg            Branch_o;
reg	       Jump_o;
reg	       MemRead_o;
reg            MemWrite_o;
reg	       MemtoReg_o;
reg	       jr_o;
reg	       jal_o;
reg  [1:0] Branch_type;
wire  rtype,beq,addi,slti,lw,sw,jump,jal,bge,bgt,bne;
//Parameter


//Main function
assign rtype = !instr_op_i[5] & !instr_op_i[4] &!instr_op_i[3] &!instr_op_i[2] &!instr_op_i[1] &!instr_op_i[0];
assign beq = !instr_op_i[5] & !instr_op_i[4] &!instr_op_i[3] &instr_op_i[2] &!instr_op_i[1] &!instr_op_i[0];
assign addi = !instr_op_i[5] & !instr_op_i[4] &instr_op_i[3] &!instr_op_i[2] &!instr_op_i[1] &!instr_op_i[0];
assign slti = !instr_op_i[5] & !instr_op_i[4] &instr_op_i[3] &!instr_op_i[2] &instr_op_i[1] &!instr_op_i[0];
assign lw = instr_op_i[5] & !instr_op_i[4] &!instr_op_i[3] &!instr_op_i[2] & instr_op_i[1] & instr_op_i[0];
assign sw = instr_op_i[5] & !instr_op_i[4] & instr_op_i[3] &!instr_op_i[2] & instr_op_i[1] & instr_op_i[0];
assign bgt = !instr_op_i[5] & !instr_op_i[4] &!instr_op_i[3] &instr_op_i[2] &instr_op_i[1] &instr_op_i[0];
assign bge = !instr_op_i[5] & !instr_op_i[4] &!instr_op_i[3] &!instr_op_i[2] &!instr_op_i[1] &instr_op_i[0];
assign bne = !instr_op_i[5] & !instr_op_i[4] &!instr_op_i[3] &instr_op_i[2] &!instr_op_i[1] &instr_op_i[0];
assign jump = 0;/*!instr_op_i[5] & !instr_op_i[4] &!instr_op_i[3] &!instr_op_i[2] & instr_op_i[1] &!instr_op_i[0];*/
assign jal = 0;/*!instr_op_i[5] & !instr_op_i[4] &!instr_op_i[3] &!instr_op_i[2] & instr_op_i[1] & instr_op_i[0];*/

always@(*) begin
	RegDst_o = rtype;
end

always@(*) begin
	ALUSrc_o = addi | slti | lw | sw;
end

always@(*) begin
	RegWrite_o = rtype | addi | slti | lw | jal;
end

always@(*) begin
	Branch_o = beq | bge | bne | bgt;
end

always@(*) begin
	Jump_o = jump | jal;
end

always@(*) begin
	MemRead_o = lw;
end

always@(*) begin
	MemWrite_o = sw;
end

always@(*) begin
	MemtoReg_o = lw;
end

always@(*) begin
	jr_o = rtype && (instr_jr_i == 6'b001000);
end
always@(*) begin
	jal_o = jal;
end

always@(*) begin
	ALU_op_o[2] = slti;
	ALU_op_o[1] = rtype;
	ALU_op_o[0] = beq | bge | bne | bgt;
end

always@(*) begin
	if(beq)
		Branch_type = 2'b00;
	else if(bgt)
		Branch_type = 2'b01;
	else if(bge)
		Branch_type = 2'b10;
	else
		Branch_type = 2'b11;
end
endmodule





                    
                    