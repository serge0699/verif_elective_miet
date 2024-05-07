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
    //     logic _r;
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
    logic [2:0] abc;
     initial begin
            logic _r;
            while(1) begin
                @(ev);
        //r values were taken from the table
            assign abc={a,b,c};
            if(
            (~a & ~b & ~c & ~r)
            ||(~a & ~b & c & r)
            ||(~a & b & ~c & r)
            ||(~a & b & c & ~r)
            ||(a & ~b & ~c & r)
            ||(a & ~b & c & r)
            ||(a & b & ~c & ~r)
            ||(a & b & c & ~r)) begin
                case(abc)
                    3'b000: $display("000: a:%1b, b: %1b, c: %1b, r: %1b", a, b, c, r);
                    3'b001: $display("001: a:%1b, b: %1b, c: %1b, r: %1b", a, b, c, r);
                    3'b010: $display("010: a:%1b, b: %1b, c: %1b, r: %1b", a, b, c, r);
                    3'b011: $display("011: a:%1b, b: %1b, c: %1b, r: %1b", a, b, c, r);
                    3'b100: $display("100: a:%1b, b: %1b, c: %1b, r: %1b", a, b, c, r);
                    3'b101: $display("101: a:%1b, b: %1b, c: %1b, r: %1b", a, b, c, r);
                    3'b110: $display("110: a:%1b, b: %1b, c: %1b, r: %1b", a, b, c, r);
                    3'b111: $display("111: a:%1b, b: %1b, c: %1b, r: %1b", a, b, c, r);
                endcase
            end
                else begin
                    $display("Error: a:%1b, b: %1b, c: %1b, r: %1b", a, b, c, r);
                end
            end
        end
    //------------------------------------------------------------

endmodule
