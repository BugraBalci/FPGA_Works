module average_acceleration (

output wire [15:0] absolutely_acceleration,

output wire is_negative, 

input  wire [15:0] current_acceleration,

input  wire rst_n,

input  wire clk

);

wire signed [15:0] final_acceleration;

reg signed [19:0] filter_acceleration;

//Geçmiş 16 değeri aklında tutmak için 16 ayrı hafıza kutusu (Register) açman ve her saniye bunları kaydırman gerekir. Çipte devasa yer kaplar.

//IIR Filtre (Eksponansiyel Hareketli Ortalama) küsüratlı değerleri korumak için bir havuz yaparız 

reg [22:0] slow_div;

    wire slow_tick = (slow_div == 23'd4_999_999);

    always @(posedge clk) begin

        if (slow_tick) slow_div <= 0;

        else slow_div <= slow_div + 1;

    end



always @(posedge clk) begin

        if (!rst_n) begin

            filter_acceleration <= 0;

        end else if (slow_tick) begin

            // Yeni değeri ekle, eski değerin 1/16'sını çıkar (Moving Average)

            filter_acceleration <= filter_acceleration - (filter_acceleration >>> 4) + current_acceleration;

        end

    end

 

assign final_acceleration = filter_acceleration >>> 4;

 

assign is_negative = final_acceleration[15];

 

assign absolutely_acceleration = is_negative ? (~final_acceleration + 1) : final_acceleration; 

endmodule


/*Eğer sayı eksiyse, onu ekrana eksi eksi diye basamayız. Önce Mutlak Değerini (Artı halini) almalıyız.

Bir binary sayıyı eksi halden artı hale getirmek için: Bütün bitleri tersine çevirirsin (~ işareti) ve üstüne 1 eklersen

Eğer sayı zaten artıysa dokunmayız.

Artık elimizde abs_val adında, tertemiz, hep pozitif bir sayımız var (Örn: 254).
*/

/*module average_acceleration (
    output wire [15:0] absolutely_acceleration,
    output wire is_negative, 
    input  wire [15:0] current_acceleration,
    input  wire rst_n,
    input  wire clk
);
    wire signed [15:0] final_acceleration;
    reg signed [19:0] filter_acceleration;
    
    // HATA 3 DÜZELTİLDİ: Sign Extension patlamasını önleyen o sihirli kablo geri geldi!
    wire signed [15:0] current_val = current_acceleration;

    reg [22:0] slow_div;
    wire slow_tick = (slow_div == 23'd4_999_999);
    always @(posedge clk) begin
        if (slow_tick) slow_div <= 0;
        else slow_div <= slow_div + 1;
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            filter_acceleration <= 0;
        end else if (slow_tick) begin
            // current_acceleration DEĞİL, current_val kullanıyoruz!
            filter_acceleration <= filter_acceleration - (filter_acceleration >>> 4) + current_val;
        end
    end
    
    assign final_acceleration = filter_acceleration >>> 4;
    assign is_negative = final_acceleration[15];
    assign absolutely_acceleration = is_negative ? (~final_acceleration + 1) : final_acceleration; 
endmodule
*/
