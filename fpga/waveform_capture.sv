// Module: waveform_capture
// Description: Converts digital wave into UART-suitable data stream
module waveform_capture (
    input  logic clk,
    input  logic rst,
    input  logic wave_in,
    output logic [7:0] data_out,
    output logic data_valid
);
    logic [7:0] shift_buf;
    logic [2:0] bit_cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_buf  <= 0;
            bit_cnt    <= 0;
            data_valid <= 0;
        end else begin
            shift_buf <= {shift_buf[6:0], wave_in};
            bit_cnt   <= bit_cnt + 1;

            if (bit_cnt == 7) begin
                data_out   <= shift_buf;
                data_valid <= 1;
            end else begin
                data_valid <= 0;
            end
        end
    end
endmodule
