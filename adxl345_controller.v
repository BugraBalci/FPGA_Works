module adxl345_i2c_accel (
    input wire clk,
    input wire rst_n,
    inout wire sda,
    output wire scl,
    output reg [15:0] accel_x
);
	//zamanı sensörün anlayabileceği şekilde yavaşlatıyoruz
    reg [8:0] div;
    wire tick = (div == 9'd124); 
    always @(posedge clk) begin
        if (tick) begin 
            div <= 0;
        end else begin 
            div <= div + 1;
        end
    end

    reg [5:0] state;
    reg [7:0] shift;
    reg [2:0] bit_idx;
    reg sda_reg, scl_reg, sda_dir;
    reg [7:0] data_x0;
    reg [15:0] delay_cnt;

    assign sda = sda_dir ? sda_reg : 1'bz; //sda_dir 1 ise sda_reg verisibi kabloya bas konuşuyorum 0 ise 1'bz ile hattı kes
    assign scl = scl_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 0;
            sda_reg <= 1; scl_reg <= 1; sda_dir <= 1;
            accel_x <= 0;
            delay_cnt <= 0;
        end else if (tick) begin
            case (state)
					//scl clock sinyalidir
                0: begin sda_reg <= 1; scl_reg <= 1; sda_dir <= 1; state <= 1; end 

                1: begin sda_reg <= 0; scl_reg <= 1; state <= 2; end 
					 // Sensöre "Sana YAZI YAZACAĞIM" diyoruz.
                2: begin sda_reg <= 0; scl_reg <= 0; shift <= 8'h3A; bit_idx <= 7; state <= 3; end //8'h3A, ADXL345 sensörünün I2C'deki "Yazma Adresi"dir. Bunu shift (Vagon) kutusuna koyduk.
					 
                3: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 4; end
					 
                4: begin scl_reg <= 1; state <= 5; end
					 
                5: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 6; end 
                    else begin bit_idx <= bit_idx - 1; state <= 3; end 
                end
					 //yukarıda ki kısım elimizde bulunan 8 bitlik veriyi sırayla yolluyor(bitene kadar 5. state kullanark)
                6: begin sda_dir <= 0; scl_reg <= 0; state <= 7; end // Mandalı bıraktık (sda_dir = 0). Sensörden ACK (0) bekliyoruz.
					 
                7: begin scl_reg <= 1; state <= 8; end // 9. Saat vuruşu (Onay anı)
					 
                8: begin scl_reg <= 0; sda_dir <= 1; shift <= 8'h2D; bit_idx <= 7; state <= 9; end //Mandalı geri aldık (sda_dir = 1). Bu sefer vagona 8'h2D (Güç Odasının Numarası) koyup aynı şekilde yolluyoruz. ACK bekliyoruz.
					 
                9: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 10; end
					 
                10: begin scl_reg <= 1; state <= 11; end
					 
                11: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 12; end 
                    else begin bit_idx <= bit_idx - 1; state <= 9; end 
                end
					 
                12: begin sda_dir <= 0; scl_reg <= 0; state <= 13; end 
					 
                13: begin scl_reg <= 1; state <= 14; end
					 
                14: begin scl_reg <= 0; sda_dir <= 1; shift <= 8'h08; bit_idx <= 7; state <= 15; end //Vagona 8'h08 (Uyanma Emri) koyup yolluyoruz. ACK bekliyoruz.
					 
                15: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 16; end
					 
                16: begin scl_reg <= 1; state <= 17; end
					 
                17: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 18; end 
                    else begin bit_idx <= bit_idx - 1; state <= 15; end 
                end
					 
                18: begin sda_dir <= 0; scl_reg <= 0; state <= 19; end 
					 
                19: begin scl_reg <= 1; state <= 20; end
					 //..............................................
                20: begin scl_reg <= 0; sda_dir <= 1; sda_reg <= 0; state <= 21; end 
					 
                21: begin scl_reg <= 1; state <= 22; end 
					 
                22: begin sda_reg <= 1; state <= 23; end
					//(yukarıdaki kod bloğu için)işimiz bitti. Saat 1 iken SDA hattını 0'dan 1'e çıkartarak STOP (Kapanış) sinyali veriyoruz. Sensör artık uyandı ve ivme ölçmeye başladı!

                23: begin
                    if (delay_cnt == 16'd500) begin
                        delay_cnt <= 0;
                        state <= 24;
                    end else begin 
                        delay_cnt <= delay_cnt + 1;
                    end
                end

               // BOLUM 2: IVMEYI OKU
					//Sensör ivmeyi ölçüyor ama sonuçlar nerede? 0x32 (X0 Ekseninin ilk yarısı) ve 0x33 (X1 Ekseninin ikinci yarısı) numaralı odalarda. O odalara gidip veriyi çekmemiz lazım.

					//State 24-37: Tekrar START veriyoruz. 8'h3A ile sensörün kapısını çalıyoruz. Vagona 8'h32 koyup "Ben 0x32 numaralı odadaki bilgiye bakacağım" diyoruz.

					//State 38-39: İşte burası çok kritik! Buna RESTART (Yeniden Başlama) denir. Hattı kapatmadan anında tekrar START sinyali çakıyoruz.

					//State 40: Vagona bu sefer 8'h3B koyuyoruz. 3B'nin anlamı: "Ey sensör, az önce söylediğim 0x32 numaralı odadaki bilgiyi BANA OKU (Gönder)!"*\

                24: begin sda_reg <= 0; scl_reg <= 1; state <= 25; end 
					 
                25: begin sda_reg <= 0; scl_reg <= 0; shift <= 8'h3A; bit_idx <= 7; state <= 26; end
					 
                26: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 27; end
					 
                27: begin scl_reg <= 1; state <= 28; end
					 
                28: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 29; end 
                    else begin bit_idx <= bit_idx - 1; state <= 26; end 
                end
					 
                29: begin sda_dir <= 0; scl_reg <= 0; state <= 30; end 
					 
                30: begin scl_reg <= 1; state <= 31; end
					 
                31: begin scl_reg <= 0; sda_dir <= 1; shift <= 8'h32; bit_idx <= 7; state <= 32; end 
					 
                32: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 33; end
					 
                33: begin scl_reg <= 1; state <= 34; end
					 
                34: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 35; end 
                    else begin bit_idx <= bit_idx - 1; state <= 32; end 
                end
					 
                35: begin sda_dir <= 0; scl_reg <= 0; state <= 36; end 
					 
                36: begin scl_reg <= 1; state <= 37; end
					 
                37: begin scl_reg <= 0; sda_dir <= 1; sda_reg <= 1; state <= 38; end

                38: begin scl_reg <= 1; sda_reg <= 1; state <= 39; end 
					 
                39: begin sda_reg <= 0; scl_reg <= 1; state <= 40; end
					 
                40: begin sda_reg <= 0; scl_reg <= 0; shift <= 8'h3B; bit_idx <= 7; state <= 41; end 
					 
                41: begin sda_reg <= shift[bit_idx]; scl_reg <= 0; state <= 42; end
					 
                42: begin scl_reg <= 1; state <= 43; end
					 
                43: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 44; end 
                    else begin bit_idx <= bit_idx - 1; state <= 41; end 
                end
					 
                44: begin sda_dir <= 0; scl_reg <= 0; state <= 45; end 
					 
                45: begin scl_reg <= 1; state <= 46; end
					 
                46: begin scl_reg <= 0; sda_dir <= 0; bit_idx <= 7; state <= 47; end
					//......................................................................
                47: begin scl_reg <= 0; state <= 48; end
					 
                48: begin scl_reg <= 1; shift[bit_idx] <= sda; state <= 49; end//Mandal (sda_dir) kapalı. Kabloda (sda) ne var? Sensör o an ne basmışsa anında alıp bizim kendi kasamıza (shift) kaydediyoruz. 8 bit dolduğunda elimizde ilk parça var.
					 
                49: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 50; end 
                    else begin bit_idx <= bit_idx - 1; state <= 47; end 
                end
					 //YUKARIDA Kİ KISIMDA FPGA DİNLİYOR SENSÖR YAZIYOR
                50: begin sda_dir <= 1; sda_reg <= 0; scl_reg <= 0; state <= 51; end //State 50-51: İlk 8 biti başarıyla okuduk. Bu sefer sensöre biz onay (Master ACK) veriyoruz (sda_reg = 0). Ve okuduğumuz ilk yarıyı data_x0 isimli bir çekmeceye saklıyoruz.
					 
                51: begin scl_reg <= 1; data_x0 <= shift; state <= 52; end
					 
                52: begin scl_reg <= 0; sda_dir <= 0; bit_idx <= 7; state <= 53; end
					//.........
                53: begin scl_reg <= 0; state <= 54; end
					 
                54: begin scl_reg <= 1; shift[bit_idx] <= sda; state <= 55; end
					 
                55: begin 
                    scl_reg <= 0; 
                    if (bit_idx == 0) begin state <= 56; end 
                    else begin bit_idx <= bit_idx - 1; state <= 53; end 
                end
					 
                56: begin sda_dir <= 1; sda_reg <= 1; scl_reg <= 0; state <= 57; end 
                //State 53-56 (İkinci 8 Biti Okuma):
					 //Sensör durmuyor, peşinden hemen 0x33 odasındaki X ekseninin ikinci yarısını (X1) kabloya basmaya devam ediyor. Onu da aynı şekilde dinleyip kasaya alıyoruz.
					 
                57: begin scl_reg <= 1; accel_x <= {shift, data_x0}; state <= 58; end 
                
                58: begin scl_reg <= 0; sda_reg <= 0; state <= 59; end
					 
                59: begin scl_reg <= 1; state <= 60; end 
					 
                60: begin sda_reg <= 1; state <= 61; end
					 //State 58-60: Kabloyu bırakıp STOP sinyali veriyoruz.
                61: begin
                    if (delay_cnt == 16'd2000) begin
                        delay_cnt <= 0;
                        state <= 24; 
                    end else begin 
                        delay_cnt <= delay_cnt + 1;
                    end
                end
					//State 61: FPGA çok hızlı olduğu için, aynı veriyi saniyede binlerce kez okuyup sensörü boğmamak adına burada 20 milisaniyelik bir gecikme (delay) ekliyoruz. Süre dolunca tekrar State 24'e (Yani okuma işleminin en başına) zıplıyoruz.	
                default: begin 
                    state <= 0; 
                end
            endcase
        end
    end
endmodule