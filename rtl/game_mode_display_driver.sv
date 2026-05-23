`timescale 1ns / 1ps

module game_mode_display_driver (
    input logic [3:0] score,  // Score to be displayed on one 7-segment display (0-9)
    input logic [9:0] low_level, // horisontal positions of everthing on the ground level. eg 2 obsticles and player
                                 // 10'b0100100100 first bit is the player, second and fifth bits are obsticles
    // horisontal positions, basically just when the player jumps
    // 10'b0100000000 when jumps, but 10'b0000000000 when on ground
    input logic player_position,  //0 = ground, 1 = air
    input logic death,
    output logic blank,
    output logic [6:0] SecondsDisplay,
    output logic [6:0] MinutesDisplay,
    output logic [6:0] HoursDisplay
);
  localparam logic [3:0] ObsEven = 4'ha, ObsOdd = 4'hb, PlayerAir= 4'hc,
  PlayerAirObsticle = 4'hd, PlayerAirObsticleBehind = 4'he, PlayerGroundObsticleBehind = 4'hf;

  // score 7segment:

  logic [3:0] digits_a[6];
  assign SecondsDisplay = {3'b000, digits_a[0]} + 7'd10 * {3'b000, digits_a[1]};
  assign MinutesDisplay = {3'b000, digits_a[2]} + 7'd10 * {3'b000, digits_a[3]};
  assign HoursDisplay   = {3'b000, digits_a[4]} + 7'd10 * {3'b000, digits_a[5]};



  // obsticle positions before last HEX infront of player
  // Goes though the low level positions and lights up the corresponding segments on the second 7-segment display
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : g_pos_pair
      always_comb begin
        if (blank) digits_a[i] = '0;
        else begin
          if (low_level[i*2] == 1'b1) begin
            digits_a[i+1] = ObsEven;
          end else if (low_level[i*2+1] == 1'b1) begin
            digits_a[i+1] = ObsOdd;
          end else begin
            digits_a[i+1] = 4'b0;  // No obsticle, all segments off
          end
        end
      end
    end
  endgenerate

  // Player and Obsticle Positions at last HEX
  always_comb begin
    digits_a[0] = score;
    if (death) begin
      blank = 1'b1;
      digits_a[5] = '0;  // All segments on when player dies
    end else if (player_position == 1'b1) begin
      blank = 1'b0;
      if (low_level[8] == 1'b1) begin
        digits_a[5] = PlayerAirObsticle;  // Player in air with obsticle on ground
      end else if (low_level[9] == 1'b1) begin
        digits_a[5] = PlayerAirObsticleBehind;  // Player in air with obsticle behind
      end else begin
        digits_a[5] = PlayerAir;  // Player in air with no obsticle on ground
      end
    end else begin
      blank = 1'b0;
      if (low_level[9] == 1'b1) begin
        digits_a[5] = PlayerGroundObsticleBehind;  // Player on ground with obsticle behind
      end else
        digits_a[5] = ObsEven;  // Player on ground, same as obsticle on even position (or no obsticle)
    end
  end

endmodule
