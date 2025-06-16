// tdr_core.sv
// Coordinates pulse generation, transmission, delay, and reflection sampling.

module tdr_core #(
    parameter DELAY_CYCLES = 64
)(
    input  logic clk,
    input  logic rst,
    input  logic trigger,
    input  logic enable,

    output logic pulse_out,        // Raw pulse from pulse_gen (for monitoring)
    output logic tx_drive,         // Output into the delay line
    output logic sample_valid,     // Indicates when sampled_value is valid
    output logic sampled_value     // Captured reflection value
);

    // Internal signals
    logic pulse;
    logic delay_out;
    logic reflected_signal;
    logic sample_en;

    // 1. Generate a 1-cycle pulse
    pulse_gen pulse_gen_inst (
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .enable(enable),
        .pulse_out(pulse)
    );

    // 2. Drive the pulse into the transmission line
    tdr_tx tdr_tx_inst (
        .clk(clk),
        .rst(rst),
        .pulse_in(pulse),
        .tx_out(tx_drive)
    );

    // 3. Simulate signal propagation and reflection
    delay_line #(.DELAY(DELAY_CYCLES)) delay_line_inst (
        .clk(clk),
        .rst(rst),
        .in_signal(tx_drive),
        .out_signal(reflected_signal)
    );

    // 4. Enable sampling DELAY_CYCLES after pulse
    typedef enum logic [1:0] {
        IDLE,
        WAIT_DELAY,
        SAMPLE
    } state_t;

    state_t state, next_state;
    logic [$clog2(DELAY_CYCLES+1)-1:0] counter;

    // FSM: state update
    always_ff @(posedge clk) begin
        state   <= rst ? IDLE : next_state;
        counter <= (state == WAIT_DELAY) ? counter + 1 : '0;
    end

    // FSM: next state logic
    always_comb begin
        case (state)
            IDLE:       next_state = (pulse && enable) ? WAIT_DELAY : IDLE;
            WAIT_DELAY: next_state = (counter == DELAY_CYCLES - 1) ? SAMPLE : WAIT_DELAY;
            SAMPLE:     next_state = IDLE;
            default:    next_state = IDLE;
        endcase
    end

    assign sample_en     = (state == SAMPLE);
    assign sample_valid  = sample_en;
    assign pulse_out     = pulse;

    // 5. Sample the reflected signal
    tdr_rx tdr_rx_inst (
        .clk(clk),
        .rst(rst),
        .reflected_signal(reflected_signal),
        .sample_en(sample_en),
        .sampled_value(sampled_value)
    );

endmodule
