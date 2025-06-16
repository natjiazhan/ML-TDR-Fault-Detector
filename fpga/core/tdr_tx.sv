// tdr_tx.sv
// Buffers and drives the launch pulse into the transmission line.

module tdr_tx (
    input  logic clk,
    input  logic rst,
    input  logic pulse_in,
    output logic tx_out
);

    // Simple registered output to drive the delay line
    always_ff @(posedge clk) begin
        tx_out <= rst ? 1'b0 : pulse_in;
    end

endmodule
