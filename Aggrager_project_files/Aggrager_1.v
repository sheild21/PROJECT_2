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
	parameter 		DATA_WIDTH		=	256, //255
	parameter 		LENGTH_WIDTH	=	32    //31
)(	
	clk,
	reset,
	data_engine1,
	data_engine2,
	valid_1,
	valid_2,
	ready,
	ready_1,
	ready_2,
	data_out,
	valid

);

//---------------------------------------------------------------------------------------------------------------------
// IO signals
//---------------------------------------------------------------------------------------------------------------------


	input								clk			;
	input								reset 		;
	input			[DATA_WIDTH-1:0]	data_engine1;
	input			[DATA_WIDTH-1:0]	data_engine2;
	input                               valid_1     ;
	input                               valid_2     ;
	input 								ready 		;
	output	reg							ready_1 	;
	output	reg							ready_2 	;
	output	reg		[DATA_WIDTH-1:0]	data_out 	;
	output 	reg							valid		;


//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------
    //none
//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------

	
	localparam READY				=	0;			// Make ready high if valid is high in two engines
	localparam GET_DATA				=	1;			// Get data from inputs to "data" register
	localparam LENGTH_BEGIN			=	2;			// Get length at the start and when a row finishes exactly after 8 blocks.
	localparam GET_LENGTH			=	3;			// Get length when the length block is between block(1-7)
	localparam LENGTH_UPDATE1		=	4;			// Add four extra bytes for length as the length does not include bytes for the length 
	localparam LENGTH_UPDATE2		=	5;			// Add four extra bytes for length as the length does not include bytes for the length 
	localparam COMBINE				=	6;			// Combine previous data with the next engine first data
	localparam CHECK_LENGTH1		=	7;			// Check length is greater than ,equal or less than 32
	localparam CHECK_LENGTH2		=	8;			
	localparam CHECK_LENGTH3		=	9;
	localparam BLOCK_UPDATE			=	10;
	localparam BUFFER				=	11;			
	localparam OUTPUT				=	12;
	localparam NEW_LENGTH			=	13;			// Update length substracting (32-(blk<<2)) 
	localparam NEXT_DATA			=	14;
	localparam READY_LOW       		=	15;			// Make ready bit low
	localparam END                  =   16;			// Reset if end of a tungsten block
	localparam RESET                =   17;
	localparam LENGTH_VERIFY        =   18;			//Check whether the end of a tungsten block 
	

	localparam ENGINE1				=	0;
	localparam ENGINE2				=	1;

	localparam STAGE1				=	0;		// when length==0
	localparam STAGE2				=	1;		// when length>32
	localparam STAGE3				=	2;		// When length<32
	localparam STAGE4				=	3;		// when data is buffering


//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------

	reg 			[DATA_WIDTH-1:0] 	data 		;
	reg 			[DATA_WIDTH-1:0] 	data_buffer ;
	reg 			[4:0]				state 		;
	reg 			[4:0]				next_state	;
	reg 								next_engine	;
	reg 			[LENGTH_WIDTH-1:0]	length 		;
	reg 			[1:0]				stage		;
	reg 			[LENGTH_WIDTH-1:0]	block_num	;		// Number of blocks with 4 bytes
	reg 			[LENGTH_WIDTH-1:0]	block 		;	
	reg             [20:0]	            counter     ;
	reg                                 end_flag 	;		//Flag to mark the end of a tungten block



	always@(posedge clk) begin
        if(reset)begin
            state   	<= READY;
        end else begin
            state   	<= next_state;
        end
    end

	always @(*) begin
	  	next_state=state;  
	    case(state)

	    	READY 			:   begin			//0								
                                    case(next_engine)
                                       ENGINE1  :   begin
                                                        if (valid_1)begin
                                                            next_state	=	READY_LOW;  
                                                        end 
                                                        else begin
                                                            next_state	=	READY;
                                                        end
                                                       end
                                       ENGINE2  :   begin 
                                                      	if (valid_2)begin
                                                           next_state    =    READY_LOW;  
                                                       	end 
                                                       	else begin
                                                           next_state    =    READY;
                                                       	end
                                                    end    
                                    endcase
                               end

		    READY_LOW       :   begin
		    						next_state	=	GET_DATA;
		    					end


		    GET_DATA 		:	begin //1
                                    case(stage)
                                        STAGE1	:	next_state	=	LENGTH_BEGIN;
                                        STAGE2	:	next_state	=	OUTPUT;
                                        STAGE3	:	next_state	=	CHECK_LENGTH2;
                                        STAGE4	:	next_state	=	COMBINE;
                                    endcase
		    						
		    					end
            

		    

		    LENGTH_BEGIN	:	begin
		    						next_state	=	LENGTH_VERIFY; //2
		    					end

	    	LENGTH_VERIFY 	:	begin   //18
                                    if (length==32'hffffffff)begin
                                        next_state	=	OUTPUT;
                                    end 
                                    else begin
                                        next_state	=	LENGTH_UPDATE1;
                                    end
	   							end

		    LENGTH_UPDATE1	:	begin
		    						next_state	=	CHECK_LENGTH1;   //4
		    					end

		    COMBINE			:	begin
		    						next_state	=	GET_LENGTH;
		    					end

		    GET_LENGTH		:	begin
		    						next_state	=	LENGTH_UPDATE2; //3
		    					end

		   	LENGTH_UPDATE2	: 	begin
		   							next_state	=	CHECK_LENGTH3;
		   						end
   	
		   
		   	CHECK_LENGTH1	:	begin  //7
		   							if (length>=32) begin
		   								next_state	=	OUTPUT;
		   							end 
		   							else begin
		   								next_state	= 	BLOCK_UPDATE;
		   							end
		   						end


	   		CHECK_LENGTH2	:	begin
	   								next_state	= 	BLOCK_UPDATE;
	   							end

	   					   	
		   	CHECK_LENGTH3	:	begin
		   							if (length>=32-(block<<2)) begin
		   								next_state	=	OUTPUT;
		   							end 
		   							else begin
		   								next_state	= 	BLOCK_UPDATE;
		   							end
		   						end

		   	BLOCK_UPDATE	:	begin
		   							next_state	= 	BUFFER;
		   						end

		   	BUFFER			:	begin
		   							next_state = READY;
		   						end

		   	OUTPUT 			:	begin //12
		   							if (ready) begin
		   								next_state	=	END;
		   							end 
		   							else begin
		   								next_state	=	OUTPUT;
		   							end
		   						end

		   	END 			:	begin //16
		   							if (end_flag==1) begin
		   								next_state	=	RESET;
		   							end 
		   							else begin
		   								next_state	=	NEW_LENGTH;
		   							end
		   						end

		   	RESET 			:	begin
		   							next_state  = READY;
		   						end

		   	NEW_LENGTH		:	begin
		   							next_state	=	NEXT_DATA; //13
		   						end
		   	NEXT_DATA		:	begin
		   							next_state	=	READY;
		   						end
		   	default          :  begin
		   	                        next_state  =   READY;
		   	                    end

		endcase // state
	end


	always@(posedge clk) begin
	    if(reset) begin
	        next_engine	<= 1'b0;
	        data_buffer	<=	0;
	        block_num <= 0;
	        length  <= 0;
	        stage <= STAGE1;
	        block <= 0;
	        ready_1 <=0;
	        ready_2 <= 0;
	        data <=0;
	        counter<=0;
	        
	        
	    end 
	    else begin
	        case(state)
	        	READY			:	begin											
			   							case(next_engine)
			   								ENGINE1	:	begin
		   													ready_1<=1'b1;
			   											end
			   								ENGINE2 :	begin 
		   													ready_2<=1'b1;
			   											end		
			   							endcase
			   						end
			   	
			   	READY_LOW       :   begin   
                                        ready_1 <=0;
                                        ready_2 <=0;
			   	                    end

		    	GET_DATA 		:	begin											
			   							case(next_engine)
			   								ENGINE1	:	begin
			   												data<=data_engine1;
			   											end
			   								ENGINE2 :	begin 
                                                            data<=data_engine2;
                                                        end	
			   							endcase
			   						end

			   	LENGTH_BEGIN	: 	begin
                                        length <= data[LENGTH_WIDTH-1:0] ;
			   	                    end

			   	LENGTH_VERIFY 	:	begin 
                                        if (length==32'hffffffff) begin
                                            end_flag<=1;
                                        end 
		   							end

				LENGTH_UPDATE1	:	begin
			   							length<=length+4;
			   						end

			   	COMBINE			:	begin
			   							data<=data| data_buffer;
			   						end

			   	GET_LENGTH		:	begin
			   	                        case(block)
				   	                        1:length 	<=	data[LENGTH_WIDTH-1+(1<<5):(1<<5)] ;
				   	                        2:length 	<=	data[LENGTH_WIDTH-1+(2<<5):(2<<5)] ;
				   	                        3:length 	<=	data[LENGTH_WIDTH-1+(3<<5):(3<<5)] ;
				   	                        4:length 	<=	data[LENGTH_WIDTH-1+(4<<5):(4<<5)] ;
				   	                        5:length 	<=	data[LENGTH_WIDTH-1+(5<<5):(5<<5)] ;
				   	                        6:length 	<=	data[LENGTH_WIDTH-1+(6<<5):(6<<5)] ;
				   	                        7:length 	<=	data[LENGTH_WIDTH-1+(7<<5):(7<<5)] ;
                                        endcase
			   						end

			   	LENGTH_UPDATE2	:	begin
			   							length<=length+4;
			   						end

			   	OUTPUT 			:	begin
			   							if (ready) begin
			   								data_out<=	data;
			   								counter<=counter+1;
			   								valid 	<=  1;	
			   							end 
			   						end

			   	RESET 			: 	begin
			   							next_engine	<= 0;
								        data_buffer	<=	0;
								        block_num <= 0;
								        length  <= 0;
								        stage <= STAGE1;
								        block <= 0;
								        ready_1 <=0;
								        ready_2 <= 0;
								        data <=0;
								    	end_flag<=0;
			   						end

			   	CHECK_LENGTH1	:	begin
			   							if (length<32) begin
				   							if ((length%4)==0) begin	   								
				   								block_num <= (length>>2);
				   							end 
				   							else begin
				   								block_num <= (length>>2)+1;
				   							end
			   							end
			   						end

			   	CHECK_LENGTH2	:	begin
			   							if ((length%4)==0) begin	   								
			   								block_num <= (length>>2);
			   							end 
			   							else begin
			   								block_num <= (length>>2)+1;
			   							end
			   						end

			   	CHECK_LENGTH3	:	begin
			   							if (length<32-(block<<2)) begin
				   							if ((length%4)==0) begin	   								
				   								block_num <= (length>>2);
				   							end 
				   							else begin
				   								block_num <= (length>>2)+1;
				   							end
			   							end
			   						end
			   	BLOCK_UPDATE	:	begin
			   							block <= block+block_num;
			   						end
			   	
			   	BUFFER			:	begin
			   							data_buffer<=data;
			   							stage <= STAGE4;
			   							next_engine <= ~next_engine;
			   						end
			   	END             :   begin
			   							valid 	<=  0;	
			   						end
			   						
			   
			   	NEW_LENGTH		:	begin
			   							length <= length-(32-(block<<2));
			   						end

			   	NEXT_DATA		:	begin
			   							block <=0;
			   							if (length==0) begin
			   								stage<=	STAGE1;
			   								next_engine <= ~next_engine;
			   							end 
			   							else if (length>=32) begin
			   								stage<=	STAGE2;
			   							end 
			   							else begin
			   								stage<=	STAGE3;
										end	
			   						end
			  
			   	                     
		    endcase // state
	    end
    end

endmodule // Aggregator