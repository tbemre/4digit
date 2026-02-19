module top_module(
    input clk,
    input btn_rst,
    output sclk,
    output rclk,
    output dio,
    output buzzer
    );

    wire rst;
    assign rst = btn_rst;

    wire tick_scan;
    wire tick_count;
    
    wire [3:0] dig0, dig1, dig2, dig3;
    wire [15:0] shift_data;
    wire update_req;
    reg update_reg_latched;
    wire driver_busy;

    // 1. Clock Divider
    clock_divider u_clk_div (
        .clk(clk),
        .rst(rst),
        .tick_scan(tick_scan),
        .tick_count(tick_count)
    );

    // 2. Counter (0000-9999)
    counter_4digit u_counter (
        .clk(clk),
        .rst(rst),
        .tick_count(tick_count),
        .dig0(dig0),
        .dig1(dig1),
        .dig2(dig2),
        .dig3(dig3)
    );

    // 3. Scanner & Data Formatter
    display_scanner u_scanner (
        .clk(clk),
        .rst(rst),
        .tick_scan(tick_scan),
        .d0(dig0), .d1(dig1), .d2(dig2), .d3(dig3),
        .shift_data(shift_data),
        .update_req(update_req)
    );

    // 4. Driver Logic
    // Only start sending if driver is free and we have a request
    // Scanner produces update_req pulse (1 cycle).
    // If driver is busy, we might miss it. But scan speed << shift speed.
    // Shift: 16 bits * 50us = ~800us. Scan: 1ms. Close call.
    // Let's ensure shift is fast enough. 1MHz sclk -> 16us + overhead.
    // 16us is much faster than 1ms scan interval. So we should be fine catching every request.
    
    // 5. 74HC595 Driver
    hc595_driver u_driver (
        .clk(clk),
        .rst(rst),
        .data_in(shift_data),
        .start_send(update_req), // Directly trigger from scanner
        .sclk(sclk),
        .rclk(rclk),
        .dio(dio),
        .busy(driver_busy)
    );

    // 6. Alarm Module
    alarm_module u_alarm (
        .clk(clk),
        .rst(rst),
        .d0(dig0), .d1(dig1), .d2(dig2), .d3(dig3),
        .buzzer(buzzer)
    );

endmodule

