`timescale 1ns/1ps

module up_down_counter#(
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

    // next state logic
    always_ff @(posedge clk) begin
        if (enable) begin
            if (up)
                count <= count < Max ? count + 1'b1 : '0;
            else
                count <= count > 0 ? count - 1'b1 : Max;
        end
    end
    
endmodule