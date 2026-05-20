`timescale 1ns / 1ps
module wave_user_top_brightness_wrapper;
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
  user_top_brightness_wrapper #(
      .CYCLES_PER_SECOND(50_000)
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

    button = 4'b0000;
    sw = 10'b1000000000;  // or whatever initial state you want
    #10;
    force dut.u_brightness_counter.count = 0;
    $dumpfile("wave_user_top_brightness_wrapper.vcd");
    $dumpvars(0, wave_user_top_brightness_wrapper);
    #1000;
    // --- Normal operation: watch counts for ~1.5 simulated seconds ---
    // seconds_disp advances once every 50 cycles; all blank_* remain 0.
    sw[9:8] = 2'b00;  // Dim
    #5000;
    sw[9:8] = 2'b00;  // Dim
    #5000;
    sw[9:8] = 2'b01;  // Low
    #5000;
    sw[9:8] = 2'b11;  // Medium
    #5000;
    sw[9:8] = 2'b10;  // High
    #5000;
    $finish;
  end
endmodule
