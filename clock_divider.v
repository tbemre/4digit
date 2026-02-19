`timescale 1ns / 1ps

module clock_divider(
    input clk,          // 50 MHz
    input rst,
    output reg tick_scan,  // For multiplexing (~1 kHz)
    output reg tick_count  // For counter increment (~10 Hz or 1 Hz)
    );

    // Scan Clock: 1 kHz -> 50,000 counts
    reg [15:0] cnt_scan;
    
    // Count Clock: 1 Hz -> 50,000,000 counts (Need 26 bits)
    reg [25:0] cnt_timer;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_scan <= 0;
            tick_scan <= 0;
            cnt_timer <= 0;
            tick_count <= 0;
        end else begin
            // Scan Tick Generation
            if (cnt_scan == 49999) begin
                cnt_scan <= 0;
                tick_scan <= 1;
            end else begin
                cnt_scan <= cnt_scan + 1;
                tick_scan <= 0;
            end
            
            // Count Tick Generation (e.g. 10Hz for faster test, or change to 4999999 for 10Hz)
            // Let's make it visible: 10Hz is good for stopwatch feel, 1Hz for clock
            // 1 Hz Generation (50,000,000 cycles)
            if (cnt_timer == 49999999) begin
                cnt_timer <= 0;
                tick_count <= 1;
            end else begin
                cnt_timer <= cnt_timer + 1;
                tick_count <= 0;
            end
        end
    end
endmodule
