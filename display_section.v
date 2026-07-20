module display_section (
    input wire [2:0] display_section,       
    input wire [7:0] code_output_input,    
    output reg [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 
);
    always @(*) begin
        HEX5 = 8'b1111_1111;
		  HEX4 = 8'b1111_1111;
		  HEX3 = 8'b1111_1111;
        HEX2 = 8'b1111_1111;
		  HEX1 = 8'b1111_1111;
		  HEX0 = 8'b1111_1111;

        if (display_section == 3'd6 || display_section == 3'd7) begin
		  //ERROR
            HEX5 = 8'b1111_1111;
				HEX4 = 8'b1000_0110;
				HEX3 = 8'b1010_1111; 
            HEX2 = 8'b1010_1111;
				HEX1 = 8'b1010_0011;
				HEX0 = 8'b1010_1111; 
        end
		  
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
    end 
endmodule