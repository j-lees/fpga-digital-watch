`timescale 1ns/1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
); 
    localparam logic [WIDTH-1:0] Max = WIDTH'(N-1);
    logic [WIDTH-1:0] next_count;
    initial count = 0;

    always_ff @(posedge clk) begin
        if (rst) count <= '0;
        else if (enable) count <= next_count;
    end

    always_comb begin
        if (count < Max) next_count = count + WIDTH'(1);
        else next_count = 0;
    end
endmodule
