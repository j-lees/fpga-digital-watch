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
  logic death;
  logic [6:0] SecondsDisplay;
  logic [6:0] MinutesDisplay;
  logic [6:0] HoursDisplay;

  game_mode_display_driver dut (
      .score(score),  // Score to be displayed on one 7-segment display (0-9)
      .low_level(low_level), // horisontal positions of everthing on the ground level. eg 2 obsticles and player
      // 10'b0100100100 first bit is the player, second and fifth bits are obsticles
      // horisontal positions, basically just when the player jumps
      // 10'b0100000000 when jumps, but 10'b0000000000 when on ground
      .player_position(player_position),  //0 = ground, 1 = air
      .blank(blank),  // blanks for 1 second when player dies
      .death(death),
      .SecondsDisplay(SecondsDisplay),
      .MinutesDisplay(MinutesDisplay),
      .HoursDisplay(HoursDisplay)
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
    death = 0;

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
    death = 1'b1;
    #100;
    death = 1'b0;
    score = 1;
    low_level = 10'b1100001000;
    player_position = 0;
    #200 $finish;
  end
endmodule
