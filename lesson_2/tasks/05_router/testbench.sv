`timescale 1ns/1ps

module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic  [3:0][1:0] sel;
    logic       [3:0] in;
    logic       [3:0] out;

    int transact_cnt;           // number of test transaction
    int sel_cur;                // current selection signal
    int in_cur;
    int out_cur;

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
    parameter CLK_PERIOD = 10; // ?;

    // TODO:
    // Cгенерируйте тактовый сигнал
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2);
            clk <= ~clk;
        end
    end

    // TODO:
    // Cгенерируйте сигнал сброса
    initial begin
        aresetn <= 1'b0;
        @(posedge clk);
        aresetn <= 1'b1;
    end

    // TODO:
    // Сгенерируйте входные сигналы
    // Не забудьте про ожидание сигнала сброса!
    initial begin
        // Входные воздействия опишите здесь.
        wait(aresetn);
        repeat(10) begin
            @(posedge clk);
            in  <= $urandom();
            sel <= $urandom();
        end

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
            // Пишите здесь.
            pkt.sel = sel;
            pkt.in  = in;
            pkt.out = out;

            mon2chk.put(pkt);
        end
    end

    // TODO:
    // Выполните проверку выходных сигналов
    // make EXAMPLE=05_router SIM_OPTS=-gui\ -sv_seed\ 1234 EXT_POSTFIX=svp
    initial begin
        packet pkt_prev, pkt_cur;

        wait(aresetn);
        mon2chk.get(pkt_prev);
        forever begin
            mon2chk.get(pkt_cur);
            // Пишите здесь
            $display("\n============= Transaction #%0d ===============", transact_cnt);
            for(int i = 0; i < 4; i++) begin
                sel_cur = pkt_prev.sel[i][1:0];
                in_cur  = pkt_prev.in[i];
                out_cur = pkt_cur.out[i];
                if( in_cur !== pkt_cur.out[sel_cur] ) begin
                    $display("----------------------------");
                    $error("(%0t) Bad Routing:\nsel[%0d]=%0d,\n in[%0d]=%0d,\nout[%0d]=%0d",
                    $time(), i, sel_cur, i, in_cur, sel_cur, out_cur);
                end else begin
                    $display("----------------------------");
                    $display("(%0t) Good Routing:\nsel[%0d]=%0d,\n in[%0d]=%0d,\nout[%0d]=%0d",
                    $time(), i, sel_cur, i, in_cur, sel_cur, out_cur);
                end
            end

            pkt_prev = pkt_cur;
            transact_cnt++;
        end
    end

endmodule
