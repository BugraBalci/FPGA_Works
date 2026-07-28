module main (
    input  wire clk, 
    input  wire buton,
    input  wire [8:0] SW,
    output wire [9:0] LEDR,
    
    // I2C Pinleri
    output wire GSENSOR_CS_N,
    output wire GSENSOR_SCLK,
    inout  wire GSENSOR_SDI,
    input  wire GSENSOR_SDO,
    
    // Ekran Pinleri
    output wire [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

    // =========================================================================
    // 0. SABİT DONANIM BAĞLANTILARI
    // =========================================================================
    assign GSENSOR_CS_N = 1'b1; 
    assign LEDR[2] = buton;     
    assign LEDR[9:3] = 7'b0000000;
    assign LEDR[1:0] = 2'b00;

    // =========================================================================
    // 1. KULLANICI GİRİŞ KONTROLCÜSÜ (Şalterler)
    // =========================================================================
    wire [5:0] lock_letter_wire;
    wire [2:0] lock_display_wire;

    user_input_manager giris_paneli (
        .clk(clk),
        .buton(buton),
        .sw_letter(SW[5:0]),
        .sw_display(SW[8:6]),
        .lock_letter(lock_letter_wire),
        .lock_display(lock_display_wire)
    );

    // =========================================================================
    // 2. I2C SENSÖR MOTORU (İvme Okuyucu)
    // =========================================================================
    wire [15:0] accel_x_wire;

    adxl345_i2c_accel i2c_motor (
        .clk(clk),
        .rst_n(buton),
        .sda(GSENSOR_SDI),   
        .scl(GSENSOR_SCLK),  
        .accel_x(accel_x_wire)
    );
    
    // =========================================================================
    // 3. MATEMATİK VE FİLTRE MOTORU (Amortisör & BCD)
    // =========================================================================
    wire is_negative_wire;
    wire [15:0] abs_val_wire; // Kullanmasak da bağlı dursun
    wire [3:0] d2_wire, d1_wire, d0_wire;

    average_acceleration avg_acc(
        .clk(clk),
        .rst_n(buton),
        .current_acceleration(accel_x_wire),
        .is_negative(is_negative_wire),
        .absolutely_acceleration(abs_val_wire),
        .digit2(d2_wire),
        .digit1(d1_wire),
        .digit0(d0_wire)
    );
    
    // =========================================================================
    // 4. TRAFİK POLİSİ (Yönlendirici MUX Modülü)
    // =========================================================================
    wire [5:0] print_id5, print_id4, print_id3, print_id2, print_id1, print_id0;
    wire [5:0] print_dp;

    mode_router trafik_polisi (
        .is_negative(is_negative_wire),
        .digit2(d2_wire),
        .digit1(d1_wire),
        .digit0(d0_wire),
        .lock_letter(lock_letter_wire),
        .lock_display(lock_display_wire),
        
        // Çıkan paketi Ekran Sekreterinin kablolarına bağlıyoruz
        .out_id5(print_id5), .out_id4(print_id4), .out_id3(print_id3),
        .out_id2(print_id2), .out_id1(print_id1), .out_id0(print_id0),
        .out_dp(print_dp)
    );

    // =========================================================================
    // 5. EKRAN SEKRETERİ (Printf Motoru)
    // =========================================================================
    print_display ekran_surucusu (
        .clk(clk),
        .id5(print_id5), .id4(print_id4), .id3(print_id3),
        .id2(print_id2), .id1(print_id1), .id0(print_id0),
        .dp_en(print_dp), 
        .HEX5(HEX5), .HEX4(HEX4), .HEX3(HEX3),
        .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0)
    );

endmodule