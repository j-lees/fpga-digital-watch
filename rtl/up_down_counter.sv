`timescale 1ns/1ps

module up_down_counter # (
    parameter int MAX = 2,
    parameter int WIDTH = 2
) (
    input logic clk, 
    input logic enable,
    input logic up, 
    output logic [WIDTH - 1:0] count
);
    // local param to satisfy linter
    localparam logic [WIDTH - 1: 0] Max = WIDTH'(MAX);

    //initialise count
    initial count = '0;
    logic [WIDTH-1:0] next_count;

    //ff
    always_ff @(posedge clk) if(enable) count <= next_count;
    
        // next state logic
    always_comb begin
        if (up) begin
            if (count < Max) next_count = count + WIDTH'(1);
            else next_count = WIDTH'(0);
        end else
            if (count > 0) next_count = count - 1'b1;
            else next_count = WIDTH'(Max);
    end
    
endmodule
