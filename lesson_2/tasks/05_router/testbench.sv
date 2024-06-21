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

    // TODO:
    // Найдите все ошибки в модуле ~router~

    // TODO:
    // Определите период тактового сигнала
    parameter CLK_PERIOD = 10;// ?;

    // TODO:
    // Cгенерируйте тактовый сигнал
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD / 2) clk = ~clk;
        end
    end
    
    // TODO:
    // Cгенерируйте сигнал сброса
    initial begin
      aresetn <= 0;
      #(CLK_PERIOD);
      aresetn <= 1;
    end

    // TODO:
    // Сгенерируйте входные сигналы
    // Не забудьте про ожидание сигнала сброса!
    initial begin
        wait(~aresetn);
        repeat(20) begin
        sel[3:0] <= $urandom_range(0, 15);
        in       <= $urandom_range(0, 15);
        end
        wait(aresetn);
        // Входные воздействия опишите здесь.
        @(posedge clk);
        $stop();
    end

    // Пользуйтесь этой структурой
    typedef struct {
        logic  [3:0][1:0] sel;
        logic       [3:0] in;
        logic       [3:0] out;
    } packet;

    mailbox#(packet) mon2chk = new();

    // TODO:
    // Сохраняйте сигналы каждый положительный
    // фронт тактового сигнала
    initial begin
        packet pkt;
        wait(aresetn);
        forever begin
            @(posedge clk);
            pkt.sel <= sel;
            pkt.in  <= in;
            pkt.out <= out;
            // Пишите здесь.
        end
    end

    // TODO:
    // Выполните проверку выходных сигналов
    initial begin
        packet pkt_prev, pkt_cur;
        wait(aresetn);
        mon2chk.get(pkt_prev);
        forever begin
            mon2chk.get(pkt_cur);
            for (int i = 0; i < 4; i++) begin
              for (int j = 0; j < 4; j++) begin
                if (sel[j] == i && out[i] == in[j])
                  $display("OK!");
                else  
                  $display("BAD SIGNAL!, time = %0t sel = %0d out = %0d in = %0d", $time, i, out[i], in[j]);
              end
            end 
            // Пишите здесь

            pkt_prev = pkt_cur;
        end
    end



endmodule
