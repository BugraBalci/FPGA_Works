module letter_selection (
    input wire [5:0] letter_id,
    output reg [7:0] letter_code
	 input wire ac_or_let
);
    always @(*) begin
        case(letter_id)
            6'd0:  letter_code = 8'b1111_1111; 
            6'd1:  letter_code = 8'b1000_1000; // A
            6'd2:  letter_code = 8'b1000_0011; // b
            6'd3:  letter_code = 8'b1100_0110; // C 
            6'd4:  letter_code = 8'b1010_0001; // d
            6'd5:  letter_code = 8'b1000_0110; // E
            6'd6:  letter_code = 8'b1000_1110; // F
            6'd7:  letter_code = 8'b1001_0000; // g
            6'd8:  letter_code = 8'b1000_1001; // H
            6'd9:  letter_code = 8'b1111_1001; // I
            6'd10: assign letter_code = ac_or_let ? 8'b10001000 : 8'1000 1111 ; // J 4'hA: seg_out = 8'b10001000;assign HEX2 = sensor_is_active ? sysB_hex2 : sysA_hex2;
            6'd11: letter_code = 8'b1000_1010; // K
            6'd12: letter_code = 8'b1100_0111; // L
            6'd13: letter_code = 8'b1010_1010; // M
            6'd14: letter_code = 8'b1010_1011; // n
            6'd15: letter_code = 8'b1010_0011; // o
            6'd16: letter_code = 8'b1000_1100; // P
            6'd17: letter_code = 8'b1001_1000; // q
            6'd18: letter_code = 8'b1010_1111; // r
            6'd19: letter_code = 8'b1001_0010; // S
            6'd20: letter_code = 8'b1000_0111; // t
            6'd21: letter_code = 8'b1100_0001; // U
            6'd22: letter_code = 8'b1100_0001; // V
            6'd23: letter_code = 8'b1000_0001; // W
            6'd24: letter_code = 8'b1000_1001; // X
            6'd25: letter_code = 8'b1001_0001; // y
            6'd26: letter_code = 8'b1010_0100; // Z
            6'd27: letter_code = 8'b1011_1111; // - (Tire)
				6'd28: letter_code = 8'b1001_0001; // 1
				6'd29: letter_code = 8'b1001_0001; // 2
				6'd30: letter_code = 8'b1001_0001; // 3
				6'd31: letter_code = 8'b1001_0001; // 4
				6'd32: letter_code = 8'b1011_1111; // 5
				6'd33: letter_code = 8'b1011_1111; // 6
				6'd34: letter_code = 8'b1011_1111; // 7
				6'd35: letter_code = 8'b1011_1111; // 8
				6'd36: letter_code = 8'b1011_1111; // 9
				6'd37: letter_code = 8'b1011_1111; // 0
			
				
            default: letter_code = 8'b1111_1111;
        endcase
    end
endmodule


