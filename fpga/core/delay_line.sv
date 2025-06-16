// delay_line.sv
// Simulates signal propagation through a transmission line using a shift register.

module delay_line #(
    parameter DELAY = 64
)(
    input  logic clk,
    input  logic rst,
    input  logic in_signal,
    output logic out_signal
);

    logic [DELAY-1:0] shift_reg;

    always_ff @(posedge clk) begin
        if (rst)
            shift_reg <= '0;
        else
            shift_reg <= {shift_reg[DELAY-2:0], in_signal};
    end

    assign out_signal = shift_reg[DELAY-1];

endmodule
