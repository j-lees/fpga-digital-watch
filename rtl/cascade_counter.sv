`timescale 1ns / 1ps

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input  logic          clk,
    input  logic          rst,
    input  logic          enable,
    output logic [W2-1:0] count2,
    output logic [W1-1:0] count1,
    output logic [W0-1:0] count0
);
  localparam logic [W0 -1 : 0] MaxCount0 = W0'(N0 - 1);
  localparam logic [W1 -1 : 0] MaxCount1 = W1'(N1 - 1);
  logic count1_enable;
  logic count2_enable;
  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) u_count0 (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count0)
  );

  assign count1_enable = enable && (count0 == MaxCount0);
  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) u_count1 (
      .clk(clk),
      .rst(rst),
      .enable(count1_enable),
      .count(count1)
  );

  assign count2_enable = count1_enable && (count1 == MaxCount1);
  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) u_count2 (
      .clk(clk),
      .rst(rst),
      .enable(count2_enable),
      .count(count2)
  );

endmodule
