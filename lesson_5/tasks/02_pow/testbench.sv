`timescale 1ns/1ps

module testbench;

    //---------------------------------
    // Импорт паккейджа тестирования
    //---------------------------------

    import test_pkg::*;


    //---------------------------------
    // Сигналы
    //---------------------------------

    logic        clk;
    logic        aresetn;


    //---------------------------------
    // Интерфейс
    //---------------------------------

    axis_intf intf_master (clk, aresetn);
    axis_intf intf_slave  (clk, aresetn);


    //---------------------------------
    // Модуль для тестирования
    //---------------------------------

    pow DUT(
        .clk      ( clk                 ),
        .aresetn  ( aresetn             ),
        .s_tvalid ( intf_master.tvalid  ),
        .s_tready ( intf_master.tready  ),
        .s_tdata  ( intf_master.tdata   ),
        .s_tid    ( intf_master.tid     ),
        .s_tlast  ( intf_master.tlast   ),
        .m_tvalid ( intf_slave.tvalid   ),
        .m_tready ( intf_slave.tready   ),
        .m_tdata  ( intf_slave.tdata    ),
        .m_tid    ( intf_slave.tid      ),
        .m_tlast  ( intf_slave.tlast    )
    );


    //---------------------------------
    // Переменные тестирования
    //---------------------------------

    // Период тактового сигнала
    parameter CLK_PERIOD = 10;


    //---------------------------------
    // Общие методы
    //---------------------------------

    // Генерация сигнала сброса
    task reset();
        aresetn <= 0;
        #(100*CLK_PERIOD);
        aresetn <= 1;
    endtask


    // TODO:
    // Создайте класс драйвера мастера
    // (отнаследуйтесь от 'master_driver_base'),
    // который в конце каждого пакета делает
    // дополнительную задержку в 100 тактов.

    class master_driver_delay_after_tlast extends master_driver_base;
        virtual task drive_master(packet p);
            super.drive_master(p);
            if(p.tlast)
                repeat(100) @(posedge vif.clk);
        endtask
    endclass


    // TODO:
    // Создайте тестовый сценарий, в котором замените
    // базовый драйвер мастера на новый, который создали.
    // Обратите внимание на то, что при переопределении
    // драйвера поля нового драйвера необходимо также
    // проинициализировать.
    class test_delay_after_tlast extends test_base;
        master_driver_delay_after_tlast master_driver;
        function new(
            virtual axis_intf intf_master,
            virtual axis_intf intf_slave
        );
            super.new(intf_master, intf_slave);

            // replace the driver
            master_driver         = new();
            master_driver.cfg     = cfg;
            master_driver.gen2drv = gen2drv;
            master_driver.vif     = intf_master;

            env.master.master_driver = master_driver;


        endfunction
    endclass


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

    // TODO:
    // Запустите новый тестовый сценарий

    initial begin
        test_delay_after_tlast test;
        test = new(intf_master, intf_slave);
        fork
            reset();
            test.run();
        join_none
        repeat(1000) @(posedge clk);
        // Сброс в середине теста
        reset();
    end

endmodule
