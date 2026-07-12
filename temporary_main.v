module temporary_main (
    input wire MAX10_CLK1_50, // Kartın üzerindeki ana 50 MHz saat kaynağı
    input wire [0:0] KEY,     // KEY[0] butonunu reset (sıfırlama) yapmak için kullanıyoruz

    // DE10-Lite Kartındaki İvmeölçer Sensörün Gerçek Pin İsimleri
    output wire GSENSOR_CS_N, // Sensörün Chip Select pini
    output wire GSENSOR_SCLK, // Sensörün SPI Clock pini
    output wire GSENSOR_SDI,  // Sensörün MOSI (Veri Giriş) pini
    input wire  GSENSOR_SDO,  // Sensörün MISO (Veri Çıkış) pini

    // Kartın Üzerindeki 7-Segment Display Çıkışları (Aktif Düşük - 0 ile yanar)
    output wire [6:0] HEX0,   // X ivmesinin en sağdaki basamağı (Bit [3:0])
    output wire [6:0] HEX1,   // X ivmesinin ikinci basamağı   (Bit [7:4])
    output wire [6:0] HEX2,   // X ivmesinin üçüncü basamağı   (Bit [11:8])
    output wire [6:0] HEX3    // X ivmesinin en soldaki basamağı (Bit [15:12])
);

    // Çiplerin kendi aralarında konuşabilmesi için sanal kablolar (wire) tanımlıyoruz
    wire spi_clk_wire;
    wire spi_start_wire;
    wire spi_done_wire;
    wire [15:0] data_to_master_wire;
    wire [15:0] data_from_master_wire;
    wire [15:0] ivme_x_wire;

    // =========================================================================
    // 1. ADIM: SAAT BÖLÜCÜ MODÜLÜ SAHAYA SÜRÜLÜYOR
    // =========================================================================
    clock_divider clk_div_inst (
        .clk_50mhz(MAX10_CLK1_50),   // Kartın 50MHz saatini bağladık
        .rst_n(KEY[0]),              // Reset butonunu bağladık
        .spi_clk(spi_clk_wire)       // Çıkan yavaş saati sanal kabloya verdik
    );

    // =========================================================================
    // 2. ADIM: SPI MASTER (KURYE ÇİPİ) SAHAYA SÜRÜLÜYOR
    // =========================================================================
    spi_master spi_master_inst (
        .clk(spi_clk_wire),
        .rst_n(KEY[0]),
        .start(spi_start_wire),
        .data_in(data_to_master_wire),
        .miso(GSENSOR_SDO),          // Gerçek MISO pinine bağlandı
        .mosi(GSENSOR_SDI),          // Gerçek MOSI pinine bağlandı
        .cs(GSENSOR_CS_N),           // Gerçek CS pinine bağlandı
        .sck(GSENSOR_SCLK),          // Gerçek SCLK pinine bağlandı
        .data_out(data_from_master_wire),
        .done(spi_done_wire)
    );

    // =========================================================================
    // 3. ADIM: ADXL345 CONTROLLER (BEYİN MODÜLÜ) SAHAYA SÜRÜLÜYOR
    // =========================================================================
    adxl345_controller controller_inst (
        .clk(spi_clk_wire),
        .rst_n(KEY[0]),
        .spi_done(spi_done_wire),
        .spi_data_in(data_from_master_wire),
        .spi_start(spi_start_wire),
        .spi_data_out(data_to_master_wire),
        .accel_x(ivme_x_wire)        // Sensörden sökülen 16 bitlik taze X verisi bu kabloda!
    );

    // =========================================================================
    // 4. ADIM: VERİYİ DISPLAY'LERE DAĞITMA VE ÇEVİRME
    // =========================================================================
    // 16 bitlik ivme_x_wire verisini 4'er bitlik parçalara bölüyoruz (Hexadecimal gösterim için)
    // Her bir parçayı kendi ekran çeviricisine gönderiyoruz.
    hex_to_7seg hex0_decoder (.hex_val(ivme_x_wire[3:0]),   .seg_out(HEX0));
    hex_to_7seg hex1_decoder (.hex_val(ivme_x_wire[7:4]),   .seg_out(HEX1));
    hex_to_7seg hex2_decoder (.hex_val(ivme_x_wire[11:8]),  .seg_out(HEX2));
    hex_to_7seg hex3_decoder (.hex_val(ivme_x_wire[15:12]), .seg_out(HEX3));

endmodule


// =========================================================================
// YARDIMCI MODÜL: 4 Bitlik Sayıyı 7 Çizgili Ekrana Çeviren Decoder (Kod Çözücü)
// =========================================================================
module hex_to_7seg (
    input wire [3:0] hex_val,
    output reg [6:0] seg_out
);
    always @(*) begin
        // DE10-Lite ekranları "Anode" yani Aktif-Düşüktür. 
        // Çizgiyi yakmak için '0', söndürmek için '1' vermek gerekir.
        case (hex_val)
            4'h0: seg_out = 7'b1000000; // 0
            4'h1: seg_out = 7'b1111001; // 1
            4'h2: seg_out = 7'b0100100; // 2
            4'h3: seg_out = 7'b0110000; // 3
            4'h4: seg_out = 7'b0011001; // 4
            4'h5: seg_out = 7'b0010010; // 5
            4'h6: seg_out = 7'b0000010; // 6
            4'h7: seg_out = 7'b1111000; // 7
            4'h8: seg_out = 7'b0000000; // 8
            4'h9: seg_out = 7'b0010000; // 9
            4'hA: seg_out = 7'b0001000; // A
            4'hB: seg_out = 7'b0000011; // b
            4'hC: seg_out = 7'b1000110; // C
            4'hD: seg_out = 7'b0100001; // d
            4'hE: seg_out = 7'b0000110; // E
            4'hF: seg_out = 7'b0001110; // F
            default: seg_out = 7'b1111111; // Hata durumunda hepsi sönük
        endcase
    end
endmodule