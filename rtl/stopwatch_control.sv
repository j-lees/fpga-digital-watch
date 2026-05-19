`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);
  localparam logic [2:0] StopLive = 3'b000, StopFrozen = 3'b001,  RunLive = 3'b010,  RunFrozen = 3'b011, Rst = 3'b100;
  logic [2:0] next_state;
  wire ss_only = rise_start_stop && !rise_lap;
  wire lap_only = !rise_start_stop && rise_lap;

  initial {counter_rst, counter_enable, lap_hold} = StopLive;
  always_ff @(posedge clk) {counter_rst, counter_enable, lap_hold} <= next_state;



  always_comb begin
    next_state[2] = ({counter_rst, counter_enable, lap_hold} == StopLive) && lap_only;

    next_state[1] = ss_only ? ~counter_enable : counter_enable;
    case ({
      counter_rst, counter_enable, lap_hold
    })
      StopLive: next_state[0] = 1'b0;
      StopFrozen: next_state[0] = lap_only ? 1'b0 : 1'b1;
      RunLive: next_state[0] = lap_only ? 1'b1 : 1'b0;
      RunFrozen: next_state[0] = lap_only ? 1'b0 : 1'b1;
      Rst: next_state[0] = 1'b0;
      default: next_state[0] = lap_hold;
    endcase
  end

endmodule
