`timescale 1ns/1ps

localparam CLK_PERIOD = 10;

// operator codes parameters
localparam OPCODE_ADD = 0;  // tid = 0 : tdata_1  + tdata_2
localparam OPCODE_SUB = 1;  // tid = 1 : tdata_1  - tdata_2
localparam OPCODE_MUL = 2;  // tid = 2 : tdata_1  * tdata_2
localparam OPCODE_SLL = 3;  // tid = 3 : tdata_1 << tdata_2

// Error parameters
localparam GOOD_TID             = 0;
localparam TID_IN_IN_MISMATCH   = 1;
localparam TID_IN_OUT_MISMATCH  = 2;

localparam GOOD_TDATA       = 0;
localparam ADD_ERROR_CODE   = OPCODE_ADD + 1;
localparam SUB_ERROR_CODE   = OPCODE_SUB + 1;
localparam MUL_ERROR_CODE   = OPCODE_MUL + 1;
localparam SLL_ERROR_CODE   = OPCODE_SLL + 1;

// Test initial values
int init_gen_pkt_amount   = 100;
int init_gen_delay_min    = 0;
int init_gen_delay_max    = 10;
int init_slave_delay_min  = 0;
int init_slave_delay_max  = 10;
int init_timeout_cycles   = 100000;

// Metrica counters
int tid_ii_mismatch_cnt;    // Counter of different tids for the first and the second operands
int tid_io_mismatch_cnt;    // Counter of different tids for both operands and output result

int pkts_sent_cnt;          // Sent packets counter

int add_error_cnt;          // Addition error counter
int sub_error_cnt;          // Subtraction error counter
int mul_error_cnt;          // Multiplication error counter
int sll_error_cnt;          // Shift left logic error counter
int good_calc_cnt;          // Goog calculation counter
int all_error_cnt;          // Number of error counter

module testbench;


    //---------------------------------
    // Сигналы
    //---------------------------------

    logic        clk;
    logic        aresetn;

    logic        s_tvalid;
    logic        s_tready;
    logic [31:0] s_tdata;
    logic [ 1:0] s_tid;

    logic        m_tvalid;
    logic        m_tready;
    logic [31:0] m_tdata;
    logic [ 1:0] m_tid;


    //---------------------------------
    // Модуль для тестирования
    //---------------------------------

    alu DUT(
        .clk      ( clk       ),
        .aresetn  ( aresetn   ),
        .s_tvalid ( s_tvalid  ),
        .s_tready ( s_tready  ),
        .s_tdata  ( s_tdata   ),
        .s_tid    ( s_tid     ),
        .m_tvalid ( m_tvalid  ),
        .m_tready ( m_tready  ),
        .m_tdata  ( m_tdata   ),
        .m_tid    ( m_tid     )
    );


    //---------------------------------
    // Переменные тестирования
    //---------------------------------

    // Период тактового сигнала
    parameter CLK_PERIOD = 10;

    // Пакет и mailbox'ы
    typedef struct {
        rand int          delay;
        rand logic [31:0] tdata;
        rand logic [ 1:0] tid;
    } packet;

    mailbox#(packet) gen2drv = new();
    mailbox#(packet) in_mbx  = new();
    mailbox#(packet) out_mbx = new();

    // Генерация тактового сигнала
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2) clk <= ~clk;
        end
    end

    //---------------------------------
    // Методы
    //---------------------------------

    // Генерация сигнала сброса
    task reset();
        aresetn <= 0;
        #(CLK_PERIOD);
        aresetn <= 1;
    endtask

    // Таймаут теста
    task timeout(int timeout_cycles = 100000);
        repeat(timeout_cycles) @(posedge clk);
        $stop();
    endtask

    initial begin

    end

    // TODO:
    // Реализуйте тестовое окружение для проверки ALU.
    // Рекомендуется использовать подход, основанный
    // на задачах и разделении master/slave. В качестве
    // примера может выступать ../examples/13_pow/.
    //
    // Обратите внимание, что существует 5 версий дизайна,
    // которые выбираются при запуске симуляции следующим
    // образом:
    //   make <аргумента> COMP_OPTS=+define+VERSION_<номер-версии>
    //
    // Полное описание работы ALU находится в файле alu.svp


// ==================== Master's Tasks ====================

// -------------------- reset_master --------------------
    task reset_master();
        wait(~aresetn);
        s_tvalid <= 0;
        // s_tready <= 0;
        s_tdata  <= 0;
        s_tid    <= 0;
        wait(aresetn);
    endtask : reset_master

// -------------------- gen_master --------------------
    task gen_master(
        int delay_min  = 0,
        int delay_max  = 10
    );
        packet pkt;
        int operator;
        int operand1;
        int operand2;

        if(!std::randomize(pkt) with {pkt.delay inside {[delay_min:delay_max]};}) begin
            $error("Cannot randomize a packet!");
            $finish();
        end
        gen2drv.put(pkt);
    endtask : gen_master

// -------------------- do_master_gen --------------------
    task do_master_gen(
        int pkt_amount = 1,
        int delay_min  = 0,
        int delay_max  = 10
    );
        repeat(pkt_amount) begin
            gen_master(delay_min, delay_max);
        end
    endtask : do_master_gen

// -------------------- drive_master --------------------
    task drive_master(packet pkt);
        repeat(pkt.delay)
            @(posedge clk);
        s_tvalid <= 1;
        // s_tready <= 1;
        s_tdata  <= pkt.tdata;
        s_tid    <= pkt.tid;
        do begin
            @(posedge clk);
        end while(~s_tready);
        s_tvalid <= 0;
    endtask : drive_master

// -------------------- do_master_drive --------------------
    task do_master_drive();
        packet pkt;
        reset_master();
        @(posedge clk);
        forever begin
            gen2drv.get(pkt);
            drive_master(pkt);
        end
    endtask : do_master_drive

// -------------------- monitor_master --------------------
    task monitor_master();
        packet pkt;
        @(posedge clk);
        if(s_tvalid & s_tready) begin
            pkt.tdata  = s_tdata;
            pkt.tid    = s_tid;
            in_mbx.put(pkt);
        end
    endtask : monitor_master

// -------------------- do_monitor_master --------------------
    task do_master_monitor();
        wait(aresetn);
        forever begin
            monitor_master();
        end
    endtask : do_master_monitor

// -------------------- master (task) --------------------
    task master(
        int gen_pkt_amount = 1,
        int gen_delay_min  = 0,
        int gen_delay_max  = 10
    );
        fork
            do_master_gen(gen_pkt_amount, gen_delay_min, gen_delay_max);
            do_master_drive();
            do_master_monitor();
        join
    endtask : master

// ==================== Slave's Tasks ====================

// -------------------- reset_slave  --------------------
    task reset_slave();
        wait(~aresetn);
        m_tready <= 0;
        // m_tvalid <= 0;
        // m_tdata  <= 0;
        // m_tid    <= 0;
        wait(aresetn);
    endtask : reset_slave

// -------------------- drive_slave --------------------
    task drive_slave(
        int delay_min  = 0,
        int delay_max  = 10
    );
        int delay;
        delay = $urandom_range(delay_min, delay_max);
        repeat(delay) @(posedge clk);
        // m_tvalid <= 1;
        m_tready <= 1;
        @(posedge clk);
        // m_tvalid <= 0;
        m_tready <= 0;
    endtask : drive_slave

// -------------------- do_slave_drive --------------------
    task do_slave_drive(
        int delay_min  = 0,
        int delay_max  = 10
    );
        reset_slave();
        @(posedge clk);
        forever drive_slave(delay_min, delay_max);
    endtask : do_slave_drive

// --------------------  --------------------
    task monitor_slave();
        packet pkt;
        @(posedge clk);
        if(m_tvalid & m_tready) begin
            pkt.tdata  = m_tdata;
            pkt.tid    = m_tid;
            out_mbx.put(pkt);
        end
    endtask : monitor_slave

// -------------------- do_slave_monitor --------------------
    task do_slave_monitor();
        wait(aresetn);
        forever begin
            monitor_slave();
        end
    endtask : do_slave_monitor

// -------------------- slave (task) --------------------
    task slave(
        int delay_min  = 0,
        int delay_max  = 10
    );
        fork
            do_slave_drive(delay_min, delay_max);
            do_slave_monitor();
        join
    endtask : slave

// ==================== Check tasks/functions ====================

// -------------------- compare_packets (check) --------------------
    function compare_packets(
        input   packet in_1,
        input   packet in_2,
        input   packet out,
        output  int    tdata_mismatch,
        output  int    tid_mismatch,
        output  int    different_tids
    );

        // int tdata_mismatch;
        // int tid_mismatch;
        different_tids = 0;

        if(in_1.tid !== in_2.tid) begin
            tid_mismatch = TID_IN_IN_MISMATCH;
            different_tids = 1;
        end else begin
            tid_mismatch = GOOD_TID;
            if(in_1.tid !== out.tid) begin
                tid_mismatch = TID_IN_OUT_MISMATCH;
            end else begin
                case(in_1.tid)
                    OPCODE_ADD: tdata_mismatch = (in_1.tdata +  in_2.tdata !== out.tdata) ? ADD_ERROR_CODE : GOOD_TDATA;
                    OPCODE_SUB: tdata_mismatch = (in_1.tdata -  in_2.tdata !== out.tdata) ? SUB_ERROR_CODE : GOOD_TDATA;
                    OPCODE_MUL: tdata_mismatch = (in_1.tdata *  in_2.tdata !== out.tdata) ? MUL_ERROR_CODE : GOOD_TDATA;
                    OPCODE_SLL: tdata_mismatch = (in_1.tdata << in_2.tdata !== out.tdata) ? SLL_ERROR_CODE : GOOD_TDATA;
                endcase
            end
        end
        return 0;
    endfunction : compare_packets

// -------------------- show_comparison_info --------------------
    function show_comparison_info(
        input packet in_1,
        input packet in_2,
        input packet out,
        input int    tdata_mismatch,
        input int    tid_mismatch
    );

        automatic string op_type = "UNDEFINED";

        case(tid_mismatch)
            TID_IN_IN_MISMATCH:     $warning("[%0t] tids are not equal: in_1.tid=%0d; in_2.tid=%0d.",
                                       $time(), in_1.tid, in_2.tid);
            TID_IN_OUT_MISMATCH:    $error("[%0t] tids are not equal: in_X.tid=%0d; out.tid=%0d.",
                                       $time(), in_1.tid, out.tid);
            GOOD_TID: begin
                $display("[%0t] Good tid=%0d.", $time(), in_1.tid);
                case(in_1.tid)
                    OPCODE_ADD: op_type = "ADD";
                    OPCODE_SUB: op_type = "SUB";
                    OPCODE_MUL: op_type = "MUL";
                    OPCODE_SLL: op_type = "SLL";
                    default: begin
                        op_type = "UNKNOWN";
                        $fatal("[%0t] Unknown operation inside show_comparison_info, (in_1.tid = %0d).", $time(), in_1.tid);
                        return 1;
                    end
                endcase
                case(tdata_mismatch)
                    ADD_ERROR_CODE: $error({"[%0t] Wrong ADD calculation:\n",
                                        "1st operand:in_1.tdata=%0d; in_2.tdata=%0d; expected=%0d; out.tdata=%0d"},
                                        $time(), in_1.tdata, in_2.tdata, (in_1.tdata +  in_2.tdata), out.tdata);
                    SUB_ERROR_CODE: $error({"[%0t] Wrong SUB calculation:\n",
                                        "1st operand:in_1.tdata=%0d; in_2.tdata=%0d; expected=%0d; out.tdata=%0d"},
                                        $time(), in_1.tdata, in_2.tdata, (in_1.tdata -  in_2.tdata), out.tdata);
                    MUL_ERROR_CODE: $error({"[%0t] Wrong MUL calculation:\n",
                                        "1st operand:in_1.tdata=%0d; in_2.tdata=%0d; expected=%0d; out.tdata=%0d"},
                                        $time(), in_1.tdata, in_2.tdata, (in_1.tdata *  in_2.tdata), out.tdata);
                    SLL_ERROR_CODE: $error({"[%0t] Wrong SLL calculation:\n",
                                        "1st operand:in_1.tdata=%0d; in_2.tdata=%0d; expected=%0d; out.tdata=%0d"},
                                        $time(), in_1.tdata, in_2.tdata, (in_1.tdata << in_2.tdata), out.tdata);
                    GOOD_TDATA:     $display("[%0t] Good %s operation!", $time(), op_type);
                    default: begin
                        $fatal("Unknown tdata_mismatch value = 0x%0h inside show_comparison_info().", tdata_mismatch);
                        return 2;
                    end
                endcase
            end
            default:    $fatal("[%0t] Unknown tid_mismatch value = %0d inside show_comparison_info.", $time(), tid_mismatch);
        endcase
        return 0;
    endfunction : show_comparison_info

// -------------------- metrics_collector --------------------
    function metrics_collector(input int tid_mismatch, input int tdata_mismatch);
        case(tid_mismatch)
            TID_IN_IN_MISMATCH:     tid_ii_mismatch_cnt++;
            TID_IN_OUT_MISMATCH:    tid_io_mismatch_cnt++;
            GOOD_TID: begin
                case(tdata_mismatch)
                    ADD_ERROR_CODE: add_error_cnt++;
                    SUB_ERROR_CODE: sub_error_cnt++;
                    MUL_ERROR_CODE: mul_error_cnt++;
                    SLL_ERROR_CODE: sll_error_cnt++;
                    GOOD_TDATA:     good_calc_cnt++;
                    default: begin
                        $fatal("Unknown tdata_mismatch value = 0x%0h inside metrics_collector().", tdata_mismatch);
                        return 1;
                    end
                endcase
            end
            default: begin
                return 2;
            end
        endcase
        all_error_cnt = tid_ii_mismatch_cnt + tid_io_mismatch_cnt + add_error_cnt + sub_error_cnt + mul_error_cnt + sll_error_cnt;
        return 0;
    endfunction : metrics_collector

    function void show_metrics();
        $display(
            "\n\t+---------------------------+",
            "\n\t|          METRICS          |",
            "\n\t+---------------------------+",
            "\n\t| Packets sent:           %0d", pkts_sent_cnt,
            "\n\t| tid i/i mismatches:     %0d", tid_ii_mismatch_cnt,
            "\n\t| tid i/o mismatches:     %0d", tid_io_mismatch_cnt,
            "\n\t| ADD (+)  errors:        %0d", add_error_cnt,
            "\n\t| SUB (-)  errors:        %0d", sub_error_cnt,
            "\n\t| MUL (*)  errors:        %0d", mul_error_cnt,
            "\n\t| SLL (<<) errors:        %0d", sll_error_cnt,
            "\n\t| Total number of errors: %0d", all_error_cnt,
            "\n\t+---------------------------+"
        );
    endfunction : show_metrics

// -------------------- do_check --------------------
    task do_check (int pkt_amount = 1);
        packet pkt_oper_1;
        packet pkt_oper_2;
        packet pkt_result;

        int    pkt_cnt;
        int    tid_check_res;
        int    tdata_check_res;
        int    is_not_a_pair;
        // int    same_tid_in_row;

        wait(aresetn);
        in_mbx.get(pkt_oper_1);

        forever begin
            in_mbx.get(pkt_oper_2);
            out_mbx.get(pkt_result);

            void'(compare_packets(
                    pkt_oper_1,
                    pkt_oper_2,
                    pkt_result,
                    tid_check_res,
                    tdata_check_res,
                    is_not_a_pair));

            void'(metrics_collector(tid_check_res, tdata_check_res));

            if((tid_check_res == GOOD_TID) && (tdata_check_res == GOOD_TDATA)) begin
                $display("[%0t] GOOD OPERATION", $time());
                in_mbx.get(pkt_oper_1);
                continue;
            end else if(is_not_a_pair) begin
                $display("[%0t] NOT A PAIR -> continue", $time());
                // same_tid_in_row = 0;
                pkt_oper_1      = pkt_oper_2;
                continue;
            end else begin
                $display("[%0t] BAD OPERATION", $time());
                in_mbx.get(pkt_oper_1);
                continue;
            end

            void'(show_comparison_info(
                pkt_oper_1,       // input
                pkt_oper_2,       // input
                pkt_result,       // input
                tid_check_res,    // input
                tdata_check_res   // input
            ));
        end
    endtask : do_check

//  ======================== TEST ===============================
    task test(
        int gen_pkt_amount   = 100,   // количество пакетов
        int gen_delay_min    = 0,     // мин. задержка между транзакциями
        int gen_delay_max    = 10,    // макс. задержка между транзакциями
        int slave_delay_min  = 0,     // минимальная задержка для slave
        int slave_delay_max  = 10,    // максимальная задержка для slave
        int timeout_cycles   = 100000 // таймаут теста
    );
        fork
            master      (gen_pkt_amount, gen_delay_min, gen_delay_max);
            slave       (slave_delay_min, slave_delay_max);
            do_check    (gen_pkt_amount);
            timeout     (timeout_cycles);
        join
    endtask : test

    initial begin
        fork
            reset();
        join_none
        test(
            .gen_pkt_amount     (init_gen_pkt_amount),
            .gen_delay_min      (init_gen_delay_min),
            .gen_delay_max      (init_gen_delay_max),
            .slave_delay_min    (init_slave_delay_min),
            .slave_delay_max    (init_slave_delay_max),
            .timeout_cycles     (init_timeout_cycles)
        );
    end
endmodule