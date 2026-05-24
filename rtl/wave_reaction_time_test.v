`timescale 1ns / 1ps
module wave_reaction_time_test;
  reg        clk = 0;
  reg  [3:0] button = 4'b0;
  reg  [9:0] sw = 10'b0;
  wire [9:0] led;
  wire [6:0] hours_disp;
  wire [6:0] minutes_disp;
  wire [6:0] seconds_disp;
  wire       blank_hours;
  wire       blank_minutes;
  wire       blank_seconds;

  // CYCLES_PER_SECOND=50 keeps the simulation concise:
  //   1 simulated second  = 50 cycles  = 500 ns
  //   PWM period (0.5 s)  = 25 cycles  = 250 ns  (2 Hz flash)
  //   PWM high (0.1 s)    =  5 cycles  =  50 ns  (display off, 20% of period)
  //   Hold threshold (1s) = 50 cycles  = 500 ns
  reaction_time_game #(
      .CYCLES_PER_SECOND(50)
  ) dut (
      .clk          (clk),
      .button       (button),
      .sw           (sw),
      .led          (led),
      .hours_disp   (hours_disp),
      .minutes_disp (minutes_disp),
      .seconds_disp (seconds_disp),
      .blank_hours  (blank_hours),
      .blank_minutes(blank_minutes),
      .blank_seconds(blank_seconds)
  );

  always #5 clk = ~clk;  // 100 MHz: 10 ns period

  initial begin
    $dumpfile("wave_reaction_time_test.vcd");
    $dumpvars(0, wave_reaction_time_test);

    // --- Normal operation: watch counts for ~1.5 simulated seconds ---
    // seconds_disp advances once every 50 cycles; all blank_* remain 0.

    #200;

    button[0] = 1;
    #10;  // 55 cycles held (> HOLD_CYCLES=50)
    button[0] = 0;
    #1500;  // 5 seconds


    button[0] = 1;
    #10 button[0] = 0;
    #1500;  // observe blank_minutes pulsing

    // --- Edit minutes: one tap inc, one tap dec ---
    button[0] = 1;
    #10;
    button[0] = 0;
    #2500;

    // --- Short press KEY[3]: cycle from minutes to hours edit mode ---
    // mode_enable becomes 3'b100; blank_minutes returns to 0;
    // blank_hours begins flashing.
    button[0] = 1;
    #10;
    button[0] = 0;
    #250;  // observe blank_hours pulsing


    // --- Short press KEY[3]: exit edit mode ---
    // disarm condition fires (count == 2 && enable_counter); latch clears.
    // mode_enable returns to 3'b000; all blank_* return to 0.
    button[0] = 1;
    #10;
    button[0] = 0;
    #2500;

    $finish;
  end
endmodule
