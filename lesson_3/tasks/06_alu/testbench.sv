`timescale 1ns/1ps

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
        .s_tvalid ( s_tvalid  ),//in
        .s_tready ( s_tready  ),//out
        .s_tdata  ( s_tdata   ),//in
        .s_tid    ( s_tid     ),//in
        .m_tvalid ( m_tvalid  ),//out
        .m_tready ( m_tready  ),//in
        .m_tdata  ( m_tdata   ),//out
        .m_tid    ( m_tid     )//out
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
    //   make EXAMPLE=06_alu EXT_POSTFIX=svp COMP_OPTS=+define+VERSION_0
    // Полное описание работы ALU находится в файле alu.svp
    
    // Master
    task gen_master(
        int delay_min  = 0,
        int delay_max  = 10
    );
        packet p;
            if( !std::randomize(p) with {
                p.delay inside {[delay_min:delay_max]};
            } ) begin
                $error("Can't randomize packet!");
                $finish();
            end
            gen2drv.put(p);
        //end
    endtask

    task do_master_gen(
        int pkt_amount = 100,
        int delay_min  = 0,
        int delay_max  = 10
    );
        repeat(pkt_amount) begin
            gen_master(delay_min, delay_max);
        end
    endtask

    task reset_master();
        wait(~aresetn);
        s_tvalid <= 0;
        s_tdata  <= 0;
        s_tid    <= 0;
        wait(aresetn);
    endtask

    task drive_master(packet p);
        repeat(p.delay) @(posedge clk);
        s_tvalid <= 1;
        s_tdata  <= p.tdata;
        s_tid    <= p.tid;
        do begin
            @(posedge clk);
        end
        while(~s_tready);
        s_tvalid <= 0;
    endtask

    task do_master_drive();
        packet p;
        reset_master();
        @(posedge clk);
        forever begin
            gen2drv.get(p);
            drive_master(p);
        end
    endtask

    task monitor_master();
        packet p;
        @(posedge clk);
        if( s_tvalid & s_tready ) begin
            p.tdata  = s_tdata;
            p.tid    = s_tid;
            $display("//////////////////");
            $display("GEN IN:%0t p.tdata = %h, p.tid = %h", $time(), p.tdata, p.tid);
            in_mbx.put(p);
        end
    endtask

    task do_master_monitor();
        wait(aresetn);
        forever begin
            monitor_master();
        end
    endtask

    // Master
    task master(        
        int gen_pkt_amount = 100,
        int gen_delay_min  = 0,
        int gen_delay_max  = 10
    );
        fork
            do_master_gen(gen_pkt_amount, gen_delay_min, gen_delay_max);
            do_master_drive();
            do_master_monitor();
        join
    endtask

    // Slave
    task reset_slave();
        wait(~aresetn);
        m_tready <= 0;
        wait(aresetn);
    endtask

    task drive_slave(
        int delay_min  = 0,
        int delay_max  = 10
    );
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min:delay_max]};});
        repeat(delay) @(posedge clk);
        m_tready <= 1;
        @(m_tvalid);////////
        @(posedge clk);
        m_tready <= 0;
    endtask

    task do_slave_drive(
        int delay_min  = 0,
        int delay_max  = 10
    );
        reset_slave();
        @(posedge clk);
        forever begin
            drive_slave(delay_min, delay_max);
        end
    endtask

    task monitor_slave();
        packet p;
        @(posedge clk);
        if( m_tvalid & m_tready ) begin
            p.tdata  = m_tdata;
            p.tid    = m_tid;
            $display("//////////////////");
            $display("GEN OUT:%0t p.tdata = %h, p.tid = %h", $time(), p.tdata, p.tid);
            out_mbx.put(p);
        end
    endtask

    task do_slave_monitor();
        wait(aresetn);
        forever begin
            monitor_slave();
        end
    endtask

    // Slave
    task slave(
        int delay_min  = 0,
        int delay_max  = 10
    );
        fork
            do_slave_drive(delay_min, delay_max);
            do_slave_monitor();
        join
    endtask

    // Проверка
    task check(packet pre_in, packet in, packet out);
        if( (in.tid !== pre_in.tid) || (in.tid !== out.tid)) begin
            $error("Invalid TID: v 1 moment: %h, v0 2 momet: %h, operacia: %h",
                pre_in.tid, in.tid, out.tid);
        end   
        case(out.tid)
            0:begin
                if(out.tdata !== (pre_in.tdata + in.tdata)) begin
                $error("Invalid TDATA: Real: %0h, Expected: %0h + %0h = %0h",
                    out.tdata, pre_in.tdata, in.tdata, (pre_in.tdata + in.tdata));
                end
            end
            1:begin
                if(out.tdata !== (pre_in.tdata - in.tdata)) begin
                $error("Invalid TDATA: Real: %0h, Expected: %0h - %0h = %0h",
                    out.tdata, pre_in.tdata, in.tdata, (pre_in.tdata - in.tdata));
                end
            end
            2:begin
                if(out.tdata !== (pre_in.tdata * in.tdata)) begin
                $error("Invalid TDATA: Real: %0h, Expected: %0h * %0h = %0h",
                    out.tdata, pre_in.tdata, in.tdata, (pre_in.tdata * in.tdata));
                end
            end
            3:begin
                if(out.tdata !== (pre_in.tdata << in.tdata)) begin
                $error("Invalid TDATA: Real: %0h, Expected: %0h << %0h = %0h",
                    out.tdata, pre_in.tdata, in.tdata, (pre_in.tdata << in.tdata));
                end
            end
        endcase
    endtask

    task do_check(int pkt_amount = 1);
        int cnt;
        packet pre_in_p, in_p, out_p;
        forever begin
            in_mbx.get(pre_in_p);
            if(pre_in_p.tid === in_p.tid) begin
                out_mbx.get(out_p);
                $display("ISCLUCHENIE OSHIBKI: pre_in_p.tid = %h, in_p.tid = %h, out_p.tid = %h", pre_in_p.tid, in_p.tid, out_p.tid);
            end
            in_mbx.get(in_p);
            cnt = cnt + 2;
            if( cnt == pkt_amount ) begin
                break;
            end
            while(pre_in_p.tid !== in_p.tid) begin
                pre_in_p <= in_p;
                in_mbx.get(in_p);
                cnt = cnt + 1;
                if( cnt == pkt_amount ) begin
                    break;
                end
            end
            out_mbx.get(out_p);
            $display("///////////////////////////////////////////");
            $display("cnt = %0d", cnt);
            $display("%0t pre_in_p.tdata = %h, in_p.tdata = %h, out_p.tdata = %h", $time(), pre_in_p.tdata, in_p.tdata, out_p.tdata);
            $display("pre_in_p.tid = %h, in_p.tid = %h, out_p.tid = %h", pre_in_p.tid, in_p.tid, out_p.tid);
            check(pre_in_p, in_p, out_p);
            //cnt = cnt + 1;
        end
        $stop();
    endtask

    task error_checker(int pkt_amount = 1);
        do_check(pkt_amount);
    endtask
    
    
    //---------------------------------
    // Выполнение
    //---------------------------------

    // Генерация тактового сигнала
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2) clk <= ~clk;
        end
    end

    task test(
        int gen_pkt_amount   = 100,   // количество пакетов 
        int gen_delay_min    = 0,     // мин. задержка между транзакциями
        int gen_delay_max    = 10,    // макс. задержка между транзакциями
        int slave_delay_min  = 0,     // минимальная задержка для slave
        int slave_delay_max  = 10,    // максимальная задержка для slave
        int timeout_cycles   = 100000 // таймаут теста
    );
        fork
            master       (gen_pkt_amount, gen_delay_min, gen_delay_max);
            slave        (slave_delay_min, slave_delay_max);
            error_checker(gen_pkt_amount);
            timeout      (timeout_cycles);
        join
    endtask

    initial begin
        fork
            reset();
        join_none
        test(
            .gen_pkt_amount (   1000),
            .gen_delay_min  (      1),
            .gen_delay_max  (      1),
            .slave_delay_min(      1),
            .slave_delay_max(      1),
            .timeout_cycles ( 10000)
        );
    end


endmodule

module tb_alu();

    //import alu_opcodes_pkg::*;

    parameter TEST_VALUES     = 1000;

    logic clk = 0;
    always #5ns clk = ~clk;

    logic [4:0]  operator_i;
    logic [31:0] operand_a_i;
    logic [31:0] operand_b_i;

    task result_test();
        repeat(TEST_VALUES)
        begin
            operator_i  = $urandom_range(4'b1111);
            operand_a_i = $urandom();
            operand_b_i = $urandom();
            @(posedge clk);
        end
    endtask

    testbench my_tb();

endmodule