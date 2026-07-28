module print_display (
    input wire clk,
    // Abinin "String" dediği girdi paketi: 6 ekran için 6 farklı ID
    input wire [5:0] id5, id4, id3, id2, id1, id0, 
    
    // "01.234" yazmak için hangi ekranın noktası yanacak? (1 = Nokta Yanar)
    input wire [5:0] dp_en, 
    
    // Gerçek Fiziksel Ekran Pinleri
    output reg [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

    // Sözlükten çıkan saf (noktasız) harf/rakam kodları
    wire [7:0] raw_h5, raw_h4, raw_h3, raw_h2, raw_h1, raw_h0;

    // SÖZLÜKLER ARTIK SADECE BU KAPALI KUTUNUN İÇİNDE!
    master_decoder d5(.id_input(id5), .code_output(raw_h5));
    master_decoder d4(.id_input(id4), .code_output(raw_h4));
    master_decoder d3(.id_input(id3), .code_output(raw_h3));
    master_decoder d2(.id_input(id2), .code_output(raw_h2));
    master_decoder d1(.id_input(id1), .code_output(raw_h1));
    master_decoder d0(.id_input(id0), .code_output(raw_h0));

    // ABİNİN İSTEDİĞİ: "clk yükselen kenarında ekrana basacak" (Senkron Çıkış)
    always @(posedge clk) begin
        // dp_en bitlerine bak. Eğer 1 ise, o ekranın 7. bitini (Noktayı) 0'a çekerek yak.
        HEX5 <= dp_en[5] ? (raw_h5 & 8'b01111111) : raw_h5;
        HEX4 <= dp_en[4] ? (raw_h4 & 8'b01111111) : raw_h4;
        HEX3 <= dp_en[3] ? (raw_h3 & 8'b01111111) : raw_h3;
        HEX2 <= dp_en[2] ? (raw_h2 & 8'b01111111) : raw_h2;
        HEX1 <= dp_en[1] ? (raw_h1 & 8'b01111111) : raw_h1;
        HEX0 <= dp_en[0] ? (raw_h0 & 8'b01111111) : raw_h0;
    end

endmodule