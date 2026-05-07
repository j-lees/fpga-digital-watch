`timescale 1ns/1ps

module rising_edge_detector (
    input logic clk,
    input logic sig_in,
    output logic rise
);
    logic prev;

    always_ff @(posedge clk) prev <= sig_in;

    assign rise = (~prev && sig_in);
endmodule
