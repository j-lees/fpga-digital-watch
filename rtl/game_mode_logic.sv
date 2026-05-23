
`timescale 1ns / 1ps

module game_mode_logic #(
    parameter int CYCLES_PER_SECOND = 50_000_000,
    parameter logic [9:0] LEVEL_DESIGN = 10'b0101010010 // number stream fed into shift register to generate obsticles
) (
    input logic clk,
    /* verilator lint_on UNUSEDSIGNAL */
    input logic [3:0] button,
    /* verilator lint_off UNUSEDSIGNAL */
    output logic blank_seconds,
    output logic blank_minutes,
    output logic blank_hours,
    output logic [6:0] SecondsDisplay,
    output logic [6:0] MinutesDisplay,
    output logic [6:0] HoursDisplay
);
  logic blank;
  logic rst;
  logic [9:0] low_level;
  logic death;
  logic player_position;
  logic [3:0] score;
  logic display_blank;
  assign rst = button[1];
  assign blank = rst || (score == 4'd9) || display_blank; // Blank the display when player dies (score reaches 9) or when reset is active
  // Score Counter

  assign blank_seconds = blank;
  assign blank_minutes = blank;
  assign blank_hours = blank;
  mod_n_counter #(
      .N(10),
      .WIDTH(4)
  ) u_score_counter (
      .clk(clk),
      .rst(death || rst),
      .enable(low_level[9] && player_position),  // Increment score when obsticle reaches player and player is in the air
      .count(score)
  );

  logic [3:0] shift_reg_counter;
  logic shift_reg_tick;
  mod_n_counter #(
      .N(10),
      .WIDTH(4)
  ) u_shift_reg_counter (
      .clk(clk),
      .rst(rst || death),
      .enable(shift_reg_tick),
      .count(shift_reg_counter)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 2)  // Adjust the speed of the game by changing the divisor
  ) u_rate_generator (
      .clk(clk),
      .run(1'b1),  // Always run
      .tick(shift_reg_tick)  // Not used directly, but could be used for timing events
  );


  logic [9:0] obsticle_shift_reg = 10'b0100000000;  // position for obsticles before they reach player
  assign low_level[7:0] = obsticle_shift_reg[7:0];  // connect shift register to low_level output
  assign low_level[8] = !player_position;  //players position or obsticle under player
  assign low_level[9] = obsticle_shift_reg[9]; // connect highest bit of shift register to low_level output


  // Obsticle Shift Register
  always_ff @(posedge clk) begin
    if (rst) begin
      obsticle_shift_reg <= 10'b0000000000;
    end else if (shift_reg_tick) begin
      obsticle_shift_reg <= {
        obsticle_shift_reg[8:0], LEVEL_DESIGN[shift_reg_counter]
      };  // Shift left and insert new obsticle from button input
    end
  end

  // Player control
  logic [1:0] jump_timer;
  mod_n_counter #(
      .N(2),
      .WIDTH(2)
  ) u_jump_counter (
      .clk(clk),
      .rst(death || rst),
      .enable(shift_reg_tick && button[0]),  // Increment score when obsticle reaches player and player is in the air
      .count(jump_timer)
  );

  always_ff @(posedge clk) begin
    if (button[0] && (jump_timer < 2'd2)) begin
      player_position <= 1'b1;  // Player jumps when button is pressed
    end else begin
      player_position <= 1'b0;  // Player is on the ground otherwise
    end
  end

  // One cycle pulse when player Dies
  rising_edge_detector u_death_pulse (
      .clk(clk),
      .sig_in(low_level[8] && (!player_position)),
      .rise(death)
  );

  game_mode_display_driver u_game_display (
      .score(score),
      .low_level(low_level),
      .player_position(player_position),
      .death(death),
      .blank(display_blank),
      .SecondsDisplay(SecondsDisplay),
      .MinutesDisplay(MinutesDisplay),
      .HoursDisplay(HoursDisplay)
  );

endmodule
