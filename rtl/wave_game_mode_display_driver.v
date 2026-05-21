`timescale 1ns / 1ps
module wave_game_mode_display_driver;
  logic clk;
  logic [3:0] score;  // Score to be displayed on one 7-segment display (0-9)
  logic [9:0] low_level; // horisontal positions of everthing on the ground level. eg 2 obsticles and player
  // 10'b0100100100 first bit is the player, second and fifth bits are obsticles
  // horisontal positions, basically just when the player jumps
  // 10'b0100000000 when jumps, but 10'b0000000000 when on ground
  logic player_position;  //0 = ground, 1 = air
  logic blank;  // blanks for 1 second when player dies

  logic [6:0] HEX0;
  logic [6:0] HEX1;
  logic [6:0] HEX2;
  logic [6:0] HEX3;
  logic [6:0] HEX4;
  logic [6:0] HEX5;

  // CYCLES_PER_SECOND=50 keeps the simulation concise:
  //   1 simulated second  = 50 cycles  = 500 ns
  //   PWM period (0.5 s)  = 25 cycles  = 250 ns  (2 Hz flash)
  //   PWM high (0.1 s)    =  5 cycles  =  50 ns  (display off, 20% of period)
  //   Hold threshold (1s) = 50 cycles  = 500 ns
  game_mode_display_driver dut (
      .score(score),  // Score to be displayed on one 7-segment display (0-9)
      .low_level(low_level), // horisontal positions of everthing on the ground level. eg 2 obsticles and player
      // 10'b0100100100 first bit is the player, second and fifth bits are obsticles
      // horisontal positions, basically just when the player jumps
      // 10'b0100000000 when jumps, but 10'b0000000000 when on ground
      .player_position(player_position),  //0 = ground, 1 = air
      .blank(blank),  // blanks for 1 second when player dies

      .HEX0(HEX0),
      .HEX1(HEX1),
      .HEX2(HEX2),
      .HEX3(HEX3),
      .HEX4(HEX4),
      .HEX5(HEX5)
  );

  always #5 clk = ~clk;  // 100 MHz: 10 ns period

  initial begin
    $dumpfile("wave_game_mode_display_driver.vcd");
    $dumpvars(0, wave_game_mode_display_driver);
    #1;
    // --- Normal operation: watch counts for ~1.5 simulated seconds ---
    // seconds_disp advances once every 50 cycles; all blank_* remain 0.
    low_level = 10'b0100000010;
    score = 0;
    blank = 0;
    player_position = 0;  // on the ground
    #100;
    low_level = 10'b0100000100;
    player_position = 1;
    #100;
    low_level = 10'b0100001000;
    player_position = 0;
    #100;
    low_level = 10'b0100010000;
    #100;
    low_level = 10'b0100100000;
    #100;
    low_level = 10'b0101000001;
    #100;
    player_position = 1;
    low_level = 10'b0110000010;
    #100;
    low_level = 10'b0100000100;
    #100;
    score = 1;
    low_level = 10'b1100001000;
    player_position = 0;
    #200 $finish;
  end
endmodule
