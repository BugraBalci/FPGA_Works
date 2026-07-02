module main (
    input wire [8:0] SW,
    
    // Alt modülümüz (display_manager) bu kablolara dışarıdan elektrik basacak.
    output wire [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

    // === 1. ŞALTERLERİ (GİRİŞLERİ) AYIRMA ===
    wire [5:0] letter_selection   = SW[5:0];  // İlk 5 şalter (Harf veya kelime kimliği)
    wire [2:0] display_section  = SW[8:6];  // Son 3 şalter (Hedef ekran numarası)
    
    // === 2. ÇİPLER ARASI SANAL KABLO ===
    wire [7:0] connection_cable;

    // === 3. BİRİNCİ ALT ENTEGRE: SÖZLÜK ÇİPİ ===
    // DÜZELTME: Buraya tel adı değil, 'harf_secici' modül adı yazıldı!
    letter_selection letter_motor (
        .letter_id(letter_selection),      // Şalterden gelen 5 bitlik sayıyı sözlüğe ver
        .letter_code(connection_cable)   // Çıkan 8 bitlik ışık kodunu bizim sanal kabloya bas
    );

    // === 4. İKİNCİ ALT ENTEGRE: DAĞITICI ÇİP ===
    display_manager distributor_motor (
        .letter_selection(letter_selection),     // Şalterden kelime durumunu dinle
        .display_section(display_section),   // Şalterden hedef ekranı dinle
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



