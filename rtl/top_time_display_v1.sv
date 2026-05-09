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
    logic en;

    // Clock digits
    logic [5:0] seconds, minutes;
    logic [4:0] hours;

    // Digits
    logic [3:0] s1, s2, m1, m2, hr1, hr2;

    // speed selection logic
    // The enable pin of the HMS counter is tied to the restartable tick generator
    // which allows us to control its rate.

    logic rate1, rate2, rate3;
    always_comb begin
        unique case (SW)
            A: en = rate1;
            B: en = rate2;
            C: en = rate3; 
            D: en= 1'b1;
            default: en = 1'b1;
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
        .clk(CLOCK_50),
        .enable(en),
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds)
    );



    // 1Hz Rate
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND)
    ) rst1 (
        .clk(CLOCK_50),
        .run(1'b1),
        .tick(rate1)
    );

    // 25Hz Rate
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND/25)
    ) rst2 (
        .clk(CLOCK_50),
        .run(1'b1),
        .tick(rate2)
    );

    //1kHz Rate
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND/1000)
    ) rst3 (
        .clk(CLOCK_50),
        .run(1'b1),
        .tick(rate3)
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
        .blank('0),
        .segments(HEX0)
    );

    // Seconds tens
    seven_segment # (
        .ACTIVE_LOW(1)
    ) sec2(
        .digit(s2),
        .blank('0),
        .segments(HEX1)
    );

    // Minutes ones
    seven_segment # (
        .ACTIVE_LOW(1)
    ) min1(
        .digit(m1),
        .blank('0),
        .segments(HEX2)
    );

    // minutes tens
    seven_segment # (
        .ACTIVE_LOW(1)
    ) min2(
        .digit(m2),
        .blank('0),
        .segments(HEX3)
    );

    // Hours ones 
    seven_segment # (
        .ACTIVE_LOW(1)
    ) hour1(
        .digit(hr1),
        .blank('0),
        .segments(HEX4)
    );

    // Hours tens
    seven_segment # (
        .ACTIVE_LOW(1)
    ) hour2(
        .digit(hr2),
        .blank('0),
        .segments(HEX5)
    );
    
endmodule
