`timescale 1ns/1ps

module hms_counter # (
    parameter int N_HOURS = 24,
    parameter int N_MINUTES = 60,
    parameter int N_SECONDS = 60,

    parameter int W_HOURS = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);
    localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
    localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);


    logic up = 1;
    logic enable_seconds, enable_minutes, enable_hours;

    assign enable_seconds = enable;

    up_down_counter #(.MAX(N_HOURS-1), .WIDTH(W_HOURS)) u_hour(.clk(clk), .enable(enable_hours), .up(up), .count(hours));
    up_down_counter #(.MAX(N_MINUTES-1), .WIDTH(W_MINUTES)) u_minutes(.clk(clk), .enable(enable_minutes), .up(up), .count(minutes));
    up_down_counter #(.MAX(N_SECONDS-1), .WIDTH(W_SECONDS)) u_seconds(.clk(clk), .enable(enable_seconds), .up(up), .count(seconds));

    assign enable_minutes = enable && (seconds == MaxSeconds);
    assign enable_hours = enable && ((seconds == MaxSeconds) && (minutes == MaxMinutes));

endmodule
