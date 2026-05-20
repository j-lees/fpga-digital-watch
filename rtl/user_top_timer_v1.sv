// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic       probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input  logic       clk,
    /* verilator lint_off UNUSED */
    input  logic [3:0] button,
    input  logic [9:0] sw,
    /* verilator lint_off UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic       blank_hours,
    output logic       blank_minutes,
    output logic       blank_seconds
);
  logic running = 1'b0;
  logic all_zeros;
  assign all_zeros = (seconds == 0 && minutes == 0 && hours == 0);

  // Down counter for seconds, minutes, and hours
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic seconds_clr;
  logic [5:0] seconds;
  logic seconds_borrow;

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick && running),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .clr(seconds_clr),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );



  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic minutes_clr;
  logic [5:0] minutes;
  logic minutes_borrow;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .clr(minutes_clr),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );



  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic hours_clr;
  logic [4:0] hours;
  logic hours_borrow;
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .clr(hours_clr),
      .count(hours),
      .borrow_out(hours_borrow)
  );



  assign seconds_clr = 1'b0;
  assign minutes_clr = 1'b0;
  assign hours_clr   = 1'b0;


  // tick logic

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_tick_gen (
      .clk (clk),
      .run (running),
      .tick(seconds_tick)
  );


  assign minutes_tick = seconds_borrow && running;
  assign hours_tick = minutes_borrow && running;
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};
  assign led = 10'b0;



  //-------------------------------------
  // Digit selection in set mode
  //-------------------------------------
  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_edit_mode (
      .clk(clk),
      .button(button[3] && !running),
      .mode_enable(mode_enable)
  );

  assign {hours_edit, minutes_edit, seconds_edit} = mode_enable;
  logic pwm_out;

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 10)
  ) u_pwm_generator (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );

  assign blank_seconds = seconds_edit && pwm_out;
  assign blank_minutes = minutes_edit && pwm_out;
  assign blank_hours   = hours_edit && pwm_out;



  //-------------------------------------
  // Set Mode Logic
  //-------------------------------------
  logic button1rise;
  logic button0rise;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_button0_edit (
      .clk(clk),
      .button(button[0] && mode_enable != 3'b000),  // edit only when in edit mode
      .pulse(button0rise)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_button1_edit (
      .clk(clk),
      .button(button[1] && mode_enable != 3'b000),
      .pulse(button1rise)
  );
  assign seconds_inc = button1rise && seconds_edit;
  assign seconds_dec = button0rise && seconds_edit;
  assign minutes_inc = button1rise && minutes_edit;
  assign minutes_dec = button0rise && minutes_edit;
  assign hours_inc   = button1rise && hours_edit;
  assign hours_dec   = button0rise && hours_edit;
  //-------------------------------------
  // Timer mode logic
  //-------------------------------------
  logic button0startstop;
  rising_edge_detector u_button0_startstop (
      .clk(clk),
      .sig_in(button[0] && mode_enable == 3'b000),  // start/stop only when not in edit mode
      .rise(button0startstop)
  );
  logic next_running;
  always_ff @(posedge clk) begin
    if (mode_enable != 3'b000 || all_zeros) running <= 1'b0;
    else running <= next_running;
  end
  assign next_running = button0startstop ? !running : running;



`ifdef FORMAL
  assign probe_running     = running;
  assign probe_mode_enable = mode_enable;
`endif
endmodule
