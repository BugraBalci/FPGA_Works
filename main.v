module led_yakma (
    input wire clk,           // FPGA sistem saati 50MHz
    input wire buton,
    input wire [7:0] SW,
    output reg [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

    wire [4:0] kelime_secimi = SW[4:0];
    wire [2:0] ekran_secimi  = SW[7:5];
    wire [7:0] baglanti_kablosu; 
    
	 
    // Kart ilk açıldığında tüm register'ların 0 (Tamamen Yanık) 
    // olmasını engellemek için başlangıçta hepsini 1 (Sönük) yapıyoruz.
    initial begin
        HEX5 = 8'b1111_1111;
        HEX4 = 8'b1111_1111;
        HEX3 = 8'b1111_1111;
        HEX2 = 8'b1111_1111;
        HEX1 = 8'b1111_1111;
        HEX0 = 8'b1111_1111;
    end

    reg buton_sync1, buton_sync2;
    always @(posedge clk) begin
        buton_sync1 <= buton;
        buton_sync2 <= buton_sync1;
    end

    // Butonun 1'den 0'a düşme anını (basılma anı) yakala düşen kenar 
    wire buton_dustu = (buton_sync2 == 1'b1 && buton_sync1 == 1'b0);
     
    // ALT MODÜLÜ ÇAĞIRMA 
    letter_selection harf_motoru (
        .harf_id(kelime_secimi),     
        .harf_kodu(baglanti_kablosu) 
    );

    always @(posedge clk) begin
        if (buton_dustu) begin
            // Ekranları yeni kelime için temizle (Sönük hale getir)
            HEX5 <= 8'b1111_1111;
            HEX4 <= 8'b1111_1111;
            HEX3 <= 8'b1111_1111;
            HEX2 <= 8'b1111_1111;
            HEX1 <= 8'b1111_1111;
            HEX0 <= 8'b1111_1111;

            // Şalter kombinasyonlarına göre kelimeleri ekrana bas
            if (kelime_secimi == 5'd28) begin
                HEX5 <= 8'b1010_1011; // m
                HEX4 <= 8'b1100_0001; // u
                HEX3 <= 8'b1001_0010; // s
                HEX2 <= 8'b1000_0111; // t
                HEX1 <= 8'b1111_1001; // i
                HEX0 <= 8'b0111_1111; // .
            end
            else if (kelime_secimi == 5'd29) begin
                HEX5 <= 8'b1111_1111; // Sönük
                HEX4 <= 8'b1000_0011; // b
                HEX3 <= 8'b1100_0001; // U
                HEX2 <= 8'b1001_0000; // g
                HEX1 <= 8'b1010_1111; // r
                HEX0 <= 8'b1000_1000; // A
            end
            else if (kelime_secimi == 5'd30) begin
                HEX5 <= 8'b1000_1000; // A
                HEX4 <= 8'b1100_0111; // L
                HEX3 <= 8'b1100_1111; // I
            end
            else if (kelime_secimi == 5'd31) begin
                HEX5 <= 8'b1001_0010; // S
                HEX4 <= 8'b1000_0110; // E
                HEX3 <= 8'b1100_0111; // L
                HEX2 <= 8'b1100_1111; // I
                HEX1 <= 8'b1010_1011; // n
                HEX0 <= 8'b0111_1111; // .
            end
            // Hata Durumu (Switch 6 veya 7 aktifse)
            else if (ekran_secimi == 3'd6 || ekran_secimi == 3'd7) begin
                HEX5 <= 8'b1111_1111; 
                HEX4 <= 8'b1000_0110; // E
                HEX3 <= 8'b1010_1111; // r
                HEX2 <= 8'b1010_1111; // r
                HEX1 <= 8'b1010_0011; // o
                HEX0 <= 8'b1010_1111; // r
            end
            // Tekli Harf Basımı
            else begin
                case(ekran_secimi)
                    3'd0: HEX0 <= baglanti_kablosu;
                    3'd1: HEX1 <= baglanti_kablosu;
                    3'd2: HEX2 <= baglanti_kablosu;
                    3'd3: HEX3 <= baglanti_kablosu;
                    3'd4: HEX4 <= baglanti_kablosu;
                    3'd5: HEX5 <= baglanti_kablosu;
                    default: ;
                endcase
            end
        end
    end
endmodule