module average_acceleration (
    input  wire clk,
    input  wire rst_n,
    input  wire [15:0] current_acceleration, // Sensörden gelen ham ve titreyen veri
    
    output wire is_negative,                 // Eksi işareti yanacak mı? (1 veya 0)
    output wire [15:0] absolutely_acceleration, // Mutlak değer (İstersen kullanırsın)
    output wire [3:0] digit2,                // Yüzler basamağı (0-9)
    output wire [3:0] digit1,                // Onlar basamağı (0-9)
    output wire [3:0] digit0                 // Birler basamağı (0-9)
);

    // 1. Gürültü ve Tabela (Sign Extension) Koruması
    wire signed [15:0] current_val = current_acceleration;
    wire signed [15:0] final_acceleration;
    reg signed [19:0] filter_acceleration;

    // 2. Metronom: Saniyede 10 Kere Vuran Saat (10 Hz)
    reg [22:0] slow_div;
    wire slow_tick = (slow_div == 23'd4_999_999);
    
    always @(posedge clk) begin
        if (slow_tick) slow_div <= 0;
        else slow_div <= slow_div + 1;
    end

    // 3. Dijital Amortisör (Moving Average Filter)
    always @(posedge clk) begin
        if (!rst_n) begin
            filter_acceleration <= 0;
        end else if (slow_tick) begin
            // Eski değerin 1/16'sını at, yeni gelen değeri ekle
            filter_acceleration <= filter_acceleration - (filter_acceleration >>> 4) + current_val;
        end
    end
    
    // 4. Filtrelenmiş Veriyi Vitrine Çıkarma
    assign final_acceleration = filter_acceleration >>> 4;
    
    // 5. İşaret Kontrolü ve Mutlak Değer (Eksiyi Artı Yapma)
    assign is_negative = final_acceleration[15];
    assign absolutely_acceleration = is_negative ? (~final_acceleration + 1) : final_acceleration; 
    
    // =========================================================================
    // 6. BCD DÖNÜŞTÜRÜCÜ (SENİN EKLEDİĞİN KISIM!)
    // Sayıyı 7-Segment Ekranlar İçin Parçalıyoruz
    // =========================================================================
    assign digit2 = (absolutely_acceleration / 100) % 10; // Yüzler basamağı
    assign digit1 = (absolutely_acceleration / 10)  % 10; // Onlar basamağı
    assign digit0 = (absolutely_acceleration)       % 10; // Birler basamağı

endmodule