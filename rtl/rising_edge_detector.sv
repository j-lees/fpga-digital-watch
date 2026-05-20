`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);
  logic prev = 1'b0;

  always_ff @(posedge clk) prev <= sig_in;
  // high when the last cycle was low and the curren signal is high
  assign rise = (~prev && sig_in);
endmodule
