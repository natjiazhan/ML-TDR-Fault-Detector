// Outputs a 1-clock-cycle wide pulse when 'trigger' and 'enable' are asserted.

module pulse_gen (
    input  logic clk,
    input  logic rst,
    input  logic trigger,
    input  logic enable,
    output logic pulse_out
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        FIRE  = 2'b01
    } state_t;

    state_t state, next_state;

    // Next-state logic (case-based)
    always_comb begin
        case (state)
            IDLE:  next_state = (trigger & enable) ? FIRE : IDLE;
            FIRE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Sequential state update
    always_ff @(posedge clk) begin
        state <= rst ? IDLE : next_state;
    end

    assign pulse_out = (state == FIRE);

endmodule
