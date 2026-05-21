`timescale 1ns / 1ps
module wave_game_mode_logic;
  logic clk = 0;
  logic rst;
  logic button;
  logic [9:0] low_level;
  logic player_position;
  logic [3:0] score;
  logic blank;
  logic death;

  game_mode_logic #(
      .CYCLES_PER_SECOND(50),
      .LEVEL_DESIGN(10'b0101010010)
  ) dut (
      .clk(clk),
      .rst(rst),
      .button(button),
      .low_level(low_level),
      .player_position(player_position),
      .score(score),
      .blank(blank),
      .death(death)
  );

  always #5 clk = ~clk;  // 100 MHz: 10 ns period

  initial begin
    $dumpfile("wave_game_mode_logic.vcd");
    $dumpvars(0, wave_game_mode_logic);
    #1;
    button = 0;
    rst = 0;
    #100 button = 1;
    #10 button = 0;
    #2000

    // --- Normal operation: watch counts for ~1.5 simulated seconds ---
    // seconds_disp advances once every 50 cycles; all blank_* remain 0.


    #200
    $finish;
  end
endmodule
