module display_section (
    input wire [2:0] display_section,       // Hangi ekranın seçildiği (0-5)
    input wire [7:0] code_output_input,    // Sözlük (harf_secici) modülünden gelen 1-0 kodu
    
    output reg [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 // Doğrudan ekranlara giden bacaklar
);

    always @(*) begin
        
        // === SIFIRLAMA (RESET) KATI ===
        // Önce tüm ekranları sönük duruma getiriyoruz ki hayalet ışıklar veya çakışma (latch) oluşmasın.
        HEX5 = 8'b1111_1111;
        HEX4 = 8'b1111_1111;
        HEX3 = 8'b1111_1111;
        HEX2 = 8'b1111_1111;
        HEX1 = 8'b1111_1111;
        HEX0 = 8'b1111_1111;

        
        // === 2. ÖNCELİK: ERROR DURUMU ===
        // Eğer 6 veya 7 numaralı olmayan bir ekran seçilirse hata bas
        if (display_section == 3'd6 || display_section == 3'd7) begin
            HEX5 = 8'b1111_1111; // Boş
            HEX4 = 8'b1000_0110; // E
            HEX3 = 8'b1010_1111; // r
            HEX2 = 8'b1010_1111; // r
            HEX1 = 8'b1010_0011; // o
            HEX0 = 8'b1010_1111; // r
        end
        
        // === 3. ÖNCELİK: TEKLİ HARF YÖNLENDİRMESİ (DAĞITICI) ===
        // Yukarıdaki özel durumlar yoksa, sözlükten gelen harfi istenen ekrana bas
        else begin
            case(display_section)
                3'd0: HEX0 = code_output_input;
                3'd1: HEX1 = code_output_input;
                3'd2: HEX2 = code_output_input;
                3'd3: HEX3 = code_output_input;
                3'd4: HEX4 = code_output_input;
                3'd5: HEX5 = code_output_input;
            endcase
        end
        
    end // always bloğunun sonu

endmodule