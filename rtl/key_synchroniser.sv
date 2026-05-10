`timescale 1ns/1ps

module key_synchroniser (
    input  logic       clk,
    input  logic [3:0] key_n,     // active-low, asynchronous
    output logic [3:0] key_sync   // active-high, synchronised
);
    logic [3:0] key_flipped = 4'b0000;
    logic [3:0] key_synced = 4'b0000;

    always_ff @ (posedge clk) begin
        key_flipped <= ~key_n;
        key_synced <= key_flipped;
    end

    assign key_sync = key_synced;

endmodule
