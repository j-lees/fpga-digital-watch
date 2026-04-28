`timescale 1ns/1ps

module binary_to_bcd (
    input logic [6:0] bin, // binary number 0-99
    output logic [3:0] tens, // tens column, 0-9
    output logic [3:0] ones // ones column, 0-9
);
    assign tens = 4'(bin / 7'd10);
    assign ones = 4'(bin - 7'd10 * tens);
endmodule
