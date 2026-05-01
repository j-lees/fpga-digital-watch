`timescale 1ns/1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);
    localparam A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;

    // Each bit represents a rate. 0100 = 25Hz, 0001 = 50Mhz
    logic [3:0] rate;
    logic en = 1;
    logic tick;
    logic clk_speed;
    logic [5:0] seconds, minutes;
    logic [4:0] hours;
    logic [3:0] s1, s2, m1, m2, hr1, hr2;
    // speed selection logic
    always_comb begin
        unique case (SW)
            A : rate = 4'b1000; 
            B : rate = 4'b0100;
            C : rate = 4'b0010;
            D : rate = 4'b0001;
            default : rate = 4'b0001;
        endcase
    end

    // Module instantiation. vewy long 
    // hms
      hms_counter # (
        .N_HOURS(24),
        .N_MINUTES(60),
        .N_SECONDS(60),

        .W_HOURS(5),
        .W_MINUTES(6),
        .W_SECONDS(6)
    ) hms (
        .clk(clk_speed),
        .enable(en),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds)
    );

    // 1Hz Rate
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND/CYCLES_PER_SECOND)
    ) rst1 (
        .clk(CLOCK_50),
        .run(rate[3]),
        .tick(tick)
    );

    // 25Hz Rate
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND/20_000_000)
    ) rst2 (
        .clk(CLOCK_50),
        .run(rate[2]),
        .tick(tick)
    );

    //1kHz Rate
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND/50_000)
    ) rst3 (
        .clk(CLOCK_50),
        .run(rate[1]),
        .tick(tick)
    );

    // binary to bcd
    binary_to_bcd digsec(.bin({1'b0, seconds}), .ones(s1), .tens(s2));
    binary_to_bcd digmin(.bin({1'b0, minutes}), .ones(m1), .tens(m2));
    binary_to_bcd dighr(.bin({2'b0, hours}), .ones(hr1), .tens(hr2));
    

    // Seconds ones
    seven_segment # (
        .ACTIVE_LOW(1)
    ) sec1(
        .digit(s1),
        .blank(0),
        .segments(HEX0)
    );

    // Seconds tens
    seven_segment # (
        .ACTIVE_LOW(1)
    ) sec2(
        .digit(s2),
        .blank(0),
        .segments(HEX1)
    );

    // Minutes ones
    seven_segment # (
        .ACTIVE_LOW(1)
    ) min1(
        .digit(m1),
        .blank(0),
        .segments(HEX2)
    );

    // minutes tens
    seven_segment # (
        .ACTIVE_LOW(1)
    ) min2(
        .digit(m2),
        .blank(0),
        .segments(HEX3)
    );

    // Hours ones 
    seven_segment # (
        .ACTIVE_LOW(1)
    ) hour1(
        .digit(hr1),
        .blank(0),
        .segments(HEX4)
    );

    // Hours tens
    seven_segment # (
        .ACTIVE_LOW(1)
    ) hour2(
        .digit(hr2),
        .blank(0),
        .segments(HEX5)
    );

    assign clk_speed = rate[0] ? CLOCK_50 : tick;
endmodule
