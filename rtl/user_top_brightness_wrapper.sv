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

module user_top_brightness_wrapper #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
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

  localparam logic [1:0] Dim = 2'b00, Low = 2'b01, Medium = 2'b11, High = 2'b10;
  localparam int Width = $clog2(CYCLES_PER_SECOND);
  localparam int HoldThreshold = CYCLES_PER_SECOND / 1000;  //1ms

  logic [Width - 1:0] count;
  logic [Width - 1:0] duty_cycles;
  initial duty_cycles = Width'(HoldThreshold);
  logic top_blank_seconds, top_blank_minutes, top_blank_hours;
  logic pwm_blank_seconds, pwm_blank_minutes, pwm_blank_hours;
  mod_n_counter #(
      .N    (HoldThreshold),
      .WIDTH(Width)
  ) u_brightness_counter (
      .clk   (clk),
      .rst   (1'b0),
      .enable(1'b1),
      .count (count)
  );

  user_top #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_user_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      /* verilator lint_off PINCONNECTEMPTY */
      .blank_hours(top_blank_hours),
      .blank_minutes(top_blank_minutes),
      .blank_seconds(top_blank_seconds)
  );
  /* verilator lint_off PINCONNECTEMPTY */
  always @(*) begin
    case (sw[9:8])
      Dim   : duty_cycles = Width'(HoldThreshold / 8);
      Low   : duty_cycles = Width'(HoldThreshold / 4);
      Medium: duty_cycles = Width'(HoldThreshold / 2);
      High  : duty_cycles = Width'(HoldThreshold);
      default: duty_cycles = Width'(HoldThreshold);
    endcase
  end

  assign pwm_blank_seconds = (duty_cycles == 0) ? 1'b1 :
        (Width'(duty_cycles) >= Width'(HoldThreshold)) ? 1'b0 : !(count < Width'(duty_cycles));

  assign pwm_blank_minutes = (duty_cycles == 0) ? 1'b1 :
        (Width'(duty_cycles) >= Width'(HoldThreshold)) ? 1'b0 : !(count < Width'(duty_cycles));

  assign pwm_blank_hours = (duty_cycles == 0) ? 1'b1 :
        (Width'(duty_cycles) >= Width'(HoldThreshold)) ? 1'b0 : !(count < Width'(duty_cycles));

  assign blank_seconds = top_blank_seconds || pwm_blank_seconds;
  assign blank_minutes = top_blank_minutes || pwm_blank_minutes;
  assign blank_hours = top_blank_hours || pwm_blank_hours;

endmodule
