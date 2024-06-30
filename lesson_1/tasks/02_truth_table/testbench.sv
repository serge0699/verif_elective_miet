`timescale 1ns/100ps

module testbench;

    logic a, b, c, r;

    truth_table DUT(
        .a ( a ),
        .b ( b ),
        .c ( c ),
        .r ( r )
    );

    `include "generator.svh"

    // TODO:
    // Референсная таблица истинности модуля 'truth_table':
    //
    // a b c   r
    // 0 0 0 | 0
    // 0 0 1 | 1
    // 0 1 0 | 1
    // 0 1 1 | 0
    // 1 0 0 | 1
    // 1 0 1 | 1
    // 1 1 0 | 0
    // 1 1 1 | 0
    //
    // Реализуйте проверку и выясните, при каких значениях
    // значения в референсной таблице не совпадают с реальными.
    //
    // Проверку можно осуществлять каждый раз, когда запускается
    // event с именем 'ev'. Отслеживайте этот момент при помощи @.
    //
    // Прототип проверки:
    //
    // initial begin
    //     logic exp_res;
    //     while(1) begin
    //         <ожидание event ev>;
    //         <вычисления>
    //         if( <некоторое условие> ) begin
    //             <вывод данных>;
    //         end
    //     end
    // end
    //
    // Вывод одного из значений можно реализовать, например, так:
    //
    // $display("a: %1b", a); // где 'a' - некая переменная
    //
    // Для двух значений:
    //
    // $display("a: %1b, b: %1b", b); // где 'a', 'b' - некие переменные


    // Пишите внутри этого блока
    //------------------------------------------------------------
    logic exp_res;
    logic is_err;

    assign is_err = r ^ exp_res;

    initial begin
        int err_cnt;
        while(1) begin
            @ ev;
            exp_res = ref_func(a, b, c);
            if(r !== exp_res) begin
                err_cnt++;
                $display("------------------------------------------------------");
                $display("(%0t) Miscompare! (a,b,c)=(%0b,%0b,%0b); res: %0b, exp: %0b;", $time(), a, b, c, r, exp_res);
            end
        end
    end

    function logic ref_func(logic a, b, c);
        ref_func = ((~a & ~b & c) | (~a & b & ~c) | (a & ~b & ~c) | (a & ~b & c));
    endfunction : ref_func
    //------------------------------------------------------------

endmodule
