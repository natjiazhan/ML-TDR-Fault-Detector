// reflection_model.sv
// Models transmission line terminations: matched, open, short, and multi-reflection.

module reflection_model #(
    parameter MULTI_DELAY_1 = 8,   // Delay for first reflection in 'multi' mode
    parameter MULTI_DELAY_2 = 16   // Delay for second reflection in 'multi' mode
)(
    input  logic clk,
    input  logic rst,
    input  logic in_signal,          // Incoming signal at the far end of the line
    input  logic [1:0] reflect_type, // 00: matched, 01: open, 10: short, 11: multi
    output logic reflected_signal    // Reflected waveform back toward source
);

    // Basic open/short logic
    logic open_reflect, short_reflect;

    assign open_reflect  = in_signal;     // Open = reflect with same polarity
    assign short_reflect = ~in_signal;    // Short = reflect inverted

    // Multi-reflection buffers (two delayed echoes)
    logic [MULTI_DELAY_1-1:0] echo1;
    logic [MULTI_DELAY_2-1:0] echo2;

    always_ff @(posedge clk) begin
        if (rst) begin
            echo1 <= '0;
            echo2 <= '0;
        end else begin
            echo1 <= {echo1[MULTI_DELAY_1-2:0], in_signal};
            echo2 <= {echo2[MULTI_DELAY_2-2:0], in_signal};
        end
    end

    // Multi = OR of both echoes (simple model of dispersion/reflection)
    logic multi_reflect;
    assign multi_reflect = echo1[MULTI_DELAY_1-1] | echo2[MULTI_DELAY_2-1];

    // Final output: select based on mode
    always_comb begin
        case (reflect_type)
            2'b00: reflected_signal = 1'b0;          // Matched = no reflection
            2'b01: reflected_signal = open_reflect;  // Open
            2'b10: reflected_signal = short_reflect; // Short
            2'b11: reflected_signal = multi_reflect; // Multi
            default: reflected_signal = 1'b0;
        endcase
    end

endmodule
