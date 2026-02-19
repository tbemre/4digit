module hc595_driver(
    input wire clk,             // System Clock (50MHz)
    input wire rst,
    input wire [15:0] data_in,  // 16-bit Data (2 cascaded 595s)
    input wire start_send,
    output reg sclk,            // SH_CP
    output reg rclk,            // ST_CP
    output reg dio,             // DS
    output reg busy
    );

    localparam IDLE = 0;
    localparam SHIFT = 1;
    localparam LATCH = 2;

    reg [1:0] state;
    reg [4:0] bit_cnt;          // 0-15 (needs 4 bits? No, 0-15 is 16 items. 4 bits = 0..15. So [3:0] is enough? No, we might exceed. [4:0] is safe)
    reg [15:0] shift_reg;
    reg [5:0] clk_div;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            sclk <= 0;
            rclk <= 0;
            dio <= 0;
            busy <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            clk_div <= 0;
        end else begin
            // Clock Divider for SPI speed
            if (state != IDLE) begin
                if (clk_div == 49) clk_div <= 0; // 1MHz
                else clk_div <= clk_div + 1;
            end else begin
                clk_div <= 0;
            end

            case (state)
                IDLE: begin
                    rclk <= 0;
                    sclk <= 0;
                    busy <= 0;
                    if (start_send) begin
                        shift_reg <= data_in;
                        state <= SHIFT;
                        busy <= 1;
                        bit_cnt <= 0;
                    end
                end

                SHIFT: begin
                    if (clk_div == 25) begin
                        // Falling edge -> Prepare data
                        sclk <= 0;
                        dio <= shift_reg[15]; // MSB first (Bit 15)
                    end else if (clk_div == 49) begin
                        // Rising edge -> Shift
                        sclk <= 1;
                        shift_reg <= {shift_reg[14:0], 1'b0};
                        if (bit_cnt == 15) begin
                            state <= LATCH;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                LATCH: begin
                    if (clk_div == 25) rclk <= 1;
                    else if (clk_div == 49) begin
                        rclk <= 0;
                        state <= IDLE;
                        busy <= 0;
                    end
                end
            endcase
        end
    end
endmodule
