`timescale 1ns/100ps
// make EXAMPLE=05_router SIM_OPTS=-gui\ -sv_seed\ random EXT_POSTFIX=svp
module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic  [3:0][1:0] sel;
    logic       [3:0] in;
    logic       [3:0] out;

    int         transact_cnt;   // number of test transaction
    int         transact_bad_cnt;
    int         sel_0_bad_cnt;
    int         sel_1_bad_cnt;
    int         sel_2_bad_cnt;
    int         sel_3_bad_cnt;
    int         correctness_unknown_cnt;

    logic       is_bad_transact;
    int         total_errors;
    logic       is_correctness_unknown;

    // Пользуйтесь этой структурой
    typedef struct {
        logic  [3:0][1:0] sel;
        logic       [3:0] in;
        logic       [3:0] out;
    } packet;

    logic [1:0] sel_cur;        // current selection signal
    logic [3:0] in_cur;
    logic [3:0] out_routed;

    logic [3:0][1:0] sel_all_cur;
    logic [3:0] in_all_cur;
    logic [3:0] out_all_cur;
    packet pkt_prev, pkt_cur;


    mailbox#(packet) mon2chk = new();

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

        // gen_tr_unique_sel($urandom_range(15, 30));
        
        show_stat();
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
    initial begin
        // $display("(%0t) [TEST] check before reset", $time());
        wait(aresetn);
        // $display("(%0t) [TEST] check after reset", $time());
        mon2chk.get(pkt_prev);
        forever begin
            // $display("(%0t) [TEST] Check forever loop", $time());
            transact_cnt++;
            mon2chk.get(pkt_cur);
            is_correctness_unknown = 0;
            is_bad_transact        = 0;

            sel_all_cur = pkt_prev.sel;
            in_all_cur  = pkt_prev.in;
            out_all_cur = pkt_cur.out;

            if(in_all_cur === 4'hF || in_all_cur === 4'h0) begin
                is_correctness_unknown = 1;
                $warning("(%0t) The correctness of routing is unknown: in[3:0] = %0d.",
                    $time(), in_all_cur);
            end

            // Transaction detail info
            $display("\n============= Transaction #%0d ===============", transact_cnt);
            for(int i = 0; i < 4; i++) begin
                // $display("(%0t) [TEST] Check for loop i=%0d", $time(), i);
                sel_cur     = sel_all_cur[i][1:0];
                in_cur      = in_all_cur[i];
                out_routed  = out_all_cur[sel_cur];

                if( in_cur !==  out_routed) begin
                    error_handler(i);
                    $error("(%0t) Bad Routing:\nsel[%0d]=%0d,\n in[%0d]=%0d,\nout[%0d]=%0d.",
                        $time(), i, sel_cur, i, in_cur, sel_cur, out_routed);
                end
                else begin
                    $display("(%0t) Good Routing:\nsel[%0d]=%0d,\n in[%0d]=%0d,\nout[%0d]=%0d.",
                        $time(), i, sel_cur, i, in_cur, sel_cur, out_routed);
                end
                $display("----------------------------");
            end
            // $display("(%0t) [TEST] Check after For loop", $time());
            // Transaction summary
            if(is_bad_transact) begin
                $display("Transaction #%0d FAILURE.", transact_cnt);
                transact_bad_cnt++;
            end
            else if(is_correctness_unknown) begin
                correctness_unknown_cnt++;
                $display("Transaction #%0d SUCCESS (???).", transact_cnt);
            end
            else
                $display("Transaction #%0d SUCCESS.", transact_cnt);

            $display("Sel: %0d%0d%0d%0d,\nIn:  %b,\nOut: %b.",
                sel_all_cur[0],
                sel_all_cur[1],
                sel_all_cur[2],
                sel_all_cur[3],
                pkt_prev.in,
                pkt_cur.out
            );
            // $display("(%0t) [TEST] Check before preparation", $time());
            // Preparing to the next transaction
            pkt_prev = pkt_cur;
            // $display("(%0t) [TEST] Check after preparation", $time());
        end
    end

    // task check_tr();
    //     wait(aresetn);

    //     mon2chk.get(pkt_prev);

    //     forever begin
    //         mon2chk.get(pkt_cur);

    //         is_correctness_unknown = 0;
    //         is_bad_transact        = 0;

    //         sel_all_cur = pkt_prev.sel;
    //         in_all_cur  = pkt_prev.in;
    //         out_all_cur = pkt_cur.out;



    //         pkt_prev = pkt_cur;
    //     end
    // endtask : check_tr

    // Generate transaction with unique select signal
    task gen_tr_unique_sel(int tr_amount = 1);
        repeat(tr_amount) begin
            logic [3:0][1:0] tmp;
            // $display("(%0t) [TEST] rand_trans before posedge", $time());
            @(posedge clk);
            // $display("(%0t) [TEST] rand_trans started!", $time());
            in  <= $urandom();
            std::randomize(tmp) with { unique{ tmp[0], tmp[1], tmp[2], tmp[3] }; };
            sel <= tmp;
        end
    endtask : gen_tr_unique_sel

    // task gen_tr(int tr_amount = 1);
    //     logic [3:0] tmp;
    //     repeat(tr_amount) begin
    //         @(posedge clk);
    //         in  <= $urandom();
    //         tmp = $urandom();
    //         for(int i = 0; i < 4; i++)
    //             for(int j = i+1; j < 3; j++)
    //                 if(tmp[i] === tmp[j])
    //                     sel[]

    //         // sel <= $urandom();
    //     end
    // endtask : gen_tr

    task gen_all_cases;
        for(int i = 0; i < 16; i++) begin
            for(int j = 0; j < 16; k++) begin
                in  <= i;
                sel <= j;
            end
        end
    endtask

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
            "\n\tUnknown correctness:     %0d", correctness_unknown_cnt,
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

    // task clock_delay(input int n=1, ref logic clock=clk, input int is_posedge=1);
    //     if(is_posedge)
    //         repeat(n) @(posedge clock);
    //     else
    //         repeat(n) @(negedge clock);
    // endtask : clock_delay

    task watchdog_timer();
        repeat(10000)
            @(posedge clk);
        $warning("Simulation was stopped by watchdog timer.");
        $stop();
    endtask
endmodule
