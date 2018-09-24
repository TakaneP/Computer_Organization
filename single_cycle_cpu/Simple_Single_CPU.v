//0516305 Bing Xun Song
//Subject:     CO project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simple_Single_CPU(
        clk_i,
		rst_i
		);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire [31:0] pc_out_o,adder1sum_o,imout,rsdata_o,rtdata_o,alu_out,sign_extend_out,aluinputB,adder2_sum,shift_left2,pc_source,mem_mux_out,mem_data_o,jump_addr,branch_mux_out;
wire [31:0] jr_mux_o,jal_mux_o;
wire regdst,regwrite,alusrc,branch,zero,mux_pc_select,jump_o,mem_read_o,memto_reg_o,mem_write_o,jr_o,jal_o;
wire [2:0] aluop;
wire [4:0] writereg,jal_reg_in;
wire [3:0] alu_control;
assign mux_pc_select = (branch & zero);
assign jump_addr = {adder1sum_o[31:28],imout[25:0],2'b00};
//Greate componentes
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(pc_source) ,   
	    .pc_out_o(pc_out_o) 
	    );
	
Adder Adder1(
        .src1_i(pc_out_o),     
	    .src2_i(32'd4),     
	    .sum_o(adder1sum_o)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc_out_o),  
	    .instr_o(imout)    
	    );

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(imout[20:16]),
        .data1_i(imout[15:11]),
        .select_i(regdst),
        .data_o(writereg)
        );	
		
Reg_File Registers(
        .clk_i(clk_i),      
	    .rst_i(rst_i) ,     
        .RSaddr_i(imout[25:21]) ,  
        .RTaddr_i(imout[20:16]) ,  
        .RDaddr_i(jal_reg_in) ,  
        .RDdata_i(jal_mux_o)  , 
        .RegWrite_i (regwrite),
        .RSdata_o(rsdata_o) ,  
        .RTdata_o(rtdata_o)
        );
	
Decoder Decoder(
        .instr_op_i(imout[31:26]),
	.instr_jr_i(imout[5:0]), 
	    .RegWrite_o(regwrite), 
	    .ALU_op_o(aluop),   
	    .ALUSrc_o(alusrc),   
	    .RegDst_o(regdst),   
	    .Branch_o(branch),
	    .Jump_o(jump_o),
	    .MemRead_o(mem_read_o),
	    .MemWrite_o(mem_write_o),
	    .MemtoReg_o(memto_reg_o),
	    .jr_o(jr_o),
	    .jal_o(jal_o)     
	    );

ALU_Ctrl AC(
        .funct_i(imout[5:0]),   
        .ALUOp_i(aluop),   
        .ALUCtrl_o(alu_control) 
        );
	
Sign_Extend SE(
        .data_i(imout[15:0]),
        .data_o(sign_extend_out)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(rtdata_o),
        .data1_i(sign_extend_out),
        .select_i(alusrc),
        .data_o(aluinputB)
        );	
		
ALU ALU(
        .src1_i(rsdata_o),
	    .src2_i(aluinputB),
	    .ctrl_i(alu_control),
	    .result_o(alu_out),
		.zero_o(zero)
	    );

Data_Memory Data_Memory(
	.clk_i(clk_i),
	.addr_i(alu_out),
	.data_i(rtdata_o),
	.MemRead_i(mem_read_o),
	.MemWrite_i(mem_write_o),
	.data_o(mem_data_o)
);
MUX_2to1 #(.size(32)) Mux_Memtoreg(
        .data0_i(alu_out),
        .data1_i(mem_data_o),
        .select_i(memto_reg_o),
        .data_o(mem_mux_out)
        );	
//adder for branch		
Adder Adder2(
        .src1_i(adder1sum_o),     
	    .src2_i(shift_left2),     
	    .sum_o(adder2_sum)      
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(sign_extend_out),
        .data_o(shift_left2)
        ); 		
//branch		
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(adder1sum_o),
        .data1_i(adder2_sum),
        .select_i(mux_pc_select),
        .data_o(branch_mux_out)
        );	
//jump
MUX_2to1 #(.size(32)) Mux_Jump(
        .data0_i(branch_mux_out),
        .data1_i(jump_addr),
        .select_i(jump_o),
        .data_o(jr_mux_o)
        );	
//jr
MUX_2to1 #(.size(32)) Mux_Jr(
        .data0_i(jr_mux_o),
        .data1_i(rsdata_o),
        .select_i(jr_o),
        .data_o(pc_source)
        );	
//jal
MUX_2to1 #(.size(32)) Mux_jal(
        .data0_i(mem_mux_out),
        .data1_i(adder1sum_o),
        .select_i(jal_o),
        .data_o(jal_mux_o)
        );
MUX_2to1 #(.size(5)) Mux_jal_IN_RF(
        .data0_i(writereg),
        .data1_i(5'd31),
        .select_i(jal_o),
        .data_o(jal_reg_in)
        );		
endmodule
		  


