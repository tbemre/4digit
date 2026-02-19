`timescale 1ns / 1ps

module button_debounce(
    input clk,
    input btn_in,
    output reg btn_state,
    output wire btn_down
    );

    // 50 MHz clock
    // Wait ~10ms for debounce
    // 10ms / 20ns = 500,000 cycles
    
    reg [18:0] count;
    reg btn_sync_0, btn_sync_1;
    
    always @(posedge clk) begin
        // Synchronize input to avoid metastability
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;
    end

    always @(posedge clk) begin
        if (btn_state != btn_sync_1) begin
            count <= count + 1;
            if (count == 500000) begin
                btn_state <= btn_sync_1;
                count <= 0;
            end
        end else begin
            count <= 0;
        end
    end

    // Detect rising edge of stable state
    reg btn_state_prev;
    always @(posedge clk) begin
        btn_state_prev <= btn_state;
    end
    
    assign btn_down = btn_state & ~btn_state_prev;

endmodule
