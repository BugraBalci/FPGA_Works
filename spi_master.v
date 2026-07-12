// --- YENİ spi_master.v KODU (MODE 0) ---
module spi_master (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [15:0] data_in,
    input wire miso,

    output reg mosi,
    output reg cs,
    output reg sck,
    output reg [15:0] data_out,
    output reg done
);

    localparam IDLE       = 3'd0;
    localparam START_CS   = 3'd1;
    localparam SCK_HIGH   = 3'd2;
    localparam SCK_LOW    = 3'd3;
    localparam DONE_STATE = 3'd4;

    reg [2:0] state;
    reg [4:0] bit_cnt;
    reg [15:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            cs <= 1'b1;
            sck <= 1'b0; // EN BÜYÜK DEĞİŞİKLİK: SPI Mode 0 (Boşta 0)
            mosi <= 1'b1;
            done <= 1'b0;
            bit_cnt <= 5'd15;
            data_out <= 16'd0;
            shift_reg <= 16'd0;
        end else begin
            case (state)
                IDLE: begin
                    cs <= 1'b1;
                    sck <= 1'b0; // Saat boşta sıfır, kilitlenme riski YOK!
                    done <= 1'b0;
                    if (start) begin
                        shift_reg <= data_in;
                        state <= START_CS;
                    end
                end

                START_CS: begin
                    cs <= 1'b0;            // Kapıyı çal (CS=0)
                    sck <= 1'b0;           // Saat hala 0
                    mosi <= shift_reg[15]; // İlk biti hatta koy
                    bit_cnt <= 5'd15;
                    state <= SCK_HIGH;
                end

                SCK_HIGH: begin
                    sck <= 1'b1;           // SAAT ÇIKAR (Yükselen Kenar). Sensör okur.
                    shift_reg <= {shift_reg[14:0], miso}; // Biz de sensörün cevabını okuruz.
                    state <= SCK_LOW;
                end

                SCK_LOW: begin
                    sck <= 1'b0;           // SAAT DÜŞER (Düşen Kenar).
                    if (bit_cnt == 5'd0) begin
                        state <= DONE_STATE;
                    end else begin
                        bit_cnt <= bit_cnt - 1'b1;
                        mosi <= shift_reg[15]; // Yeni biti hatta koy
                        state <= SCK_HIGH;
                    end
                end

                DONE_STATE: begin
                    cs <= 1'b1;
                    sck <= 1'b0;
                    done <= 1'b1;
                    data_out <= shift_reg;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule