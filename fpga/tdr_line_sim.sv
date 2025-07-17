// Module: tdr_line_sim
// Description: Simulates a digital transmission line with reflections at a configurable delay
module tdr_line_sim (
    input  logic clk,
    input  logic rst,
    input  logic pulse_in,
    input  logic [1:0] reflect_type,
    input  logic [3:0] reflect_delay,
    output logic wave_out
);
    logic [15:0] line; // delay line (circular shift register)
    logic [3:0]  delay_cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            line <= 0;
            delay_cnt <= 0;
        end else begin
            // Shift in the pulse or 0 each cycle
            line <= {line[14:0], pulse_in};

            // Track delay to inject reflection
            if (pulse_in)
                delay_cnt <= reflect_delay;
            else if (delay_cnt != 0)
                delay_cnt <= delay_cnt - 1;

            // Inject reflection at delay point
            if (delay_cnt == 1) begin
                unique case (reflect_type)
                    2'b01: line[0] <= 1;       // Open = positive reflection
                    2'b10: line[0] <= ~line[1]; // Short = inverted reflection
                    2'b11: line[0] <= line[1];  // Multi = repeated echo
                    default: ;                 // No reflection
                endcase
            end
        end
    end

    assign wave_out = line[15]; // Tap the output end of the line

endmodule
