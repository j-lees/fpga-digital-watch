`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH -1:0] d,
    output logic [WIDTH -1:0] q
);
  logic [WIDTH - 1:0] last_d = 0;

  always_ff @(posedge clk) if (!hold) last_d <= d;

  assign q = hold ? last_d : d;
endmodule
