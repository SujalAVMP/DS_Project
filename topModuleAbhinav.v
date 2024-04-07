`timescale 1ns / 1ps

module topModuleAbhinav(
    input clk,
    input reset,
    input [7:0] in_data, // The incoming pixel data
    input in_valid_data, // Signal that says that the incoming data is valid. You should write it.
    input ready_data, // Signal that says that data is ready to be read
    output [7:0] final_out_data
    );

parameter START = 1, STOP = 0;
reg [7:0] i, j;

// Increasing i and j
always @(posedge clk) begin
    if(reset) begin
        i <= 0;
        j <= 0;
    end
    else if(in_valid_data) // We're constantly checking to see if we should accept the incoming data. If we should, we increment the write pointer. The data is written to the memory location pointed by the write pointer in the above always block
        if(i == 127) begin
            i <= 0;
            if(j == 127)
                j <= 128;
            else
                j <= j + 1;
        end
        else
            i <= i + 1;
end

reg [71:0] input_to_convolution;
reg [7:0] bram [0:16383];
// Assigning of input data
always @(posedge clk) begin
    if((i == 0) && (j == 0))
        input_to_convolution <= {bram[0], bram[0], bram[1], bram[0], bram[0], bram[1], bram[128], bram[128], bram[129]};
    else if((i == 0) && (j == 127))
        input_to_convolution <= {bram[126], bram[127], bram[127], bram[126], bram[127], bram[127], bram[254], bram[255], bram[255]};
    else if((i == 127) && (j == 0))
        input_to_convolution <= {bram[16128], bram[16128], bram[16129], bram[16256], bram[16256], bram[16257], bram[16256], bram[16256], bram[16257]};
    else if((i == 127) && (j == 127))
        input_to_convolution <= {bram[16254], bram[16255], bram[16255], bram[16382], bram[16383], bram[16383], bram[16382], bram[16383], bram[16383]};
    else if(i == 0)
        input_to_convolution <= {bram[j-1], bram[j], bram[j+1], bram[j-1], bram[j], bram[j+1], bram[(j-1)+128], bram[j+128], bram[(j+1)+128]};
    else if(i == 127)
        input_to_convolution <= {bram[(128*(127-1))+j-1], bram[(128*(127-1))+j], bram[(128*(127-1))+j+1], bram[(128*(127)+j-1)], bram[(128*(127)+j)], bram[(128*(127)+j+1)], bram[(128*(127))+j-1], bram[(128*(127))+j], bram[(128*(127))+j+1]};
    else if(j == 0)
        input_to_convolution <= {bram[(128*(i-1))], bram[(128*(i-1))], bram[(128*(i-1))+1], bram[128*(i)], bram[128*(i)], bram[128*(i)+1], bram[(128*(i+1))], bram[(128*(i+1))], bram[(128*(i+1))+1]};
    else if(j == 127)
        input_to_convolution <= {bram[(128*(i-1))+127-1], bram[(128*(i-1))+127], bram[(128*(i-1))+127], bram[(128*(i)+127-1)], bram[(128*(i)+127)], bram[(128*(i)+127)], bram[(128*(i+1)+127-1)], bram[(128*(i+1)+127)], bram[(128*(i+1)+127)]};
    else
        input_to_convolution <= {bram[(128*(i-1))+j-1], bram[(128*(i-1))+j], bram[(128*(i-1))+j+1], bram[(128*(i)+j-1)], bram[(128*(i)+j)], bram[(128*(i)+j+1)], bram[(128*(i+1))+j-1], bram[(128*(i+1))+j], bram[(128*(i+1))+j+1]};
end


.convolutionOperation(.clk(clk), .in_pixel_data(input_to_convolution), .in_pixel_valid(in_valid_data), .out_pixel_data(final_out_data), .out_pixel_valid(ready_data));

reg [7:0] i_write, j_write;
reg [7:0] convImg [16383:0];

always @(posedge clk) begin
    if(reset)
        i_write <= 0;
        j_write <= 0;

    if(ready_data) begin
        convImg[(128*i_write)+j_write] <= final_out_data;
        if(j_write == 127) begin
            j_write <= 0;
            i_write <= i_write + 1;
        end
        else begin
            j_write <= j_write + 1;
        end
    end

end






endmodule
