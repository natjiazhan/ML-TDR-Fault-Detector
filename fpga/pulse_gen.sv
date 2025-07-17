// Module: pulse_gen
// Description: Generates a single-cycle pulse on trigger
module pulse_gen (
    input  logic clk,
    input  logic rst,
    input  logic trigger,
    output logic pulse
);
    logic trigger_d;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            trigger_d <= 0;
            pulse     <= 0;
        end else begin
            trigger_d <= trigger;
            pulse     <= trigger & ~trigger_d; // rising edge detect
        end
    end
endmodule
