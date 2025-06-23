module tdr_demo_top (
    input  logic clk,
    input  logic rst,
    input  logic trigger_btn,          // External pushbutton or switch
    input  logic [1:0] reflect_type,   // Select reflection type
    output logic sample_led,           // Lights up when sample is 1
    output logic pulse_led             // Lights up when launch pulse is sent
);

    // Internal wires
    logic pulse, tx, reflected, sample_valid, sampled;

    // Main TDR controller
    tdr_core #(.DELAY_CYCLES(64)) core_inst (
        .clk(clk),
        .rst(rst),
        .trigger(trigger_btn),
        .enable(1'b1),
        .reflected_signal(reflected),
        .pulse_out(pulse),
        .tx_drive(tx),
        .sample_valid(sample_valid),
        .sampled_value(sampled)
    );

    // Reflection model simulates DUT response
    reflection_model #(
        .MULTI_DELAY_1(8),
        .MULTI_DELAY_2(16)
    ) reflect_inst (
        .clk(clk),
        .rst(rst),
        .in_signal(tx),
        .reflect_type(reflect_type),
        .reflected_signal(reflected)
    );

    // LED indicators
    assign pulse_led  = pulse;
    assign sample_led = sampled;

endmodule
