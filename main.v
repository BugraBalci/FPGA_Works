module main (
    input wire [8:0] SW,
	 input wire clk, // clk sinyali
	 input wire buton,
    
    // Alt modülümüz (display_section) bu kablolara dışarıdan elektrik basacak.
    output wire [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

    // === 1. ŞALTERLERİ (GİRİŞLERİ) AYIRMA ===
    wire [5:0] letter_selection   = SW[5:0];  // İlk 5 şalter (Harf veya kelime kimliği)
    wire [2:0] display_section  = SW[8:6];  // Son 3 şalter (Hedef ekran numarası)
	 
	 // === 2. FALLING EDGE (DÜŞEN KENAR) DETEKTÖRÜ ===
	 reg buton_r1, buton_r2;
	 // Buton sinyalini saat senkronizasyonuna alıyoruz (Meta-stabiliteyi önlemek için)
	 always @(posedge clk) begin
        buton_r1 <= buton;
        buton_r2 <= buton_r1;
    end
	 
	 // Düşen kenar formülü: Önceki durumda 1 (bırakılmış) ama şimdiki durumda 0 (basılmış) ise tetiklenir
    // (Active-Low butonlar için basıldığı an falling edge'dir)
    wire falling_edge = (buton_r2 == 1'b1) && (buton_r1 == 1'b0);


    // === 3. GÖRÜNTÜ YAKALAMA (DATA ACQUISITION) REGISTERS ===
    // Düşen kenar geldiğinde şalterlerdeki değerleri bu kalıcı hafıza odalarına kilitleyeceğiz
    reg [4:0] lock_letter;
    reg [2:0] lock_display;

    always @(posedge clk) begin
        if (falling_edge) begin
            lock_letter <= letter_selection; // Sinyali gördüğün an seçimi hafızaya al
            lock_display  <= display_section;  // Sinyali gördüğün an ekranı hafızaya al
        end
    end
    
    // === 2. ÇİPLER ARASI SANAL KABLO ===
    wire [7:0] connection_cable;
	

    // === 3. BİRİNCİ ALT ENTEGRE: SÖZLÜK ÇİPİ ===
    // DÜZELTME: Buraya tel adı değil, 'harf_secici' modül adı yazıldı!
    letter_selection letter_motor (
        .letter_id(lock_letter),      // Şalterden gelen 5 bitlik sayıyı sözlüğe ver
        .letter_code(connection_cable)   // Çıkan 8 bitlik ışık kodunu bizim sanal kabloya bas
    );

    // === 4. İKİNCİ ALT ENTEGRE: DAĞITICI ÇİP ===
    display_section distributor_motor (
        .letter_selection(lock_letter),     // Şalterden kelime durumunu dinle
        .display_section(lock_display),   // Şalterden hedef ekranı dinle
        .letter_code_input(connection_cable),  // Sözlükten gelen harf kodunu al
        
        // Dağıtıcı çipten çıkan sonuçları anakartın fiziksel bacaklarına (HEX) bağla
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0)
    );

endmodule



