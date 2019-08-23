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
// PROJECT      :   AGGEGATOR
// PRODUCT      :   
// FILE         :   TEST_BENCH
// AUTHOR       :   SAUMYA HERATH
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

`define IVERILOG 1

`ifdef IVERILOG
`include "/home/shield/intern/Aggrager_project_files/Aggrager_1.v"
`include "/home/shield/intern/Aggrager_project_files/output_monitor.v"

`endif

module Aggregator_test ;
initial 
    begin
    $dumpfile("Aggregator_output.vcd");
    $dumpvars(0,Aggregator_test);
end
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
	parameter 		DATA_WIDTH		=	256; 
	parameter 		LENGTH_WIDTH	=	32 ;  
	parameter 		INPUT_ENGINE1	=    "/home/shield/intern/Aggrager_project_files/input_golden_2_blocks1.blk";
	//parameter 		INPUT_ENGINE1	=	"/home/shield/intern/Aggrager_project_files/ENGINE_1_OUT1.txt";
	parameter 		INPUT_ENGINE2	=	"/home/shield/intern/Aggrager_project_files/input_golden_2_blocks2.blk";
	//parameter 		INPUT_ENGINE2	=	"/home/shield/intern/Aggrager_project_files/ENGINE_2_OUT1.txt";
	parameter       OUTPUT_FILE     =  "/home/shield/intern/Aggrager_project_files/OUT_BLOCK2_END.txt";
//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------
    //none
//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------

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
    localparam      PAUSE           =   14;
    localparam		CLOSE 			=	15;
    localparam		RESET 			=	16;

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
	reg									clk			;
	reg									reset 		;
	reg			        [DATA_WIDTH-1:0] 	data_engine1	;
	reg			        [DATA_WIDTH-1:0]  data_engine2	;
	reg                             	valid_1     ;
	reg                             	valid_2     ;
	reg 								ready 		;
	wire								ready_1 	;
	wire								ready_2 	;
	wire		        [DATA_WIDTH-1:0]	data_out 	;
	wire 								valid		;

	reg					[4:0]			state_test	;
	reg					[2:0]			stage_test	;
	reg                 [3:0]		    row_done    ;
	reg			        [DATA_WIDTH-1:0] 	input_data	;
	reg			        [LENGTH_WIDTH-1:0]input_test	;
	reg			        [LENGTH_WIDTH-1:0]input_arrange;
	reg 				[LENGTH_WIDTH-1:0]len 		;
	reg 								input_file	;
	reg 								output_file ;
	reg                 [2:0]           blk_no      ;
	reg                 [2:0]           blk         ;
	reg			        [DATA_WIDTH-1:0]  data1    	;
	reg			        [DATA_WIDTH-1:0]  data2    	;
	reg                                 close1      ;
	reg                                 close2      ;
	reg                                 next1      	;
	reg                                 next2	  	;	
	reg                                 finish  	;	
	reg                 [3:0]           count1      ;
	reg                 [3:0]           count2      ;

	integer input_engine1,input_engine2,r2,r1;

Aggregator #(
		.DATA_WIDTH(DATA_WIDTH),
		.LENGTH_WIDTH(LENGTH_WIDTH)
	) 
	Aggregator1(	
        .clk(clk),
        .reset(reset),
        .valid_1(valid_1),
        .valid_2(valid_2),
        .data_engine1(data_engine1)	,
        .data_engine2(data_engine2),
        .ready(ready)	,
        .ready_1 (ready_1),
        .ready_2(ready_2),
        .data_out(data_out),
        .valid(valid)

	);
	
	output_monitor #(
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
	    input_engine1=$fopen(INPUT_ENGINE1,"rb");
        input_engine2=$fopen(INPUT_ENGINE2,"rb");
		repeat(15) @(posedge clk);
		reset <= 1'b0;
		
		
		/*data_engine1<=256'h0000000000ffff07ffff7f0080ffff1fffffffffc1ffff1f00e0ffff00000020;
		repeat(10) @(posedge clk);
		data_engine1<=256'h00000000000000000000000000000000000000000000000000000000ff7f0080;
		data_engine2<=256'hcffff01000ffff07ffff7f0080ffff1fff0100feff7ffcff0000002000000020;
		repeat(15) @(posedge clk);
		data_engine1<=256'h7ff0ffff0700f8fffff1ffffff1ffcffff0100feff7ffcffffff07ffff7f0080;
		data_engine2<=256'h7ff0ffff0700f8fffff1ffffff1ffcffff0100feff7ffcffffff07ffff7f0080;*/
		
	end


	always @(posedge clk) begin
		if(reset) begin
		    stage_test<=1;
		    input_file<=0;
		    output_file<=0;
		    row_done<=0;
		    len<=0;
		    input_test<=0;
		    data1<=0;
		    data2<=0;
		    state_test <= GET;
		    count1<=0;
			count2<=0;
			valid_1<=0;
			valid_2<=0;
			blk<=0;
			blk_no<=0;
			input_arrange<=0;
			finish<=0;


	    end 
	    else begin
		   	case(state_test)
	   			RESET 			:  	begin
							   			stage_test<=1;
									    input_file<=0;
									    output_file<=0;
									    row_done<=0;
									    len<=0;
									    input_test<=0;
									    data1<=0;
									    data2<=0;
									    data_engine1<=0;
									    data_engine2<=0;
									    count1<=0;
									    count2<=0;
									    next1<=0;
									    next2<=0;state_test <= GET;	
								   	end					
				GET 			:	begin		//0									
			   							case(input_file)
			   								0	:	begin
		   												if ($feof(input_engine1)==0) begin
															//r1= $fscanf(input_engine1,"%h",input_test);
															//r1=$fgets(input_test,input_engine1);
															r1=$fread(input_test,input_engine1);
															count1<=count1+1;
															state_test	<=	ARRANGE1;
														end
														else begin
	    													state_test	<=	CLOSE;
	    												end
	    														
	    													
			   										end 
			   								1	:	begin 
		   											  	if ($feof(input_engine2)==0) begin
															//r2= $fscanf(input_engine2,"%h",input_test);
															//r1=$fgets(input_test,input_engine2);
															r2=$fread(input_test,input_engine2);
															count2<=count2+1;
															state_test	<=	ARRANGE1;
														end
														else begin
	    													state_test	<=	CLOSE;
	    												end
													end
			   							endcase
			   						end

			   	ARRANGE1			:	begin //6
				   							input_arrange[7:0]	<=	input_test [31:24];
				   							input_arrange[15:8]	<=	input_test [23:16];
				   							input_arrange[23:16]	<=	input_test [15:8];
				   							input_arrange[31:24]	<=	input_test [7:0];
				   							state_test	<=	ARRANGE2;
			   							end

			   	ARRANGE2		:	begin   //7
			   							input_test	<=	input_arrange;
			   							state_test	<=	GET1;
			   							ready<=0;
			   						end

		        GET1	   		:	begin  //1
		                                case(stage_test)
	                                        1	:	begin
                                                      	if ((input_test==32'hffffffff)&&(input_file==0)) begin
                                                           state_test	<=	PAUSE;
                                                           next1<=1;
                                                       	end else if ((input_test==32'hffffffff)&&(input_file==1))begin
                                                           state_test	<=	PAUSE;
                                                           next2<=1;
                                                       	end else begin
                                                           state_test	<=	LEN_BEGIN;
                                                        end
                                                    end
	                                        
	                                        2	:	begin
                                        				state_test	<=	OUT;
                                        			end

	                                        3	:	begin
                                        				state_test	<=	CHECK_LEN2;
                                        			end

	                                        4	:	begin
                                                      	if ((input_test==32'hffffffff)&&(input_file==0)) begin
                                                           state_test	<=	PAUSE;
                                                           next1<=1;
                                                       	end else if ((input_test==32'hffffffff)&&(input_file==1))begin
                                                           state_test	<=	PAUSE;
                                                           next2<=1;
                                                       	end else begin
                                                           state_test	<=	LEN_BEGIN;
                                                        end
                                                    end
	                                    endcase
	                                end

		   		LEN_BEGIN		: 	begin
                                        len <= input_test + 4 ;
                                        case(stage_test)
                                            1	:	begin
                                                        state_test	<=	CHECK_LEN1;
                                                    end
                                            4	:   begin
                                                        state_test	<=	CHECK_LEN3;
                                                    end
                                        endcase
		   	                    	end

				OUT  			:	begin //b
			   							case(input_file)
				   							0:	begin
				   									if (count1==8)begin
				   										count1<=0;
				   									end
					   								case(row_done)
	                                                    0:data1[DATA_WIDTH-1-(7<<5):(0<<5)]<=input_test;
						   								1:data1[DATA_WIDTH-1-(6<<5):(1<<5)]<=input_test;
						   								2:data1[DATA_WIDTH-1-(5<<5):(2<<5)]<=input_test;
						   								3:data1[DATA_WIDTH-1-(4<<5):(3<<5)]<=input_test;
						   								4:data1[DATA_WIDTH-1-(3<<5):(4<<5)]<=input_test;
						   								5:data1[DATA_WIDTH-1-(2<<5):(5<<5)]<=input_test;
	                                                    6:data1[DATA_WIDTH-1-(1<<5):(6<<5)]<=input_test;
	                                                    7:data1[DATA_WIDTH-1-(0<<5):(7<<5)]<=input_test;
                                                	endcase
				   								end
				   							1:	begin
				   									if (count2==8)begin
				   										count2<=0;
				   									end
					   							    case(row_done)
						   								0:data2[DATA_WIDTH-1-(7<<5):(0<<5)]<=input_test;
						   								1:data2[DATA_WIDTH-1-(6<<5):(1<<5)]<=input_test;
						   								2:data2[DATA_WIDTH-1-(5<<5):(2<<5)]<=input_test;
						   								3:data2[DATA_WIDTH-1-(4<<5):(3<<5)]<=input_test;
						   								4:data2[DATA_WIDTH-1-(3<<5):(4<<5)]<=input_test;
						   								5:data2[DATA_WIDTH-1-(2<<5):(5<<5)]<=input_test;
	                                                    6:data2[DATA_WIDTH-1-(1<<5):(6<<5)]<=input_test;
	                                                    7:data2[DATA_WIDTH-1-(0<<5):(7<<5)]<=input_test;
                                                	endcase
				   								end
					   					endcase
                                        state_test	<= ROW_DONE;
                                        len<=len-4;
                                        row_done<=row_done+1;
			   						end

			   	ROW_DONE		:	begin //8
			   							if (row_done==8)begin
			   								state_test	<=	CHECK_READY	;
			   								ready<=1;	
			   							end
			   							else begin
			   								if (len==0)begin
			   									state_test	<=	CHECK_READY;
			   									stage_test <=4;
			   									ready<=1;
			   								end 
			   								else begin	   								
			   									stage_test <=2;
			   									state_test <=	GET	;
			   								end

			   							end
			   						end

			   	CHECK_READY		:	begin //13
			   							case(input_file)
				   							0	:	begin
					   									if (ready_1) begin
							   								valid_1 <=1;
					            							data_engine1<=data1;
					            							state_test <= SEND_DATA;
				            							end 
				            							else begin
				            						    	state_test <= CHECK_READY;
				            						    end
				            						end
			            					1:	begin
			            							if (next2==1) begin
			            								state_test <= RESET;
			            							end 
			            							else begin
					            						if (ready_2) begin
							   								valid_2 <=1;
					            							data_engine2<=data2;
					            							state_test <= SEND_DATA;
					            						end 
					            						else begin
					            							state_test <= CHECK_READY;
					            						end
					            					end
				   								end
			   							endcase // input_file
			   						end

			   	SEND_DATA		:	begin //c
			   	                        valid_1 <=0;
			   	                        valid_2 <=0;
			   							if (row_done==8) begin
			   								row_done <=	0;
			   								data1 	<=0;
                                            data2    <=0;
			   								state_test	<=	NEXT_ROW	;
			   							end
			   							else begin
			   								input_file <=	~input_file;
			   								data1 	<=0;
			   								data2 	<=0;
			   								state_test	<=	GET	;
			   							end

			   						end
			   
			   	CHECK_LEN1		:	begin  //3
			   							if (len<32) begin
				   							if ((len%4)==0) begin	   								
				   								blk_no <= (len>>2);
				   							end 
				   							else begin
				   								blk_no <= (len>>2)+1;
				   							end
				   							state_test <=	BLOCK_UP;
			   							end
			   							else begin
			   								state_test	<=	OUT;
			   							end
			   						end

			   	CHECK_LEN2		:	begin  //4
			   							if ((len%4)==0) begin	   								
			   								blk_no <= (len>>2);
			   							end 
			   							else begin
			   								blk_no <= (len>>2)+1;
			   							end
			   							state_test <=	BLOCK_UP;
			   						end

			   	CHECK_LEN3		:	begin  //5
			   							if (len<32-(blk<<2)) begin
				   							if ((len%4)==0) begin	   								
				   								blk_no <= (len>>2);
				   							end 
				   							else begin
				   								blk_no <= (len>>2)+1;
				   							end
				   							state_test <=BLOCK_UP;
			   							end
			   							else begin
			   								state_test	<=	OUT;
			   							end
			   						end

				BLOCK_UP		:	begin //a
				   						blk <= blk+blk_no;
				   						state_test	<=	OUT;
				   					end

			   	NEXT_ROW		:	begin 
			   							blk <=0;
			   							if (len==0) begin
			   								stage_test<=	1;
			   								input_file <= ~input_file;
			   							end 
			   							else if (len>32) begin
			   								stage_test<=	2;
			   							end 
			   							else begin
			   								stage_test<=	3; 						    
			   							end
			   							state_test	<= GET;	
			   						end

			    PAUSE   	    :   begin
			                            if (next1==1) begin
			    	                        len<=(9-count1)*4;
			    	                        next1<=0;
			                            end
			                            else if (next2==1) begin
			                             	input_test<=0;
			                               	len<=(9-count2)*4;
			                            end
	                                    case(stage_test)
                                            1	:	begin
                                                        state_test	<=	CHECK_LEN1;
                                                    end
                                            4	:   begin
                                                        state_test	<=	CHECK_LEN3;
                                                    end
                                        endcase
	                                end

			    CLOSE 			:	begin
			    						finish<=1;
			    						$fclose(input_engine1);
			    						$fclose(input_engine2);
			    						reset<=1;
			    					end
			endcase // state 	
		end		
	end
endmodule // Aggregator_test