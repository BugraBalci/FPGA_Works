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

    wire [5:0] master_decoder = SW[5:0];
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
            lock_letter  <= master_decoder; 
            lock_display <= display_section;  
        end
    end

    // =========================================================================
    // SİSTEM A: HARFLER
    // =========================================================================
    wire [7:0] connection_cable;
    wire [7:0] sysA_hex5, sysA_hex4, sysA_hex3, sysA_hex2, sysA_hex1, sysA_hex0;

    master_decoder letter_motor (
        .id_input(lock_letter),
        .code_output(connection_cable)
    );

    display_section distributor_motor (
        .display_section(lock_display),
        .code_output_input(connection_cable), 
        .HEX5(sysA_hex5),
        .HEX4(sysA_hex4),
        .HEX3(sysA_hex3),
        .HEX2(sysA_hex2),
        .HEX1(sysA_hex1),
        .HEX0(sysA_hex0)
    );
	 
	
	 

    // =========================================================================
    // SİSTEM B: İVMEÖLÇER
    // =========================================================================
    wire [15:0] accel_x_wire;
    wire [7:0]  sysB_hex3, sysB_hex2, sysB_hex1, sysB_hex0; // DÜZELTİLDİ: 8-Bit (7:0) oldular!
	 wire [15:0] abs_val;
	 wire is_negative;

    adxl345_i2c_accel i2c_motor (
        .clk(clk),
        .rst_n(buton),
        .sda(GSENSOR_SDI),   
        .scl(GSENSOR_SCLK),  
        .accel_x(accel_x_wire)
    );
	 
	 
	 average_acceleration avg_acc(
			.rst_n(buton),
			.clk(clk),
			.current_acceleration(accel_x_wire),
			.is_negative(is_negative),
			.absolutely_acceleration(abs_val)
	 );
	 
	 
	 //artık verilerin işlenmesi lazım ve o şekilde dönüp kullanılması lazım
	 wire [3:0] digit2 = (abs_val / 100) % 10; // Yüzler basamağı
    wire [3:0] digit1 = (abs_val / 10)  % 10; // Onlar basamağı
    wire [3:0] digit0 = (abs_val)       % 10; // Birler basamağı
	 
	 // Eksi işareti çıkacak mı? (Eksiyse 18. kod, Artıysa 19. kod)
	 wire [5:0] sign_code = is_negative ? 6'd37 : 6'd38; // is_negatif
	 
	 

    master_decoder h0 (.id_input({2'b00, digit0}),  .code_output(sysB_hex0));
    master_decoder h1 (.id_input({2'b00, digit1}),  .code_output(sysB_hex1));
    master_decoder h2 (.id_input({2'b00, digit2}),  .code_output(sysB_hex2));
    master_decoder h3 (.id_input(sign_code), .code_output(sysB_hex3));

    // =========================================================================
    // DECODER ILE DISPLAYE HANGİ SECENEGİN GİDECEİĞİBİ BELİRLER
	 // =========================================================================
	 // =========================================================================
    // TRAFİK POLİSİ (MUX) - YENİ VIP ÖNCELİK SİSTEMİ
    // =========================================================================
    
    // =========================================================================
    // TRAFİK POLİSİ (MUX)
    // =========================================================================
    // 1. KURAL: Hata var mı? (Adam 6 veya 7 numaralı ekranı mı seçmiş?)
    //wire hata_var_mi = (lock_display == 3'd6 || lock_display == 3'd7);
    
    // 2. KURAL: Sensör sadece şalter 63'teyse VE HATA YOKSA aktif olsun!&& !hata_var_mi
    wire sensor_aktif_mi = (lock_letter == 6'd63) ;
    
    assign HEX0 = sensor_aktif_mi ? sysB_hex0 : sysA_hex0;
    assign HEX1 = sensor_aktif_mi ? sysB_hex1 : sysA_hex1;
    assign HEX2 = sensor_aktif_mi ? sysB_hex2 : sysA_hex2;
    assign HEX3 = sensor_aktif_mi ? sysB_hex3 : sysA_hex3;
    
    assign HEX4 = sensor_aktif_mi ? 8'b11111111 : sysA_hex4;
    assign HEX5 = sensor_aktif_mi ? 8'b11111111 : sysA_hex5;

endmodule