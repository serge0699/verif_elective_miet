<<<<<<< HEAD
`timescale 1ns/1ps
=======
`timescale 1ns/100ps
>>>>>>> 769a96cc8924089df6af59b00273aba374cf00b8

module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic  [3:0][1:0] sel;
    logic       [3:0] in;
    logic       [3:0] out;

<<<<<<< HEAD
    int transact_cnt;           // number of test transaction
    int sel_cur;                // current selection signal
    int in_cur;
    int out_cur;
=======
    int         transact_cnt;   // number of test transaction
    int         transact_bad_cnt;
    int         sel_0_bad_cnt;
    int         sel_1_bad_cnt;
    int         sel_2_bad_cnt;
    int         sel_3_bad_cnt;
    logic       is_bad_transact;
    int         total_errors;


    // Пользуйтесь этой структурой
    typedef struct {
        logic  [3:0][1:0] sel;
        logic       [3:0] in;
        logic       [3:0] out;
    } packet;

    mailbox#(packet) mon2chk = new();
>>>>>>> 769a96cc8924089df6af59b00273aba374cf00b8

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
<<<<<<< HEAD
        repeat(10) begin
            @(posedge clk);
            in  <= $urandom();
            sel <= $urandom();
        end

        @(posedge clk);
=======
        repeat(5) begin
            @(posedge clk);
            in  <= $urandom();
            sel[3:0] <= {3, 2, 1, 0};
        end
        
        // clock_delay(5, clk, 1);
        repeat(5) @(posedge clk);
        
        repeat(20) begin
            @(posedge clk);
            rand_transact();
        end
        show_stat();
>>>>>>> 769a96cc8924089df6af59b00273aba374cf00b8
        $stop();
    end

    

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
        logic [1:0] sel_cur;        // current selection signal
        logic [3:0] in_cur;
        logic [3:0] out_routed;
        packet pkt_prev, pkt_cur;

        wait(aresetn);
        mon2chk.get(pkt_prev);
        forever begin
            transact_cnt++;
            mon2chk.get(pkt_cur);
<<<<<<< HEAD
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
=======
            is_bad_transact = 0;
            // Пишите здесь
            $display("\n============= Transaction #%0d ===============", transact_cnt);
            for(int i = 0; i < 4; i++) begin
                sel_cur    = pkt_prev.sel[i][1:0];
                in_cur     = pkt_prev.in[i];
                out_routed = pkt_cur.out[sel_cur];
                if( in_cur !==  out_routed) begin
                    error_handler(i);
                    $error("(%0t) Bad Routing:\nsel[%0d]=%0d,\n in[%0d]=%0d,\nout[%0d]=%0d",
                        $time(), i, sel_cur, i, in_cur, sel_cur, out_routed);
                end else begin
                    $display("(%0t) Good Routing:\nsel[%0d]=%0d,\n in[%0d]=%0d,\nout[%0d]=%0d",
                        $time(), i, sel_cur, i, in_cur, sel_cur, out_routed);
                end
                $display("----------------------------");
            end
            if(is_bad_transact)
                $display("BAD Transaction");
            else
                $display("GOOD Transaction");
            $display("In:  %b,\nSel: %0d%0d%0d%0d\nOut: %b",
                pkt_prev.in,
                pkt_prev.sel[0],
                pkt_prev.sel[1],
                pkt_prev.sel[2],
                pkt_prev.sel[3],
                pkt_cur.out
            );
            pkt_prev = pkt_cur;
            transact_bad_cnt = is_bad_transact ? (transact_bad_cnt+1) : transact_bad_cnt;
>>>>>>> 769a96cc8924089df6af59b00273aba374cf00b8
        end
    end

    task rand_transact();
        in  <= $urandom();
        std::randomize(sel) with { unique{ sel[0], sel[1], sel[2], sel[3] }; };
    endtask : rand_transact

    function void show_stat();
        $display(
            "\n\t@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
            "\n\t@         STATISTICS       @",
            "\n\t@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
            "\n\tTransactions sent:       %0d", transact_cnt,
            "\n\tBad transactions:        %0d", transact_bad_cnt,
            "\n\tBad sel[0] counter:      %0d", sel_0_bad_cnt,
            "\n\tBad sel[1] counter:      %0d", sel_1_bad_cnt,
            "\n\tBad sel[2] counter:      %0d", sel_2_bad_cnt,
            "\n\tBad sel[3] counter:      %0d", sel_3_bad_cnt,
            "\n\tTotal number of errors:  %0d", total_errors,
            "\n\t@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        );
    endfunction : show_stat

    function void error_handler(input int iter);
        is_bad_transact = 1;
        case(iter)
            0: sel_0_bad_cnt++;
            1: sel_1_bad_cnt++;
            2: sel_2_bad_cnt++;
            3: sel_3_bad_cnt++;
        endcase
        total_errors++;
    endfunction : error_handler

    task clock_delay(input int n=1, input clock=clk, input int is_posedge=1);
        if(is_posedge)
            repeat(n) @(posedge clock);
        else
            repeat(n) @(negedge clock);
    endtask : clock_delay

    task watchdog_timer();
        repeat(10000)
            @(posedge clk);
        $warning("Simulation was stopped by watchdog timer.");
        $stop();
    endtask
endmodule
