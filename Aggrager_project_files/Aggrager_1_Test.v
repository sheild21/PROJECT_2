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
	parameter 		INPUT_ENGINE1	=	"G:/intern/Aggrager_project_files/engine_1_output.blk";
	parameter 		INPUT_ENGINE2	=	"G:/intern/Aggrager_project_files/engine__output.blk";
	parameter		OUTFILE1 		=	"G:/intern/Aggrager_project_files/ENGINE_1_OUT_ZERO.txt";
	parameter		OUTFILE2 		=	"G:/intern/Aggrager_project_files/ENGINE_2_OUT_ZERO.txt";
	parameter		OPEN_FILE   	=	1;
	parameter		OPEN_FILE2     	=	2;
	parameter		OPEN_FILE1		=	3;
	parameter       CHECK_READY     =   4;
	parameter		SEND_FILE1		=	5;
	parameter 		SEND_FILE2		=	6;
	parameter 		CHECK_ENGINE	=	7;
	
	localparam		GET 			=	1;
	localparam		LEN_BEGIN 		=	2;
	localparam		CHECK_LEN1 		=	3;
	localparam		CHECK_LEN2 		=	4;
	localparam		CHECK_LEN3 		=	5;
	localparam		ADD_ZERO1 		=	6;
	localparam		ADD_ZERO2 		=	7;
	localparam		ROW_DONE 		=	8;
	localparam		NEXT_ROW		=	9;
	localparam		BLOCK_UP 		=	10;
	localparam		OUT 		    =	11;


	reg									clk			;
	reg									reset 		;
	reg									start 		;
	reg			        [DATA_WIDTH:0] 	DATA_IN1	;
	reg			        [DATA_WIDTH:0]  DATA_IN2	;
	reg                             	valid_1     ;
	reg                             	valid_2     ;
	reg 								ready 		;
	wire								ready_1 	;
	wire								ready_2 	;
	wire		        [DATA_WIDTH:0]	DATA_OUT 	;
	wire 								valid		;

	reg					[2:0]			state1		;
	reg					[3:0]			state_zero	;
	reg					[2:0]			stage_zero	;
	reg                 [2:0]		    row_done    ;
	reg			        [DATA_WIDTH:0] 	input_data	;
	reg			        [LENGTH_WIDTH:0]input_zero	;
	reg 				[LENGTH_WIDTH:0]len 		;
	reg					[LENGTH_WIDTH:0]zero_reg	;
	reg 								input_file	;
	reg 								output_file ;
	reg                 [2:0]           i           ;
	reg                 [2:0]           blk_no      ;
	reg                 [2:0]           blk         ;
	reg			        [DATA_WIDTH:0]  data1    	;
	reg			        [DATA_WIDTH:0]  data2    	;
	
	
	integer input_engine1,input_engine2,outfile1,outfile2,r,r1;

Aggregator #(
		12'h0FF,
		8'h1F
	) Aggregator1(	
	.clk(clk),
	.reset(reset),
	.start(start),
	.valid_1(valid_1),
	.valid_2(valid_2),
	.DATA_IN1(DATA_IN1)	,
	.DATA_IN2(DATA_IN2),
	.ready(ready)	,
	.ready_1 (ready_1),
	.ready_2(ready_2),
	.DATA_OUT(DATA_OUT),
	.valid(valid)

	);

	initial begin
    clk=0;
    forever 
	    begin
	       #10 clk=~clk;             
	    end  
    end

	initial begin
		
	    reset <=1'b1;
		repeat(15) @(posedge clk);
		reset <= 1'b0;
		ready <=1'b1;
		
		/*DATA_IN1<=256'h0000000000ffff07ffff7f0080ffff1fffffffffc1ffff1f00e0ffff00000020;
		repeat(10) @(posedge clk);
		DATA_IN1<=256'h00000000000000000000000000000000000000000000000000000000ff7f0080;
		DATA_IN2<=256'hcffff01000ffff07ffff7f0080ffff1fff0100feff7ffcff0000002000000020;
		repeat(15) @(posedge clk);
		DATA_IN1<=256'h7ff0ffff0700f8fffff1ffffff1ffcffff0100feff7ffcffffff07ffff7f0080;
		DATA_IN2<=256'h7ff0ffff0700f8fffff1ffffff1ffcffff0100feff7ffcffffff07ffff7f0080;*/
		
	end


always @(posedge clk) begin
			 if(reset) begin
			 	input_engine1=$fopen(INPUT_ENGINE1,"rb");
			    input_engine2=$fopen(INPUT_ENGINE2,"rb");
			    outfile1=$fopen(OUTFILE1,"wb");
			    outfile2=$fopen(OUTFILE2,"wb");
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
		    	GET 			:	begin											
			   							case(input_file)
			   								0		:	begin
			   												if (!$feof(input_engine1)) begin
			   												  //for (
	    														//r1= $fscanf(input_engine1,"%h",input_zero);
	    														//r1=$fgets(input_zero,input_engine1);
	    														r1=$fread(input_zero,input_engine1);
	    														
	    													end
	    													else begin
	    														$fclose(input_engine1);
	    														$fclose(outfile1);
	    													end
			   											end 
			   								1		 :	begin 
			   											  	if (!$feof(input_engine1)) begin
	    														//r1= $fscanf(input_engine1,"%h",input_zero);
	    														//r1=$fgets(input_zero,input_engine1);
	    														r1=$fread(input_zero,input_engine1);
	    														
	    													end
	    													else begin
	    														$fclose(input_engine2);
	    														$fclose(outfile2);
	    													end
			   												
			   											end	
			   							endcase
			   							case(stage_zero)
	                                        1		:	state_zero	<=	LEN_BEGIN;
	                                        2		:	state_zero	<=	OUT;
	                                        3		:	state_zero	<=	CHECK_LEN2;
	                                        4		:	state_zero	<=	LEN_BEGIN;
	                                    endcase
				   					end
		   		LEN_BEGIN		: 	begin
                                        len <= input_zero ;
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
			   							case(output_file)
				   							0:	begin
					   								/*$fdisplay(outfile1,"%h",input_zero);
					   								$display("data=%d", input_zero);
					   								$fclose(outfile1);*/
					   								case(row_done)
						   								0:data1[DATA_WIDTH:DATA_WIDTH-(1<<5)+1]<=input_zero;
						   								1:data1[DATA_WIDTH-(1<<5):DATA_WIDTH-(2<<5)+1]<=input_zero;
						   								2:data1[DATA_WIDTH-(2<<5):DATA_WIDTH-(3<<5)+1]<=input_zero;
						   								3:data1[DATA_WIDTH-(3<<5):DATA_WIDTH-(4<<5)+1]<=input_zero;
						   								4:data1[DATA_WIDTH-(4<<5):DATA_WIDTH-(5<<5)+1]<=input_zero;
						   								5:data1[DATA_WIDTH-(5<<5):DATA_WIDTH-(6<<5)+1]<=input_zero;
	                                                    6:data1[DATA_WIDTH-(6<<5):DATA_WIDTH-(7<<5)+1]<=input_zero;
	                                                    7:data1[DATA_WIDTH-(7<<5):DATA_WIDTH-(8<<5)+1]<=input_zero;
                                                	endcase
				   								end
				   							1:	begin
					   								/*$fdisplay(outfile2,"%h",input_zero);
					   								$display("data=%d", input_zero);
					   							    $fclose(outfile1);*/
					   							    case(row_done)
						   								0:data2[DATA_WIDTH:DATA_WIDTH-(1<<5)+1]<=input_zero;
						   								1:data2[DATA_WIDTH-(1<<5):DATA_WIDTH-(2<<5)+1]<=input_zero;
						   								2:data2[DATA_WIDTH-(2<<5):DATA_WIDTH-(3<<5)+1]<=input_zero;
						   								3:data2[DATA_WIDTH-(3<<5):DATA_WIDTH-(4<<5)+1]<=input_zero;
						   								4:data2[DATA_WIDTH-(4<<5):DATA_WIDTH-(5<<5)+1]<=input_zero;
						   								5:data2[DATA_WIDTH-(5<<5):DATA_WIDTH-(6<<5)+1]<=input_zero;
	                                                    6:data2[DATA_WIDTH-(6<<5):DATA_WIDTH-(7<<5)+1]<=input_zero;
	                                                    7:data2[DATA_WIDTH-(7<<5):DATA_WIDTH-(8<<5)+1]<=input_zero;
                                                	endcase
				   								end

					   						
				   						endcase
                                        state_zero	<= ROW_DONE;
                                        len<=len-1;
                                        row_done<=row_done+1;
			   							
			   						end
			   	ROW_DONE		:	begin
			   							if (row_done==8)begin
			   								state_zero	<=	NEXT_ROW	;
			   								row_done<=0;
			   								data1<=0;
			   								data2<=0;
			   							end
			   							else begin
			   								if (len==0)begin
			   									state_zero	<=	ADD_ZERO1	;

			   								end else begin	   								
			   									stage_zero <=2;
			   									state_zero <=	GET	;
			   								end

			   							end
			   						end
			   	ADD_ZERO1		:	begin
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
				                                            
			                                        endcase*/
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
			   						end



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
			   								output_file <= ~output_file;
			   							end else if (len>32) begin
			   								stage_zero<=	2;
			   							end else begin
			   								stage_zero<=	3; 						    
			   							
			   							end
			   							state_zero	<= GET;	
			   						end


		    endcase // state 	
		end

	end					





		

		/*always @(posedge clk) begin
			 if(reset) begin
	            state1   	<= OPEN_FILE;
	        end else begin
	            case(state1)   	
	            	OPEN_FILE 	:	begin
	            								input_engine1=$fopen(INPUT_ENGINE1,"r");
	            								input_engine2=$fopen(INPUT_ENGINE2,"r");
	            								state1	<=  CHECK_READY;
	            							end
	            	
		            OPEN_FILE1 			: 	begin
							                    /*if(io_out_tlast && io_out_ready && io_out_valid) begin
							                        input_engine1 = $fopen(INPUT_ENGINE1,"r");
							                        state1 <= SEND_FILE1;
							                        set <= 1; 
							                    end
						                	end	
				    CHECK_READY         :   begin
				                                if (ready_1)begin
				                                    state1	<=  SEND_FILE1;
				                                end else begin
				                                    state1	<=  CHECK_READY;
				                                end
				                            end					
	            	SEND_FILE1			:	begin
	            								if (!$feof(input_engine1)) begin
	            								        valid_1 <=1;
	            										r= $fscanf(input_engine1,"%h\n",input_data);
	            										DATA_IN1<=input_data;
	            										state1 <= CHECK_ENGINE;
	            							    end
	            								else begin
							                        if(ready_1) begin
							                            valid_1     <= 0;
							                            $fclose(input_engine1);
							                            state1 <= OPEN_FILE1;
							                        end
							                    end
							                end
					SEND_FILE2			:	begin
	            								if (!$feof(input_engine2)) begin
	            										valid_2 <=1;
	            										r= $fscanf(input_engine2,"%h\n",input_data);
	            										DATA_IN2<=input_data;
	            										state1 <= CHECK_ENGINE;
	            								end 
	            								else begin
							                        if(ready_2) begin
							                            valid_2     <= 0;
							                            $fclose(input_engine1);
							                            state1 <= OPEN_FILE1;
							                        end
							                    end
							                 end
					CHECK_ENGINE		:	begin	
												if (ready_1) begin
													state1 <= SEND_FILE1;
												end 
												else if (ready_2)begin
												    state1 <= SEND_FILE2;
												end
												else begin
													state1 <= CHECK_ENGINE ;
												end
											end
				/*	default				:	begin
										 	end

		            endcase        	

	        end


		end*/





endmodule // Aggregator_test