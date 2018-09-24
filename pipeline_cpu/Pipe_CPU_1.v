//0516305 Bing Xun Song
`timescale 1ns / 1ps
//Subject:     CO project 4 - Pipe CPU 1
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
    clk_i,
    rst_i
    );
    
/****************************************
I/O ports
****************************************/
input clk_i;
input rst_i;

/****************************************
Internal signal
****************************************/
/**** IF stage ****/
wire [31:0] pc_out,mux0_o,pc_plus4_o_if,imout_if;
wire [63:0] databus_ifid_i;

/**** ID stage ****/
wire [63:0] databus_ifid_o;
wire [63:0] databus_ifid_o_f;
wire [31:0] pc_plus4_o_id,imout_id,rsdata_o_id,rtdata_o_id,sign_extend_id;
wire [154:0] databus_idex_i;
wire hazard_flag,pc_write,ifid_write,branch_flag;
//control signal
wire regwrite_id_o,memtoreg_id_o; //to wb
wire alusrc_id_o,regdst_id_o; //to ex
wire [2:0] aluop_id_o; //to ex
wire branch_id_o,memwrite_id_o,memread_id_o; //to mem
wire [1:0] branch_type;//to mem

wire regwrite_id,memtoreg_id; //to wb
wire alusrc_id,regdst_id; //to ex
wire [2:0] aluop_id; //to ex
wire branch_id,memwrite_id,memread_id; //to mem
/**** EX stage ****/
wire [154:0] databus_idex_o;
wire [31:0] branch_addr_ex,rsdata_o_ex,rtdata_o_ex,sign_extend_ex,pc_plus4_o_ex,sll2out,mux1_o,alu_out_ex,alusrc1_i,alusrc2_i;
wire [4:0] idex_rt,idex_rd,mux2_o_ex,idex_rs;
wire [3:0] alu_control;
wire zero_ex;
wire [108:0] databus_exmem_i;
wire [1:0] forwarda,forwardb;
//control signal
wire regwrite_ex,memtoreg_ex; //to wb
wire alusrc_ex,regdst_ex; //to ex
wire [2:0] aluop_ex; //to ex
wire branch_ex,memwrite_ex,memread_ex; //to mem
wire [1:0] branch_type_ex; //to mem

wire regwrite_ex_o,memtoreg_ex_o; //to wb
wire branch_ex_o,memwrite_ex_o,memread_ex_o; //to mem
wire [1:0] branch_type_ex_o; //to mem

/**** MEM stage ****/
wire [108:0] databus_exmem_o;
wire [31:0] branch_addr_mem,alu_out_mem,rtdata_o_mem,mem_data_mem;
wire signed [31:0] signed_alu_out_mem;
wire [4:0] exmem_rd;
wire zero_mem,greater;
wire [70:0] databus_memwb_i;
wire branch_type_mux_o;
//control signal
wire pcsrc;
wire regwrite_mem,memtoreg_mem; //to wb
wire branch_mem,memwrite_mem,memread_mem; //to mem
wire [1:0] branch_type_mem;
/**** WB stage ****/
wire [4:0] memwb_rd;
wire [31:0] mux3_out,mem_data_wb,alu_out_wb;
wire [70:0] databus_memwb_o;
//control signal
wire regwrite_wb,memtoreg_wb; //to wb

/****************************************
Instantiate modules
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux0(
	.data0_i(pc_plus4_o_if),
	.data1_i(branch_addr_mem),
	.select_i(pcsrc),
	.data_o(mux0_o)
);

ProgramCounter PC(
	.clk_i(clk_i),      
	.rst_i (rst_i),     
	.pc_in_i(mux0_o),
	.pc_write(pc_write),
	.pc_out_o(pc_out) 
);

Instruction_Memory IM(
	.addr_i(pc_out),  
	.instr_o(imout_if) 
);
			
Adder Add_pc(
	.src1_i(pc_out),     
	.src2_i(32'd4),     
	.sum_o(pc_plus4_o_if)
);

		
FLUSH_Pipe_Reg #(.size(64)) IF_ID(       //N is the total length of input/output
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i(databus_ifid_i),
	.ifid_write(ifid_write),
	.data_o(databus_ifid_o)
);

assign databus_ifid_o_f = (branch_flag)? 64'd0:databus_ifid_o;
//Instantiate the components in ID stage
hazard_detection hazard_detection(
	.memread_ex(memread_ex),
	.idex_rt(idex_rt),
	.ifid_rs(imout_id[25:21]),
	.ifid_rt(imout_id[20:16]),
	.branch(pcsrc),
	.hazard_flag(hazard_flag),
	.pc_write(pc_write),
	.ifid_write(ifid_write),
	.branch_flag(branch_flag)
);
Reg_File RF(
	.clk_i(clk_i),      
	.rst_i(rst_i) ,     
	.RSaddr_i(imout_id[25:21]) ,  
	.RTaddr_i(imout_id[20:16]) ,  
	.RDaddr_i(memwb_rd) ,  
	.RDdata_i(mux3_out)  , 
	.RegWrite_i (regwrite_wb),
	.RSdata_o(rsdata_o_id) ,  
	.RTdata_o(rtdata_o_id)

);

Decoder Control(
	.instr_op_i(imout_id[31:26]),
	.RegWrite_o(regwrite_id_o), 
	.ALU_op_o(aluop_id_o),   
	.ALUSrc_o(alusrc_id_o),   
	.RegDst_o(regdst_id_o),   
	.Branch_o(branch_id_o),
	.MemRead_o(memread_id_o),
	.MemWrite_o(memwrite_id_o),
	.MemtoReg_o(memtoreg_id_o),
	.Branch_type(branch_type)
);
assign regwrite_id = (hazard_flag | branch_flag)? 0:regwrite_id_o;
assign aluop_id = (hazard_flag | branch_flag)? 0:aluop_id_o;
assign alusrc_id = (hazard_flag | branch_flag)? 0:alusrc_id_o;
assign regdst_id = (hazard_flag | branch_flag)? 0:regdst_id_o;
assign branch_id = (hazard_flag | branch_flag)? 0:branch_id_o;
assign memread_id = (hazard_flag | branch_flag)? 0:memread_id_o;
assign memwrite_id = (hazard_flag | branch_flag)? 0:memwrite_id_o;
assign memtoreg_id = (hazard_flag | branch_flag)? 0:memtoreg_id_o;
Sign_Extend Sign_Extend(
 	.data_i(imout_id[15:0]),
	.data_o(sign_extend_id)
);	

Pipe_Reg #(.size(155)) ID_EX(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i(databus_idex_i),
	.data_o(databus_idex_o)
);

//Instantiate the components in EX stage	   
Shift_Left_Two_32 Shifter(
	.data_i(sign_extend_ex),
	.data_o(sll2out)
);
//forwarda 3to1mux
MUX_3to1 #(.size(32)) forward_mux1(
	.data0_i(rsdata_o_ex),
	.data1_i(mux3_out),
	.data2_i(alu_out_mem),
	.select_i(forwarda),
	.data_o(alusrc1_i)
);

ALU ALU(
	.src1_i(alusrc1_i),
	.src2_i(mux1_o),
	.ctrl_i(alu_control),
	.result_o(alu_out_ex),
	.zero_o(zero_ex)
);
		
ALU_Ctrl ALU_Control(
	.funct_i(sign_extend_ex[5:0]),   
	.ALUOp_i(aluop_ex),   
	.ALUCtrl_o(alu_control) 
);
//forwardb 3to1mux
MUX_3to1 #(.size(32)) forward_mux2(
	.data0_i(rtdata_o_ex),
	.data1_i(mux3_out),
	.data2_i(alu_out_mem),
	.select_i(forwardb),
	.data_o(alusrc2_i)
);

MUX_2to1 #(.size(32)) Mux1(
	.data0_i(alusrc2_i),
	.data1_i(sign_extend_ex),
	.select_i(alusrc_ex),
	.data_o(mux1_o)
);
		
MUX_2to1 #(.size(5)) Mux2(
	.data0_i(idex_rt),
	.data1_i(idex_rd),
	.select_i(regdst_ex),
	.data_o(mux2_o_ex)
);

Adder Add_pc_branch(
	.src1_i(pc_plus4_o_ex),     
	.src2_i(sll2out),     
	.sum_o(branch_addr_ex)
);

Pipe_Reg #(.size(109)) EX_MEM(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i(databus_exmem_i),
	.data_o(databus_exmem_o)
);

forwarding_unit forwarding_unit(
	.regwrite_wb(regwrite_wb),
	.memwb_rd(memwb_rd),
	.regwrite_mem(regwrite_mem),
	.exmem_rd(exmem_rd),
	.idex_rs(idex_rs),
	.idex_rt(idex_rt),
	.forwarda(forwarda),
	.forwardb(forwardb)
);

assign regwrite_ex_o = (branch_flag)? 0:regwrite_ex;
assign memtoreg_ex_o = (branch_flag)? 0:memtoreg_ex;
assign branch_ex_o = (branch_flag)? 0:branch_ex;
assign memwrite_ex_o = (branch_flag)? 0:memwrite_ex;
assign memread_ex_o = (branch_flag)? 0:memread_ex;
assign branch_type_ex_o = (branch_flag)? 0:branch_type_ex;
//Instantiate the components in MEM stage
branch_mux branch_mux(
	.data0_i(zero_mem),
	.data1_i(greater),
	.data2_i(zero_mem | greater),
	.data3_i(!zero_mem),
	.select_i(branch_type_mem),
	.data_o(branch_type_mux_o)
);

Data_Memory DM(
	.clk_i(clk_i),
	.addr_i(alu_out_mem),
	.data_i(rtdata_o_mem),
	.MemRead_i(memread_mem),
	.MemWrite_i(memwrite_mem),
	.data_o(mem_data_mem)
);

Pipe_Reg #(.size(71)) MEM_WB(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i(databus_memwb_i),
	.data_o(databus_memwb_o)
);


//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux3(
	.data0_i(mem_data_wb),
	.data1_i(alu_out_wb),
	.select_i(!memtoreg_wb),
	.data_o(mux3_out)
);

/****************************************
signal assignment
****************************************/
//if/id
assign databus_ifid_i = {pc_plus4_o_if,imout_if};
assign pc_plus4_o_id = databus_ifid_o_f[63:32];
assign imout_id = databus_ifid_o_f[31:0];

//id/ex
assign databus_idex_i = {branch_type,imout_id[25:21],regwrite_id,memtoreg_id,alusrc_id,regdst_id,aluop_id,
                         branch_id,memwrite_id,memread_id,pc_plus4_o_id,rsdata_o_id,
                         rtdata_o_id,sign_extend_id,imout_id[20:16],imout_id[15:11]};
assign regwrite_ex = databus_idex_o[147];
assign memtoreg_ex = databus_idex_o[146];
assign alusrc_ex = databus_idex_o[145];
assign regdst_ex = databus_idex_o[144];
assign aluop_ex = databus_idex_o[143:141];
assign branch_ex = databus_idex_o[140];
assign memwrite_ex = databus_idex_o[139];
assign memread_ex = databus_idex_o[138];
assign pc_plus4_o_ex = databus_idex_o[137:106];
assign rsdata_o_ex = databus_idex_o[105:74];
assign rtdata_o_ex = databus_idex_o[73:42];
assign sign_extend_ex = databus_idex_o[41:10];
assign idex_rt = databus_idex_o[9:5];
assign idex_rd = databus_idex_o[4:0];
assign idex_rs = databus_idex_o[152:148];
assign branch_type_ex = databus_idex_o[154:153];
//ex/mem
assign signed_alu_out_mem = alu_out_mem;
assign greater = (signed_alu_out_mem > 0)? 1:0;
assign databus_exmem_i = {branch_type_ex_o,regwrite_ex_o,memtoreg_ex_o,branch_ex_o,memwrite_ex_o,memread_ex_o,
			  zero_ex,branch_addr_ex,alu_out_ex,alusrc2_i,mux2_o_ex};
assign regwrite_mem = databus_exmem_o[106];
assign memtoreg_mem = databus_exmem_o[105];
assign branch_mem = databus_exmem_o[104];
assign memwrite_mem = databus_exmem_o[103];
assign memread_mem = databus_exmem_o[102];
assign zero_mem = databus_exmem_o[101];
assign branch_addr_mem = databus_exmem_o[100:69];
assign alu_out_mem = databus_exmem_o[68:37];
assign rtdata_o_mem = databus_exmem_o[36:5];
assign exmem_rd = databus_exmem_o[4:0];
assign branch_type_mem = databus_exmem_o[108:107];
//mem/wb
assign pcsrc = branch_type_mux_o & branch_mem;
assign databus_memwb_i = {regwrite_mem,memtoreg_mem,mem_data_mem,alu_out_mem,exmem_rd};
assign regwrite_wb = databus_memwb_o[70];
assign memtoreg_wb = databus_memwb_o[69];
assign mem_data_wb = databus_memwb_o[68:37];
assign alu_out_wb = databus_memwb_o[36:5];
assign memwb_rd = databus_memwb_o[4:0];
endmodule

