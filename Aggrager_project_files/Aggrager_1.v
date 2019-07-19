//*********************************************************************************************************************
//
// Copyright(C) 2019 ParaQum Technologies Pvt Ltd.
// All rights reserved.
//
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF
// PARAQUM TECHNOLOGIES PVT LIMITED.
//
// This copy of the Source Code is intended for ParaQum's internal use only and is
// intended for view by persons duly authorized by the management of ParaQum. No
// part of this file may be reproduced or distributed in any form or by any
// means without the written approval of the Management of ParaQum.
//
// Paraqum Technologies (Pvt) Ltd.,
// 106, 1st Floor, Bernards' Business Park,
// Dutugemunu Street,
// Kohuwala, Sri Lanka. 10350
//
// ********************************************************************************************************************
//
// PROJECT      :   
// PRODUCT      :   
// FILE         :   
// AUTHOR       :  SAUMYA HERATH 
// DESCRIPTION  :   
//
// ********************************************************************************************************************
//
// REVISIONS:
//
//  Date        Developer           Description
//  ----        ---------           -----------
// 
//  
//  
//  
//  
// ********************************************************************************************************************
`timescale 1ns / 1ps

module Aggregator #(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
	parameter 		DATA_WIDTH		=	12'h0FF,
	parameter 		LENGTH_WIDTH	=	8'h1F
)(	
	clk,
	reset,
	start,
	DATA_IN1,
	DATA_IN2,
	ready,
	ready_1,
	ready_2,
	DATA_OUT,
	valid

);

//---------------------------------------------------------------------------------------------------------------------
// IO signals
//---------------------------------------------------------------------------------------------------------------------


	input								clk			;
	input								reset 		;
	input								start 		;
	input			[DATA_WIDTH-1:0]	DATA_IN1	;
	input			[DATA_WIDTH-1:0]	DATA_IN2	;
	input 								ready 		;
	output	reg							ready_1 	;
	output	reg							ready_2 	;
	output	reg		[DATA_WIDTH:0]		DATA_OUT 	;
	output 	reg							valid		;


//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------
    //none
//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------

	localparam CHECK_START			=	4'h0;	
	localparam READY1				=	4'h1;
	localparam READY2				=	4'h2;
	localparam GET_DATA1			=	4'h3;
	localparam GET_DATA2			=	4'h4;
	localparam CHECK_LENGTH			=	4'h5;
	localparam CHECK_ROW			=	4'h6;
	localparam OUTPUT				=	4'h7;
	localparam NEXT_DATA			=	4'h8;
	localparam WAIT					=	4'h9;

	localparam ENGINE1				=	1'b0;
	localparam ENGINE2				=	1'b1;


//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------

	reg 			[DATA_WIDTH:0] 		DATA 		;
	reg 			[3:0]				state 		;
	reg 			[3:0]				next_state	;
	reg 								next_engine	;
	reg             [LENGTH_WIDTH:0]	count       ;
	reg                                 count_done  ;
	reg 			[LENGTH_WIDTH:0]	LENGTH 		;
	reg 			[LENGTH_WIDTH:0]	ROW 		;
	reg 			[LENGTH_WIDTH:0]	ROW_NUM		;		



	always@(posedge clk) begin
	        if(reset) begin
	            state   	<= CHECK_START;
	        end else begin
	            state   	<= next_state;
	        end
    end

	always @(*) begin
	  	next_state=state;  
		    case(state)

		    	CHECK_START		:	begin
			    						if (start) begin
			    							next_state=READY1;
			    						end else begin
			    							next_state=CHECK_START;
			    						end
			    					end


			   	READY1			:	next_state	=	GET_DATA1;
				   						
				READY2   		:	next_state	=	GET_DATA2;
				   				

			   	GET_DATA1		:	next_state	=	CHECK_LENGTH;

			   	GET_DATA2		:	next_state	=	OUTPUT;

			   	CHECK_LENGTH	:	next_state	=	CHECK_ROW;

			   	CHECK_ROW		:	next_state	=	OUTPUT;

			   	OUTPUT 			:	begin
			   							if (ready) begin
			   								next_state	=	NEXT_DATA;
			   							end else begin
			   								next_state	=	OUTPUT;
			   							end
			   						end

			   	NEXT_DATA		:	begin
			   							if (LENGTH>8) begin
			   								next_state	=	WAIT;
			   							end else begin
			   								next_state	=	READY1;
			   							end
			   						end

			   	WAIT			:   begin
				   						if (count_done) begin
				   							next_state	=	READY1;
				   						end else begin
				   							next_state	=	READY2;
				   						end
				   					end
			   						


		    endcase // state
	end


	always@(posedge clk) begin
	    if(reset) begin
	        next_engine	<= 1'b0;
	    end else begin
	        case(state)

		    	READY1,READY2	:	begin
			   							case(next_engine)
			   								ENGINE1	:	begin
			   												ready_1<=1'b1;
			   											end
			   								ENGINE2 :	begin 
			   												ready_2<=1'b1;
			   											end	
			   							endcase
			   						end

		    	GET_DATA1,GET_DATA1	:begin
			   							case(next_engine)
			   								ENGINE1	:	begin
			   												DATA<=DATA_IN1;
			   												valid<=1'b1;
			   											end
			   								ENGINE2 :	begin 
			   												DATA<=DATA_IN2;
			   												valid<=1'b1;
			   											end	
			   							endcase
			   						end
			   	CHECK_LENGTH	:	begin
                                        LENGTH 	<=	DATA[LENGTH_WIDTH:0];
                                        ROW 	<=	(LENGTH >> 3);
			   						end

			   	CHECK_ROW		:	ROW_NUM	<=	ROW +1'b1;

			   	OUTPUT 			:	begin
			   							if (ready) begin
			   								DATA_OUT<=	DATA;
			   							end 
			   						end

			   	NEXT_DATA		:	begin
			   							if (LENGTH<=8) begin
			   								next_engine	<= ~next_engine;
			   							end
			   						end

			   	WAIT			:	begin
				   						if (count_done) begin
				   							next_engine	<= ~next_engine;
				   						end
				   					end

		    endcase // state
	    end
    end


	always @(posedge clk) begin
	    if(reset) begin
	       count     <= 'b1;
	    end else begin 
	        case(state) 
		        NEXT_DATA: 	begin
		        				if (LENGTH>8) begin   
					               if(count_done) begin
					                   count <= 'b1;
					               end else begin
					                   count <= count + 1'b1;
					               end
				            	end
				            end
	        endcase
	    end
	end
   
    always @(*) begin
        count_done = 1'b0;
        case(state) 
        NEXT_DATA	:count_done = (count == ROW_NUM);
        READY1 		:count_done = (count == ROW_NUM);
        
       
      
       endcase
    end 


endmodule // Aggregator
