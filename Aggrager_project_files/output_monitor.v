`timescale 1ns / 1ps

module output_monitor(
    clk,
    reset,
    data1,
    valid,
    ready
);
//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter WIDTH                 = 256;
    parameter FILE_NAME             = "";
    parameter OUT_VERIFY            = 1;
    parameter DEBUG                 = 1;  // if you want to see the output all the time
   
//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    
    input               clk;
    input               reset;
    input               valid;
    input               ready; 
    input [WIDTH-1:0]   data1;
    
// synthesis translate_off
    integer             file_in;
    integer             i,j;
    reg [7:0]           temp;
    reg                 wrong_compare;
    
    wire [7:0]          data1_arry[WIDTH/8-1:0];
    reg [WIDTH-1:0]     temp_word;
    integer             address;
    integer             output_number = 0;
   
//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// Implmentation
//---------------------------------------------------------------------------------------------------------------------

initial begin
    if(OUT_VERIFY) begin
        file_in = $fopen(FILE_NAME,"rb");
        if(file_in) begin
            $display("Output file open!!");
        end
        else begin
            $display("file not open!!");
            $stop;
        end
    end
end

always@(posedge clk) begin
    if (valid && ready) begin
        if (OUT_VERIFY) begin
            i = $fscanf(file_in,"%h\n",temp_word);
            if(temp_word == data1) begin
                if(DEBUG ==1) begin
                    output_number = output_number + 1;
                    $display("%d  output no %d  compare success in %x", $time, output_number, data1);
                end
            end                     
            else begin
                output_number = output_number + 1;
                $display("%d  output no  %d  compare fail output %x expected %x", $time, output_number, data1, temp_word);
                $stop;
                wrong_compare <= 1;
            end
        end
    end
end

endmodule