module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] c;

    sum DUT(
        .clk     ( clk     ),
        .aresetn ( aresetn ),
        .a       ( a       ),
        .b       ( b       ),
        .c       ( c       )
    );

    `include "generator.svh"

    // TODO:
    // В ходе тестирования на порты 'a' и 'b'
    // подаются некоторые значения. Проанализируйте
    // модель покрытия и результаты сбора покрытия
    // (используйте GUI).
    // Добавьте генерацию недостающих входных значений
    // и добейтесь покрытия в 100%.

    // 283 cycles synth school best record
    int a_cycles = 0;
    int b_cycles = 0;

    task send_a (int a_val);
        @(posedge clk);
        a <= a_val;
        a_cycles++;
    endtask

    task send_b (int b_val);
        @(posedge clk);
        b <= b_val;
        b_cycles++;
    endtask

    task send_a_b (int a_val, int b_val);
        fork
            send_a(a_val);
            send_b(b_val);
        join
    endtask

    initial begin
        @done;
        // TODO:
        // Добавьте недостающие входные воздействия здесь.
        $display("[%0t] Direct tests are running.", $time());
        fork
            begin
                // a_i_cp.low in [2:49]
                for(int i = 2; i <= 49; i++)
                    send_a(i);

                // a_i_cp.mid even in [100:170]
                for(int i = 100; i <= 170; i += 2)
                    send_a(i);
            end

            begin
                // b_i_cp.low [50:63]
                for(int i = 50; i <= 63; i++)
                    send_b(i);

                // b_i_cp.high odd in [173:253]
                for(int i = 173; i <= 253; i += 2)
                    send_b(i);
            end
        join

        // cross_1 [<MAX:mid[64]> - <MAX:mid[171]>]
        for(int i = 64; i <= 171; i++)
            send_a_b(255, i);

        // cross_2 [<HIGH[172]:0> - <HIGH[255]:0>]
        for(int i = 172; i <= 255; i++)
            send_a_b(i, 0);

        // cross_3
        begin
            send_a_b(1,   1  );
            send_a_b(9,   1  );
            send_a_b(0,   1  );
            send_a_b(9,   0  );
            send_a_b(0,   0  );
            send_a_b(9,   255);
            send_a_b(180, 255);
            send_a_b(255, 255);
        end

        $display("a_cycles = %0d, b_cycles = %0d", a_cycles, b_cycles);
        @(posedge clk);
        ->> user_done;
    end

    // TODO:
    // Анализируйте эту модель.
    // Особое внимание уделите перекрестному покрытию.
    covergroup sum_cg @(posedge clk);

        // Обычные coverpoint.

        // Интервалы для a (массивы).
        a_i_cp: coverpoint a {
            bins low  [] = {[0:63]};
            bins mid  [] = {[64:171]};
            bins high [] = {[172:255]};
        }

        // Интервалы для а (единичное попадание дает 100%).
        a_in_cp: coverpoint a {
            bins low  = {[0:63]};
            bins mid  = {[64:171]};
            bins high = {[172:255]};
        }

        // Интервалы для b.
        b_i_cp: coverpoint b {
            bins low  [] = {[0:63]};
            bins mid  [] = {[64:171]};
            bins high [] = {[172:255]};
        }

        // Специалльные значения для a.
        a_s_cp: coverpoint a {
            bins one       = {1};
            bins magics [] = {1, 9, 180};
            bins zero      = {0};
            bins max       = {255};
        }

        // Специальные значения для b.
        b_s_cp: coverpoint b {
            bins one  = {1};
            bins zero = {0};
            bins max  = {255};
        }

        // Перекрестное покрытие.

        // Этот cross создает пересечение всех bins из a_s_cp и a_s_cp.
        cross_1: cross a_s_cp, b_i_cp {
            // Этот фильтр исключает (ignore) все пересечения, в которых есть b - low и b - high.
            ignore_bins b_l_h = binsof(b_i_cp.low) || binsof(b_i_cp.high);
            // А что исключает этот?
            ignore_bins a_m_b_m = binsof(a_s_cp.one); // it excludes a = 1 bin
            // А этот?
            ignore_bins a_mag_b_m = binsof(a_s_cp.magics) && binsof(b_i_cp.mid); // excludes [1, 64], ... [1, 171]; [9, 64] ... [9, 171]; ...
        }

        // Этот cross создает пересечение всех bins из a_i_cp и b_s_cp.
        cross_2: cross a_i_cp, b_s_cp {
            // Этот фильтр исключает все пересечения, в которых есть a - low и a - mid.
            ignore_bins a_low_mid = binsof(a_i_cp.low) || binsof(a_i_cp.mid);
            // А что исключает этот?
            ignore_bins a_mid_b_low = binsof(a_i_cp.high) && binsof(b_s_cp.max);
        }

        // Этот cross создает пересечение всех bins из a_i_cp и b_s_cp.
        cross_3: cross a_s_cp, b_s_cp {
            // Такой фильтр означает, что в пересечении участвуют только bins, которые привязаны к 1.
            bins ones     = binsof(a_s_cp.one) && binsof(b_s_cp.one);
            // А такой фильтр выбирает два варианта: a - 0 и b - max, a - max и b - 0
            // Для удобства восприятия разбит на 2 строки
            bins zero_max = binsof(a_s_cp.zero) && binsof(b_s_cp.max ) ||
                            binsof(a_s_cp.max ) && binsof(b_s_cp.zero);
            // А что выбирает такой фильтр?
            bins two_max  = binsof(a_s_cp.max ) && binsof(b_s_cp.max);
            // А что исключает этот?
            ignore_bins max_one = binsof(a_s_cp.max ) && binsof(b_s_cp.one);
        }

        // Да, тройное перекрестное покрытие тоже возможно.
        // Этот cross создает пересечение всех bins из a_in_cp, a_s_cp и b_s_cp.
        // Попробуйте разобраться (GUI в помощь).
        cross_4: cross a_in_cp, a_s_cp, b_s_cp {
            ignore_bins a_magics_zero = binsof(a_s_cp.magics) || binsof(a_s_cp.zero);
            ignore_bins a_mid         = binsof(a_in_cp.mid);
            ignore_bins b_one         = binsof(b_s_cp.one);
            ignore_bins a_high_one    = binsof(a_in_cp.high) && binsof(a_s_cp.one);
            ignore_bins a_low_max     = binsof(a_in_cp.low) && binsof(a_s_cp.max);
        }
    endgroup

    sum_cg cg = new();

endmodule
