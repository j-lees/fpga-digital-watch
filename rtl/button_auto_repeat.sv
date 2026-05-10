`timescale 1ns/1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

    logic rise;
    logic held;
    logic pulse_train;
    assign pulse = rise | (button & pulse_train);

    rising_edge_detector urisingedge(
            .clk(clk),
            .sig_in(button),
            .rise(rise)
    );

    button_hold_detect # (
        .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
    )ubutton(
        .clk(clk), 
        .button(button), 
        .held(held)
    );

    restartable_rate_generator # (
        .CYCLE_COUNT(REPEAT_CYCLES)
    ) urate_generator(
        .clk(clk),
        .run(held),
        .tick(pulse_train)
    );
endmodule
