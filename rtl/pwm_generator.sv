`timescale 1ns/1ps

module pwm_generator # (
    parameter int PERIOD_CYCLES = 50_000_000,

    parameter int DUTY_CYCLES = 25_000_000
) (
    input logic clk,
    input logic rst,
    output logic pwm_out
);  
    // satisfying linter
    localparam int Width = $clog2(PERIOD_CYCLES);
    logic [Width - 1: 0] count;
    
    logic en = 1'b1;

    mod_n_counter # (
        .N(PERIOD_CYCLES),
        .WIDTH(Width)
    ) n(
        .clk(clk),
        .rst(rst),
        .enable(en),
        .count(count)
    );
    // If 0, always low
    // If duty cycles is more or equal to the period, itll always be high
    // other wise only go high for duty cycles rising edges
    assign pwm_out = 
        (DUTY_CYCLES == 0) ? 1'b0 :
        (DUTY_CYCLES >= PERIOD_CYCLES) ? 1'b1 : (count < Width'(DUTY_CYCLES));
endmodule
