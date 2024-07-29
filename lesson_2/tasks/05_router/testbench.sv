
module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic  [3:0][1:0] sel;
    logic       [3:0] in;
    logic       [3:0] out;

    router DUT(
        .clk     ( clk     ),
        .aresetn ( aresetn ),
        .sel     ( sel     ),
        .in      ( in      ),
        .out     ( out     )
    );

    // Определите период тактового сигнала
    parameter CLK_PERIOD = 10;

    // Генерация тактового сигнала
    initial begin
        clk <= 0;
        forever begin
        #(CLK_PERIOD / 2) clk = ~clk;
        end
    end
    
    // Генерация сигнала сброса
    initial begin
        aresetn = 0;
        #(2 * CLK_PERIOD);
        aresetn = 1;
    end

    // Сгенерируйте входные сигналы
    initial begin
        wait(aresetn);
        @(posedge clk);

        sel = 4'b00_01_10_11;
        in  = 4'b1010;
        @(posedge clk);

        sel = 4'b00_00_01_01;
        in = 4'b1100;
        @(posedge clk);

        sel = 4'b11_10_01_00;
        in = 4'b0011;
        @(posedge clk);

        sel = 4'b01_01_01_01;
        in = 4'b1111;
        @(posedge clk);

        sel = 4'b10_10_10_10;
        in = 4'b0110;
        @(posedge clk);

        sel = 4'b11_11_11_11;
        in = 4'b1001;
        @(posedge clk);
        // Завершите симуляцию
        $stop();
    end

    // Пользуйтесь этой структурой
    typedef struct {
        logic  [3:0][1:0] sel;
        logic       [3:0] in;
        logic       [3:0] out;
    } packet;

    mailbox#(packet) mon2chk = new();

    // Сохраняйте сигналы каждый положительный фронт тактового сигнала
    initial begin
        packet pkt;
        wait(aresetn);
        forever begin
            @(posedge clk);
            pkt.sel = sel;
            pkt.in = in;
            pkt.out = out;
            mon2chk.put(pkt);
        end
    end

    // Выполните проверку выходных сигналов
    initial begin
        packet pkt_prev, pkt_cur;
        wait(aresetn);
        mon2chk.get(pkt_prev);
        forever begin
            mon2chk.get(pkt_cur);

            // Проверка работы маршрутизации
            for (int i = 0; i < 4; i++) begin
                logic [3:0] expected_out;
                expected_out = 4'b0;
                for (int j = 0; j < 4; j++) begin
                    if (pkt_cur.sel[j] == i[1:0]) begin
                        expected_out[i] = pkt_cur.in[j];
                    break;
                    end
                end
                if (pkt_cur.out[i] !== expected_out[i]) begin
                 $error("Error at time %0t: expected out[%0d] = %0b, got %0b", $time, i, expected_out[i], pkt_cur.out[i]);
                end
            end

            pkt_prev = pkt_cur;
        end
    end

endmodule