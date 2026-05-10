`timescale 1ns/1ps

module button_hold_detect # (
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic held
);
    localparam int CountMax = HOLD_CYCLES; 
    localparam int CountWidth = $clog2(CountMax + 1);

    logic count_rst;
    logic count_enable;
    logic [CountWidth - 1:0] count;

    mod_n_counter # (
        .N(CountMax + 1),
        .WIDTH(CountWidth)
    ) mod(
        .clk(clk),
        .rst(count_rst),
        .enable(count_enable),
        .count(count)
    );



    always_comb begin
        if (button) begin
            count_rst = 1'b0;
            if (count == CountWidth'(CountMax)) begin
                count_enable = 1'b0;
                held = 1'b1;
            end
            else begin
                count_enable = 1'b1;
                held = 1'b0; 
            end
        end
        else begin
            count_enable = 1'b0;
            held = 1'b0;
            count_rst = 1'b1;
        end
    end

endmodule 
