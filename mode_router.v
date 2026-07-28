module mode_router (
    // 1. Sensör Çipinden Gelenler
    input wire is_negative,
    input wire [3:0] digit2,
    input wire [3:0] digit1,
    input wire [3:0] digit0,

    // 2. Şalter (Kullanıcı) Çipinden Gelenler
    input wire [5:0] lock_letter,
    input wire [2:0] lock_display,

    // 3. Ekran Sekreterine (Printf) Gidecek Çıkış Paketi
    output wire [5:0] out_id5,
    output wire [5:0] out_id4,
    output wire [5:0] out_id3,
    output wire [5:0] out_id2,
    output wire [5:0] out_id1,
    output wire [5:0] out_id0,
    output wire [5:0] out_dp
);

    // Kendi içindeki zeka (Logic)
    wire [5:0] sign_code = is_negative ? 6'd37 : 6'd38; 
    wire is_sensor_active = (lock_letter == 6'd63);

    // Yönlendirme (Routing) İşlemleri
    assign out_id5 = is_sensor_active ? 6'd38 : 6'd38;
    assign out_id4 = is_sensor_active ? 6'd38 : 6'd38;
    assign out_id3 = is_sensor_active ? sign_code : {3'b000, lock_display};
    assign out_id2 = is_sensor_active ? {2'b00, digit2} : 6'd38;
    assign out_id1 = is_sensor_active ? {2'b00, digit1} : lock_letter;
    assign out_id0 = is_sensor_active ? {2'b00, digit0} : lock_letter;

    // Nokta (Decimal Point) Yönlendirmesi
    assign out_dp  = is_sensor_active ? 6'b001000 : 6'b000000;

endmodule