`timescale 1ns/1ps

module button_hold_pulse #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

    logic held;

    // goes high when button has been held for long enough
    button_hold_detect #(
        .HOLD_CYCLES(HOLD_CYCLES)
    ) u_detect (
        .clk    (clk),
        .button (button),
        .held   (held)
    );


    // Detects when held goes high and generates a one cycle pulse
    rising_edge_detector u_detector (
        .clk   (clk),
        .sig_in(held),
        .rise  (pulse)
    );

endmodule 
