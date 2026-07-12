module main (
    // Ortak Saat ve Buton/Salterler
    input wire clk, 
    input wire buton,
    input wire [8:0] SW,
    output wire [9:0] LEDR,
    
    // I2C Pinleri
    output wire GSENSOR_CS_N,
    output wire GSENSOR_SCLK,
    inout  wire GSENSOR_SDI,
    input  wire GSENSOR_SDO,
    
    // Ekran Pinleri
    output wire [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

    assign GSENSOR_CS_N = 1'b1; 
    assign LEDR[2] = buton;     

    wire [5:0] letter_selection = SW[5:0];
    wire [2:0] display_section  = SW[8:6];
    
    reg buton_r1, buton_r2;
    always @(posedge clk) begin
        buton_r1 <= buton;
        buton_r2 <= buton_r1;
    end
    wire falling_edge = (buton_r2 == 1'b1) && (buton_r1 == 1'b0);

    reg [5:0] lock_letter;
    reg [2:0] lock_display;

    always @(posedge clk) begin
        if (falling_edge) begin
            lock_letter  <= letter_selection; 
            lock_display <= display_section;  
        end
    end

    wire [7:0] connection_cable;
    wire [7:0] sysA_hex5, sysA_hex4, sysA_hex3, sysA_hex2, sysA_hex1, sysA_hex0;

    letter_selection letter_motor (
        .letter_id(lock_letter),
        .letter_code(connection_cable)
    );

    display_section distributor_motor (
        .display_section(lock_display),
        .letter_code_input(connection_cable),
        .HEX5(sysA_hex5),
        .HEX4(sysA_hex4),
        .HEX3(sysA_hex3),
        .HEX2(sysA_hex2),
        .HEX1(sysA_hex1),
        .HEX0(sysA_hex0)
    );

    wire [15:0] accel_x_wire;
    wire [6:0]  sysB_hex3, sysB_hex2, sysB_hex1, sysB_hex0;

    adxl345_i2c_accel i2c_motor (
        .clk(clk),
        .rst_n(buton),
        .sda(GSENSOR_SDI),   
        .scl(GSENSOR_SCLK),  
        .accel_x(accel_x_wire)
    );

    hex_to_7seg h0 (.hex_val(accel_x_wire[3:0]),   .seg_out(sysB_hex0));
    hex_to_7seg h1 (.hex_val(accel_x_wire[7:4]),   .seg_out(sysB_hex1));
    hex_to_7seg h2 (.hex_val(accel_x_wire[11:8]),  .seg_out(sysB_hex2));
    hex_to_7seg h3 (.hex_val(accel_x_wire[15:12]), .seg_out(sysB_hex3));

    wire sensor_is_active = (lock_letter == 6'd63);
    
    assign HEX0 = sensor_is_active ? sysB_hex0 : sysA_hex0;
    assign HEX1 = sensor_is_active ? sysB_hex1 : sysA_hex1;
    assign HEX2 = sensor_is_active ? sysB_hex2 : sysA_hex2;
    assign HEX3 = sensor_is_active ? sysB_hex3 : sysA_hex3;
    assign HEX4 = sensor_is_active ? 8'b11111111 : sysA_hex4;
    assign HEX5 = sensor_is_active ? 8'b11111111 : sysA_hex5;

endmodule


module hex_to_7seg (
    input wire [3:0] hex_val, 
    output reg [6:0] seg_out  
);
    always @(*) begin
        case (hex_val)
            4'h0: seg_out = 8'b11000000;
            4'h1: seg_out = 8'b11111001;
            4'h2: seg_out = 8'b10100100;
            4'h3: seg_out = 8'b10110000;
            4'h4: seg_out = 8'b10011001;
            4'h5: seg_out = 8'b10010010;
            4'h6: seg_out = 8'b10000010;
            4'h7: seg_out = 8'b11111000;
            4'h8: seg_out = 8'b10000000;
            4'h9: seg_out = 8'b10010000;
            4'hA: seg_out = 8'b10001000;
            4'hB: seg_out = 8'b10000011;
            4'hC: seg_out = 8'b11000110;
            4'hD: seg_out = 8'b10100001;
            4'hE: seg_out = 8'b10000110;
            4'hF: seg_out = 8'b10001110;
            default: seg_out = 8'b11111111;
        endcase
    end
endmodule