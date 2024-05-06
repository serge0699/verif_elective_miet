`timescale 1ns/1ps

module testbench;

    localparam BIN_LENGTH = 6;
    localparam ONEHOT_LENGTH = (2**BIN_LENGTH);

    // 5-битный входной сигнал
    logic [BIN_LENGTH-1:0] bin;
    // 6'b111111 = 63
    // TODO:
    // Определите разрядность выходного
    // one-hot сигнала
    logic [ONEHOT_LENGTH-1:0] onehot;

    // Тестируемый модуль: one-hot кодировщик
    // Соответствие выхода входу:
    // bin =  0 | onehot = 0...001
    // bin =  1 | onehot = 0...010
    // bin =  2 | onehot = 0...100
    // ...
    // bin = 63 | onehot = 1...000
    bin_to_onehot DUT (
        .bin    ( bin    ),
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
    logic [ONEHOT_LENGTH-1:0] ref_onehot;
    int err_cnt;
    logic is_error;

    assign is_error = |(onehot ^ ref_onehot);

    initial begin
        #1;
        for(int i = 0; i < 2**BIN_LENGTH; i++) begin
            bin = i;
            ref_onehot = 'b1 << i;
            #1;
            if(onehot !== ref_onehot) begin
                err_cnt++;
                $display("(%0t) Onehot miscompare! res: 0x%0h, exp: 0x%0h;", $time(), onehot, ref_onehot);
            end
        end
        if(!err_cnt)
            $display("SUCCESS!");
        else
            $display("FAILURE! Total number of errors: %0d", err_cnt);
        $stop();
    end
    //------------------------------------------------------------

endmodule
