`timescale 1ns / 1ps

module game_mode_display_driver (
    input logic [3:0] score,  // Score to be displayed on one 7-segment display (0-9)
    input logic [9:0] low_level, // horisontal positions of everthing on the ground level. eg 2 obsticles and player
                                 // 10'b0100100100 first bit is the player, second and fifth bits are obsticles
    // horisontal positions, basically just when the player jumps
    // 10'b0100000000 when jumps, but 10'b0000000000 when on ground
    input logic player_position,  //0 = ground, 1 = air
    input logic blank,  // blanks for 1 second when player dies

    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5
);
  // All possible combinations of player and obsticle positions:
  // Player ground is the same as obsticle even
  localparam logic [6:0] ObsEven = 7'b0000100, ObsOdd = 7'b0010000, PlayerAir= 7'b0000010,
  PlayerAirObsticle = 7'b0000110, PlayerAirObsticleBehind = 7'b0010010, PlayerGroundObsticleBehind = 7'b0010100;

  // score 7segment:

  logic [6:0] hex_a[6];
  assign HEX1 = hex_a[1];
  assign HEX2 = hex_a[2];
  assign HEX3 = hex_a[3];
  assign HEX4 = hex_a[4];
  assign HEX5 = hex_a[5];

  seven_segment #(
      .ACTIVE_LOW('1)
  ) u_seven_segment_ones (
      .digit(score),
      .blank(blank),
      .segments(HEX0)  //right most 7-segment display
  );

  // obsticle positions before last HEX infront of player
  // Goes though the low level positions and lights up the corresponding segments on the second 7-segment display
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : g_pos_pair
      always_comb begin
        if (blank) hex_a[i] = 7'b0;
        else begin
          if (low_level[i*2] == 1'b1) begin
            hex_a[i+1] = ObsEven;
          end else if (low_level[i*2+1] == 1'b1) begin
            hex_a[i+1] = ObsOdd;
          end else begin
            hex_a[i+1] = 7'b0;  // No obsticle, all segments off
          end
        end
      end
    end
  endgenerate

  // Player and Obsticle Positions at last HEX
  always_comb begin
    if (blank) hex_a[5] = 7'b0;
    else if (player_position == 1'b1) begin
      if (low_level[8] == 1'b1) begin
        hex_a[5] = PlayerAirObsticle;  // Player in air with obsticle on ground
      end else if (low_level[9] == 1'b1) begin
        hex_a[5] = PlayerAirObsticleBehind;  // Player in air with obsticle behind
      end else begin
        hex_a[5] = PlayerAir;  // Player in air with no obsticle on ground
      end
    end else begin
      if (low_level[9] == 1'b1) begin
        hex_a[5] = PlayerGroundObsticleBehind;  // Player on ground with obsticle behind
      end else
        hex_a[5] = ObsEven;  // Player on ground, same as obsticle on even position (or no obsticle)
    end
  end

endmodule
