module adxl345_i2c_accel (
    input wire clk,
    input wire rst_n,
    inout wire sda,
    output wire scl,
    output reg [15:0] accel_x
);
    reg [8:0] div;
    wire tick = (div == 9'd124); 
    always @(posedge clk) begin
        if (tick) begin 
            div <= 0;
        end else begin 
            div <= div + 1;
        end
    end

    reg [5:0] state;
    reg [7:0] shift;
    reg [2:0] bit_idx;
    reg sda_reg, scl_reg, sda_dir;
    reg [7:0] data_x0;
    reg [15:0] delay_cnt;

    assign sda = sda_dir ? sda_reg : 1'bz;
    assign scl = scl_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 0;
            sda_reg <= 1; scl_reg <= 1; sda_dir <= 1;
            accel_x <= 0;
            delay_cnt <= 0;
        end else if (tick) begin
            case (state)
                0: begin sda_reg <= 1; scl_reg <= 1; sda_dir <= 1; state <= 1; end

                // BOLUM 1: SENSORU UYANDIR
                1: begin sda_reg <= 0; scl_reg <= 1; state <= 2; end 
                2: begin sda_reg <= 0; scl_reg <= 0; shift <= 8'h3A; bit_idx <= 7; state <= 3; end 
                3: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 4; end
                4: begin scl_reg <= 1; state <= 5; end
                5: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 6; end 
                    else begin bit_idx <= bit_idx - 1; state <= 3; end 
                end
                6: begin sda_dir <= 0; scl_reg <= 0; state <= 7; end 
                7: begin scl_reg <= 1; state <= 8; end
                8: begin scl_reg <= 0; sda_dir <= 1; shift <= 8'h2D; bit_idx <= 7; state <= 9; end 
                9: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 10; end
                10: begin scl_reg <= 1; state <= 11; end
                11: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 12; end 
                    else begin bit_idx <= bit_idx - 1; state <= 9; end 
                end
                12: begin sda_dir <= 0; scl_reg <= 0; state <= 13; end 
                13: begin scl_reg <= 1; state <= 14; end
                14: begin scl_reg <= 0; sda_dir <= 1; shift <= 8'h08; bit_idx <= 7; state <= 15; end 
                15: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 16; end
                16: begin scl_reg <= 1; state <= 17; end
                17: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 18; end 
                    else begin bit_idx <= bit_idx - 1; state <= 15; end 
                end
                18: begin sda_dir <= 0; scl_reg <= 0; state <= 19; end 
                19: begin scl_reg <= 1; state <= 20; end
                20: begin scl_reg <= 0; sda_dir <= 1; sda_reg <= 0; state <= 21; end 
                21: begin scl_reg <= 1; state <= 22; end 
                22: begin sda_reg <= 1; state <= 23; end

                23: begin
                    if (delay_cnt == 16'd500) begin
                        delay_cnt <= 0;
                        state <= 24;
                    end else begin 
                        delay_cnt <= delay_cnt + 1;
                    end
                end

                // BOLUM 2: IVMEYI OKU
                24: begin sda_reg <= 0; scl_reg <= 1; state <= 25; end 
                25: begin sda_reg <= 0; scl_reg <= 0; shift <= 8'h3A; bit_idx <= 7; state <= 26; end
                26: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 27; end
                27: begin scl_reg <= 1; state <= 28; end
                28: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 29; end 
                    else begin bit_idx <= bit_idx - 1; state <= 26; end 
                end
                29: begin sda_dir <= 0; scl_reg <= 0; state <= 30; end 
                30: begin scl_reg <= 1; state <= 31; end
                31: begin scl_reg <= 0; sda_dir <= 1; shift <= 8'h32; bit_idx <= 7; state <= 32; end 
                32: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 33; end
                33: begin scl_reg <= 1; state <= 34; end
                34: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 35; end 
                    else begin bit_idx <= bit_idx - 1; state <= 32; end 
                end
                35: begin sda_dir <= 0; scl_reg <= 0; state <= 36; end 
                36: begin scl_reg <= 1; state <= 37; end
                37: begin scl_reg <= 0; sda_dir <= 1; sda_reg <= 1; state <= 38; end

                38: begin scl_reg <= 1; sda_reg <= 1; state <= 39; end 
                39: begin sda_reg <= 0; scl_reg <= 1; state <= 40; end
                40: begin sda_reg <= 0; scl_reg <= 0; shift <= 8'h3B; bit_idx <= 7; state <= 41; end 
                41: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 42; end
                42: begin scl_reg <= 1; state <= 43; end
                43: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 44; end 
                    else begin bit_idx <= bit_idx - 1; state <= 41; end 
                end
                44: begin sda_dir <= 0; scl_reg <= 0; state <= 45; end 
                45: begin scl_reg <= 1; state <= 46; end
                46: begin scl_reg <= 0; sda_dir <= 0; bit_idx <= 7; state <= 47; end

                47: begin scl_reg <= 0; state <= 48; end
                48: begin scl_reg <= 1; shift[bit_idx] <= sda; state <= 49; end
                49: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 50; end 
                    else begin bit_idx <= bit_idx - 1; state <= 47; end 
                end
                50: begin sda_dir <= 1; sda_reg <= 0; scl_reg <= 0; state <= 51; end 
                51: begin scl_reg <= 1; data_x0 <= shift; state <= 52; end
                52: begin scl_reg <= 0; sda_dir <= 0; bit_idx <= 7; state <= 53; end

                53: begin scl_reg <= 0; state <= 54; end
                54: begin scl_reg <= 1; shift[bit_idx] <= sda; state <= 55; end
                55: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 56; end 
                    else begin bit_idx <= bit_idx - 1; state <= 53; end 
                end
                56: begin sda_dir <= 1; sda_reg <= 1; scl_reg <= 0; state <= 57; end 
                
                57: begin scl_reg <= 1; accel_x <= {shift, data_x0}; state <= 58; end 
                
                58: begin scl_reg <= 0; sda_reg <= 0; state <= 59; end
                59: begin scl_reg <= 1; state <= 60; end 
                60: begin sda_reg <= 1; state <= 61; end

                61: begin
                    if (delay_cnt == 16'd2000) begin
                        delay_cnt <= 0;
                        state <= 24; 
                    end else begin 
                        delay_cnt <= delay_cnt + 1;
                    end
                end

                default: begin 
                    state <= 0; 
                end
            endcase
        end
    end
endmodule