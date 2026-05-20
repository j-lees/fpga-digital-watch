`timescale 1ns / 1ps

//Normal mode: 
//           -  Time increments once
//              per second
//           -  Holding KEY[3] for > 1s 
//                activates edit mode with 
//                seconds selected
// Edit mode: 
//           - digits flash at 2Hz with
//             80% duty cycle
//           - KEY[0] Advances the selection
//           - KEY[1] Increments
//           - KEY[2] Decrements


module user_top_watch_v1 #(
    // - - - - - - - - - - - - - - - - - -
    //        Core Functionality
    // - - - - - - - - - - - - - - - - - -

    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);
  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );
  assign seconds_edit = 1'b0;
  assign seconds_inc  = 1'b0;
  assign seconds_dec  = 1'b0;

  // Minutes
  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );
  assign minutes_edit = 1'b0;
  assign minutes_inc  = 1'b0;
  assign minutes_dec  = 1'b0;

  // Hours
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;

  assign hours_edit = 1'b0;
  assign hours_inc  = 1'b0;
  assign hours_dec  = 1'b0;
  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  // Derive 1 Hz tick from system clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (1'b1),
      .tick(seconds_tick)
  );

  assign minutes_tick = (seconds == 59) && seconds_tick;
  assign hours_tick = (minutes == 59) && minutes_tick;

  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};
  assign led = 10'b0;
  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;


endmodule
