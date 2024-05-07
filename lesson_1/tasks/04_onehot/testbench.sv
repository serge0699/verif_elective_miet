`timescale 1ns/1ps

module testbench;

    // 5-битный входной сигнал
    logic [5:0] bin;

    // TODO:
    // Определите разрядность выходного
    // one-hot сигнала
    logic [63:0] onehot;

    // Тестируемый модуль: one-hot кодировщик
    // Соответствие выхода входу:
    // bin =  0 | onehot = 0...001
    // bin =  1 | onehot = 0...010
    // bin =  2 | onehot = 0...100
    // ...
    // bin = 63 | onehot = 1...000
    bin_to_onehot DUT (
        .bin  ( bin  ),
        .onehot ( onehot )
    );

    `include "checker.svh"

    // TODO:
    // Сгенерируйте все возможные входные воздействия и проверки.
    // Как думаете, есть ли способ компактнее, чем copy-paste?
    //
    // В конце симуляции будет выведена статистика о том, какая
    // часть из требуемых значений была подана. Для оценки того,
    // значения из какого интервала не были поданы, воспользуйтесь
    // отчетом 04_onehot/stats/covsummary.html (отчет сформируется
    // после завершения симуляции).

    // Пишите внутри этого блока. Можно использовать подход из
    // нескольких initial, можно из одного. 
    //------------------------------------------------------------
    localparam MAX_BIT = 64 ;
    event ev;
    initial begin
        for (int i = 0; i<MAX_BIT; i++) begin
        #9
        bin = i;
        #1; ->> ev;
        end
    end
    initial begin
        while(1) begin
            @ev;
            if( onehot[bin] === 1'b1 ) begin
                automatic int left = bin + 1;
                automatic int right      = 0;
                automatic int left_ones  = 0;
                automatic int right_ones = 0;
                for (int i = left; i < MAX_BIT; i++) begin
                    if (onehot[i] === 1'b1) begin
                        left_ones = 1;
                        $error("BAD");
                        break;
                    end
                end
                for (int i = right; i < bin; i++) begin
                    if (onehot[i] === 1'b1) begin
                        right_ones = 1;
                        $error("BAD");
                        break;
                    end
                end
                if(left_ones === 0 && right_ones === 0) begin
                    $display("GOOD bin = %d , onehot[%d] = 1 ", bin,bin);
                end
                
            end 
            else $error("BAD");
            if(bin == 63) -> gen_done;
        end
    end
    //------------------------------------------------------------
    
endmodule
