module clock_divider (
    input wire clk_50mhz,
    input wire rst_n,
    output reg spi_clk
);
    reg [7:0] counter; // Sayaç büyüdü!
    always @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 8'd0;
            spi_clk <= 1'b0;
        end else begin
            // 50 MHz'i 100 kHz'e düşürmek için 250'ye kadar sayıyoruz
            if (counter == 8'd249) begin
                counter <= 8'd0;
                spi_clk <= ~spi_clk;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule