//0516305 Bing Xun Song
`timescale 1ns / 1ps
//Subject:     CO project 4 - Pipe Register
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module FLUSH_Pipe_Reg(
    clk_i,
    rst_i,
    data_i,
    ifid_write,
    data_o
    );
					
parameter size = 0;

input   clk_i;		  
input   rst_i,ifid_write;
input   [size-1:0] data_i;
output reg  [size-1:0] data_o;
	  
always@(posedge clk_i) begin
    if(~rst_i)
        data_o <= 0;
    else if(ifid_write)
        data_o <= data_o;
    else
        data_o <= data_i;
end

endmodule	
