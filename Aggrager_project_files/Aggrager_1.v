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
	parameter 		DATA_WIDTH		=	255, //255
	parameter 		LENGTH_WIDTH	=	31    //31
)(	
	clk,
	reset,
	start,
	DATA_IN1,
	DATA_IN2,
	valid_1,
	valid_2,
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
	input			[DATA_WIDTH:0]		DATA_IN1	;
	input			[DATA_WIDTH:0]		DATA_IN2	;
	input                               valid_1     ;
	input                               valid_2     ;
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
	localparam READY				=	4'h1;
	localparam GET_DATA				=	4'h2;
	localparam LENGTH_BEGIN			=	4'h3;
	localparam GET_LENGTH			=	4'h4;
	localparam COMBINE				=	4'h5;
	localparam CHECK_LENGTH1		=	4'h6;
	localparam CHECK_LENGTH2		=	4'h7;
	localparam CHECK_LENGTH3		=	4'h8;
	localparam BLOCK_UPDATE			=	4'h9;
	localparam BUFFER				=	4'hA;
	localparam OUTPUT				=	4'hB;
	localparam NEW_LENGTH			=	4'hC;
	localparam NEXT_DATA			=	4'hD;
	localparam COUNT       			=	4'hE;
	localparam READY_LOW       		=	4'hF;
	

	localparam ENGINE1				=	1'b0;
	localparam ENGINE2				=	1'b1;

	localparam stage1				=	2'b00;
	localparam stage2				=	2'b01;
	localparam stage3				=	2'b10;
	localparam stage4				=	2'b11;


//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------

	reg 			[DATA_WIDTH:0] 		data 		;
	reg 			[DATA_WIDTH:0] 		data_buffer ;
	reg 			[3:0]				state 		;
	reg 			[3:0]				next_state	;
	reg 								next_engine	;
	reg             [LENGTH_WIDTH:0]	count       ;
	reg                                 count_done  ;
	reg							        flag_1 	    ;
    reg                                 flag_2      ;
	reg 			[LENGTH_WIDTH:0]	length 		;
	reg 			[LENGTH_WIDTH:0]	past_len	;
	reg 			[1:0]				stage		;
	reg 			[LENGTH_WIDTH:0]	block_num	;	
	reg 			[LENGTH_WIDTH:0]	block 		;		



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
			    							next_state=READY;
			    						end else begin
			    							next_state=CHECK_START;
			    						end
			    					end
			    READY 			:	next_state	=	READY_LOW;
			    
			    READY_LOW       :   next_state	=	COUNT;

			    COUNT 			:   begin
			    						if (count_done) begin
			    							next_state	=	GET_DATA;
			    						end else begin
			    							next_state	=	COUNT;
			    						end
			    					end


			    GET_DATA 		:	begin
                                         if (((flag_1)&& (valid_1))||((flag_2)&& (valid_2))) begin
                                            case(stage)
                                            stage1	:	next_state	=	LENGTH_BEGIN;
                                            stage2	:	next_state	=	OUTPUT;
                                            stage3	:	next_state	=	CHECK_LENGTH2;
                                            stage4	:	next_state	=	COMBINE;
                                            endcase
                                         end else begin
                                            next_state	=	GET_DATA;	
                                         end
			    						
			    					end
                

			    

			    LENGTH_BEGIN	:	next_state	=	CHECK_LENGTH1;

			    COMBINE			:	next_state	=	GET_LENGTH;

			    GET_LENGTH		:	next_state	=	CHECK_LENGTH3;

			   		   	
			   
			   	CHECK_LENGTH1	:	begin
			   							if (length>=32) begin
			   								next_state	=	OUTPUT;
			   							end else begin
			   								next_state	= 	BLOCK_UPDATE;
			   								
			   							end
			   						end


		   		CHECK_LENGTH2	:	begin
		   								next_state	= 	BLOCK_UPDATE;
		   							
		   							end

		   					   	
			   	CHECK_LENGTH3	:	begin
			   							if (length>=32-(block<<2)) begin
			   								next_state	=	OUTPUT;
			   							end else begin
			   								next_state	= 	BLOCK_UPDATE;

			   							end
			   						end
			   	BLOCK_UPDATE	:	next_state	= 	BUFFER;

			   	BUFFER			:	next_state = READY;

			   	OUTPUT 			:	begin
			   							if (ready) begin
			   								next_state	=	NEW_LENGTH;
			   							end else begin
			   								next_state	=	OUTPUT;
			   							end
			   						end

			   	NEW_LENGTH		:	next_state	=	NEXT_DATA;

			   	NEXT_DATA		:	begin
			   							
			   							next_state	=	READY;
			   						end

			   	
			   						


		    endcase // state
	end


	always@(posedge clk) begin
	    if(reset) begin
	        next_engine	<= 1'b0;
	        data_buffer	<=	0;
	        block_num <= 0;
	        past_len  <= 0;
	        stage <= stage1;
	        block <= 0;
	        ready_1 <=0;
	        ready_2 <= 0;
	        data <=0;
	        
	        
	    end else begin
	        case(state)
	        	

	        	

		    	READY			:	begin											//SENDING THE READY SIGNALS
			   							case(next_engine)
			   								ENGINE1	:	begin
			   												ready_1<=1'b1;
			   												flag_1 <=1'b1;
			   											end
			   								ENGINE2 :	begin 
			   												ready_2<=1'b1;
			   												flag_2 <=1'b1;
			   											end	
			   							endcase
			   						end
			   	
			   	READY_LOW       :    begin   
                                         ready_1 <=0;
                                         ready_2 <=0;
			   	                     end
		    	GET_DATA 		:	begin											//
			   							case(next_engine)
			   								ENGINE1	:	begin
			   								              if ((flag_1) && (valid_1)) begin
			   												data<=DATA_IN1;
			   											  end 
			   											    
			   												
			   											end
			   								ENGINE2 :	begin 
			   											  if ((flag_2) && (valid_2)) begin
                                                                data<=DATA_IN2;
                                                          end
			   												
			   											end	
			   							endcase
			   						end
			   	LENGTH_BEGIN	: 	begin
                                        length <= data[LENGTH_WIDTH:0] ;
                                        flag_1 <=0;
                                        flag_2 <=0;
			   	                    end
			   	COMBINE			:	begin
			   							data<=data| data_buffer;
			   							flag_1 <=0;
                                        flag_2 <=0;
			   						end

			   	GET_LENGTH		:	begin
			   	                         case(block)
			   	                         1:length 	<=	data[LENGTH_WIDTH+(1<<5):(1<<5)];
			   	                         2:length 	<=	data[LENGTH_WIDTH+(2<<5):(2<<5)];
			   	                         3:length 	<=	data[LENGTH_WIDTH+(3<<5):(3<<5)];
			   	                         4:length 	<=	data[LENGTH_WIDTH+(4<<5):(4<<5)];
			   	                         5:length 	<=	data[LENGTH_WIDTH+(5<<5):(5<<5)];
			   	                         6:length 	<=	data[LENGTH_WIDTH+(6<<5):(6<<5)];
			   	                         7:length 	<=	data[LENGTH_WIDTH+(7<<5):(7<<5)];
                                            
                                        endcase
			   						end

			

			   	OUTPUT 			:	begin
			   	                        flag_1 <=0;
                                        flag_2 <=0;
			   							if (ready) begin
			   								DATA_OUT<=	data;
			   								valid 	<=  1;	
			   							end 
			   						end

			   	CHECK_LENGTH1	:	begin
			   							if (length<32) begin
			   							
			   								past_len <= length;
				   							if ((length%4)==0) begin	   								
				   								block_num <= (length>>2);
				   							end else begin
				   								block_num <= (length>>2)+1;
				   							end
			   							end
			   						end

			   	CHECK_LENGTH2	:	begin
			   							past_len <= length;
			   							flag_1 <=0;
                                        flag_2 <=0;
			   							if ((length%4)==0) begin	   								
			   								block_num <= (length>>2);
			   							end else begin
			   								block_num <= (length>>2)+1;
			   							end
			   						end

			   	CHECK_LENGTH3	:	begin
			   							if (length<32-(block<<2)) begin
				   							past_len <= length;
				   							if ((length%4)==0) begin	   								
				   								block_num <= (length>>2);
				   							end else begin
				   								block_num <= (length>>2)+1;
				   							end
			   							end
			   						end
			   	BLOCK_UPDATE	:	block <= block+block_num;

			   	

			   	BUFFER			:	begin
			   							data_buffer<=data;
			   							stage <= stage4;
			   							next_engine <= ~next_engine;

			   						end
			   	NEW_LENGTH		:	begin
			   							length <= length-(32-(block<<2));					
			   						end

			   	NEXT_DATA		:	begin
			   							block <=0;
			   							if (length==0) begin
			   								stage<=	stage1;
			   								next_engine <= ~next_engine;
			   							end else if (length>32) begin
			   								stage<=	stage2;
			   							end else begin
			   								stage<=	stage3;

			   						    
			   							
			   							end	
			   						end


		    endcase // state
	    end
    end

    always @(posedge clk) begin
    	if (reset) begin
    		count <=0;
    	end else begin
    		case (state)
    			COUNT 			:   begin
			    						if (count_done) begin
			    							count <=0;
			    						end else begin
			    							count 	<= count + 1 ;
			    						end			    						
			    					end

			endcase
		end
	end

	always @(*) begin
		count_done = 0;
		case(state)
			COUNT 				:   begin
										count_done=(count==5);
									end
		endcase
	end
endmodule // Aggregator
 