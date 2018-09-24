//0516305 Bing Xun Song
//Subject:     CO project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;

//Parameter
wire mult = funct_i[4] & funct_i[3] & !funct_i[2] & !funct_i[1] & !funct_i[0];
       
//Select exact operation
always@(*) begin
	ALUCtrl_o[0] = ((funct_i[0] | funct_i[3]) & ALUOp_i[1]) | ALUOp_i[2] | mult;
	ALUCtrl_o[1] = (!funct_i[2] | !ALUOp_i[1]) | ALUOp_i[2] | mult;
	ALUCtrl_o[2] = (((funct_i[1] & ALUOp_i[1]) | ALUOp_i[0]) | ALUOp_i[2]) & !mult;
	ALUCtrl_o[3] = 0;
end
endmodule     





                    
                    