module master_decoder (
    input wire [5:0] id_input,
    output reg [7:0] code_output
);
    always @(*) begin
        case(id_input)
            // İLK 10 SIRA (0-9) MATEMATİK MOTORU İÇİN KESİNLİKLE RAKAM OLMALI!
            6'd0:  code_output = 8'b1100_0000; // 0
            6'd1:  code_output = 8'b1111_1001; // 1
            6'd2:  code_output = 8'b1010_0100; // 2
            6'd3:  code_output = 8'b1011_0000; // 3
            6'd4:  code_output = 8'b1001_1001; // 4
            6'd5:  code_output = 8'b1001_0010; // 5
            6'd6:  code_output = 8'b1000_0010; // 6
            6'd7:  code_output = 8'b1111_1000; // 7
            6'd8:  code_output = 8'b1000_0000; // 8
            6'd9:  code_output = 8'b1001_0000; // 9

            // SENİN HARFLERİN (10'DAN BAŞLIYOR, HARF MODUNDA ÇALIŞIR)
            6'd10: code_output = 8'b1000_1000; // A
            6'd11: code_output = 8'b1000_0011; // b
            6'd12: code_output = 8'b1100_0110; // C 
            6'd13: code_output = 8'b1010_0001; // d
            6'd14: code_output = 8'b1000_0110; // E
            6'd15: code_output = 8'b1000_1110; // F
            6'd16: code_output = 8'b1001_0000; // g
            6'd17: code_output = 8'b1000_1001; // H
            6'd18: code_output = 8'b1111_1001; // I
            6'd19: code_output = 8'b1000_1000; // J 
            6'd20: code_output = 8'b1000_1010; // K
            6'd21: code_output = 8'b1100_0111; // L
            6'd22: code_output = 8'b1010_1010; // M
            6'd23: code_output = 8'b1010_1011; // n
            6'd24: code_output = 8'b1010_0011; // o
            6'd25: code_output = 8'b1000_1100; // P
            6'd26: code_output = 8'b1001_1000; // q
            6'd27: code_output = 8'b1010_1111; // r
            6'd28: code_output = 8'b1001_0010; // S
            6'd29: code_output = 8'b1000_0111; // t
            6'd30: code_output = 8'b1100_0001; // U
            6'd31: code_output = 8'b1100_0001; // V
            6'd32: code_output = 8'b1000_0001; // W
            6'd33: code_output = 8'b1000_1001; // X
            6'd34: code_output = 8'b1001_0001; // y
            6'd35: code_output = 8'b1010_0100; // Z
            
            // ÖZEL EKRAN KODLARI (SENSÖR EKSİ VE BOŞLUK İÇİN)
            6'd37: code_output = 8'b1011_1111; // - (Tire)(Eksi)
            6'd38: code_output = 8'b1111_1111; // BOŞ EKRAN
                
            default: code_output = 8'b1111_1111;
        endcase
    end
endmodule