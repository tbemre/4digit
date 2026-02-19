`timescale 1ns / 1ps

module display_scanner(
    input clk,
    input rst,
    input tick_scan,        // Switch to next digit
    input [3:0] d0,         // Digit 0 value
    input [3:0] d1,         // Digit 1 value
    input [3:0] d2,         // Digit 2 value
    input [3:0] d3,         // Digit 3 value
    output reg [15:0] shift_data, // {Digit_Sel[7:0], Segments[7:0]} or similar
    output reg update_req   // Pulse to trigger shift register send
    );

    reg [1:0] scan_idx;     // 0..3
    reg [7:0] segments;
    reg [7:0] digit_sel;
    reg [3:0] current_hex;

    // Hex to 7-Segment ROM
    always @(*) begin
        case(current_hex)
            //                        p g f e d c b a
            4'h0: segments = 8'b00111111; // 0
            4'h1: segments = 8'b00000110; // 1
            4'h2: segments = 8'b01011011; // 2
            4'h3: segments = 8'b01001111; // 3
            4'h4: segments = 8'b01100110; // 4
            4'h5: segments = 8'b01101101; // 5
            4'h6: segments = 8'b01111101; // 6
            4'h7: segments = 8'b00000111; // 7
            4'h8: segments = 8'b01111111; // 8
            4'h9: segments = 8'b01101111; // 9
            default: segments = 8'b00000000;
        endcase
    end

    // Scanner Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_idx <= 0;
            update_req <= 0;
            shift_data <= 0;
            current_hex <= 0;
            digit_sel <= 8'b11111111; // All off (Common Cathode -> Active Low)
        end else begin
            update_req <= 0; // Default

            if (tick_scan) begin
                scan_idx <= scan_idx + 1;
                update_req <= 1; // Trigger update on every scan tick
                
                // Prepare data for the NEXT state (or current, depending on timing)
                // Let's calculate for the new scan_idx
                case (scan_idx) // Current scan_idx before increment? No, inside non-blocking it uses old value.
                                // Actually, let's look at logic:
                                // tick_scan -> scan_idx increments. 
                                // We want to output data for the *new* scan_idx? 
                                // Or we can optimize: just cycle through.
                    2'b00: begin // Digit 0
                        current_hex <= d0;
                        digit_sel <= 8'b11111110; // Select Digit 0 (Rightmost)
                    end
                    2'b01: begin // Digit 1
                        current_hex <= d1;
                        digit_sel <= 8'b11111101;
                    end
                    2'b10: begin // Digit 2
                        current_hex <= d2;
                        digit_sel <= 8'b11111011;
                    end
                    2'b11: begin // Digit 3
                        current_hex <= d3;
                        digit_sel <= 8'b11110111; // Select Digit 3 (Leftmost)
                    end
                endcase
            end
            
            // Format 16-bit packet
            // High Byte: Digit Selection (connected to 2nd 74HC595?) 
            // Low Byte: Segment Data (connected to 1st 74HC595?)
            // This depends on wiring. Assuming:
            // SDO(FPGA) -> DS(595_1 Segment) -> Q7'(595_1) -> DS(595_2 Digit)
            // So first shifted byte ends up in 595_2 (Digit), second in 595_1 (Segment).
            // Data format: {Segment, Digit} vs {Digit, Segment}
            // If we shift MSB first:
            // We shift 16 bits. Bit 15 goes first.
            // Bit 15...8 will end up in the LAST register (chain end)? No.
            // Shift register: 
            // In -> [0] ... [7] -> Out
            // If we shift 16 bits:
            // Bit 0 enters first, pushed to end. Bit 15 enters last, stays at start.
            // Wait, standard MSB first driver:
            // Sends Bit 15 first. It travels through Reg1 to Reg2.
            // So Bit 15 ends up in Reg2's MSB (or LSB depending on connection).
            // Usually: Last sent bit (Bit 0) stays in first register. First sent bit (Bit 15) goes to last register.
            
            // Let's assume:
            // Register 2 (Far end) = Digit Select
            // Register 1 (Near end) = Segments
            // So we want Digit Select in High Byte, Segments in Low Byte.
            // Driver sends [15] first. 
            // [15..8] (Digits) -> pushes through -> ends in Reg 2.
            // [7..0] (Segments) -> stays in Reg 1.
             
            shift_data <= {digit_sel, segments};
        end
    end

endmodule
