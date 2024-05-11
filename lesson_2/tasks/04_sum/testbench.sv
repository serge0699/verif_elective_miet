module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] C;

    sum DUT (
        .clk     ( clk     ),
        .aresetn ( aresetn ),
        .a       ( A       ),
        .b       ( B       ),
        .c       ( C       )
    );

    `include "checker.svh"

    // TODO:
    // Определите период тактового сигнала
    parameter CLK_PERIOD = 2; // ?;

    // TODO:
    // Cгенерируйте тактовый сигнал
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2) clk = ~clk; // Пишите тут.
        end
    end
    
    // Генерация сигнала сброса
    initial begin
        aresetn <= 0;
        #(CLK_PERIOD);
        aresetn <= 1;
    end

    // TODO:
    // Циклически сгенерируйте входные воздействия
    // в соответствии с заданием.

    // В конце симуляции будет выведена статистика о том, какая
    // часть из требуемых значений была подана. Для оценки того,
    // значения из какого интервала не были поданы, воспользуйтесь
    // отчетом 04_sum/stats/covsummary.html (отчет сформируется
    // после закрытия QuestaSim).

    // Для оценки вы также можете воспользоваться файлом 
    // 04_sum/out/cov.ucdb

    int k = 127;
    initial begin
        // Входные воздействия опишите здесь.
        // Не забудьте про ожидание сигнала сброса!
        wait(aresetn);

        // TODO:
        // A: от 0 до 100 с шагом  1
        // B: от 100 до 0 с шагом -1
        // Используйте for()
        // Помните про ожидание фронта через @(posedge clk).
        for (int i = 0; i <= 100; i++) begin
            @(posedge clk);
            A <= i;
            B <= (100 - i);
        end

        // TODO:
        // A: от 127 до 255 с шагом 4
        // B: от 127 до 255 с шагом 4
        // Используйте repeat()
        // Помните про ожидание фронта через @(posedge clk).
        repeat(32) begin
            @(posedge clk);
            A <= k;
            B <= k;
            k += 4;
        end

        // TODO:
        // A: от 3FF до 103FE с шагом 5
        // B: от FFFFFFFF до FFFFBFFF с шагом -32
        // Используйте for()
        // Помните про ожидание фронта через @(posedge clk).
        fork
            begin
                for (int i = 'h3FF; i < 'h103FE; i += 5) begin
                    @(posedge clk);
                    A <= i;
                end
            end

            begin
                for(int j = 'hFFFF_FFFF; j >= 'hFFFF_BFFF; j -= 32) begin
                    @(posedge clk);
                    B <= j;
                end
            end
        join


        ->> gen_done;

    end

endmodule
