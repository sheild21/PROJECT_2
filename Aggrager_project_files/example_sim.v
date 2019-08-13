`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2019 10:19:09 AM
// Design Name: 
// Module Name:
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module example_sim();

    parameter AXIS_BYTES                = 32;    // axi4 stream interface bytes
    parameter AXIS_TUSER_BPB            = 4;     // axi4 stream sideband bits per byte
    parameter AXIS_TID_BITS             = 2;     // axi4 stream identifier bits
    parameter OPERATION       		= 2'b01; // TID code for an operational packet
    parameter CONFIGURATION   		= 2'b11; // TID code for a configuration packet
    parameter INPUT_FILE                = "/home/dpi_3/kasun/aggregator/input_data_golden.txt";
    parameter OUTPUT_FILE               = "/home/dpi_3/kasun/aggregator/output_hw.txt";
    parameter EXPECTED_OUTPUT_FILE      = "/home/dpi_3/kasun/aggregator/output_golden.txt";
    parameter STATE_OPEN_FIRST_FILE     = 1;
    parameter STATE_OPEN_FILE           = 2;
    parameter STATE_SEND_FILE_1         = 3;


    reg                                 clk;
    reg                                 reset;
    reg  [AXIS_BYTES * 8 - 1: 0]        io_in_tdata;
    reg                                 io_in_valid;
    wire                                io_in_ready;
    reg                                 io_out_ready;
    wire                                io_out_valid;
    wire                                io_out_tlast;
    wire [AXIS_BYTES * 8 - 1: 0]        io_out_bits_tdata;
    reg                                 init;
    reg  [AXIS_BYTES * 8 - 1: 0]        input_data;
    reg  [AXIS_BYTES * 8 - 1: 0]        file_result;
    reg  [3:0]                          input_state;

    initial begin
        clk         =   1'b0;
        reset       =   1; 
        
        #10 reset = 0;
        init = 1;
    end
    
    //for iverilog simulation only
    //initial begin
    //    $dumpfile("full_design.vcd");
    //    $dumpvars(0, tungsten_passer_top_test);
    //end

    always begin
        #5 clk = !clk;
    end

    Top #(
        .AXIS_BYTES(AXIS_BYTES),
        .AXIS_TUSER_BPB(AXIS_TUSER_BPB),
        .AXIS_TID_BITS(AXIS_TID_BITS),
        .OPERATION(OPERATION),
        .CONFIGURATION(CONFIGURATION)
    ) tp_1(
        .clk(clk),
        .reset(reset),
        .io_in_valid(io_in_valid),
        .io_in_tid(2'b0),
        .io_in_bits_tdata(io_in_tdata),
        .io_in_bits_tkeep(32'b1),
        .io_in_bits_tlast(1'b0),
        .io_in_bits_tuser(128'b1),
        .io_in_ready(io_in_ready),
        //output of the system 
        .io_out_ready(io_out_ready),
        .io_out_valid(io_out_valid),
        .io_out_bits_tdata(io_out_bits_tdata),
        .io_out_bits_tuser(),   //tuser, tkeep, tlast and tid are not checked for the time being
        .io_out_bits_tkeep(),
        .io_out_bits_tlast(io_out_tlast),
        .io_out_tid()
    );

    //for validation
    output_monitor  #(
        .WIDTH(AXIS_BYTES*8),
        .FILE_NAME(EXPECTED_OUTPUT_FILE),
        .OUT_VERIFY(1),
        .DEBUG(1)
    ) output_monitor_1(
        .clk(clk),
        .reset(reset),
        .data1(io_out_bits_tdata),
        .valid(io_out_valid),
        .ready(io_out_ready)
    );

    integer input_file, output_file, input_count = 1, output_count = 1, tmp, block_count = 0, block_limit = 2;

    //feeding input to the system
    always @(posedge clk) begin
        if(reset) begin
            input_state <= STATE_OPEN_FIRST_FILE; 
        end
        else begin
            case (input_state)
                STATE_OPEN_FIRST_FILE : begin
                    input_file = $fopen(INPUT_FILE,"r");
                    input_state <= STATE_SEND_FILE_1;
                end
                STATE_OPEN_FILE : begin
                    if(io_out_tlast && io_out_ready && io_out_valid) begin
                        input_file = $fopen(INPUT_FILE,"r");
                        input_state <= STATE_SEND_FILE_1;
                        init <= 1; 
                    end
                end
                STATE_SEND_FILE_1 : begin
                    //while(!$feof(input_file)) begin
                    if(!$feof(input_file)) begin
                            if(io_in_ready && io_in_valid) begin
                                tmp = $fscanf(input_file,"%h\n",input_data);
                                io_in_tdata <= input_data;
                            end
                            else if (init) begin
                                //#15;
                                io_in_valid <= 1;
                                tmp = $fscanf(input_file,"%h\n",input_data);
                                io_in_tdata <= input_data;
                                init <= 0;
                            end
                        input_count  =  input_count + 1;
                        if(input_count % 64 != 0) begin
                            io_in_valid <= 1;
                        end
                        else begin
                            io_in_valid <= 0;
                        end
                    end
                    else begin
                        if(io_in_ready) begin
                            io_in_valid     <= 0;
                            $fclose(input_file);
                            input_state <= STATE_OPEN_FILE;
                        end
                    end
                end
                default: begin
                end
            endcase
        end
    end
    

    //writing the output to a file
    initial begin            
        output_file = $fopen(OUTPUT_FILE, "w");
        $fclose(output_file);           
    end
    
    always @(posedge clk)begin
        if(reset) begin
            io_out_ready    <= 0;
        end
        else begin
            output_file     = $fopen(OUTPUT_FILE, "a");
            output_count    =   output_count + 1;
            if(output_count % 128 == 0) begin
                if(io_out_ready && io_out_valid) begin
                    $fwrite(output_file, "%h\n", io_out_bits_tdata); 
                end
                io_out_ready    <= 0;
            end
            else begin
                io_out_ready    <=  1;
                if(io_out_ready && io_out_valid) begin
                    $fwrite(output_file, "%h\n", io_out_bits_tdata); 
                end
            end
            $fclose(output_file);
        end
    end

endmodule