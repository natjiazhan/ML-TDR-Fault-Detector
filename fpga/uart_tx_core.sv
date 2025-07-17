// Module: uart_tx_core
// Description: Transmits 8-bit data via UART protocol (115200 baud at 50 MHz clock)
module uart_tx_core (
    input  logic clk,
    input  logic rst,
    input  logic [7:0] data_in,
    input  logic data_valid,
    output logic tx
);
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    logic [3:0] bit_idx;
    logic [7:0] shift_reg;
    logic [12:0] baud_cnt;
    logic tx_reg;

    parameter BAUD_DIV = 434; // 50 MHz / 115200 ~= 434

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            tx_reg    <= 1;
            shift_reg <= 0;
            bit_idx   <= 0;
            baud_cnt  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_reg   <= 1;
                    baud_cnt <= 0;
                    if (data_valid) begin
                        shift_reg <= data_in;
                        state     <= START;
                    end
                end
                START: begin
                    if (baud_cnt == BAUD_DIV) begin
                        baud_cnt <= 0;
                        tx_reg   <= 0; // start bit
                        bit_idx  <= 0;
                        state    <= DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                DATA: begin
                    if (baud_cnt == BAUD_DIV) begin
                        baud_cnt <= 0;
                        tx_reg   <= shift_reg[0];
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        bit_idx  <= bit_idx + 1;
                        if (bit_idx == 7) state <= STOP;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STOP: begin
                    if (baud_cnt == BAUD_DIV) begin
                        baud_cnt <= 0;
                        tx_reg   <= 1; // stop bit
                        state    <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
            endcase
        end
    end

    assign tx = tx_reg;

endmodule
