`timescale 1ns / 1ps

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic tick,  // Count increments on tick when edit_mode is low
    input logic clr,
    input logic edit_mode,
    input logic inc,  // Count increments by one when edit_mode is high
    input logic dec,  // Count decrements by one when edit_mode is high
    output logic borrow_out,  // goes low for one cycle when count transitions from 0 to N-1
    output logic [WIDTH-1:0] count
);
  logic enable;
  logic up;

  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk   (clk),
      .enable(enable),
      .rst   (clr),
      .up    (up),
      .count (count)
  );

  wire inc_event = edit_mode && inc && !dec && !clr;
  wire dec_event = edit_mode && dec && !inc && !clr;
  wire tick_event = !edit_mode && tick && !clr;

  assign up = inc_event ? 1'b1 : 1'b0;

  assign enable = tick_event || inc_event || dec_event;

  assign borrow_out = (tick_event && (count == 0));
endmodule
