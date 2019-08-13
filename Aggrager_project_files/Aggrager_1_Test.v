//*********************************************************************************************************************
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
// AUTHOR       :   
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

module Aggregator_test ;

	parameter 		DATA_WIDTH		=	255; 
	parameter 		LENGTH_WIDTH	=	31 ;  
	parameter 		INPUT_ENGINE1	=    "/home/shield/intern/Aggrager_project_files/input_golden_2_blocks1.blk";
	//parameter 		INPUT_ENGINE1	=	"/home/shield/intern/Aggrager_project_files/ENGINE_1_OUT1.txt";
	parameter 		INPUT_ENGINE2	=	"/home/shield/intern/Aggrager_project_files/input_golden_2_blocks2.blk";
	//parameter 		INPUT_ENGINE2	=	"/home/shield/intern/Aggrager_project_files/ENGINE_2_OUT1.txt";
	//parameter       OUTPUT_FILE     =  "/home/shield/intern/Aggrager_project_files/OUT_END.txt";
	parameter		OPEN_FILE   	=	1;
	parameter		OPEN_FILE2     	=	2;
	parameter		OPEN_FILE1		=	3;
	//parameter       CHECK_READY     =   4;
	parameter		SEND_FILE1		=	5;
	parameter 		SEND_FILE2		=	6;
	parameter 		CHECK_ENGINE	=	7;
	
	localparam		GET 			=	0;
	localparam		GET1 			=	1;
	localparam		LEN_BEGIN 		=	2;
	localparam		CHECK_LEN1 		=	3;
	localparam		CHECK_LEN2 		=	4;
	localparam		CHECK_LEN3 		=	5;
	localparam		ARRANGE1 		=	6;
	localparam		ARRANGE2 		=	7;
	localparam		ROW_DONE 		=	8;
	localparam		NEXT_ROW		=	9;
	localparam		BLOCK_UP 		=	10;
	localparam		OUT 		    =	11;
	localparam      SEND_DATA       =   12;
	localparam      CHECK_READY     =   13;
    localparam      STOP            =   14;
    localparam		CLOSE 			=	15;
    localparam		RESET 			=	16;

	reg									clk			;
	reg									reset 		;
	reg			        [DATA_WIDTH:0] 	data_in1	;
	reg			        [DATA_WIDTH:0]  data_in2	;
	reg                             	valid_1     ;
	reg                             	valid_2     ;
	reg 								ready 		;
	wire								ready_1 	;
	wire								ready_2 	;
	wire		        [DATA_WIDTH:0]	data_out 	;
	wire 								valid		;

	reg					[2:0]			state1		;
	reg					[4:0]			state_zero	;
	reg					[2:0]			stage_zero	;
	reg                 [3:0]		    row_done    ;
	reg			        [DATA_WIDTH:0] 	input_data	;
	reg			        [LENGTH_WIDTH:0]input_zero	;
	reg			        [LENGTH_WIDTH:0]input_arrange	;
	reg 				[LENGTH_WIDTH:0]len 		;
	reg					[LENGTH_WIDTH:0]zero_reg	;
	reg 								input_file	;
	reg 								output_file ;
	reg                 [2:0]           i           ;
	reg                 [2:0]           blk_no      ;
	reg                 [2:0]           blk         ;
	reg			        [DATA_WIDTH:0]  data1    	;
	reg			        [DATA_WIDTH:0]  data2    	;
	reg                                 done        ;
	reg                                 close1      ;
	reg                                 close2      ;
	reg                                 next1      	;
	reg                                 next2	  	;	
	reg                                 finish  	;	
	
	integer input_engine1,input_engine2,r2,r1;

Aggregator #(
		.DATA_WIDTH1(DATA_WIDTH),
		.LENGTH_WIDTH(LENGTH_WIDTH)
	) 
	Aggregator1(	
        .clk(clk),
        .reset(reset),
        .valid_1(valid_1),
        .valid_2(valid_2),
        .data_in1(data_in1)	,
        .data_in2(data_in2),
        .ready(ready)	,
        .ready_1 (ready_1),
        .ready_2(ready_2),
        .data_out(data_out),
        .valid(valid)

	);
	
/*	output_monitor #(
	    .WIDTH(256),
        .FILE_NAME(OUTPUT_FILE),
        .OUT_VERIFY(1),
        .DEBUG(1) 
	)
	monitor1(
        .clk(clk),
        .reset(reset),
        .data1(data_out),
        .valid(valid),
        .ready(ready)
    );*/

	initial begin
    clk=0;
    forever 
	    begin
	       #10 clk=~clk;             
	    end  
    end

	initial begin
		
	    reset <=1'b1;
	    input_engine1=$fopen(INPUT_ENGINE1,"rb");
        input_engine2=$fopen(INPUT_ENGINE2,"rb");
		repeat(15) @(posedge clk);
		reset <= 1'b0;
		
		
		/*data_in1<=256'h0000000000ffff07ffff7f0080ffff1fffffffffc1ffff1f00e0ffff00000020;
		repeat(10) @(posedge clk);
		data_in1<=256'h00000000000000000000000000000000000000000000000000000000ff7f0080;
		data_in2<=256'hcffff01000ffff07ffff7f0080ffff1fff0100feff7ffcff0000002000000020;
		repeat(15) @(posedge clk);
		data_in1<=256'h7ff0ffff0700f8fffff1ffffff1ffcffff0100feff7ffcffffff07ffff7f0080;
		data_in2<=256'h7ff0ffff0700f8fffff1ffffff1ffcffff0100feff7ffcffffff07ffff7f0080;*/
		
	end


always @(posedge clk) begin
			 if(reset) begin
			 	
			    stage_zero<=1;
			    input_file<=0;
			    output_file<=0;
			    row_done<=0;
			    zero_reg<=0;
			    len<=0;
			    input_zero<=0;
			    data1<=0;
			    data2<=0;
			    state_zero   	<= GET;
	        end else begin

	    	

	   case(state_zero)
	   			RESET 			:  	begin
							   			stage_zero<=1;
									    input_file<=0;
									    output_file<=0;
									    row_done<=0;
									    zero_reg<=0;
									    len<=0;
									    input_zero<=0;
									    data1<=0;
									    data2<=0;
									    state_zero   	<= GET;	
								   	end					





		    	GET 			:	begin											
			   							case(input_file)
			   								0		:	begin
			   												if ($feof(input_engine1)==0) begin
	    														//r1= $fscanf(input_engine1,"%h",input_zero);
	    														//r1=$fgets(input_zero,input_engine1);
	    														r1=$fread(input_zero,input_engine1);
	    														state_zero	<=	ARRANGE1;
	    														done<=0;
	    														
	    													end
	    													else begin
	    														if ((close1==1)&&(close2==1)) begin
	    															state_zero	<=	CLOSE;
	    														end else begin
		    														$fclose(input_engine1);
		    														close1<=1;
		    														state_zero	<=	CLOSE;
		    													end
	    														
	    													end
			   											end 
			   								1		 :	begin 
			   											  	if ($feof(input_engine2)==0) begin
	    														//r2= $fscanf(input_engine2,"%h",input_zero);
	    														//r1=$fgets(input_zero,input_engine2);
	    														r2=$fread(input_zero,input_engine2);
	    														state_zero	<=	ARRANGE1;
	    														
	    													end
	    													else begin
	    														if ((close1==1)&&(close2==1)) begin
	    															state_zero	<=	CLOSE;
	    														end else begin
		    														$fclose(input_engine2);
		    														state_zero	<=	CLOSE;
		    														close2<=1;
		    													end
	    													end
			   												
			   											end	
			   							endcase
			   						end

			   	ARRANGE1			:	begin
				   							input_arrange[7:0]	<=	input_zero [31:24];
				   							input_arrange[15:8]	<=	input_zero [23:16];
				   							input_arrange[23:16]	<=	input_zero [15:8];
				   							input_arrange[31:24]	<=	input_zero [7:0];
				   							state_zero	<=	ARRANGE2;


			   							end
			   	ARRANGE2		:	begin
			   							input_zero	<=	input_arrange;
			   							state_zero	<=	GET1;
			   							ready<=0;
			   						end
		        GET1	   		:	 begin
		        
		                                case(stage_zero)
	                                        1		:	begin
	                                                      	if ((input_zero==32'hffffffff)&&(input_file==0)) begin
	                                                           state_zero	<=	STOP;
	                                                           next1<=1;
	                                                       	end else if ((input_zero==32'hffffffff)&&(input_file==1))begin
	                                                           state_zero	<=	STOP;
                                                               next2<=1;
                                                           	end else begin
                                                               state_zero	<=	LEN_BEGIN;
                                                            end
                                                        end
	                                        
	                                        2		:	state_zero	<=	OUT;
	                                        3		:	state_zero	<=	CHECK_LEN2;
	                                        4		:	state_zero	<=	LEN_BEGIN;
	                                    endcase
				   					end
		   		LEN_BEGIN		: 	begin
                                        len <= input_zero + 4 ;
                                        case(stage_zero)
                                            1	:	begin
                                                        state_zero	<=	CHECK_LEN1;
                                                    end
                                            4	:   begin
                                                        state_zero	<=	CHECK_LEN3;
                                                    end
                                        endcase

		   	                    	end

				OUT  			:	begin
			   							case(input_file)
				   							0:	begin
					   								case(row_done)
						   								/*0:data1[DATA_WIDTH:DATA_WIDTH-(1<<5)+1]<=input_zero;
						   								1:data1[DATA_WIDTH-(1<<5):DATA_WIDTH-(2<<5)+1]<=input_zero;
						   								2:data1[DATA_WIDTH-(2<<5):DATA_WIDTH-(3<<5)+1]<=input_zero;
						   								3:data1[DATA_WIDTH-(3<<5):DATA_WIDTH-(4<<5)+1]<=input_zero;
						   								4:data1[DATA_WIDTH-(4<<5):DATA_WIDTH-(5<<5)+1]<=input_zero;
						   								5:data1[DATA_WIDTH-(5<<5):DATA_WIDTH-(6<<5)+1]<=input_zero;
	                                                    6:data1[DATA_WIDTH-(6<<5):DATA_WIDTH-(7<<5)+1]<=input_zero;
	                                                    7:data1[DATA_WIDTH-(7<<5):DATA_WIDTH-(8<<5)+1]<=input_zero;*/

	                                                    0:data1[DATA_WIDTH-(7<<5):DATA_WIDTH-(8<<5)+1]<=input_zero;
						   								1:data1[DATA_WIDTH-(6<<5):DATA_WIDTH-(7<<5)+1]<=input_zero;
						   								2:data1[DATA_WIDTH-(5<<5):DATA_WIDTH-(6<<5)+1]<=input_zero;
						   								3:data1[DATA_WIDTH-(4<<5):DATA_WIDTH-(5<<5)+1]<=input_zero;
						   								4:data1[DATA_WIDTH-(3<<5):DATA_WIDTH-(4<<5)+1]<=input_zero;
						   								5:data1[DATA_WIDTH-(2<<5):DATA_WIDTH-(3<<5)+1]<=input_zero;
	                                                    6:data1[DATA_WIDTH-(1<<5):DATA_WIDTH-(2<<5)+1]<=input_zero;
	                                                    7:data1[DATA_WIDTH-(0<<5):DATA_WIDTH-(1<<5)+1]<=input_zero;
                                                	endcase
				   								end
				   							1:	begin
					   							    case(row_done)
						   								/*0:data2[DATA_WIDTH:DATA_WIDTH-(1<<5)+1]<=input_zero;
						   								1:data2[DATA_WIDTH-(1<<5):DATA_WIDTH-(2<<5)+1]<=input_zero;
						   								2:data2[DATA_WIDTH-(2<<5):DATA_WIDTH-(3<<5)+1]<=input_zero;
						   								3:data2[DATA_WIDTH-(3<<5):DATA_WIDTH-(4<<5)+1]<=input_zero;
						   								4:data2[DATA_WIDTH-(4<<5):DATA_WIDTH-(5<<5)+1]<=input_zero;
						   								5:data2[DATA_WIDTH-(5<<5):DATA_WIDTH-(6<<5)+1]<=input_zero;
	                                                    6:data2[DATA_WIDTH-(6<<5):DATA_WIDTH-(7<<5)+1]<=input_zero;
	                                                    7:data2[DATA_WIDTH-(7<<5):DATA_WIDTH-(8<<5)+1]<=input_zero;*/


	                                                    0:data2[DATA_WIDTH-(7<<5):DATA_WIDTH-(8<<5)+1]<=input_zero;
						   								1:data2[DATA_WIDTH-(6<<5):DATA_WIDTH-(7<<5)+1]<=input_zero;
						   								2:data2[DATA_WIDTH-(5<<5):DATA_WIDTH-(6<<5)+1]<=input_zero;
						   								3:data2[DATA_WIDTH-(4<<5):DATA_WIDTH-(5<<5)+1]<=input_zero;
						   								4:data2[DATA_WIDTH-(3<<5):DATA_WIDTH-(4<<5)+1]<=input_zero;
						   								5:data2[DATA_WIDTH-(2<<5):DATA_WIDTH-(3<<5)+1]<=input_zero;
	                                                    6:data2[DATA_WIDTH-(1<<5):DATA_WIDTH-(2<<5)+1]<=input_zero;
	                                                    7:data2[DATA_WIDTH-(0<<5):DATA_WIDTH-(1<<5)+1]<=input_zero;
                                                	endcase
				   								end

					   						
				   						endcase
                                        state_zero	<= ROW_DONE;
                                        len<=len-4;
                                        row_done<=row_done+1;
			   							
			   						end
			   	ROW_DONE		:	begin
			   							if (row_done==8)begin
			   								state_zero	<=	CHECK_READY	;
			   								ready<=1;
			   								//row_done<=0;
			   								
			   							end
			   							else begin
			   								if (len==0)begin
			   									//row_done<=0;
			   									state_zero	<=	CHECK_READY;
			   									stage_zero <=4;
			   									ready<=1;

			   								end else begin	   								
			   									stage_zero <=2;
			   									state_zero <=	GET	;
			   								end

			   							end
			   						end
			   	CHECK_READY		:	begin
			   							case(input_file)
			   							0:	if (ready_1) begin
				   								valid_1 <=1;
		            							data_in1<=data1;
		            							
		            							state_zero <= SEND_DATA;
		            						end else begin
		            						    
		            							state_zero <= CHECK_READY;
		            						end
		            					1:	if (ready_2) begin
				   								valid_2 <=1;
		            							data_in2<=data2;
		            							//ready<=1;
		            							state_zero <= SEND_DATA;
		            						end else begin
		            						    
		            							state_zero <= CHECK_READY;
		            						end
                                        endcase
			   						end

			   	SEND_DATA		:	begin
			   	                        valid_1 <=0;
			   	                        valid_2 <=0;
			   							if (row_done==8) begin
			   								row_done 	<=	0;
			   								data1 	<=0;
                                            data2     <=0;
			   								state_zero	<=	NEXT_ROW	;
			   							end
			   							else begin
			   								input_file <=	~input_file;
			   								data1 	<=0;
			   								data2 	<=0;
			   								state_zero	<=	GET	;
			   							end

			   						end
			   	/*ADD_ZERO1		:	begin
			   							case(output_file)
				   							0:	begin
					   								for (i=0;i<(9-blk);i=i+1) begin
					   									$fdisplay(outfile1,"%h",zero_reg);
					   									$display("data=%d", zero_reg);
					   								end
					   								/*case(blk)
							   	                         1:length 	<=	data[DATA_WIDTH-(1<<5):0]&&zero_reg[DATA_WIDTH-(1<<5):0] ;
							   	                         2:length 	<=	data[DATA_WIDTH-(2<<5):0]&&zero_reg[DATA_WIDTH-(2<<5):0] ;
							   	                         3:length 	<=	data[DATA_WIDTH-(3<<5):0]&&zero_reg[DATA_WIDTH-(3<<5):0] ;
							   	                         4:length 	<=	data[DATA_WIDTH-(4<<5):0]&&zero_reg[DATA_WIDTH-(4<<5):0] ;
							   	                         5:length 	<=	data[DATA_WIDTH-(5<<5):0]&&zero_reg[DATA_WIDTH-(5<<5):0] ;
							   	                         6:length 	<=	data[DATA_WIDTH-(6<<5):0]&&zero_reg[DATA_WIDTH-(6<<5):0] ;
							   	                         7:length 	<=	data[DATA_WIDTH-(7<<5):0]&&zero_reg[DATA_WIDTH-(7<<5):0] ;
				                                            
			                                        endcase
				   								end

				   							1:	begin
					   								for (i=0;i<(9-blk);i=i+1) begin
					   									$fdisplay(outfile2,"%h",zero_reg);
					   									$display("data=%d", zero_reg);
					   								end

					   							end
				   						endcase
			   							stage_zero<=4;
			   							input_file<=~input_file;
			   							output_file<=~output_file;
			   							state_zero <=ADD_ZERO2;
			   						end
			   	ADD_ZERO2		:	begin
			   	                        i<=0;
			   							case(output_file)
				   							0:	begin
					   								for (i=0;i<blk;i=i+1) begin
					   									$fdisplay(outfile1,"%h",zero_reg);
					   								end
					   							end
				   							1:	begin
					   								for (i=0;i<blk;i=i+1) begin
					   									$fdisplay(outfile2,"%h",zero_reg);
					   								end
					   							end
				   						endcase
			   							state_zero <=GET;
			   						end*/



			   	CHECK_LEN1		:	begin
			   							if (len<32) begin
				   							if ((len%4)==0) begin	   								
				   								blk_no <= (len>>2);
				   							end else begin
				   								blk_no <= (len>>2)+1;
				   							end
				   							state_zero <=	BLOCK_UP;

			   							end
			   							else
			   								state_zero	<=	OUT;
			   						end

			   	CHECK_LEN2		:	begin
			   							if ((len%4)==0) begin	   								
			   								blk_no <= (len>>2);
			   							end else begin
			   								blk_no <= (len>>2)+1;
			   							end
			   							state_zero <=	BLOCK_UP;
			   						end

			   	CHECK_LEN3		:	begin
			   							if (len<32-(blk<<2)) begin
				   							if ((len%4)==0) begin	   								
				   								blk_no <= (len>>2);
				   							end else begin
				   								blk_no <= (len>>2)+1;
				   							end
				   							state_zero <=BLOCK_UP;
			   							end
			   							else begin
			   								state_zero	<=	OUT;
			   							end

			   						end
				BLOCK_UP		:	begin
				   						blk <= blk+blk_no;
				   						state_zero	<=	OUT;
				   					end

			   	NEXT_ROW		:	begin
			   							blk <=0;
			   							if (len==0) begin
			   								stage_zero<=	1;
			   								input_file <= ~input_file;
			   							end else if (len>32) begin
			   								stage_zero<=	2;
			   							end else begin
			   								stage_zero<=	3; 						    
			   							
			   							end
			   							state_zero	<= GET;	
			   						end
			   STOP             :   begin
			                             if ((next1==1)&&(next2==1)) begin
			                                repeat (30) @(posedge clk);
	                                        done <=1;
	                                        data_in1<=0;
	                                        data_in2<=0;
	                                        reset<=10;
	                                        state_zero<=RESET;
			                             end
			                             else if (next1==1) begin
			                                state_zero<=GET;
			                                input_file<=1;
			                             end
			                             else if (next2==1) begin
                                            state_zero<=GET;
                                            input_file<=0;
                                         end
			                        end
			    CLOSE 			:	begin
			    						if ((close1==1)&&(close2==1)) begin
			    							finish<=1;
			    						end else if (close1==1) begin
			    							state_zero<=GET;
			    							input_file<=1;
			    						end else if (close2==1) begin
			    							state_zero<=GET;
			    							input_file<=0;
			    						end
			    					end


		    endcase // state 	
		end

	end					




endmodule // Aggregator_test