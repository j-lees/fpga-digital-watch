`timescale 1ns / 1ps

module reaction_time_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       clk,
    input  logic       rst,                 // Takes priority over enable
    input  logic       enable,
    output logic [5:0] seconds,
    output logic [3:0] milliseconds_carry,  // Hundreds collumn 
    output logic [6:0] milliseconds         // Tens and Ones of milliseconds
);
  logic tick;
  cascade_counter #(
      .N0(100),
      .N1(10),
      .N2(60),

      .W0(7),
      .W1(4),
      .W2(6)
  ) u_cascadecounter (
      .clk(clk),
      .rst(rst),
      .enable(tick && enable),
      .count0(milliseconds),
      .count1(milliseconds_carry),
      .count2(seconds)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) u_centisecond_rate (
      .clk (clk),
      .run (enable && !rst),
      .tick(tick)
  );

endmodule
