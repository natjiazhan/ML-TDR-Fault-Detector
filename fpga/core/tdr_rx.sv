// tdr_rx.sv
// Samples the reflected signal coming back through the delay line.

module tdr_rx (
    input  logic clk,
    input  logic rst,
    input  logic reflected_signal,
    input  logic sample_en,
    output logic sampled_value
);

    always_ff @(posedge clk) begin
        sampled_value <= (rst) ? 1'b0 : (sample_en ? reflected_signal : sampled_value);
    end

endmodule
