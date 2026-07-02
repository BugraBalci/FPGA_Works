module letter_selection (
    input wire [4:0] harf_id,
    output reg [7:0] harf_kodu
);
    always @(*) begin
        case(harf_id)
            5'd0:  harf_kodu = 8'b1111_1111; 
            5'd1:  harf_kodu = 8'b1000_1000; // A
            5'd2:  harf_kodu = 8'b1000_0011; // b
            5'd3:  harf_kodu = 8'b1100_0110; // C 
            5'd4:  harf_kodu = 8'b1010_0001; // d
            5'd5:  harf_kodu = 8'b1000_0110; // E
            5'd6:  harf_kodu = 8'b1000_1110; // F
            5'd7:  harf_kodu = 8'b1001_0000; // g
            5'd8:  harf_kodu = 8'b1000_1001; // H
            5'd9:  harf_kodu = 8'b1111_1001; // I
            5'd10: harf_kodu = 8'b1111_0001; // J
            5'd11: harf_kodu = 8'b1000_1010; // K
            5'd12: harf_kodu = 8'b1100_0111; // L
            5'd13: harf_kodu = 8'b1010_1010; // M
            5'd14: harf_kodu = 8'b1010_1011; // n
            5'd15: harf_kodu = 8'b1010_0011; // o
            5'd16: harf_kodu = 8'b1000_1100; // P
            5'd17: harf_kodu = 8'b1001_1000; // q
            5'd18: harf_kodu = 8'b1010_1111; // r
            5'd19: harf_kodu = 8'b1001_0010; // S
            5'd20: harf_kodu = 8'b1000_0111; // t
            5'd21: harf_kodu = 8'b1100_0001; // U
            5'd22: harf_kodu = 8'b1100_0001; // V
            5'd23: harf_kodu = 8'b1000_0001; // W
            5'd24: harf_kodu = 8'b1000_1001; // X
            5'd25: harf_kodu = 8'b1001_0001; // y
            5'd26: harf_kodu = 8'b1010_0100; // Z
            5'd27: harf_kodu = 8'b1011_1111; // - (Tire)
            default: harf_kodu = 8'b1111_1111;
        endcase
    end
endmodule