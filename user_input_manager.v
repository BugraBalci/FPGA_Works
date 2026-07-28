module user_input_manager (
    input  wire clk,
    input  wire buton,
    
    // Şalterlerden gelen anlık (canlı) veriler
    input  wire [5:0] sw_letter,
    input  wire [2:0] sw_display,
    
    // Butona basıldığında kilitlenip dışarı (main.v'ye) aktarılan veriler
    output reg  [5:0] lock_letter,
    output reg  [2:0] lock_display
);

    // 1. Kenar Yakalama (Edge Detection) Devresi
    reg buton_r1, buton_r2;
    always @(posedge clk) begin
        buton_r1 <= buton;
        buton_r2 <= buton_r1;
    end
    
    wire falling_edge = (buton_r2 == 1'b1) && (buton_r1 == 1'b0);

    // 2. Hafıza (Lock) Devresi
    always @(posedge clk) begin
        if (falling_edge) begin
            lock_letter  <= sw_letter; 
            lock_display <= sw_display;  
        end
    end

endmodule