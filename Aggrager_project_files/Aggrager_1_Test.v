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

	reg								clk			;
	reg								reset 		;
	reg								start 		;
	reg			[DATA_WIDTH-1:0]	DATA_IN1	;
	reg			[DATA_WIDTH-1:0]	DATA_IN2	;
	reg 							ready 		;
	wire							ready_1 	;
	wire							ready_2 	;
	wire		[DATA_WIDTH:0]		DATA_OUT 	;
	wire 							valid		;

	module Aggregator #(
		12'h0FF,
		8'h1F
	)(	
	.clk(clk),
	.reset(reset),
	.start(start),
	.DATA_IN1(DATA_IN1)	,
	.DATA_IN2(DATA_IN2),
	.DATA_OUT(DATA_OUT),
	.valid(valid),
	.ready(ready)	,
	.ready_1 (ready_1),
	.ready_2(ready_2,
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
		reset <=



endmodule // Aggregator_test