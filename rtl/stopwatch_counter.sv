`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       clk,
    input  logic       rst,          // Takes priority over enable
    input  logic       enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundredths of a second
);
  logic tick;
  cascade_counter #(
      .N0(100),
      .N1(60),
      .N2(100),

      .W0(7),
      .W1(6),
      .W2(7)
  ) u_cascadecounter (
      .clk(clk),
      .rst(rst),
      .enable(tick && enable),
      .count0(centiseconds),
      .count1(seconds),
      .count2(minutes)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_centisecond_rate (
      .clk (clk),
      .run (enable && !rst),
      .tick(tick)
  );

endmodule
