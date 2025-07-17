// Top-Level Module Declaration
module tdr_top (
    output logic led_reflect_00,
    output logic led_reflect_01,
    output logic led_reflect_10,
    output logic led_reflect_11,
    output logic pulse_led,
    input  logic clk,
    input  logic rst,           // universal reset (SW3)
    input  logic trigger_btn,   // trigger button
        output logic uart_tx        // UART TX line
);

    // Internal wires
    logic pulse;
    logic reflected_wave;
    logic [7:0] waveform_data;
    logic data_valid;

    // Pulse Generator: one-shot pulse when trigger is pressed
    pulse_gen u_pulse_gen (
        .clk(clk),
        .rst(rst),
        .trigger(trigger_btn),
        .pulse(pulse)
    );

    // TDR Transmission Line Simulation
    tdr_line_sim u_tdr_line_sim (
        .clk(clk),
        .rst(rst),
        .pulse_in(pulse),
        .reflect_type(2'b10), // short
        .reflect_delay(4'd5),
        .wave_out(reflected_wave)
    );

    // Waveform Capture and Encoding for UART
    waveform_capture u_waveform_capture (
        .clk(clk),
        .rst(rst),
        .wave_in(reflected_wave),
        .data_out(waveform_data),
        .data_valid(data_valid)
    );

    // Reflection LED latches (stay on after reflection detected)
    logic ref_detected_00, ref_detected_01, ref_detected_10, ref_detected_11;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ref_detected_00 <= 0;
            ref_detected_01 <= 0;
            ref_detected_10 <= 0;
            ref_detected_11 <= 0;
        end else begin
            // Only ref_detected_10 is updated in this hardcoded mode
            if (reflected_wave)
                ref_detected_10 <= 1;
        end
    end

    assign led_reflect_00 = ref_detected_00;
    assign led_reflect_01 = ref_detected_01;
    assign led_reflect_10 = ref_detected_10;
    assign led_reflect_11 = ref_detected_11;


    // Pulse LED
    assign pulse_led = pulse;

    // UART Transmitter
    uart_tx_core u_uart_tx (
        .clk(clk),
        .rst(rst),
        .data_in(waveform_data),
        .data_valid(data_valid),
        .tx(uart_tx)
    );

endmodule
