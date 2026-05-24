`timescale 1ns / 1ps

module reaction_time_game #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_off UNUSEDPARAM */
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_off UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds

);
  localparam logic [1:0] Standby = 2'b00, Delaying = 2'b01, TimerRunning = 2'b10;

  assign blank_hours   = delay_running;
  assign blank_minutes = delay_running;
  assign blank_seconds = delay_running;

  logic [6:0] milliseconds;
  logic [3:0] milliseconds_carry;
  logic [5:0] seconds;
  logic delay_running;
  logic reaction_rst;
  logic reaction_enable;
  logic [1:0] state;
  logic [1:0] next_state;
  logic rise_start_stop;

  assign next_state = {reaction_enable, delay_running};
  assign led = {10{delay_running}};

  rising_edge_detector u_rise_start_stop (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );
  // Random Counter will run continuously until the user Readys the game
  // When button 0 is pressed the game is armed and the LEDS go high
  // Random_seed will be a random number between 0 and CYCLES_PER_SECOND
  // and the LEDs will take a proportional time to turn off

  // The delay between the LEDs turning off and when the user presses
  // button 0 again is then held on the screen. Pressing button 0 again
  // resets the game.
  logic [31:0] delay_cycles;
  logic [26:0] random_count;
  logic [26:0] random_seed;
  // random delay between 2-5 seconds
  always_ff @(posedge clk) if (rise_start_stop) random_seed <= random_count;

  assign delay_cycles = CYCLES_PER_SECOND * 2 + {5'b0, random_seed} % (CYCLES_PER_SECOND * 3);

  mod_n_counter #(
      .N    (3 * CYCLES_PER_SECOND),
      .WIDTH(27)
  ) u_random_count (
      .clk   (clk),
      .rst   (1'b0),
      .enable(1'b1),
      .count (random_count)
  );

  // delay timer
  logic [31:0] delay_count;
  always_ff @(posedge clk) begin
    state <= next_state;
    if (state == Delaying && (delay_count != delay_cycles)) delay_count <= delay_count + 1;
    else delay_count <= 0;
  end

  always_comb begin
    case (state)
      // start delay when standby and button is pressed
      Standby: begin
        delay_running   = rise_start_stop ? 1'b1 : 1'b0;
        reaction_enable = 1'b0;
      end
      // Go back to standby if button is pressed either go to standby, or if delay is finished go to TimerRunning
      Delaying: begin
        delay_running   = rise_start_stop || delay_count == delay_cycles ? 1'b0 : 1'b1;
        reaction_enable = delay_count == delay_cycles ? 1'b1 : 1'b0;
      end
      // If the timer is running pin enable to 0
      TimerRunning: begin
        delay_running   = 1'b0;
        reaction_enable = rise_start_stop ? 1'b0 : 1'b1;
      end
      default begin
        delay_running   = 1'b0;
        reaction_enable = 1'b0;
      end
    endcase
  end

  // Stopwatch counter
  reaction_time_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
      .clk(clk),
      .rst(state == Delaying),
      .enable(reaction_enable),
      .seconds(seconds), // seconds 0-59
      .milliseconds_carry(milliseconds_carry), // hundreds column 0-9
      .milliseconds(milliseconds) // ones tens column 0-99
  );

  assign seconds_disp = milliseconds;
  assign minutes_disp = {3'b0, milliseconds_carry};
  assign hours_disp   = {1'b0, seconds};
endmodule
